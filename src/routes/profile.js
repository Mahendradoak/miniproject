const express = require('express');
const router = express.Router();
const JobSeeker = require('../models/JobSeeker');
const { protect, authorize } = require('../middleware/auth');

// @route   POST /api/profile/job-seeker
// @desc    Create a new profile version (up to 5 max)
// @access  Private (Job Seekers only)
router.post('/job-seeker', protect, authorize('job_seeker'), async (req, res) => {
  try {
    const { name, description, skills, experience, education, desiredJobTypes, 
            desiredSalary, preferredLocations, remotePreference } = req.body;

    let jobSeeker = await JobSeeker.findOne({ userId: req.user.id });

    if (!jobSeeker) {
      // Create new job seeker with first profile
      jobSeeker = await JobSeeker.create({
        userId: req.user.id,
        profiles: [{
          name: name || 'Default Profile',
          description,
          skills,
          experience,
          education,
          desiredJobTypes,
          desiredSalary,
          preferredLocations,
          remotePreference,
          isActive: true
        }]
      });
    } else {
      // Check if max profiles reached
      if (jobSeeker.profiles.length >= 5) {
        return res.status(400).json({
          success: false,
          error: 'Maximum 5 profile versions allowed. Delete one to create a new profile.'
        });
      }

      // Add new profile version
      jobSeeker.profiles.push({
        name: name || `Profile ${jobSeeker.profiles.length + 1}`,
        description,
        skills,
        experience,
        education,
        desiredJobTypes,
        desiredSalary,
        preferredLocations,
        remotePreference,
        isActive: false // New profiles are inactive by default
      });

      await jobSeeker.save();
    }

    res.json({
      success: true,
      jobSeeker
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: error.message
    });
  }
});

// @route   GET /api/profile/job-seeker
// @desc    Get all profile versions for job seeker
// @access  Private
router.get('/job-seeker', protect, async (req, res) => {
  try {
    const jobSeeker = await JobSeeker.findOne({ userId: req.user.id })
      .populate('userId', 'email profile');

    if (!jobSeeker) {
      return res.status(404).json({
        success: false,
        error: 'No profiles found. Create your first profile.'
      });
    }

    res.json({
      success: true,
      jobSeeker,
      activeProfile: jobSeeker.getActiveProfile()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// @route   GET /api/profile/job-seeker/active
// @desc    Get only the active profile
// @access  Private
router.get('/job-seeker/active', protect, async (req, res) => {
  try {
    const jobSeeker = await JobSeeker.findOne({ userId: req.user.id });

    if (!jobSeeker) {
      return res.status(404).json({
        success: false,
        error: 'Profile not found'
      });
    }

    const activeProfile = jobSeeker.getActiveProfile();

    res.json({
      success: true,
      profile: activeProfile
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// @route   PUT /api/profile/job-seeker/:profileId
// @desc    Update a specific profile version
// @access  Private (Job Seekers only)
router.put('/job-seeker/:profileId', protect, authorize('job_seeker'), async (req, res) => {
  try {
    const jobSeeker = await JobSeeker.findOne({ userId: req.user.id });

    if (!jobSeeker) {
      return res.status(404).json({
        success: false,
        error: 'Job seeker not found'
      });
    }

    const profile = jobSeeker.profiles.id(req.params.profileId);

    if (!profile) {
      return res.status(404).json({
        success: false,
        error: 'Profile version not found'
      });
    }

    // Update profile fields
    Object.assign(profile, req.body);
    profile.updatedAt = Date.now();

    await jobSeeker.save();

    res.json({
      success: true,
      profile
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: error.message
    });
  }
});

// @route   POST /api/profile/job-seeker/:profileId/activate
// @desc    Set a profile version as active
// @access  Private (Job Seekers only)
router.post('/job-seeker/:profileId/activate', protect, authorize('job_seeker'), async (req, res) => {
  try {
    const jobSeeker = await JobSeeker.findOne({ userId: req.user.id });

    if (!jobSeeker) {
      return res.status(404).json({
        success: false,
        error: 'Job seeker not found'
      });
    }

    const profile = jobSeeker.profiles.id(req.params.profileId);

    if (!profile) {
      return res.status(404).json({
        success: false,
        error: 'Profile version not found'
      });
    }

    // Deactivate all profiles and activate the selected one
    jobSeeker.setActiveProfile(req.params.profileId);
    await jobSeeker.save();

    res.json({
      success: true,
      message: 'Profile activated successfully',
      activeProfile: profile
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: error.message
    });
  }
});

// @route   DELETE /api/profile/job-seeker/:profileId
// @desc    Delete a profile version
// @access  Private (Job Seekers only)
router.delete('/job-seeker/:profileId', protect, authorize('job_seeker'), async (req, res) => {
  try {
    const jobSeeker = await JobSeeker.findOne({ userId: req.user.id });

    if (!jobSeeker) {
      return res.status(404).json({
        success: false,
        error: 'Job seeker not found'
      });
    }

    if (jobSeeker.profiles.length === 1) {
      return res.status(400).json({
        success: false,
        error: 'Cannot delete your only profile. You must have at least one profile.'
      });
    }

    const profile = jobSeeker.profiles.id(req.params.profileId);

    if (!profile) {
      return res.status(404).json({
        success: false,
        error: 'Profile version not found'
      });
    }

    const wasActive = profile.isActive;
    
    // Remove the profile using pull
    jobSeeker.profiles.pull(req.params.profileId);

    // If we deleted the active profile, make the first remaining profile active
    if (wasActive && jobSeeker.profiles.length > 0) {
      jobSeeker.profiles[0].isActive = true;
    }

    await jobSeeker.save();

    res.json({
      success: true,
      message: 'Profile deleted successfully'
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: error.message
    });
  }
});

// @route   POST /api/profile/job-seeker/:profileId/duplicate
// @desc    Duplicate a profile version to create a new one
// @access  Private (Job Seekers only)
router.post('/job-seeker/:profileId/duplicate', protect, authorize('job_seeker'), async (req, res) => {
  try {
    const jobSeeker = await JobSeeker.findOne({ userId: req.user.id });

    if (!jobSeeker) {
      return res.status(404).json({
        success: false,
        error: 'Job seeker not found'
      });
    }

    if (jobSeeker.profiles.length >= 5) {
      return res.status(400).json({
        success: false,
        error: 'Maximum 5 profiles allowed'
      });
    }

    const sourceProfile = jobSeeker.profiles.id(req.params.profileId);

    if (!sourceProfile) {
      return res.status(404).json({
        success: false,
        error: 'Source profile not found'
      });
    }

    // Create a copy
    const newProfile = {
      name: `${sourceProfile.name} (Copy)`,
      description: sourceProfile.description,
      skills: [...sourceProfile.skills],
      experience: sourceProfile.experience.map(exp => ({...exp.toObject()})),
      education: sourceProfile.education.map(edu => ({...edu.toObject()})),
      resume: sourceProfile.resume,
      desiredJobTypes: [...sourceProfile.desiredJobTypes],
      desiredSalary: {...sourceProfile.desiredSalary},
      preferredLocations: [...sourceProfile.preferredLocations],
      remotePreference: sourceProfile.remotePreference,
      isActive: false
    };

    jobSeeker.profiles.push(newProfile);
    await jobSeeker.save();

    res.json({
      success: true,
      message: 'Profile duplicated successfully',
      newProfile: jobSeeker.profiles[jobSeeker.profiles.length - 1]
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: error.message
    });
  }
});

// @route   GET /api/profile/job-seeker/:id
// @desc    Get specific job seeker active profile (for employers)
// @access  Private (Employers only)
router.get('/job-seeker/:id', protect, authorize('employer'), async (req, res) => {
  try {
    const jobSeeker = await JobSeeker.findOne({ userId: req.params.id })
      .populate('userId', 'email profile');

    if (!jobSeeker) {
      return res.status(404).json({
        success: false,
        error: 'Profile not found'
      });
    }

    // Employers only see the active profile
    const activeProfile = jobSeeker.getActiveProfile();

    res.json({
      success: true,
      profile: activeProfile,
      user: jobSeeker.userId
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

module.exports = router;
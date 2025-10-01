const express = require('express');
const router = express.Router();
const Application = require('../models/Application');
const Job = require('../models/Job');
const JobSeeker = require('../models/JobSeeker');
const JobMatchingService = require('../services/matchingService');
const { protect, authorize } = require('../middleware/auth');

router.post('/', protect, authorize('job_seeker'), async (req, res) => {
  try {
    const { jobId, coverLetter } = req.body;

    if (!jobId) {
      return res.status(400).json({
        success: false,
        error: 'Job ID is required'
      });
    }

    const job = await Job.findById(jobId);
    if (!job) {
      return res.status(404).json({
        success: false,
        error: 'Job not found'
      });
    }

    if (job.status !== 'active') {
      return res.status(400).json({
        success: false,
        error: 'This job is no longer accepting applications'
      });
    }

    const existingApplication = await Application.findOne({
      jobId,
      jobSeekerId: req.user.id
    });

    if (existingApplication) {
      return res.status(400).json({
        success: false,
        error: 'You have already applied to this job'
      });
    }

    const jobSeeker = await JobSeeker.findOne({ userId: req.user.id });
    if (!jobSeeker) {
      return res.status(400).json({
        success: false,
        error: 'Please complete your profile before applying'
      });
    }

    const matchScore = JobMatchingService.calculateMatchScore(jobSeeker, job);

    const application = await Application.create({
      jobId,
      jobSeekerId: req.user.id,
      coverLetter,
      matchScore
    });

    await Job.findByIdAndUpdate(jobId, { applicantCount: job.applicantCount + 1 });

    const populatedApplication = await Application.findById(application._id)
      .populate('jobId', 'title company location jobType')
      .populate('jobSeekerId', 'email profile');

    res.status(201).json({
      success: true,
      application: populatedApplication
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: error.message
    });
  }
});

router.get('/', protect, async (req, res) => {
  try {
    let applications;
    
    if (req.user.userType === 'job_seeker') {
      applications = await Application.find({ jobSeekerId: req.user.id })
        .populate('jobId', 'title company location jobType salary')
        .populate('jobSeekerId', 'email profile')
        .sort({ appliedAt: -1 });
    } else if (req.user.userType === 'employer') {
      const employerJobs = await Job.find({ employerId: req.user.id });
      const jobIds = employerJobs.map(job => job._id);
      applications = await Application.find().where('jobId').in(jobIds)
        .populate('jobId', 'title company location jobType salary')
        .populate('jobSeekerId', 'email profile')
        .sort({ appliedAt: -1 });
    }

    res.json({
      success: true,
      count: applications.length,
      applications
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

router.get('/:id', protect, async (req, res) => {
  try {
    const application = await Application.findById(req.params.id)
      .populate('jobId')
      .populate('jobSeekerId', 'email profile');

    if (!application) {
      return res.status(404).json({
        success: false,
        error: 'Application not found'
      });
    }

    if (req.user.userType === 'job_seeker' && 
        application.jobSeekerId._id.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to view this application'
      });
    }

    if (req.user.userType === 'employer' && 
        application.jobId.employerId.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to view this application'
      });
    }

    res.json({
      success: true,
      application
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

router.patch('/:id/status', protect, authorize('employer'), async (req, res) => {
  try {
    const { status } = req.body;

    if (!['pending', 'reviewed', 'shortlisted', 'rejected', 'accepted'].includes(status)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid status'
      });
    }

    const application = await Application.findById(req.params.id)
      .populate('jobId');

    if (!application) {
      return res.status(404).json({
        success: false,
        error: 'Application not found'
      });
    }

    if (application.jobId.employerId.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to update this application'
      });
    }

    application.status = status;
    await application.save();

    res.json({
      success: true,
      application
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: error.message
    });
  }
});

module.exports = router;

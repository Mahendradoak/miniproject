const express = require('express');
const router = express.Router();
const Job = require('../models/Job');
const JobMatchingService = require('../services/matchingService');
const { protect, authorize } = require('../middleware/auth');

router.post('/', protect, authorize('employer'), async (req, res) => {
  try {
    const job = await Job.create({
      ...req.body,
      employerId: req.user.id
    });

    res.status(201).json({
      success: true,
      job
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: error.message
    });
  }
});

router.get('/', async (req, res) => {
  try {
    const { location, jobType, skills, remote, search } = req.query;
    let query = { status: 'active' };

    if (location) {
      query[''] = [
        { 'location.city': new RegExp(location, 'i') },
        { 'location.state': new RegExp(location, 'i') },
        { 'location.country': new RegExp(location, 'i') }
      ];
    }

    if (jobType) query.jobType = jobType;
    if (remote) query.remoteType = remote;
    
    if (skills) {
      const skillArray = skills.split(',').map(s => s.trim());
      query['requirements.skills'] = { '': skillArray.map(s => new RegExp(s, 'i')) };
    }

    if (search) {
      query[''] = [
        { title: new RegExp(search, 'i') },
        { company: new RegExp(search, 'i') },
        { description: new RegExp(search, 'i') }
      ];
    }

    const jobs = await Job.find(query)
      .populate('employerId', 'profile.company profile.firstName profile.lastName')
      .sort({ postedAt: -1 })
      .limit(100);

    res.json({
      success: true,
      count: jobs.length,
      jobs
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

router.get('/matches', protect, authorize('job_seeker'), async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 20;
    const matches = await JobMatchingService.findMatchingJobs(req.user.id, limit);

    res.json({
      success: true,
      count: matches.length,
      matches
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const job = await Job.findById(req.params.id)
      .populate('employerId', 'profile.company profile.firstName profile.lastName email');

    if (!job) {
      return res.status(404).json({
        success: false,
        error: 'Job not found'
      });
    }

    res.json({
      success: true,
      job
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

router.get('/:jobId/candidates', protect, authorize('employer'), async (req, res) => {
  try {
    const job = await Job.findById(req.params.jobId);
    
    if (!job) {
      return res.status(404).json({
        success: false,
        error: 'Job not found'
      });
    }

    if (job.employerId.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to view candidates for this job'
      });
    }

    const limit = parseInt(req.query.limit) || 50;
    const candidates = await JobMatchingService.findMatchingCandidates(req.params.jobId, limit);

    res.json({
      success: true,
      count: candidates.length,
      candidates
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

router.put('/:id', protect, authorize('employer'), async (req, res) => {
  try {
    let job = await Job.findById(req.params.id);

    if (!job) {
      return res.status(404).json({
        success: false,
        error: 'Job not found'
      });
    }

    if (job.employerId.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to update this job'
      });
    }

    job = await Job.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    });

    res.json({
      success: true,
      job
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: error.message
    });
  }
});

router.delete('/:id', protect, authorize('employer'), async (req, res) => {
  try {
    const job = await Job.findById(req.params.id);

    if (!job) {
      return res.status(404).json({
        success: false,
        error: 'Job not found'
      });
    }

    if (job.employerId.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to delete this job'
      });
    }

    await job.deleteOne();

    res.json({
      success: true,
      message: 'Job deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

module.exports = router;

const express = require('express');
const router = express.Router();
const Job = require('../models/Job');
const JobMatchingService = require('../services/matchingService');
const { protect, authorize } = require('../middleware/auth');

// @route   POST /api/jobs
// @desc    Create a new job posting
// @access  Private (Employers only)
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

// @route   GET /api/jobs
// @desc    Get all active jobs with optional filters (OPTIMIZED)
// @access  Public
router.get('/', async (req, res) => {
  try {
    const { location, jobType, skills, remote, search, page = 1, limit = 20 } = req.query;
    
    // Pagination
    const pageNum = parseInt(page);
    const limitNum = parseInt(limit);
    const skip = (pageNum - 1) * limitNum;
    
    let query = { status: 'active' };
    let sort = { postedAt: -1 };

    // TEXT SEARCH (uses the index we created!)
    if (search) {
      query[''] = { '': search };
      sort = { score: { '': 'textScore' }, postedAt: -1 };
    }

    // Location filter (exact match now, much faster)
    if (location) {
      const locationLower = location.toLowerCase();
      query[''] = [
        { 'location.city': { '': locationLower, '': 'i' } },
        { 'location.state': { '': locationLower, '': 'i' } }
      ];
    }

    // Job type filter (uses index)
    if (jobType) {
      query.jobType = jobType;
    }
    
    // Remote filter (uses index)
    if (remote) {
      query.remoteType = remote;
    }
    
    // Skills filter (uses index)
    if (skills) {
      const skillArray = skills.split(',').map(s => s.trim());
      query['requirements.skills'] = { '': skillArray };
    }

    // Count total for pagination
    const total = await Job.countDocuments(query);

    // Execute query with pagination
    let jobsQuery = Job.find(query)
      .populate('employerId', 'profile.company profile.firstName profile.lastName')
      .sort(sort)
      .skip(skip)
      .limit(limitNum);

    // If text search, include score
    if (search) {
      jobsQuery = jobsQuery.select({ score: { '': 'textScore' } });
    }

    const jobs = await jobsQuery;

    res.json({
      success: true,
      count: jobs.length,
      total: total,
      page: pageNum,
      pages: Math.ceil(total / limitNum),
      jobs
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// @route   GET /api/jobs/matches
// @desc    Get matching jobs for current job seeker
// @access  Private (Job Seekers only)
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

// @route   GET /api/jobs/:id
// @desc    Get single job by ID
// @access  Public
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

// @route   GET /api/jobs/:jobId/candidates
// @desc    Get matching candidates for a job
// @access  Private (Employers only)
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

// @route   PUT /api/jobs/:id
// @desc    Update job
// @access  Private (Employers only)
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

// @route   DELETE /api/jobs/:id
// @desc    Delete job
// @access  Private (Employers only)
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

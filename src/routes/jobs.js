const express = require('express');
const router = express.Router();
const Job = require('../models/Job');
const EnhancedJobMatchingService = require('../services/enhancedMatchingService');
const { protect, authorize } = require('../middleware/auth');
const { validateJobCreate, validatePagination } = require('../middleware/validation');
const { cacheMiddleware } = require('../utils/cache');

// @route   POST /api/jobs
// @desc    Create a new job posting
// @access  Private (Employers only)
router.post('/', protect, authorize('employer'), validateJobCreate, async (req, res, next) => {
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
    next(error);
  }
});

// @route   GET /api/jobs
// @desc    Get all active jobs with filters (CACHED)
// @access  Public
router.get('/', cacheMiddleware(300), validatePagination, async (req, res, next) => {
  try {
    const { location, jobType, skills, remote, search } = req.query;
    const { page, limit } = req.pagination;
    const skip = (page - 1) * limit;
    
    let query = { status: 'active' };
    let sort = { postedAt: -1 };

    // TEXT SEARCH
    if (search) {
      query['$text'] = { '$search': search };
      sort = { score: { '$meta': 'textScore' }, postedAt: -1 };
    }

    // Location filter
    if (location) {
      const locationLower = location.toLowerCase();
      query['$or'] = [
        { 'location.city': { '$regex': locationLower, '$options': 'i' } },
        { 'location.state': { '$regex': locationLower, '$options': 'i' } }
      ];
    }

    if (jobType) query.jobType = jobType;
    if (remote) query.remoteType = remote;
    
    if (skills) {
      const skillArray = skills.split(',').map(s => s.trim());
      query['requirements.skills'] = { '$in': skillArray };
    }

    // Count total
    const total = await Job.countDocuments(query);

    // Execute query
    let jobsQuery = Job.find(query)
      .populate('employerId', 'profile.company profile.firstName profile.lastName')
      .sort(sort)
      .skip(skip)
      .limit(limit)
      .lean(); // Use lean() for better performance

    if (search) {
      jobsQuery = jobsQuery.select({ score: { '$meta': 'textScore' } });
    }

    const jobs = await jobsQuery;

    res.json({
      success: true,
      count: jobs.length,
      total: total,
      page: page,
      pages: Math.ceil(total / limit),
      jobs
    });
  } catch (error) {
    next(error);
  }
});

// @route   GET /api/jobs/matches
// @desc    Get matching jobs for current job seeker
// @access  Private (Job Seekers only)
router.get('/matches', protect, authorize('job_seeker'), async (req, res, next) => {
  try {
    const limit = parseInt(req.query.limit) || 20;
    const matches = await EnhancedJobMatchingService.findMatchingJobs(req.user.id, limit);

    res.json({
      success: true,
      count: matches.length,
      matches
    });
  } catch (error) {
    next(error);
  }
});

// @route   GET /api/jobs/:id
// @desc    Get single job by ID (CACHED)
// @access  Public
router.get('/:id', cacheMiddleware(600), async (req, res, next) => {
  try {
    const job = await Job.findById(req.params.id)
      .populate('employerId', 'profile.company profile.firstName profile.lastName email')
      .lean();

    if (!job) {
      return res.status(404).json({
        success: false,
        error: 'Job not found',
        timestamp: new Date().toISOString()
      });
    }

    res.json({
      success: true,
      job
    });
  } catch (error) {
    next(error);
  }
});

// @route   GET /api/jobs/:jobId/candidates
// @desc    Get matching candidates for a job
// @access  Private (Employers only)
router.get('/:jobId/candidates', protect, authorize('employer'), async (req, res, next) => {
  try {
    const job = await Job.findById(req.params.jobId).lean();
    
    if (!job) {
      return res.status(404).json({
        success: false,
        error: 'Job not found',
        timestamp: new Date().toISOString()
      });
    }

    if (job.employerId.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to view candidates for this job',
        timestamp: new Date().toISOString()
      });
    }

    const limit = parseInt(req.query.limit) || 50;
    const candidates = await EnhancedJobMatchingService.findMatchingCandidates(req.params.jobId, limit);

    res.json({
      success: true,
      count: candidates.length,
      candidates
    });
  } catch (error) {
    next(error);
  }
});

// @route   PUT /api/jobs/:id
// @desc    Update job
// @access  Private (Employers only)
router.put('/:id', protect, authorize('employer'), async (req, res, next) => {
  try {
    let job = await Job.findById(req.params.id);

    if (!job) {
      return res.status(404).json({
        success: false,
        error: 'Job not found',
        timestamp: new Date().toISOString()
      });
    }

    if (job.employerId.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to update this job',
        timestamp: new Date().toISOString()
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
    next(error);
  }
});

// @route   DELETE /api/jobs/:id
// @desc    Delete job
// @access  Private (Employers only)
router.delete('/:id', protect, authorize('employer'), async (req, res, next) => {
  try {
    const job = await Job.findById(req.params.id);

    if (!job) {
      return res.status(404).json({
        success: false,
        error: 'Job not found',
        timestamp: new Date().toISOString()
      });
    }

    if (job.employerId.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to delete this job',
        timestamp: new Date().toISOString()
      });
    }

    await job.deleteOne();

    res.json({
      success: true,
      message: 'Job deleted successfully'
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;

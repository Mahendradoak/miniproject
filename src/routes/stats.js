const express = require('express');
const router = express.Router();
const { cache } = require('../utils/cache');
const { protect, authorize } = require('../middleware/auth');

// @route   GET /api/stats
// @desc    Get API statistics
// @access  Private (Admin only - for now just protected)
router.get('/', protect, async (req, res) => {
  try {
    const stats = {
      cache: {
        size: cache.size(),
        entries: cache.cache.size
      },
      server: {
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        nodeVersion: process.version
      },
      timestamp: new Date().toISOString()
    };

    res.json({
      success: true,
      stats
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

module.exports = router;

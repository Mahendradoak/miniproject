const { ValidationError } = require('../utils/errors');

// Validate registration input
exports.validateRegister = (req, res, next) => {
  const { email, password, userType } = req.body;
  const errors = [];

  if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    errors.push({ field: 'email', message: 'Valid email is required' });
  }

  if (!password || password.length < 6) {
    errors.push({ field: 'password', message: 'Password must be at least 6 characters' });
  }

  if (!userType || !['job_seeker', 'employer'].includes(userType)) {
    errors.push({ field: 'userType', message: 'User type must be job_seeker or employer' });
  }

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      error: 'Validation Error',
      errors: errors,
      timestamp: new Date().toISOString()
    });
  }

  next();
};

// Validate login input
exports.validateLogin = (req, res, next) => {
  const { email, password } = req.body;
  const errors = [];

  if (!email) {
    errors.push({ field: 'email', message: 'Email is required' });
  }

  if (!password) {
    errors.push({ field: 'password', message: 'Password is required' });
  }

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      error: 'Validation Error',
      errors: errors,
      timestamp: new Date().toISOString()
    });
  }

  next();
};

// Validate job creation
exports.validateJobCreate = (req, res, next) => {
  const { title, company, description, jobType } = req.body;
  const errors = [];

  if (!title || title.trim().length < 3) {
    errors.push({ field: 'title', message: 'Title must be at least 3 characters' });
  }

  if (!company || company.trim().length < 2) {
    errors.push({ field: 'company', message: 'Company name is required' });
  }

  if (!description || description.trim().length < 20) {
    errors.push({ field: 'description', message: 'Description must be at least 20 characters' });
  }

  if (!jobType || !['full-time', 'part-time', 'contract', 'internship'].includes(jobType)) {
    errors.push({ field: 'jobType', message: 'Invalid job type' });
  }

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      error: 'Validation Error',
      errors: errors,
      timestamp: new Date().toISOString()
    });
  }

  next();
};

// Validate pagination params
exports.validatePagination = (req, res, next) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 20;

  if (page < 1) {
    return res.status(400).json({
      success: false,
      error: 'Page must be greater than 0',
      timestamp: new Date().toISOString()
    });
  }

  if (limit < 1 || limit > 100) {
    return res.status(400).json({
      success: false,
      error: 'Limit must be between 1 and 100',
      timestamp: new Date().toISOString()
    });
  }

  req.pagination = { page, limit };
  next();
};

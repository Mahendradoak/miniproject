// Standardized error response format
class ApiError extends Error {
  constructor(message, statusCode = 500, errors = null) {
    super(message);
    this.statusCode = statusCode;
    this.errors = errors;
    this.timestamp = new Date().toISOString();
  }
}

class ValidationError extends ApiError {
  constructor(errors) {
    super('Validation Error', 400, errors);
  }
}

class NotFoundError extends ApiError {
  constructor(resource = 'Resource') {
    super('${resource} not found', 404);
  }
}

class UnauthorizedError extends ApiError {
  constructor(message = 'Not authorized') {
    super(message, 401);
  }
}

class ForbiddenError extends ApiError {
  constructor(message = 'Access forbidden') {
    super(message, 403);
  }
}

// Error response formatter
const formatErrorResponse = (err) => {
  return {
    success: false,
    error: err.message || 'Internal Server Error',
    errors: err.errors || null,
    timestamp: err.timestamp || new Date().toISOString(),
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  };
};

module.exports = {
  ApiError,
  ValidationError,
  NotFoundError,
  UnauthorizedError,
  ForbiddenError,
  formatErrorResponse
};

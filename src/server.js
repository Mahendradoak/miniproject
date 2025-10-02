const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const { formatErrorResponse } = require('./utils/errors');
require('dotenv').config();

const app = express();

// Middleware
app.use(helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    connectSrc: ["'self'", 'http://localhost:5000', 'https://your-api-domain.com'],
    scriptSrc: ["'self'"],
    styleSrc: ["'self'", "'unsafe-inline'"],
    imgSrc: ["'self'", 'data:'],
  }
}));

app.use(cors({
  origin: (origin, callback) => {
    if (process.env.NODE_ENV === 'production') {
      if (origin === 'https://your-flutter-app-domain.com') {
        callback(null, true);
      } else {
        callback(new Error('Not allowed by CORS'));
      }
    } else {
      if (!origin || origin.startsWith('http://localhost')) {
        callback(null, true);
      } else {
        callback(new Error('Not allowed by CORS'));
      }
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rate limiting
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  message: { success: false, error: 'Too many authentication attempts, please try again later.' }
});

const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  message: { success: false, error: 'Too many requests, please try again later.' }
});

app.use('/api/auth', authLimiter);
app.use('/api', apiLimiter);

// Database connection
mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  serverSelectionTimeoutMS: 5000,
  maxPoolSize: 10
})
  .then(() => console.log('✓ MongoDB connected'))
  .catch(err => {
    console.error('✗ MongoDB connection error:', err);
    process.exit(1);
  });

// Request logging (development only)
if (process.env.NODE_ENV !== 'production') {
  app.use((req, res, next) => {
    console.log(new Date().toISOString() + ' [' + req.method + '] ' + req.path);
    next();
  });
}

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    message: 'Server is running',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/jobs', require('./routes/jobs'));
app.use('/api/applications', require('./routes/applications'));
app.use('/api/profile', require('./routes/profile'));
app.use('/api/stats', require('./routes/stats'));

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Endpoint not found',
    path: req.path,
    timestamp: new Date().toISOString()
  });
});

// Global error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  
  // Mongoose validation error
  if (err.name === 'ValidationError') {
    const errors = Object.values(err.errors).map(e => ({
      field: e.path,
      message: e.message
    }));
    return res.status(400).json({
      success: false,
      error: 'Validation Error',
      errors: errors,
      timestamp: new Date().toISOString()
    });
  }
  
  // Mongoose duplicate key error
  if (err.code === 11000) {
    const field = Object.keys(err.keyPattern)[0];
    return res.status(400).json({
      success: false,
      error: 'Duplicate Error',
      message: field + ' already exists',
      timestamp: new Date().toISOString()
    });
  }

  // Mongoose cast error (invalid ObjectId)
  if (err.name === 'CastError') {
    return res.status(400).json({
      success: false,
      error: 'Invalid ID format',
      timestamp: new Date().toISOString()
    });
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({
      success: false,
      error: 'Invalid token',
      timestamp: new Date().toISOString()
    });
  }

  if (err.name === 'TokenExpiredError') {
    return res.status(401).json({
      success: false,
      error: 'Token expired',
      timestamp: new Date().toISOString()
    });
  }

  // Default error response
  const statusCode = err.statusCode || 500;
  res.status(statusCode).json(formatErrorResponse(err));
});

// Handle MongoDB disconnection
mongoose.connection.on('disconnected', () => {
  console.log('✗ MongoDB disconnected. Attempting to reconnect...');
});

mongoose.connection.on('reconnected', () => {
  console.log('✓ MongoDB reconnected');
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log('✓ Server running on port ' + PORT);
  console.log('✓ Environment: ' + (process.env.NODE_ENV || 'development'));
  console.log('✓ Visit: http://localhost:' + PORT + '/health');
});

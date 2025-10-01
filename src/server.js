
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const app = express();

// Middleware
app.use(helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    connectSrc: ["'self'", 'http://localhost:5000', 'https://your-api-domain.com'], // Allow API connections
    scriptSrc: ["'self'"],
    styleSrc: ["'self'", "'unsafe-inline'"],
    imgSrc: ["'self'", 'data:'],
  }
}));
app.use(cors({
  origin: (origin, callback) => {
    if (process.env.NODE_ENV === 'production') {
      // Only allow production URL
      if (origin === 'https://your-flutter-app-domain.com') {
        callback(null, true);
      } else {
        callback(new Error('Not allowed by CORS'));
      }
    } else {
      // Allow any localhost origin in development
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
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 200, // Increase limit for general use
  message: 'Too many requests, please try again later.'
});
app.use('/api/auth', limiter); 
// Apply only to auth routes

// Database connection
mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  serverSelectionTimeoutMS: 5000, // Timeout for initial connection
  maxPoolSize: 10 // Adjust based on your app’s needs
})
  .then(() => console.log('✓ MongoDB connected'))
  .catch(err => {
    console.error('✗ MongoDB connection error:', err);
    process.exit(1); // Exit process on connection failure (optional)
  });

//routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/jobs', require('./routes/jobs'));
app.use('/api/applications', require('./routes/applications'));
app.use('/api/profile', require('./routes/profile'));

// Handle MongoDB disconnection events
mongoose.connection.on('disconnected', () => {
  console.log('✗ MongoDB disconnected. Attempting to reconnect...');
});
// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Server is running' });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  
  if (err.name === 'ValidationError') {
    return res.status(400).json({
      success: false,
      error: 'Validation Error',
      details: Object.values(err.errors).map(e => e.message)
    });
  }
  
  if (err.code === 11000) { // MongoDB duplicate key error
    return res.status(400).json({
      success: false,
      error: 'Duplicate key error',
      details: 'A record with this value already exists'
    });
  }

  res.status(err.status || 500).json({
    success: false,
    error: err.message || 'Internal Server Error'
  });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log('✓ Server running on port ' + PORT);
  console.log('✓ Environment: ' + process.env.NODE_ENV);
  console.log('✓ Visit: http://localhost:' + PORT + '/health');
});

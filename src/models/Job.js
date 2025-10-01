const mongoose = require('mongoose');

const jobSchema = new mongoose.Schema({
  employerId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User', 
    required: true 
  },
  title: { type: String, required: true },
  company: { type: String, required: true },
  description: { type: String, required: true },
  requirements: {
    skills: [String],
    experience: {
      min: Number,
      max: Number
    },
    education: [String]
  },
  jobType: { 
    type: String, 
    enum: ['full-time', 'part-time', 'contract', 'internship'],
    required: true
  },
  salary: {
    min: Number,
    max: Number,
    currency: { type: String, default: 'USD' }
  },
  location: {
    city: String,
    state: String,
    country: String
  },
  remoteType: { 
    type: String, 
    enum: ['remote', 'onsite', 'hybrid'],
    default: 'onsite'
  },
  status: { 
    type: String, 
    enum: ['active', 'closed', 'draft'], 
    default: 'active' 
  },
  postedAt: { type: Date, default: Date.now },
  expiresAt: Date,
  applicantCount: { type: Number, default: 0 }
});

module.exports = mongoose.model('Job', jobSchema);

const mongoose = require('mongoose');

const jobSchema = new mongoose.Schema({
  employerId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User', 
    required: true,
    index: true
  },
  title: { 
    type: String, 
    required: true,
    index: true
  },
  company: { 
    type: String, 
    required: true,
    index: true
  },
  description: { type: String, required: true },
  requirements: {
    skills: {
      type: [String],
      index: true
    },
    experience: {
      min: Number,
      max: Number
    },
    education: [String]
  },
  jobType: { 
    type: String, 
    enum: ['full-time', 'part-time', 'contract', 'internship'],
    required: true,
    index: true
  },
  salary: {
    min: Number,
    max: Number,
    currency: { type: String, default: 'USD' }
  },
  location: {
    city: { type: String, index: true },
    state: { type: String, index: true },
    country: String
  },
  remoteType: { 
    type: String, 
    enum: ['remote', 'onsite', 'hybrid'],
    default: 'onsite',
    index: true
  },
  status: { 
    type: String, 
    enum: ['active', 'closed', 'draft'], 
    default: 'active',
    index: true
  },
  postedAt: { 
    type: Date, 
    default: Date.now,
    index: true
  },
  expiresAt: Date,
  applicantCount: { type: Number, default: 0 }
}, { timestamps: true });

jobSchema.index({ status: 1, postedAt: -1 });
jobSchema.index({ employerId: 1, status: 1 });
jobSchema.index({ 'location.city': 1, 'location.state': 1, status: 1 });
jobSchema.index({ remoteType: 1, status: 1 });
jobSchema.index({ jobType: 1, status: 1 });

jobSchema.index({ 
  title: 'text', 
  description: 'text', 
  company: 'text'
}, { 
  weights: {
    title: 10,
    company: 5,
    description: 1
  }
});

module.exports = mongoose.model('Job', jobSchema);

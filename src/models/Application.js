const mongoose = require('mongoose');

const applicationSchema = new mongoose.Schema({
  jobId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Job', 
    required: true,
    index: true
  },
  jobSeekerId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User', 
    required: true,
    index: true
  },
  status: { 
    type: String, 
    enum: ['pending', 'reviewed', 'shortlisted', 'rejected', 'accepted'],
    default: 'pending',
    index: true
  },
  coverLetter: String,
  matchScore: { 
    type: Number, 
    min: 0, 
    max: 100,
    index: true
  },
  appliedAt: { 
    type: Date, 
    default: Date.now,
    index: true
  }
}, { timestamps: true });

applicationSchema.index({ jobId: 1, jobSeekerId: 1 }, { unique: true });
applicationSchema.index({ jobSeekerId: 1, status: 1, appliedAt: -1 });
applicationSchema.index({ jobId: 1, status: 1, matchScore: -1 });

module.exports = mongoose.model('Application', applicationSchema);

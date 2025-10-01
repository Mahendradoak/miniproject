const mongoose = require('mongoose');

// Profile Version Schema - each user can have up to 5 versions
const profileVersionSchema = new mongoose.Schema({
  name: { 
    type: String, 
    required: true,
    trim: true 
  }, // e.g., "Frontend Developer", "Full Stack Engineer"
  description: String, // Optional description of this profile version
  skills: [String],
  experience: [{
    title: String,
    company: String,
    startDate: Date,
    endDate: Date,
    description: String,
    current: { type: Boolean, default: false }
  }],
  education: [{
    degree: String,
    institution: String,
    field: String,
    graduationYear: Number
  }],
  resume: String,
  desiredJobTypes: [{ 
    type: String, 
    enum: ['full-time', 'part-time', 'contract', 'internship'] 
  }],
  desiredSalary: {
    min: Number,
    max: Number,
    currency: { type: String, default: 'USD' }
  },
  preferredLocations: [String],
  remotePreference: { 
    type: String, 
    enum: ['remote', 'onsite', 'hybrid', 'any'],
    default: 'any'
  },
  isActive: { 
    type: Boolean, 
    default: false 
  }, // Only one profile can be active at a time
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

const jobSeekerSchema = new mongoose.Schema({
  userId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User', 
    required: true,
    unique: true
  },
  profiles: {
    type: [profileVersionSchema],
    validate: {
      validator: function(profiles) {
        return profiles.length <= 5;
      },
      message: 'Maximum 5 profile versions allowed'
    }
  },
  activeProfileId: mongoose.Schema.Types.ObjectId, // ID of currently active profile
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

// Ensure only one profile is marked as active
jobSeekerSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  
  // Count active profiles
  const activeProfiles = this.profiles.filter(p => p.isActive);
  
  // If multiple profiles are active, keep only the first one
  if (activeProfiles.length > 1) {
    this.profiles.forEach((profile, index) => {
      if (index > 0 && profile.isActive) {
        profile.isActive = false;
      }
    });
  }
  
  // If no active profile but profiles exist, make first one active
  if (activeProfiles.length === 0 && this.profiles.length > 0) {
    this.profiles[0].isActive = true;
  }
  
  // Set activeProfileId
  const activeProfile = this.profiles.find(p => p.isActive);
  if (activeProfile) {
    this.activeProfileId = activeProfile._id;
  }
  
  next();
});

// Method to get active profile
jobSeekerSchema.methods.getActiveProfile = function() {
  return this.profiles.find(p => p.isActive) || this.profiles[0];
};

// Method to switch active profile
jobSeekerSchema.methods.setActiveProfile = function(profileId) {
  this.profiles.forEach(profile => {
    profile.isActive = profile._id.toString() === profileId.toString();
  });
  this.activeProfileId = profileId;
};

module.exports = mongoose.model('JobSeeker', jobSeekerSchema);
const mongoose = require('mongoose');

const profileVersionSchema = new mongoose.Schema({
  name: { 
    type: String, 
    required: true,
    trim: true 
  },
  description: String,
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
  }
}, { timestamps: true });

const jobSeekerSchema = new mongoose.Schema({
  userId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User', 
    required: true,
    unique: true,
    index: true
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
  activeProfileId: mongoose.Schema.Types.ObjectId
}, { timestamps: true });

jobSeekerSchema.index({ userId: 1, 'profiles.isActive': 1 });

jobSeekerSchema.pre('save', function(next) {
  const activeProfiles = this.profiles.filter(p => p.isActive);
  
  if (activeProfiles.length > 1) {
    this.profiles.forEach((profile, index) => {
      if (index > 0 && profile.isActive) {
        profile.isActive = false;
      }
    });
  }
  
  if (activeProfiles.length === 0 && this.profiles.length > 0) {
    this.profiles[0].isActive = true;
  }
  
  const activeProfile = this.profiles.find(p => p.isActive);
  if (activeProfile) {
    this.activeProfileId = activeProfile._id;
  }
  
  next();
});

jobSeekerSchema.methods.getActiveProfile = function() {
  return this.profiles.find(p => p.isActive) || this.profiles[0];
};

jobSeekerSchema.methods.setActiveProfile = function(profileId) {
  this.profiles.forEach(profile => {
    profile.isActive = profile._id.toString() === profileId.toString();
  });
  this.activeProfileId = profileId;
};

module.exports = mongoose.model('JobSeeker', jobSeekerSchema);

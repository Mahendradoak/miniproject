const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  email: { 
    type: String, 
    required: [true, 'Email is required'],
    unique: true,
    lowercase: true,
    trim: true,
    index: true
  },
  password: { 
    type: String, 
    required: [true, 'Password is required'],
    minlength: 6,
    select: false
  },
  userType: { 
    type: String, 
    enum: ['job_seeker', 'employer'], 
    required: true,
    index: true
  },
  profile: {
    firstName: String,
    lastName: String,
    company: String,
    phone: String,
    location: {
      city: String,
      state: String,
      country: String
    }
  },
  isActive: { type: Boolean, default: true },
  lastLoginAt: Date
}, { timestamps: true });

userSchema.index({ userType: 1, isActive: 1 });

userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

userSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('User', userSchema);

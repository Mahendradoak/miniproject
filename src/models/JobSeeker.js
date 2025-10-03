const mongoose = require('mongoose');

const ExperienceSchema = new mongoose.Schema({
  title: String,
  company: String,
  startDate: Date,
  endDate: Date,
  description: String
});

const EducationSchema = new mongoose.Schema({
  degree: String,
  institution: String,
  graduationDate: Date,
  field: String
});

const CertificationSchema = new mongoose.Schema({
  title: String,
  institution: String,
  issueDate: Date,
  expiryDate: Date
});

const ProjectSchema = new mongoose.Schema({
  name: String,
  description: String,
  link: String
});

const SocialLinkSchema = new mongoose.Schema({
  type: String,   // 'LinkedIn', 'GitHub', etc.
  url: String
});

const ProfileSchema = new mongoose.Schema({
  name: { type: String, default: 'Default Profile' },
  description: String,
  skills: [String],
  experience: [ExperienceSchema],
  education: [EducationSchema],
  certifications: [CertificationSchema],
  projects: [ProjectSchema],
  portfolioLinks: [String],
  socialLinks: [SocialLinkSchema],
  languages: [String],
  interests: [String],
  desiredJobTypes: [String],
  desiredSalary: {
    min: Number,
    max: Number
  },
  preferredLocations: [String],
  remotePreference: { type: String, enum: ['onsite', 'remote', 'hybrid', 'any'] },
  profileImage: String, // URL or path
  isActive: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
  updatedAt: Date
});

ProfileSchema.methods.getCompletion = function() {
  let fieldsTotal = 13; // count the relevant fields for completion
  let filled = 0;
  if (this.name) filled++;
  if (this.description) filled++;
  if (this.skills && this.skills.length) filled++;
  if (this.experience && this.experience.length) filled++;
  if (this.education && this.education.length) filled++;
  if (this.certifications && this.certifications.length) filled++;
  if (this.projects && this.projects.length) filled++;
  if (this.portfolioLinks && this.portfolioLinks.length) filled++;
  if (this.socialLinks && this.socialLinks.length) filled++;
  if (this.languages && this.languages.length) filled++;
  if (this.interests && this.interests.length) filled++;
  if (this.desiredJobTypes && this.desiredJobTypes.length) filled++;
  if (this.desiredSalary && (this.desiredSalary.min || this.desiredSalary.max)) filled++;
  // add more as needed
  return Math.round((filled / fieldsTotal) * 100);
};

const JobSeekerSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
  profiles: [ProfileSchema]
});

JobSeekerSchema.methods.getActiveProfile = function() {
  return this.profiles.find(p => p.isActive) || null;
};

module.exports = mongoose.model('JobSeeker', JobSeekerSchema);

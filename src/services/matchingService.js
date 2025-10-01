const JobSeeker = require('../models/JobSeeker');
const Job = require('../models/Job');

class JobMatchingService {
  
  static calculateMatchScore(jobSeeker, job) {
    let score = 0;
    let maxScore = 0;

    const skillWeight = 40;
    maxScore += skillWeight;
    if (job.requirements.skills && jobSeeker.skills && job.requirements.skills.length > 0) {
      const matchedSkills = job.requirements.skills.filter(skill => 
        jobSeeker.skills.some(js => js.toLowerCase().includes(skill.toLowerCase()) || 
                                     skill.toLowerCase().includes(js.toLowerCase()))
      );
      score += (matchedSkills.length / job.requirements.skills.length) * skillWeight;
    } else if (job.requirements.skills && job.requirements.skills.length > 0) {
      score += 0;
    } else {
      score += skillWeight * 0.5;
    }

    const expWeight = 25;
    maxScore += expWeight;
    const totalExp = this.calculateTotalExperience(jobSeeker.experience);
    if (job.requirements.experience && job.requirements.experience.min) {
      if (totalExp >= job.requirements.experience.min && 
          totalExp <= (job.requirements.experience.max || Infinity)) {
        score += expWeight;
      } else if (totalExp >= job.requirements.experience.min * 0.7) {
        score += expWeight * 0.7;
      } else if (totalExp >= job.requirements.experience.min * 0.5) {
        score += expWeight * 0.4;
      }
    } else {
      score += expWeight * 0.5;
    }

    const locWeight = 20;
    maxScore += locWeight;
    if (this.isLocationMatch(jobSeeker, job)) {
      score += locWeight;
    }

    const typeWeight = 15;
    maxScore += typeWeight;
    if (jobSeeker.desiredJobTypes && 
        jobSeeker.desiredJobTypes.includes(job.jobType)) {
      score += typeWeight;
    }

    return Math.round((score / maxScore) * 100);
  }

  static calculateTotalExperience(experiences) {
    if (!experiences || experiences.length === 0) return 0;
    let totalMonths = 0;
    experiences.forEach(exp => {
      const end = exp.endDate || new Date();
      const start = exp.startDate || new Date();
      const months = (end - start) / (1000 * 60 * 60 * 24 * 30);
      totalMonths += Math.max(0, months);
    });
    return totalMonths / 12;
  }

  static isLocationMatch(jobSeeker, job) {
    if (job.remoteType === 'remote' || 
        jobSeeker.remotePreference === 'remote' || 
        jobSeeker.remotePreference === 'any') {
      return true;
    }

    if (jobSeeker.preferredLocations && job.location) {
      return jobSeeker.preferredLocations.some(loc => 
        loc.toLowerCase().includes(job.location.city?.toLowerCase() || '') ||
        loc.toLowerCase().includes(job.location.state?.toLowerCase() || '') ||
        (job.location.city?.toLowerCase() || '').includes(loc.toLowerCase()) ||
        (job.location.state?.toLowerCase() || '').includes(loc.toLowerCase())
      );
    }

    return false;
  }

  static async findMatchingJobs(jobSeekerId, limit = 20) {
  const jobSeekerDoc = await JobSeeker.findOne({ userId: jobSeekerId });
  
  if (!jobSeekerDoc) {
    throw new Error('Job seeker profile not found. Please create your profile first.');
  }

  // Use the active profile for matching
  const jobSeeker = jobSeekerDoc.getActiveProfile();
  
  if (!jobSeeker) {
    throw new Error('No active profile found.');
  }

  const activeJobs = await Job.find({ status: 'active' })
    .populate('employerId', 'profile.company profile.firstName profile.lastName');

  const jobsWithScores = activeJobs.map(job => ({
    job,
    matchScore: this.calculateMatchScore(jobSeeker, job)
  }));

  return jobsWithScores
    .sort((a, b) => b.matchScore - a.matchScore)
    .slice(0, limit);
}
  static async findMatchingCandidates(jobId, limit = 50) {
    const job = await Job.findById(jobId);
    if (!job) {
      throw new Error('Job not found');
    }

    const jobSeekers = await JobSeeker.find().populate('userId', 'profile email');

    const candidatesWithScores = jobSeekers.map(seeker => ({
      candidate: seeker,
      matchScore: this.calculateMatchScore(seeker, job)
    }));

    return candidatesWithScores
      .filter(c => c.matchScore >= 50)
      .sort((a, b) => b.matchScore - a.matchScore)
      .slice(0, limit);
  }
}

module.exports = JobMatchingService;

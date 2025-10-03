const JobSeeker = require('../models/JobSeeker');
const Job = require('../models/Job');

class EnhancedJobMatchingService {
  
  /**
   * Calculate detailed match score with breakdown
   * @param {Object} jobSeeker - Job seeker profile
   * @param {Object} job - Job posting
   * @returns {Object} - Match score and detailed breakdown
   */
  static calculateDetailedMatchScore(jobSeeker, job) {
    const breakdown = {
      skills: { score: 0, max: 40, matched: [], missing: [] },
      experience: { score: 0, max: 25, details: '' },
      location: { score: 0, max: 15, details: '' },
      jobType: { score: 0, max: 10, details: '' },
      salary: { score: 0, max: 5, details: '' },
      education: { score: 0, max: 5, details: '' },
    };

    // 1. SKILLS MATCHING (40%)
    if (job.requirements.skills && jobSeeker.skills) {
      const jobSkills = job.requirements.skills.map(s => s.toLowerCase());
      const seekerSkills = jobSeeker.skills.map(s => s.toLowerCase());
      
      const matchedSkills = jobSkills.filter(skill => 
        seekerSkills.some(js => 
          js.includes(skill) || skill.includes(js)
        )
      );
      
      const missingSkills = jobSkills.filter(skill => 
        !seekerSkills.some(js => 
          js.includes(skill) || skill.includes(js)
        )
      );

      breakdown.skills.matched = matchedSkills;
      breakdown.skills.missing = missingSkills;
      
      if (jobSkills.length > 0) {
        const percentage = matchedSkills.length / jobSkills.length;
        breakdown.skills.score = percentage * breakdown.skills.max;
      }
    }

    // 2. EXPERIENCE MATCHING (25%)
    const totalExp = this.calculateTotalExperience(jobSeeker.experience);
    if (job.requirements.experience && job.requirements.experience.min) {
      const requiredMin = job.requirements.experience.min;
      const requiredMax = job.requirements.experience.max || Infinity;
      
      if (totalExp >= requiredMin && totalExp <= requiredMax) {
        breakdown.experience.score = breakdown.experience.max;
        breakdown.experience.details = `Perfect fit: ${totalExp.toFixed(1)} years (Required: ${requiredMin}-${requiredMax})`;
      } else if (totalExp >= requiredMin * 0.7) {
        breakdown.experience.score = breakdown.experience.max * 0.7;
        breakdown.experience.details = `Good fit: ${totalExp.toFixed(1)} years (Required: ${requiredMin}+)`;
      } else if (totalExp >= requiredMin * 0.5) {
        breakdown.experience.score = breakdown.experience.max * 0.4;
        breakdown.experience.details = `Growing: ${totalExp.toFixed(1)} years (Required: ${requiredMin}+)`;
      } else {
        breakdown.experience.details = `Below requirement: ${totalExp.toFixed(1)} years (Required: ${requiredMin}+)`;
      }
    } else {
      breakdown.experience.score = breakdown.experience.max * 0.5;
      breakdown.experience.details = `${totalExp.toFixed(1)} years of experience`;
    }

    // 3. LOCATION MATCHING (15%)
    if (this.isLocationMatch(jobSeeker, job)) {
      breakdown.location.score = breakdown.location.max;
      if (job.remoteType === 'remote') {
        breakdown.location.details = 'Remote work available';
      } else if (jobSeeker.remotePreference === 'remote') {
        breakdown.location.details = 'Matches remote preference';
      } else {
        breakdown.location.details = 'Location matches preferences';
      }
    } else {
      breakdown.location.details = 'Location may not match preferences';
    }

    // 4. JOB TYPE MATCHING (10%)
    if (jobSeeker.desiredJobTypes && jobSeeker.desiredJobTypes.includes(job.jobType)) {
      breakdown.jobType.score = breakdown.jobType.max;
      breakdown.jobType.details = `Matches desired job type: ${job.jobType}`;
    } else {
      breakdown.jobType.details = `Job type: ${job.jobType}`;
    }

    // 5. SALARY MATCHING (5%)
    if (this.isSalaryMatch(jobSeeker, job)) {
      breakdown.salary.score = breakdown.salary.max;
      breakdown.salary.details = 'Salary meets expectations';
    } else {
      breakdown.salary.details = 'Salary information not specified';
    }

    // 6. EDUCATION MATCHING (5%)
    if (this.isEducationMatch(jobSeeker, job)) {
      breakdown.education.score = breakdown.education.max;
      breakdown.education.details = 'Education requirements met';
    } else {
      breakdown.education.details = 'Education requirements may differ';
    }

    // Calculate total score
    const totalScore = Object.values(breakdown).reduce(
      (sum, category) => sum + category.score, 
      0
    );

    return {
      score: Math.round(totalScore),
      breakdown,
      label: this.getMatchLabel(Math.round(totalScore)),
      color: this.getMatchColor(Math.round(totalScore)),
    };
  }

  /**
   * Get match label based on score
   */
  static getMatchLabel(score) {
    if (score >= 90) return 'Excellent Match';
    if (score >= 75) return 'Great Match';
    if (score >= 60) return 'Good Match';
    if (score >= 40) return 'Fair Match';
    return 'Low Match';
  }

  /**
   * Get color code for match score
   */
  static getMatchColor(score) {
    if (score >= 90) return '#4CAF50'; // Green
    if (score >= 75) return '#8BC34A'; // Light Green
    if (score >= 60) return '#FF9800'; // Orange
    if (score >= 40) return '#FF5722'; // Deep Orange
    return '#F44336'; // Red
  }

  /**
   * Calculate total years of experience
   */
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

  /**
   * Check if location matches
   */
  static isLocationMatch(jobSeeker, job) {
    // Remote work always matches
    if (job.remoteType === 'remote' || 
        jobSeeker.remotePreference === 'remote' || 
        jobSeeker.remotePreference === 'any') {
      return true;
    }

    // Check preferred locations
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

  /**
   * Check if salary matches
   */
  static isSalaryMatch(jobSeeker, job) {
    if (!jobSeeker.desiredSalary || !job.salary) return false;

    const seekerMin = jobSeeker.desiredSalary.min || 0;
    const jobMin = job.salary.min || 0;
    const jobMax = job.salary.max || Infinity;

    return seekerMin <= jobMax;
  }

  /**
   * Check if education matches
   */
  static isEducationMatch(jobSeeker, job) {
    if (!job.requirements.education || !jobSeeker.education) return true;

    const requiredLevel = job.requirements.education.level;
    const seekerHighestLevel = this.getHighestEducationLevel(jobSeeker.education);

    const educationHierarchy = {
      'high_school': 1,
      'associate': 2,
      'bachelor': 3,
      'master': 4,
      'phd': 5,
    };

    return educationHierarchy[seekerHighestLevel] >= educationHierarchy[requiredLevel];
  }

  /**
   * Get highest education level
   */
  static getHighestEducationLevel(educations) {
    const levels = ['high_school', 'associate', 'bachelor', 'master', 'phd'];
    let highest = 'high_school';

    educations.forEach(edu => {
      if (levels.indexOf(edu.degree) > levels.indexOf(highest)) {
        highest = edu.degree;
      }
    });

    return highest;
  }

  /**
   * Find matching jobs with detailed scores
   */
  static async findMatchingJobsWithBreakdown(jobSeekerId, limit = 20) {
    const jobSeekerDoc = await JobSeeker.findOne({ userId: jobSeekerId });
    
    if (!jobSeekerDoc) {
      throw new Error('Job seeker profile not found. Please create your profile first.');
    }

    const jobSeeker = jobSeekerDoc.getActiveProfile();
    
    if (!jobSeeker) {
      throw new Error('No active profile found.');
    }

    const activeJobs = await Job.find({ status: 'active' })
      .populate('employerId', 'profile.company profile.firstName profile.lastName');

    const jobsWithScores = activeJobs.map(job => {
      const matchData = this.calculateDetailedMatchScore(jobSeeker, job);
      return {
        job,
        matchScore: matchData.score,
        matchLabel: matchData.label,
        matchColor: matchData.color,
        breakdown: matchData.breakdown,
      };
    });

    return jobsWithScores
      .sort((a, b) => b.matchScore - a.matchScore)
      .slice(0, limit);
  }

  /**
   * Get swipe statistics for user
   */
  static async getSwipeStats(jobSeekerId) {
    // This would query your application/swipe tracking system
    // For now, returning sample structure
    return {
      totalSwipes: 150,
      likes: 45,
      superLikes: 12,
      passes: 93,
      applications: 15,
      interviews: 3,
      averageMatchScore: 72,
      successRate: 10, // percentage
    };
  }

  /**
   * Track swipe action
   */
  static async trackSwipe(jobSeekerId, jobId, action) {
    // action: 'like', 'super_like', 'pass'
    // Store in database for analytics
    const swipeData = {
      jobSeekerId,
      jobId,
      action,
      timestamp: new Date(),
    };

    // Save to SwipeHistory collection (you'll need to create this model)
    // await SwipeHistory.create(swipeData);

    return swipeData;
  }

  /**
   * Simple match score calculation (for backward compatibility)
   * @param {Object} jobSeeker - Job seeker profile
   * @param {Object} job - Job posting
   * @returns {Number} - Match score (0-100)
   */
  static calculateMatchScore(jobSeeker, job) {
    const detailedScore = this.calculateDetailedMatchScore(jobSeeker, job);
    return detailedScore.score;
  }

  /**
   * Find matching jobs for a job seeker (simplified version)
   * @param {String} jobSeekerId - User ID of job seeker
   * @param {Number} limit - Maximum number of jobs to return
   * @returns {Array} - Array of matching jobs
   */
  static async findMatchingJobs(jobSeekerId, limit = 20) {
    const matches = await this.findMatchingJobsWithBreakdown(jobSeekerId, limit);
    return matches.map(m => ({
      ...m.job.toObject(),
      matchScore: m.matchScore,
      matchLabel: m.matchLabel,
    }));
  }

  /**
   * Find matching candidates for a job posting
   * @param {String} jobId - Job ID
   * @param {Number} limit - Maximum number of candidates to return
   * @returns {Array} - Array of matching candidates
   */
  static async findMatchingCandidates(jobId, limit = 50) {
    const job = await Job.findById(jobId);

    if (!job) {
      throw new Error('Job not found');
    }

    const allJobSeekers = await JobSeeker.find({ isActive: true })
      .populate('userId', 'email');

    const candidatesWithScores = allJobSeekers
      .map(seekerDoc => {
        const jobSeeker = seekerDoc.getActiveProfile();
        if (!jobSeeker) return null;

        const matchScore = this.calculateMatchScore(jobSeeker, job);
        return {
          jobSeeker: seekerDoc,
          matchScore,
          matchLabel: this.getMatchLabel(matchScore),
        };
      })
      .filter(candidate => candidate !== null && candidate.matchScore >= 40);

    return candidatesWithScores
      .sort((a, b) => b.matchScore - a.matchScore)
      .slice(0, limit);
  }
}

module.exports = EnhancedJobMatchingService;
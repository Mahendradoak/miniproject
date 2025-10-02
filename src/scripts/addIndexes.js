require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User.improved');
const Job = require('../models/Job.improved');
const JobSeeker = require('../models/JobSeeker.improved');
const Application = require('../models/Application.improved');

async function addIndexes() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✓ Connected to MongoDB');
    
    console.log('Creating indexes...');
    
    // This will create all indexes defined in the schemas
    await Promise.all([
      User.createIndexes(),
      Job.createIndexes(),
      JobSeeker.createIndexes(),
      Application.createIndexes()
    ]);
    
    console.log('✓ All indexes created successfully!');
    
    // List all indexes
    const userIndexes = await User.listIndexes();
    const jobIndexes = await Job.listIndexes();
    const jobSeekerIndexes = await JobSeeker.listIndexes();
    const applicationIndexes = await Application.listIndexes();
    
    console.log('\n📊 Index Summary:');
    console.log(`User indexes: ${userIndexes.length}`);
    console.log(`Job indexes: ${jobIndexes.length}`);
    console.log(`JobSeeker indexes: ${jobSeekerIndexes.length}`);
    console.log(`Application indexes: ${applicationIndexes.length}`);
    
    process.exit(0);
  } catch (error) {
    console.error('✗ Error creating indexes:', error);
    process.exit(1);
  }
}

addIndexes();
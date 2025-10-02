require('dotenv').config();
const mongoose = require('mongoose');

async function recreateIndexes() {
  try {
    console.log('🔌 Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✓ Connected!\n');
    
    // Get the Job collection directly
    const db = mongoose.connection.db;
    const jobCollection = db.collection('jobs');
    
    console.log('🗑️  Dropping old text index...');
    try {
      await jobCollection.dropIndex('job_search_index');
      console.log('✓ Old index dropped\n');
    } catch (err) {
      console.log('⚠️  Index might not exist, continuing...\n');
    }
    
    // Now import models (this will try to create new indexes)
    const User = require('../models/User');
    const Job = require('../models/Job');
    const JobSeeker = require('../models/JobSeeker');
    const Application = require('../models/Application');
    
    console.log('📊 Creating all indexes...\n');
    
    await Promise.all([
      User.createIndexes(),
      Job.createIndexes(),
      JobSeeker.createIndexes(),
      Application.createIndexes()
    ]);
    
    console.log('✓ All indexes created!\n');
    
    // Show index counts
    const userIndexes = await User.listIndexes();
    const jobIndexes = await Job.listIndexes();
    const jobSeekerIndexes = await JobSeeker.listIndexes();
    const applicationIndexes = await Application.listIndexes();
    
    console.log('📈 Index Summary:');
    console.log('   User: ' + userIndexes.length + ' indexes');
    console.log('   Job: ' + jobIndexes.length + ' indexes');
    console.log('   JobSeeker: ' + jobSeekerIndexes.length + ' indexes');
    console.log('   Application: ' + applicationIndexes.length + ' indexes');
    console.log('');
    console.log('   Total: ' + (userIndexes.length + jobIndexes.length + jobSeekerIndexes.length + applicationIndexes.length) + ' indexes');
    
    console.log('\n📋 Job Indexes Details:');
    jobIndexes.forEach(function(idx) {
      console.log('   - ' + idx.name);
    });
    
    await mongoose.connection.close();
    console.log('\n✓ Done!');
    process.exit(0);
  } catch (error) {
    console.error('✗ Error:', error.message);
    console.error(error);
    process.exit(1);
  }
}

recreateIndexes();

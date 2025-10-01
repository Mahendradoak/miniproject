require('dotenv').config();
const mongoose = require('mongoose');
const Job = require('./src/models/Job');
const User = require('./src/models/User');

// Sample data arrays
const jobTitles = [
  'Software Engineer', 'Senior Software Engineer', 'Full Stack Developer', 
  'Frontend Developer', 'Backend Developer', 'DevOps Engineer', 'Data Scientist',
  'Machine Learning Engineer', 'Product Manager', 'UX Designer', 'UI Designer',
  'Marketing Manager', 'Sales Representative', 'Account Manager', 'Business Analyst',
  'Project Manager', 'Scrum Master', 'QA Engineer', 'Security Engineer',
  'Mobile Developer', 'iOS Developer', 'Android Developer', 'React Developer',
  'Python Developer', 'Java Developer', 'Node.js Developer', 'Cloud Architect',
  'Database Administrator', 'Network Engineer', 'System Administrator', 'Technical Writer',
  'Content Writer', 'Graphic Designer', 'Video Editor', 'Social Media Manager',
  'HR Manager', 'Recruiter', 'Financial Analyst', 'Data Analyst', 'Customer Success Manager'
];

const companies = [
  'Google', 'Microsoft', 'Amazon', 'Apple', 'Meta', 'Netflix', 'Tesla', 'SpaceX',
  'Uber', 'Lyft', 'Airbnb', 'Stripe', 'Shopify', 'Square', 'PayPal', 'Adobe',
  'Salesforce', 'Oracle', 'IBM', 'Intel', 'AMD', 'NVIDIA', 'Cisco', 'Dell',
  'HP', 'Lenovo', 'Twitter', 'LinkedIn', 'Snap', 'Pinterest', 'Reddit', 'Discord',
  'Zoom', 'Slack', 'Dropbox', 'Box', 'Twilio', 'Atlassian', 'GitHub', 'GitLab',
  'MongoDB', 'Redis Labs', 'Elastic', 'Databricks', 'Snowflake', 'Datadog',
  'Cloudflare', 'DigitalOcean', 'Heroku', 'Vercel', 'Netlify'
];

const cities = [
  'San Francisco', 'New York', 'Seattle', 'Austin', 'Boston', 'Los Angeles',
  'Chicago', 'Denver', 'Atlanta', 'Miami', 'Portland', 'San Diego', 'Phoenix',
  'Dallas', 'Houston', 'Philadelphia', 'Washington DC', 'Minneapolis', 'Detroit',
  'Las Vegas', 'Salt Lake City', 'Nashville', 'Charlotte', 'Raleigh', 'Tampa'
];

const states = ['CA', 'NY', 'WA', 'TX', 'MA', 'IL', 'CO', 'GA', 'FL', 'OR', 
                'AZ', 'PA', 'DC', 'MN', 'MI', 'NV', 'UT', 'TN', 'NC'];

const skills = [
  'JavaScript', 'Python', 'Java', 'C++', 'C#', 'Ruby', 'PHP', 'Go', 'Rust', 'Swift',
  'Kotlin', 'TypeScript', 'React', 'Angular', 'Vue.js', 'Node.js', 'Express',
  'Django', 'Flask', 'Spring Boot', 'ASP.NET', 'Ruby on Rails', 'Laravel',
  'MongoDB', 'PostgreSQL', 'MySQL', 'Redis', 'Elasticsearch', 'GraphQL', 'REST API',
  'Docker', 'Kubernetes', 'AWS', 'Azure', 'GCP', 'Jenkins', 'CI/CD', 'Git',
  'Agile', 'Scrum', 'TDD', 'Machine Learning', 'Deep Learning', 'TensorFlow',
  'PyTorch', 'Pandas', 'NumPy', 'SQL', 'NoSQL', 'Microservices', 'System Design',
  'HTML', 'CSS', 'SASS', 'Webpack', 'Redux', 'Next.js', 'Nest.js', 'GraphQL'
];

const jobTypes = ['full-time', 'part-time', 'contract', 'internship'];
const remoteTypes = ['remote', 'onsite', 'hybrid'];

function getRandomElement(array) {
  return array[Math.floor(Math.random() * array.length)];
}

function getRandomElements(array, count) {
  const shuffled = array.sort(() => 0.5 - Math.random());
  return shuffled.slice(0, count);
}

function getRandomNumber(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function generateJobDescription(title, company) {
  const templates = [
    `${company} is seeking a talented ${title} to join our growing team. You'll work on cutting-edge projects and collaborate with industry experts.`,
    `We're looking for an experienced ${title} at ${company}. This role offers excellent growth opportunities and the chance to work with modern technologies.`,
    `Join ${company} as a ${title} and help build innovative solutions that impact millions of users worldwide.`,
    `${company} is hiring a ${title} to work on exciting projects. Great benefits, competitive salary, and amazing team culture.`,
    `Become part of ${company}'s mission as a ${title}. You'll contribute to products used by customers globally.`
  ];
  return getRandomElement(templates);
}

async function seedJobs() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    // Get or create a default employer
    let employer = await User.findOne({ userType: 'employer' });
    
    if (!employer) {
      console.log('Creating default employer...');
      employer = await User.create({
        email: 'system@jobmatcher.com',
        password: 'system123',
        userType: 'employer',
        profile: {
          firstName: 'System',
          lastName: 'Admin',
          company: 'Job Matcher Platform'
        }
      });
    }

    // Clear existing jobs
    console.log('Clearing existing jobs...');
    await Job.deleteMany({});

    // Generate 1000 jobs
    console.log('Generating 1000 jobs...');
    const jobs = [];

    for (let i = 0; i < 1000; i++) {
      const title = getRandomElement(jobTitles);
      const company = getRandomElement(companies);
      const city = getRandomElement(cities);
      const state = getRandomElement(states);
      const jobType = getRandomElement(jobTypes);
      const remoteType = getRandomElement(remoteTypes);
      const requiredSkills = getRandomElements(skills, getRandomNumber(3, 8));
      const minExp = getRandomNumber(0, 8);
      const maxExp = minExp + getRandomNumber(2, 7);
      const minSalary = getRandomNumber(50, 200) * 1000;
      const maxSalary = minSalary + getRandomNumber(20, 80) * 1000;

      const job = {
        employerId: employer._id,
        title: title,
        company: company,
        description: generateJobDescription(title, company),
        requirements: {
          skills: requiredSkills,
          experience: {
            min: minExp,
            max: maxExp
          },
          education: ['Bachelor\'s Degree', 'Master\'s Degree']
        },
        jobType: jobType,
        salary: {
          min: minSalary,
          max: maxSalary,
          currency: 'USD'
        },
        location: {
          city: city,
          state: state,
          country: 'USA'
        },
        remoteType: remoteType,
        status: 'active',
        postedAt: new Date(Date.now() - Math.random() * 30 * 24 * 60 * 60 * 1000) // Random date within last 30 days
      };

      jobs.push(job);

      // Show progress
      if ((i + 1) % 100 === 0) {
        console.log(`Generated ${i + 1} jobs...`);
      }
    }

    // Insert all jobs
    console.log('Inserting jobs into database...');
    await Job.insertMany(jobs);

    console.log('Successfully created 1000 jobs!');
    console.log('\nSample statistics:');
    console.log(`- Total jobs: ${await Job.countDocuments()}`);
    console.log(`- Remote jobs: ${await Job.countDocuments({ remoteType: 'remote' })}`);
    console.log(`- Full-time jobs: ${await Job.countDocuments({ jobType: 'full-time' })}`);
    console.log(`- Companies represented: ${companies.length}`);
    console.log(`- Unique job titles: ${jobTitles.length}`);

  } catch (error) {
    console.error('Error seeding jobs:', error);
  } finally {
    await mongoose.connection.close();
    console.log('\nDatabase connection closed');
  }
}

// Run the seed script
seedJobs();
import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context),
            _buildFeaturesSection(context),
            _buildHowItWorksSection(context),
            _buildStatsSection(context),
            _buildCTASection(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: Responsive.padding(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
        ),
      ),
      child: ResponsiveLayout(
        mobile: _buildHeroMobile(context),
        desktop: _buildHeroDesktop(context),
      ),
    );
  }

  Widget _buildHeroMobile(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40),
        Text(
          'Find Your Dream Job',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          'AI-powered job matching connecting talent with opportunity',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white.withValues(alpha:0.9),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40),
        _buildCTAButtons(context),
        SizedBox(height: 40),
      ],
    );
  }

  Widget _buildHeroDesktop(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 80),
              Text(
                'Find Your Dream Job',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'AI-powered job matching connecting talent with opportunity.\nJoin thousands of job seekers and employers.',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white.withValues(alpha:0.9),
                  height: 1.6,
                ),
              ),
              SizedBox(height: 48),
              _buildCTAButtons(context),
              SizedBox(height: 80),
            ],
          ),
        ),
        SizedBox(width: 80),
        Expanded(
          child: _buildHeroIllustration(),
        ),
      ],
    );
  }

  Widget _buildHeroIllustration() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Icon(
          Icons.work_outline,
          size: 200,
          color: Colors.white.withValues(alpha:0.3),
        ),
      ),
    );
  }

  Widget _buildCTAButtons(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF667eea),
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
          ),
          child: Text(
            'Get Started',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        OutlinedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/jobs');
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white, width: 2),
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Browse Jobs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Container(
      padding: Responsive.padding(context),
      child: Column(
        children: [
          SizedBox(height: 80),
          Text(
            'Why Choose Our Platform?',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 32),
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a1a1a),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            'Everything you need to find the perfect match',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 60),
          ResponsiveLayout(
            mobile: _buildFeaturesMobile(),
            desktop: _buildFeaturesDesktop(),
          ),
          SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildFeaturesMobile() {
    return Column(
      children: _featuresList.map((feature) => _buildFeatureCard(feature)).toList(),
    );
  }

  Widget _buildFeaturesDesktop() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _featuresList.map((feature) => 
        Expanded(child: _buildFeatureCard(feature))
      ).toList(),
    );
  }

  final List<Map<String, dynamic>> _featuresList = [
    {
      'icon': Icons.psychology,
      'title': 'AI-Powered Matching',
      'description': 'Smart algorithms match your skills with the perfect opportunities',
    },
    {
      'icon': Icons.speed,
      'title': 'Fast & Easy',
      'description': 'Apply to multiple jobs with one click and track all applications',
    },
    {
      'icon': Icons.verified_user,
      'title': 'Verified Employers',
      'description': 'All companies are verified to ensure legitimate opportunities',
    },
  ];

  Widget _buildFeatureCard(Map<String, dynamic> feature) {
    return Container(
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              feature['icon'],
              size: 40,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24),
          Text(
            feature['title'],
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a1a1a),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            feature['description'],
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    return Container(
      padding: Responsive.padding(context),
      color: Colors.grey[50],
      child: Column(
        children: [
          SizedBox(height: 80),
          Text(
            'How It Works',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 32),
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a1a1a),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 60),
          ResponsiveLayout(
            mobile: _buildStepsMobile(),
            desktop: _buildStepsDesktop(),
          ),
          SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStepsMobile() {
    return Column(
      children: [
        _buildStep(1, 'Create Profile', 'Sign up and complete your professional profile'),
        SizedBox(height: 40),
        _buildStep(2, 'Get Matched', 'Our AI finds the best opportunities for you'),
        SizedBox(height: 40),
        _buildStep(3, 'Apply & Connect', 'One-click applications to your dream jobs'),
      ],
    );
  }

  Widget _buildStepsDesktop() {
    return Row(
      children: [
        Expanded(child: _buildStep(1, 'Create Profile', 'Sign up and complete your professional profile')),
        SizedBox(width: 40),
        Expanded(child: _buildStep(2, 'Get Matched', 'Our AI finds the best opportunities for you')),
        SizedBox(width: 40),
        Expanded(child: _buildStep(3, 'Apply & Connect', 'One-click applications to your dream jobs')),
      ],
    );
  }

  Widget _buildStep(int number, String title, String description) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 24),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a1a1a),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12),
        Text(
          description,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Container(
      padding: Responsive.padding(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      ),
      child: ResponsiveLayout(
        mobile: _buildStatsMobile(),
        desktop: _buildStatsDesktop(),
      ),
    );
  }

  Widget _buildStatsMobile() {
    return Column(
      children: [
        SizedBox(height: 60),
        _buildStatItem('10,000+', 'Active Jobs'),
        SizedBox(height: 40),
        _buildStatItem('5,000+', 'Job Seekers'),
        SizedBox(height: 40),
        _buildStatItem('500+', 'Companies'),
        SizedBox(height: 40),
        _buildStatItem('95%', 'Success Rate'),
        SizedBox(height: 60),
      ],
    );
  }

  Widget _buildStatsDesktop() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(height: 120),
        _buildStatItem('10,000+', 'Active Jobs'),
        _buildStatItem('5,000+', 'Job Seekers'),
        _buildStatItem('500+', 'Companies'),
        _buildStatItem('95%', 'Success Rate'),
        SizedBox(height: 120),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white.withValues(alpha:0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return Container(
      padding: Responsive.padding(context),
      child: Column(
        children: [
          SizedBox(height: 80),
          Text(
            'Ready to Get Started?',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 36),
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a1a1a),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            'Join thousands of successful job seekers and employers',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF667eea),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
            ),
            child: Text(
              'Sign Up Now - It\'s Free',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: Responsive.padding(context),
      color: Color(0xFF1a1a1a),
      child: Column(
        children: [
          SizedBox(height: 60),
          ResponsiveLayout(
            mobile: _buildFooterMobile(),
            desktop: _buildFooterDesktop(),
          ),
          SizedBox(height: 40),
          Divider(color: Colors.grey[800]),
          SizedBox(height: 20),
          Text(
            '© 2025 Job Platform. All rights reserved.',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildFooterMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFooterColumn('Company', ['About Us', 'Careers', 'Contact']),
        SizedBox(height: 30),
        _buildFooterColumn('For Job Seekers', ['Browse Jobs', 'Career Advice', 'Success Stories']),
        SizedBox(height: 30),
        _buildFooterColumn('For Employers', ['Post a Job', 'Pricing', 'Resources']),
      ],
    );
  }

  Widget _buildFooterDesktop() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Job Platform',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Connecting talent with opportunity',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _buildFooterColumn('Company', ['About Us', 'Careers', 'Contact'])),
        Expanded(child: _buildFooterColumn('For Job Seekers', ['Browse Jobs', 'Career Advice', 'Success Stories'])),
        Expanded(child: _buildFooterColumn('For Employers', ['Post a Job', 'Pricing', 'Resources'])),
      ],
    );
  }

  Widget _buildFooterColumn(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16),
        ...links.map((link) => Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {},
            child: Text(
              link,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ),
        )).toList(),
      ],
    );S
  }
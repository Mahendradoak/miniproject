import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import 'login_screen.dart';
import '../job_seeker/home_screen.dart';
import '../employer/employer_home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _companyController = TextEditingController();
  final _authService = AuthService();
  
  String _userType = 'job_seeker';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final profile = _userType == 'job_seeker'
          ? {
              'firstName': _firstNameController.text.trim(),
              'lastName': _lastNameController.text.trim(),
            }
          : {
              'company': _companyController.text.trim(),
              'firstName': _firstNameController.text.trim(),
              'lastName': _lastNameController.text.trim(),
            };

      final result = await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        userType: _userType,
        profile: profile,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success']) {
        if (!mounted) return;
        if (_userType == 'job_seeker') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const JobSeekerHomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const EmployerHomeScreen()),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Registration failed'),
            backgroundColor: AppColors.accentPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark 
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.darkBackground,
                  AppColors.darkSurface,
                  AppColors.darkBackground,
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue[900]!,
                  Colors.blue[700]!,
                  Colors.blue[500]!,
                ],
              ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      // Logo
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            AppColors.glowShadow(
                              color: AppColors.primaryPurple,
                              opacity: 0.5,
                              blur: 30,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_add_outlined,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Title
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimary : Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join thousands of job seekers and employers',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark 
                            ? AppColors.textSecondary 
                            : Colors.white.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // User Type Selection
                      Row(
                        children: [
                          Expanded(
                            child: _buildUserTypeCard(
                              'Job Seeker',
                              Icons.person_search,
                              'job_seeker',
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildUserTypeCard(
                              'Employer',
                              Icons.business_center,
                              'employer',
                              isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Form Card
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: isDark 
                            ? AppColors.darkSurface 
                            : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: isDark 
                            ? Border.all(
                                color: AppColors.primaryPurple.withOpacity(0.2),
                                width: 1,
                              )
                            : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // First Name & Last Name
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _firstNameController,
                                      style: TextStyle(
                                        color: isDark ? AppColors.textPrimary : Colors.black87,
                                      ),
                                      decoration: _buildInputDecoration(
                                        'First Name',
                                        Icons.person_outlined,
                                        isDark,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _lastNameController,
                                      style: TextStyle(
                                        color: isDark ? AppColors.textPrimary : Colors.black87,
                                      ),
                                      decoration: _buildInputDecoration(
                                        'Last Name',
                                        Icons.person_outlined,
                                        isDark,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              
                              // Company (if employer)
                              if (_userType == 'employer')
                                Column(
                                  children: [
                                    TextFormField(
                                      controller: _companyController,
                                      style: TextStyle(
                                        color: isDark ? AppColors.textPrimary : Colors.black87,
                                      ),
                                      decoration: _buildInputDecoration(
                                        'Company Name',
                                        Icons.business,
                                        isDark,
                                      ),
                                      validator: (value) {
                                        if (_userType == 'employer' &&
                                            (value == null || value.isEmpty)) {
                                          return 'Please enter company name';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              
                              // Email
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(
                                  color: isDark ? AppColors.textPrimary : Colors.black87,
                                ),
                                decoration: _buildInputDecoration(
                                  'Email',
                                  Icons.email_outlined,
                                  isDark,
                                  hintText: 'Enter your email',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              
                              // Password
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: TextStyle(
                                  color: isDark ? AppColors.textPrimary : Colors.black87,
                                ),
                                decoration: _buildInputDecoration(
                                  'Password',
                                  Icons.lock_outlined,
                                  isDark,
                                  hintText: 'Create a password',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: isDark 
                                        ? AppColors.textSecondary 
                                        : Colors.grey[600],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              
                              // Confirm Password
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                style: TextStyle(
                                  color: isDark ? AppColors.textPrimary : Colors.black87,
                                ),
                                decoration: _buildInputDecoration(
                                  'Confirm Password',
                                  Icons.lock_outlined,
                                  isDark,
                                  hintText: 'Confirm your password',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: isDark 
                                        ? AppColors.textSecondary 
                                        : Colors.grey[600],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword = !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),
                              
                              // Register Button
                              GradientButton(
                                text: _isLoading ? 'Creating Account...' : 'Create Account',
                                onPressed: _isLoading ? () {} : _register,
                                gradient: AppColors.primaryGradient,
                                height: 56,
                              ),
                              const SizedBox(height: 24),
                              
                              // Login link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: TextStyle(
                                      color: isDark 
                                        ? AppColors.textSecondary 
                                        : Colors.grey[600],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: isDark 
                                        ? AppColors.primaryPurple 
                                        : Colors.blue,
                                    ),
                                    child: const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard(String title, IconData icon, String value, bool isDark) {
    final isSelected = _userType == value;
    return GestureDetector(
      onTap: () {
        setState(() => _userType = value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected 
            ? AppColors.primaryGradient 
            : null,
          color: isSelected 
            ? null 
            : (isDark ? AppColors.darkSurfaceVariant : Colors.grey[100]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
              ? Colors.transparent 
              : (isDark 
                  ? AppColors.primaryPurple.withOpacity(0.2) 
                  : Colors.grey[300]!),
            width: 2,
          ),
          boxShadow: isSelected 
            ? [
                AppColors.glowShadow(
                  color: AppColors.primaryPurple,
                  opacity: 0.4,
                  blur: 15,
                ),
              ]
            : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected 
                ? Colors.white 
                : (isDark ? AppColors.textSecondary : Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: isSelected 
                  ? Colors.white 
                  : (isDark ? AppColors.textPrimary : Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String label,
    IconData icon,
    bool isDark, {
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? AppColors.textSecondary : Colors.grey[700],
      ),
      hintText: hintText,
      hintStyle: TextStyle(
        color: isDark ? AppColors.textTertiary : Colors.grey[400],
      ),
      prefixIcon: Icon(
        icon,
        color: isDark ? AppColors.primaryPurple : Colors.blue,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark ? AppColors.darkSurfaceVariant : Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark 
            ? AppColors.primaryPurple.withOpacity(0.2)
            : Colors.transparent,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? AppColors.primaryPurple : Colors.blue,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.accentPink,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.accentPink,
          width: 2,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyController.dispose();
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/onboarding_bloc.dart';
import '../widgets/welcome_step.dart';
import '../widgets/user_info_step.dart';
import '../widgets/theme_step.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../../core/theme/theme_cubit.dart';


class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  final TextEditingController _surNameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  
  int _currentPage = 0;
  bool _isDarkMode = false; // Default to light

  @override
  void initState() {
    super.initState();
    // Initialize dark mode from current theme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentTheme = context.read<ThemeCubit>().state;
      if (currentTheme == ThemeMode.dark && !_isDarkMode) {
        setState(() {
          _isDarkMode = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _secondNameController.dispose();
    _surNameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 1) {
      if (!_formKey.currentState!.validate()) return;
    }
    
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage++;
      });
    } else {
      _submit();
    }
  }

  void _submit() {
    final bloc = context.read<OnboardingBloc>();
    if (bloc.state is OnboardingLoading) return;
    
    bloc.add(SubmitUserInfo(
      firstName: _firstNameController.text,
      secondName: _secondNameController.text,
      surName: _surNameController.text,
      nickname: _nicknameController.text.isNotEmpty ? _nicknameController.text : null,
      isDarkMode: _isDarkMode,
    ));
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) {

          if (state is OnboardingSuccess) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const DashboardPage()),
            );
          } else if (state is OnboardingFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      children: [
                        const WelcomeStep(),
                        UserInfoStep(
                          firstNameController: _firstNameController,
                          secondNameController: _secondNameController,
                          surNameController: _surNameController,
                          nicknameController: _nicknameController,
                          formKey: _formKey,
                        ),
                         BlocBuilder<ThemeCubit, ThemeMode>(
                          builder: (context, themeMode) {
                            // Sync local state with theme cubit
                            final currentIsDark = themeMode == ThemeMode.dark;
                            if (_isDarkMode != currentIsDark) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                setState(() {
                                  _isDarkMode = currentIsDark;
                                });
                              });
                            }
                            
                            return ThemeStep(
                              isDarkMode: currentIsDark,
                              onThemeChanged: (val) {
                                setState(() {
                                  _isDarkMode = val;
                                });
                                context.read<ThemeCubit>().toggleTheme(val);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        if (_currentPage > 0)
                          TextButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: const Text('رجوع'),
                          )
                        else
                          const SizedBox(width: 64), // Placeholder for alignment

                        // Indicator
                        Row(
                          children: List.generate(3, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? AppColors.primary
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),

                         // Next/Finish Button
                        state is OnboardingLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _nextPage,
                              child: Text(_currentPage == 2 ? 'ابدأ' : 'التالي'),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
  }
}


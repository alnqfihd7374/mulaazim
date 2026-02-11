import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/dashboard_bloc.dart';

class DynamicHeader extends StatelessWidget {
  final VoidCallback? onSettingsTap;

  const DynamicHeader({super.key, this.onSettingsTap});


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoaded) {
          final user = state.user;
          final displayName = user.displayName;
          
          // Configure Hijri Locale
          HijriCalendar.setLocal('ar');
          final hijriDate = HijriCalendar.now();

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
            decoration: BoxDecoration(
              color: isDark ? theme.scaffoldBackgroundColor : AppColors.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row( // This new Row contains the user's name and settings button
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'أهلاً بك،', // Changed from 'مرحباً بك،'
                              style: GoogleFonts.tajawal(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            BlocBuilder<DashboardBloc, DashboardState>(
                              builder: (context, state) {
                                String name = 'طالب العلم';
                                if (state is DashboardLoaded) {
                                  name = (state.user.nickname != null && state.user.nickname!.isNotEmpty)
                                      ? state.user.nickname!
                                      : state.user.firstName;
                                }

                                return Text(
                                  name,
                                  style: GoogleFonts.tajawal(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: onSettingsTap,
                          icon: const Icon(Icons.settings, color: Colors.white70),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            hijriDate.hDay.toString(),
                            style: GoogleFonts.tajawal(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            hijriDate.toFormat('MMMM'), // Hijri Month Name
                            style: GoogleFonts.tajawal(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink(); // Or generic loading header
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../courses/presentation/bloc/course_bloc.dart';
import '../../../courses/presentation/pages/add_course_page.dart';

import '../bloc/dashboard_bloc.dart';
import '../widgets/dynamic_header.dart';
import '../widgets/course_card.dart';
import '../widgets/check_in_card.dart';
import 'pending_lessons_page.dart';
import 'analysis_page.dart';
import '../../../courses/presentation/pages/course_details_page.dart';

import '../../../settings/presentation/pages/settings_page.dart';

import '../../../courses/data/models/course.dart';


import '../../../courses/data/models/pending_lesson.dart';




class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<DashboardBloc>()..add(LoadDashboardData())),
        BlocProvider(create: (context) => sl<CourseBloc>()..add(LoadCourses())),
      ],
      child: Scaffold(
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddCoursePage()),
                );
                if (result == true) {
                  context.read<CourseBloc>().add(LoadCourses());
                }
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
        ),
        body: SingleChildScrollView(
          child: BlocBuilder<CourseBloc, CourseState>(
            builder: (context, state) {
              List<Course> courses = [];
              if (state is CourseLoaded) {
                courses = state.courses;
              }
              
              // Calculate Check-ins
              final dueCourses = _getDueCourses(courses);
              
              // Calculate Stats
              final stats = _calculateStats(courses);
              
              // Get Pending Lessons
              final pendingLessons = _getPendingLessons(courses);

              return Column(
                children: [
                  DynamicHeader(
                    onSettingsTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Check-in Cards Section (Only if due)
                        if (dueCourses.isNotEmpty) ...[
                          Text(
                            'التحضير اليومي',
                            style: GoogleFonts.tajawal(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...dueCourses.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: CheckInCard(course: c),
                          )),
                          const SizedBox(height: 16),
                        ],

                        // Analysis Button (NEW)
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AnalysisPage()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.analytics_outlined, color: Colors.white, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'لوحة المتابعة والتحليل',
                                style: GoogleFonts.tajawal(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'شاهد إحصائياتك وقائمة الاستدراك',
                                style: GoogleFonts.tajawal(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                     // Pending Lessons Section
                    if (pendingLessons.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'قائمة الاستدراك',
                            style: GoogleFonts.tajawal(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const PendingLessonsPage()),
                              );
                            },
                            child: Text(

                              'عرض الكل (${pendingLessons.length})',
                              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildPendingLessonsList(pendingLessons),
                    ] else
                       _buildPendingLessonsPlaceholder(context),

                    const SizedBox(height: 32),
                    // Courses Section
                    Row(

                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'موادك الدراسية',
                          style: GoogleFonts.tajawal(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCourseList(context, courses),

                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  ),
);
}







  Widget _buildCourseList(BuildContext context, List<Course> courses) {

    if (courses.isEmpty) {
      return const Center(child: Text('لم تقم بإضافة أي مواد بعد'));
    }
    return Column(
      children: courses.map((course) => CourseCard(
        course: course,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourseDetailsPage(course: course),
            ),
          );
        },
      )).toList(),
    );
  }


  // --- Logic Helpers ---

  List<Course> _getDueCourses(List<Course> courses) {
    final now = DateTime.now();
    return courses.where((c) {
      // Is today a schedule day?
      if (!c.scheduleDays.contains(now.weekday)) return false;
      
      // Has checked in today?
      if (c.lastCheckInDate != null) {
        final last = c.lastCheckInDate!;
        if (last.year == now.year && last.month == now.month && last.day == now.day) {
          return false;
        }
      }

      // Is it time for the reminder yet?
      if (c.reminderTime != null) {
        try {
          final parts = c.reminderTime!.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          final reminderTime = DateTime(now.year, now.month, now.day, hour, minute);
          if (now.isBefore(reminderTime)) return false;
        } catch (e) {
          // If time parsing fails, show it anyway or ignore
        }
      }
      
      return true;
    }).toList();
  }
  
  Map<String, String> _calculateStats(List<Course> courses) {
    // Mock Logic for now as we don't have full history log, just current status
    // Attendance % could be derived if we stored total sessions vs attended. 
    // For now, hardcode or calculate basic.
    int totalPending = 0;
    for (var c in courses) {
      totalPending += c.pendingLessons.where((p) => !p.isHeard).length;
    }
    
    return {
      'attendance': '85%', // Placeholder
      'pending': totalPending.toString(),
      'streak': '12', // Placeholder
    };
  }

  List<Map<String, dynamic>> _getPendingLessons(List<Course> courses) {
    List<Map<String, dynamic>> allPending = [];
    for (var c in courses) {
      for (var p in c.pendingLessons) {
        if (!p.isHeard) {
          allPending.add({
            'courseName': c.bookName,
            'lessonNumber': p.lessonNumber,
            'date': p.missedDate,
            'reason': p.reason,
            'courseId': c.id,
            'pendingObject': p, // for reference
          });
        }
      }
    }
    // Sort by date desc
    allPending.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return allPending;
  }

  Widget _buildStatsRow(BuildContext context, Map<String, String> stats) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(context, 'الحضور', stats['attendance']!, Icons.check_circle_outline, Colors.green)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard(context, 'الاستدراك', stats['pending']!, Icons.history, Colors.orange)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard(context, 'الالتزام', '${stats['streak']!} يوم', Icons.local_fire_department, Colors.red)),
      ],
    );
  }

  Widget _buildPendingLessonsList(List<Map<String, dynamic>> items) {
     if (items.isEmpty) return const SizedBox.shrink();
     
     // specific formatting for Pending Lessons List
     return Column(
       children: items.take(3).map((item) {
         final date = item['date'] as DateTime;
         return Card(
           margin: const EdgeInsets.only(bottom: 8),
           elevation: 2,
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
           child: ListTile(
             leading: CircleAvatar(
               backgroundColor: Colors.orange.withOpacity(0.1),
               child: Text('${item['lessonNumber']}', style: const TextStyle(color: Colors.orange)),
             ),
             title: Text(item['courseName'], style: const TextStyle(fontWeight: FontWeight.bold)),
             subtitle: Text('${date.day}/${date.month} • ${item['reason'] ?? "بدون عذر"}'),
             trailing: const Icon(Icons.arrow_forward_ios, size: 14),
           ),
         );
       }).toList(),
     );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Theme.of(context).brightness == Brightness.light ? const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ] : null,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textPrimary,
            ),
          ),
           Text(
            title,
            style: GoogleFonts.tajawal(
              fontSize: 12,
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingLessonsPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.orange.withOpacity(0.15) : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.orange.withOpacity(0.3) : Colors.orange.shade200),
      ),
      child: Center(
        child: Text(
          'لا يوجد دروس متأخرة حالياً',
          style: GoogleFonts.tajawal(color: isDark ? Colors.orange.shade300 : Colors.orange.shade800),
        ),
      ),
    );
  }


}

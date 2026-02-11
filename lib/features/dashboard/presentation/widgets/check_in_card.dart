import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../courses/data/models/course.dart';
import '../../../courses/presentation/bloc/course_bloc.dart';


class CheckInCard extends StatelessWidget {
  final Course course;

  const CheckInCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'حان موعد الدرس!',
                  style: GoogleFonts.tajawal(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${course.teacherTitle} ${course.teacherName}',
              style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 14),
            ),
            Text(
              course.bookName,
              style: GoogleFonts.tajawal(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              'الدرس رقم ${course.currentLessonNumber}',
              style: GoogleFonts.tajawal(
                color: Colors.amber, // Highlight lesson number
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    label: 'حضرت',
                    icon: Icons.check_circle,
                    color: Colors.white,
                    textColor: AppColors.primary,
                    onTap: () {
                      context.read<CourseBloc>().add(CheckInEvent(
                        course: course,
                        status: CheckInStatus.attended,
                      ));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    context,
                    label: 'لم أحضر',
                    icon: Icons.cancel,
                    color: Colors.white.withOpacity(0.2),
                    textColor: Colors.white,
                    onTap: () => _showMissedDialog(context),
                  ),
                ),
                const SizedBox(width: 8),
                 Expanded(
                  child: _buildActionButton(
                    context,
                    label: 'اعتذار',
                    icon: Icons.info_outline,
                    color: Colors.transparent,
                    textColor: Colors.white,
                    isBordered: true,
                    onTap: () {
                       context.read<CourseBloc>().add(CheckInEvent(
                        course: course,
                        status: CheckInStatus.excuse,
                      ));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
    bool isBordered = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: isBordered ? Border.all(color: Colors.white54) : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.tajawal(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMissedDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('سبب الغياب', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text('سيتم إضافة هذا الدرس لقائمة الاستدراك', style: GoogleFonts.tajawal(fontSize: 12, color: Colors.grey)),
             const SizedBox(height: 12),
             TextField(
               controller: reasonController,
               decoration: const InputDecoration(
                 hintText: 'سفر، مرض، انشغال...',
               ),
             ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
             child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
               context.read<CourseBloc>().add(CheckInEvent(
                course: course,
                status: CheckInStatus.missed,
                excuseReason: reasonController.text,
              ));
              Navigator.pop(ctx);
            },
            child: const Text('تسجيل'),
          ),
        ],
      ),
    );
  }
}

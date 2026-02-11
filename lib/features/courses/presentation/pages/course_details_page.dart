 import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/models/course.dart';
import '../../data/models/lesson_note.dart';
import '../bloc/course_bloc.dart';
import 'edit_course_page.dart';

class CourseDetailsPage extends StatefulWidget {
  final Course course;
  const CourseDetailsPage({super.key, required this.course});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<CourseBloc>()..add(LoadCourses()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.course.bookName, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.primary,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditCoursePage(course: widget.course)),
                ).then((_) => context.read<CourseBloc>().add(LoadCourses()));
              },
            ),
          ],
        ),
        body: BlocBuilder<CourseBloc, CourseState>(
          builder: (context, state) {
            Course currentCourse = widget.course;
            if (state is CourseLoaded) {
              try {
                currentCourse = state.courses.firstWhere((c) => c.id == widget.course.id);
              } catch (e) {}
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(currentCourse),
                  const SizedBox(height: 24),
                  _buildProgressSection(currentCourse),
                  const SizedBox(height: 32),
                  _buildNotesSection(context, currentCourse),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Course course) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Text(
              course.bookName.isNotEmpty ? course.bookName.substring(0, 1) : '?',
              style: GoogleFonts.tajawal(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${course.teacherTitle} ${course.teacherName}',
                  style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'الدرس الحالي: ${course.currentLessonNumber}',
                  style: GoogleFonts.tajawal(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(Course course) {
    double progress = course.currentLessonNumber > 0 ? (course.currentLessonNumber / (course.currentLessonNumber + 10)) : 0; 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التقدم العام للمادة',
          style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        LinearPercentIndicator(
          lineHeight: 12.0,
          percent: progress > 1 ? 1 : progress,
          backgroundColor: Colors.grey.shade200,
          progressColor: AppColors.primary,
          barRadius: const Radius.circular(10),
          animation: true,
        ),
        const SizedBox(height: 8),
        Text(
          'أنت تتقدم بشكل ممتاز في هذا الكتاب.',
          style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context, Course course) {
    final filteredNotes = course.notes.where((n) => n.content.contains(_searchQuery)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Text(
               'محرر الفوائد (The Insights Keeper)',
               style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
             ),
             IconButton(
               onPressed: () => _showAddNoteDialog(context, course),
               icon: const Icon(Icons.history_edu, color: AppColors.primary, size: 28),
             ),
           ],
         ),
         const SizedBox(height: 12),
         TextField(
           controller: _searchController,
           onChanged: (val) => setState(() => _searchQuery = val),
           decoration: InputDecoration(
             hintText: 'ابحث في الفوائد...',
             prefixIcon: const Icon(Icons.search, size: 20),
             contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
             filled: true,
             fillColor: Colors.grey.shade100,
             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
           ),
         ),
         const SizedBox(height: 16),
         if (filteredNotes.isEmpty)
           Container(
             padding: const EdgeInsets.all(24),
             alignment: Alignment.center,
             child: Text(
               _searchQuery.isEmpty ? 'لا توجد فوائد مسجلة بعد' : 'لا توجد نتائج للبحث',
               style: GoogleFonts.tajawal(color: Colors.grey),
             ),
           )
         else
           ...filteredNotes.reversed.map((note) => Card(
             margin: const EdgeInsets.only(bottom: 12),
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
             child: ListTile(
               onTap: () => _showViewNoteDialog(context, course, note),
               title: Text(
                 note.content, 
                 maxLines: 3, 
                 overflow: TextOverflow.ellipsis,
                 style: GoogleFonts.tajawal(height: 1.5)
               ),
               subtitle: Text('درس رقم ${note.lessonNumber} • ${note.createdAt.day}/${note.createdAt.month}', style: GoogleFonts.tajawal(fontSize: 12, color: AppColors.primary)),
               leading: CircleAvatar(
                 backgroundColor: AppColors.primary.withOpacity(0.1),
                 child: const Icon(Icons.draw, color: AppColors.primary, size: 20),
               ),
             ),
           )),
      ],
    );
  }

  void _showAddNoteDialog(BuildContext context, Course course) {
    final noteController = TextEditingController();
    final lessonController = TextEditingController(text: course.currentLessonNumber.toString());
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تقييد فائدة علمية', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: lessonController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'رقم الدرس'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: noteController,
              maxLines: 5,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'اكتب خلاصة ما استفدت من هذا الدرس...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (noteController.text.isNotEmpty) {
                final lessonNum = int.tryParse(lessonController.text) ?? course.currentLessonNumber;
                context.read<CourseBloc>().add(AddNoteEvent(
                  course: course,
                  content: noteController.text,
                  lessonNumber: lessonNum,
                ));
              }
              Navigator.pop(ctx);
            },
            child: const Text('حفظ الفائدة'),
          ),
        ],
      ),
    );
  }

  void _showViewNoteDialog(BuildContext context, Course course, LessonNote note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('عرض الفائدة (درس ${note.lessonNumber})', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: SelectableText(
            note.content,
            style: GoogleFonts.tajawal(height: 1.6),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.blue),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: note.content));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ النص')));
              Navigator.pop(ctx);
            },
            tooltip: 'نسخ النص',
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.green),
            onPressed: () {
              Navigator.pop(ctx);
              _showEditNoteDialog(context, course, note);
            },
            tooltip: 'تعديل',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              _confirmDeleteNote(context, course, note);
            },
            tooltip: 'حذف',
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
        ],
      ),
    );
  }

  void _showEditNoteDialog(BuildContext context, Course course, LessonNote note) {
    final noteController = TextEditingController(text: note.content);
    final lessonController = TextEditingController(text: note.lessonNumber.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تعديل الفائدة', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: lessonController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'رقم الدرس'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (noteController.text.isNotEmpty) {
                 final lessonNum = int.tryParse(lessonController.text) ?? note.lessonNumber;
                context.read<CourseBloc>().add(UpdateNoteEvent(
                  course: course,
                  oldNote: note,
                  newContent: noteController.text,
                  newLessonNumber: lessonNum,
                ));
              }
              Navigator.pop(ctx);
            },
            child: const Text('تحديث'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteNote(BuildContext context, Course course, LessonNote note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الفائدة؟'),
        content: const Text('لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<CourseBloc>().add(DeleteNoteEvent(course: course, note: note));
              Navigator.pop(ctx);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

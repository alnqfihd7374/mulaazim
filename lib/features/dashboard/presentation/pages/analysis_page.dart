import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../courses/presentation/bloc/course_bloc.dart';
import '../../../courses/data/models/course.dart';
import '../../../courses/data/models/pending_lesson.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  String? _selectedTeacher;
  int? _selectedDay; // 1 = Monday, ..., 7 = Sunday
  
  final List<String> _weekDays = ['الكل', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<CourseBloc>()..add(LoadCourses()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('لوحة المتابعة', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primary,
        ),
        body: BlocBuilder<CourseBloc, CourseState>(
          builder: (context, state) {
            if (state is CourseLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CourseLoaded) {
              final allCourses = state.courses;
              var courses = _selectedTeacher == null 
                  ? allCourses 
                  : allCourses.where((c) => c.teacherName == _selectedTeacher).toList();
              
              if (_selectedDay != null) {
                courses = courses.where((c) => c.scheduleDays.contains(_selectedDay)).toList();
              }
              
              final teachers = allCourses.map((c) => c.teacherName).toSet().toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ملخص إحصائي', style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primary)),
                        Row(
                          children: [
                            if (teachers.isNotEmpty) ...[
                              _buildTeacherFilter(teachers),
                              const SizedBox(width: 8),
                              _buildDayFilter(),
                            ],
                            IconButton(
                              onPressed: () => _exportToPDF(courses),
                              icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                              tooltip: 'تصدير تقرير PDF',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildQuickStats(courses),
                    const SizedBox(height: 32),
                    _buildPendingSection(context, courses),
                    const SizedBox(height: 32),
                    _buildCourseAnalysis(courses),
                  ],
                ),
              );
            }

            return const Center(child: Text('حدث خطأ أثناء تحميل البيانات'));
          },
        ),
      ),
    );
  }

  Widget _buildTeacherFilter(List<String> teachers) {
    return PopupMenuButton<String>(
      tooltip: 'تصفية حسب الشيخ',
      icon: Icon(Icons.person_search_outlined, color: _selectedTeacher != null ? Colors.orange : (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primary)),
      onSelected: (val) => setState(() => _selectedTeacher = val == 'الكل' ? null : val),
      itemBuilder: (ctx) => [
        const PopupMenuItem(value: 'الكل', child: Text('جميع المشايخ')),
        ...teachers.map((t) => PopupMenuItem(value: t, child: Text(t))),
      ],
    );
  }

  Widget _buildDayFilter() {
    return PopupMenuButton<int>(
      tooltip: 'تصفية حسب اليوم',
      icon: Icon(Icons.calendar_month_outlined, color: _selectedDay != null ? Colors.orange : (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primary)),
      onSelected: (val) => setState(() => _selectedDay = val == 0 ? null : val),
      itemBuilder: (ctx) => [
        PopupMenuItem(value: 0, child: Text(_weekDays[0])),
        ...List.generate(7, (index) => PopupMenuItem(
          value: index + 1,
          child: Text(_weekDays[index + 1]),
        )),
      ],
    );
  }


  Future<void> _exportToPDF(List<Course> courses) async {
    final pdf = pw.Document();
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicFontBold = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.MultiPage(
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFontBold),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('تقرير أداء طالب العلم - تطبيق مُلازم', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                pw.Text(DateTime.now().toString().substring(0, 10)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text('كشف الحضور والالتزام للمواد العلمية:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
            cellAlignment: pw.Alignment.centerRight,
            headers: ['المادة', 'المُدرس', 'الدرس الحالي', 'الغياب'],
            data: courses.map((c) => [
              c.bookName,
              c.teacherName,
              c.currentLessonNumber.toString(),
              c.pendingLessons.length.toString(),
            ]).toList(),
          ),
          pw.SizedBox(height: 30),
          pw.Text('قائمة الدروس التي لم تُسمع بعد:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
          pw.SizedBox(height: 10),
          ...courses.expand((c) => c.pendingLessons.where((l) => !l.isHeard).map((l) => 
            pw.Bullet(text: '${c.bookName}: درس رقم ${l.lessonNumber} (بتاريخ ${l.missedDate.toString().substring(0, 10)})')
          )),
          pw.SizedBox(height: 40),
          pw.Divider(),
          pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text('قُيّد لمصلحة طلبة العلم - نفع الله بكم', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Widget _buildQuickStats(List<Course> courses) {
    int totalAttended = 0;
    int totalMissed = 0;
    int pendingHeard = 0;
    int pendingTotal = 0;

    for (var course in courses) {
      pendingTotal += course.pendingLessons.where((l) => !l.isHeard).length;
      pendingHeard += course.pendingLessons.where((l) => l.isHeard).length;
      
      totalAttended += course.currentLessonNumber - course.pendingLessons.length;
      totalMissed += course.pendingLessons.where((l) => !l.isHeard).length;
    }

    double attendanceRate = (totalAttended + totalMissed) == 0 ? 0 : (totalAttended / (totalAttended + totalMissed)) * 100;

    return Row(
      children: [
        _buildStatCard('نسبة الحضور', '${attendanceRate.toStringAsFixed(0)}%', Icons.show_chart, Colors.green),
        const SizedBox(width: 12),
        _buildStatCard('الاستدراك', '$pendingTotal', Icons.headphones, Colors.orange),
        const SizedBox(width: 12),
        _buildStatCard('الالتزام', '7 أيام', Icons.local_fire_department, Colors.red), 
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? color.withOpacity(0.15) : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(isDark ? 0.3 : 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : color)),
            Text(title, style: GoogleFonts.tajawal(fontSize: 12, color: isDark ? const Color(0xFFBDBDBD) : color.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingSection(BuildContext context, List<Course> courses) {
    final List<Map<String, dynamic>> pendingItems = [];
    for (var course in courses) {
      for (var lesson in course.pendingLessons.where((l) => !l.isHeard)) {
        pendingItems.add({
          'course': course,
          'lesson': lesson,
        });
      }
    }

    if (pendingItems.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('قائمة الاستدراك (الأولوية القصوى)', style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primary)),
        const SizedBox(height: 16),
        ...pendingItems.map((item) {
          final Course course = item['course'];
          final PendingLesson lesson = item['lesson'];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              title: Text(course.bookName, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
              subtitle: Text('درس رقم ${lesson.lessonNumber} • ${lesson.missedDate.day}/${lesson.missedDate.month}', style: GoogleFonts.tajawal(fontSize: 12)),
              trailing: ElevatedButton(
                onPressed: () {
                  context.read<CourseBloc>().add(MarkLessonAsDone(course: course, lesson: lesson));
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(60, 36),
                ),
                child: const Text('تم السماع'),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCourseAnalysis(List<Course> courses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('التحليل التفصيلي للمواد', style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primary)),
        const SizedBox(height: 16),
        ...courses.map((course) => _buildCourseAnalysisItem(course)),
      ],
    );
  }

  Widget _buildCourseAnalysisItem(Course course) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int total = course.currentLessonNumber;
    int missed = course.pendingLessons.where((l) => !l.isHeard).length;
    int heard = course.pendingLessons.where((l) => l.isHeard).length;
    int attended = total - (missed + heard);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(course.bookName, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
              Text('$total دروس', style: GoogleFonts.tajawal(fontSize: 12, color: isDark ? const Color(0xFFBDBDBD) : AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 12,
              width: double.infinity,
              color: isDark ? const Color(0xFF333333) : Colors.grey.shade200,
              child: Row(
                children: [
                  if (attended > 0) Expanded(flex: attended, child: Container(color: Colors.green)),
                  if (heard > 0) Expanded(flex: heard, child: Container(color: Colors.green.shade300)),
                  if (missed > 0) Expanded(flex: missed, child: Container(color: Colors.red)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildIndicator('حضور', Colors.green),
              const SizedBox(width: 12),
              _buildIndicator('استدراك', Colors.green.shade300),
              const SizedBox(width: 12),
              _buildIndicator('غياب', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.tajawal(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}

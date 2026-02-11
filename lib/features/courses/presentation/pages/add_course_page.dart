import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/course_bloc.dart';

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final _bookNameController = TextEditingController();
  final _teacherNameController = TextEditingController();
  final _currentLessonController = TextEditingController();
  
  String _teacherTitle = 'الشيخ'; // Default
  final List<int> _selectedDays = [];
  String? _selectedTime;

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى اختيار أيام الدرس')),
        );
        return;
      }

      context.read<CourseBloc>().add(AddCourseEvent(
        bookName: _bookNameController.text,
        teacherName: _teacherNameController.text,
        teacherTitle: _teacherTitle,
        scheduleDays: _selectedDays,
        currentLessonNumber: int.parse(_currentLessonController.text),
        reminderTime: _selectedTime,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CourseBloc>(),
      child: BlocListener<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state is CourseOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context, true); // Return result to refresh
          } else if (state is CourseFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('إضافة كتاب جديد'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primary,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('بيانات المادة'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _bookNameController,
                    label: 'اسم المتن أو الكتاب',
                    icon: Icons.menu_book,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF333333) : Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _teacherTitle,
                            onChanged: (val) => setState(() => _teacherTitle = val!),
                            items: const [
                              DropdownMenuItem(value: 'الشيخ', child: Text('الشيخ')),
                              DropdownMenuItem(value: 'الأخ', child: Text('الأخ')),
                              DropdownMenuItem(value: 'الدكتور', child: Text('الدكتور')),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTextField(
                          controller: _teacherNameController,
                          label: 'اسم المُدرس',
                          icon: Icons.person,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  _buildSectionTitle('الجدول الزمني'),
                  const SizedBox(height: 8),
                  Text(
                    'اختر أيام الدرس ليذكرك التطبيق',
                    style: GoogleFonts.tajawal(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFBDBDBD) : AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildDayChip('السبت', 6),
                      _buildDayChip('الأحد', 7),
                      _buildDayChip('الإثنين', 1),
                      _buildDayChip('الثلاثاء', 2),
                      _buildDayChip('الأربعاء', 3),
                      _buildDayChip('الخميس', 4),
                      _buildDayChip('الجمعة', 5),
                    ],
                  ),

                  const SizedBox(height: 32),
                  _buildSectionTitle('وقت التذكير'),
                  const SizedBox(height: 16),
                  _buildTimePicker(),

                  const SizedBox(height: 32),
                  _buildSectionTitle('نقطة الانطلاق'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _currentLessonController,
                    label: 'رقم الدرس الحالي',
                    icon: Icons.format_list_numbered,
                    keyboardType: TextInputType.number,
                    helperText: 'إذا أدخلت 20، سيبدأ التحضير من 21',
                  ),

                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: Builder(
                      builder: (context) {
                        return ElevatedButton(
                          onPressed: () => _submit(context),
                          child: const Text('إضافة المادة'),
                        );
                      }
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null) {
          setState(() {
            _selectedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF333333) : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primary),
            const SizedBox(width: 12),
            Text(
              _selectedTime ?? 'اختر وقت التنبيه',
              style: GoogleFonts.tajawal(
                color: _selectedTime != null 
                  ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textPrimary)
                  : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFFBDBDBD) : AppColors.textSecondary),
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_drop_down, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : null),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.tajawal(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primary),
        helperText: helperText,
      ),
    );
  }

  Widget _buildDayChip(String label, int value) {
    final isSelected = _selectedDays.contains(value);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          if (selected) {
            _selectedDays.add(value);
          } else {
            _selectedDays.remove(value);
          }
        });
      },
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.textPrimary),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : (isDark ? const Color(0xFF333333) : Colors.grey.shade300),
        ),
      ),
    );
  }
}

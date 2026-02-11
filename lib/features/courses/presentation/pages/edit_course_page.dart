import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/models/course.dart';
import '../bloc/course_bloc.dart';

class EditCoursePage extends StatefulWidget {
  final Course course;
  const EditCoursePage({super.key, required this.course});

  @override
  State<EditCoursePage> createState() => _EditCoursePageState();
}

class _EditCoursePageState extends State<EditCoursePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bookNameController;
  late TextEditingController _teacherNameController;
  late TextEditingController _currentLessonController;
  
  late String _teacherTitle;
  late List<int> _selectedDays;
  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    _bookNameController = TextEditingController(text: widget.course.bookName);
    _teacherNameController = TextEditingController(text: widget.course.teacherName);
    _currentLessonController = TextEditingController(text: widget.course.currentLessonNumber.toString());
    _teacherTitle = widget.course.teacherTitle;
    _selectedDays = List.from(widget.course.scheduleDays);
    _selectedTime = widget.course.reminderTime;
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى اختيار أيام الدرس')),
        );
        return;
      }

      final updatedCourse = widget.course.copyWith(
        bookName: _bookNameController.text,
        teacherName: _teacherNameController.text,
        teacherTitle: _teacherTitle,
        scheduleDays: _selectedDays,
        currentLessonNumber: int.parse(_currentLessonController.text),
        reminderTime: _selectedTime,
      );

      context.read<CourseBloc>().add(UpdateCourseEvent(updatedCourse));
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
            Navigator.pop(context, true);
          } else if (state is CourseFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('تعديل المادة'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.primary,
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
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
                  _buildSectionTitle('رقم الدرس الحالي'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _currentLessonController,
                    label: 'رقم الدرس',
                    icon: Icons.format_list_numbered,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: Builder(
                      builder: (context) {
                        return ElevatedButton(
                          onPressed: () => _submit(context),
                          child: const Text('حفظ التغييرات'),
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
        final initialTime = _selectedTime != null 
            ? TimeOfDay(hour: int.parse(_selectedTime!.split(':')[0]), minute: int.parse(_selectedTime!.split(':')[1]))
            : TimeOfDay.now();
            
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: initialTime,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              _selectedTime ?? 'اختر وقت التنبيه',
              style: GoogleFonts.tajawal(
                color: _selectedTime != null ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_drop_down),
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
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
      ),
    );
  }

  Widget _buildDayChip(String label, int value) {
    final isSelected = _selectedDays.contains(value);
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
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
        ),
      ),
    );
  }
}

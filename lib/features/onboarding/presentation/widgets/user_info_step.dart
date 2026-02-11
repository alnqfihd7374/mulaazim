import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class UserInfoStep extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController secondNameController;
  final TextEditingController surNameController;
  final TextEditingController nicknameController;
  final GlobalKey<FormState> formKey;

  const UserInfoStep({
    super.key,
    required this.firstNameController,
    required this.secondNameController,
    required this.surNameController,
    required this.nicknameController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              'لنتعرف عليك',
              style: GoogleFonts.tajawal(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.brightness == Brightness.light ? AppColors.primary : Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أدخل بياناتك لنخاطبك بها في التطبيق',
              style: GoogleFonts.tajawal(
                fontSize: 16,
                color: theme.brightness == Brightness.light ? AppColors.textSecondary : AppColors.darkTextSecondary,
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              context: context,
              controller: firstNameController,
              label: 'الاسم الأول',
              icon: Icons.person_outline,
              validator: (value) =>
                  value == null || value.isEmpty ? 'الاسم مطلوب' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context: context,
              controller: secondNameController,
              label: 'الاسم الثاني',
              icon: Icons.people_outline,
               validator: (value) =>
                  value == null || value.isEmpty ? 'الاسم الثاني مطلوب' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context: context,
              controller: surNameController,
              label: 'اللقب',
              icon: Icons.badge_outlined,
               validator: (value) =>
                  value == null || value.isEmpty ? 'اللقب مطلوب' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context: context,
              controller: nicknameController,
              label: 'الكنية (اختياري)',
              icon: Icons.star_border,
              helperText: 'سيعرض في الهيدر الرئيسي (مثال: أبو عمر)',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: isDark ? Colors.white70 : AppColors.primary),
        helperText: helperText,
        helperStyle: GoogleFonts.tajawal(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
      ),
      style: GoogleFonts.tajawal(color: isDark ? Colors.white : AppColors.textPrimary),
    );
  }
}

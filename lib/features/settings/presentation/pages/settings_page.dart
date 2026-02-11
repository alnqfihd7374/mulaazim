import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../onboarding/domain/repositories/user_repository.dart';
import '../../../courses/domain/repositories/course_repository.dart';
import '../../../onboarding/data/models/user_model.dart';
import '../../../courses/data/models/course.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';



class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<DashboardBloc>()..add(LoadDashboardData()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('الإعدادات', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
          foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primary,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            UserModel? user;
            if (state is DashboardLoaded) {
              user = state.user;
            }

            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSectionTitle('الملف الشخصي'),
                    const SizedBox(height: 8),
                    if (user != null)
                      _buildSettingTile(
                        title: user.displayName,
                        subtitle: 'تعديل الاسم والكنية',
                        icon: Icons.person_outline,
                        onTap: () => _editProfile(context, user!),
                      ),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('المظهر'),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: Text('الوضع الليلي', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
                      secondary: Icon(Icons.dark_mode_outlined, color: context.watch<ThemeCubit>().state == ThemeMode.dark ? Colors.white : AppColors.primary),
                      value: context.watch<ThemeCubit>().state == ThemeMode.dark,
                      onChanged: (val) {
                        context.read<ThemeCubit>().toggleTheme(val);
                        if (user != null) {
                           context.read<DashboardBloc>().add(UpdateUserProfile(user.copyWith(isDarkMode: val)));
                        }
                      },
                    ),

                    const SizedBox(height: 24),
                    _buildSectionTitle('البيانات النسخ الاحتياطي'),
                    const SizedBox(height: 8),
                    _buildSettingTile(
                      title: 'تعديل مادة',
                      subtitle: 'تعديل بيانات الدروس المضافة',
                      icon: Icons.edit_calendar,
                      onTap: () {
                         // This could navigate to a list to select which course to edit
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ننتقل للرئيسية ونختار المادة للتعديل')));
                      },
                    ),
                    _buildSettingTile(
                      title: 'تصدير البيانات',
                      subtitle: 'حفظ نسخة احتياطية من جميع بياناتك',
                      icon: Icons.upload_file,
                      onTap: _exportData,
                    ),
                    _buildSettingTile(
                      title: 'استيراد البيانات',
                      subtitle: 'استعادة بيانات من نسخة سابقة',
                      icon: Icons.download,
                      onTap: _importData,
                    ),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('إدارة التطبيق'),
                    const SizedBox(height: 8),
                    _buildSettingTile(
                      title: 'حذف جميع البيانات',
                      subtitle: 'إعادة التطبيق لحالته الأصلية (حذر!)',
                      icon: Icons.delete_forever,
                      iconColor: Colors.red,
                      onTap: _clearAllData,
                    ),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('عن التطبيق'),
                    const SizedBox(height: 8),
                    _buildSettingTile(
                      title: 'حول "مُلازم"',
                      subtitle: 'الإصدار 1.0.0 (تجريبي)',
                      icon: Icons.info_outline,
                      onTap: _showAboutDialog,
                    ),
                    _buildSettingTile(
                      title: 'تواصل مع المطور',
                      subtitle: 'اقتراحات ومميزات جديدة',
                      icon: Icons.chat_outlined,

                      iconColor: Colors.green,
                      onTap: _contactDev,
                    ),
                  ],
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black45,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _editProfile(BuildContext context, UserModel user) {
    final firstNameController = TextEditingController(text: user.firstName);
    final secondNameController = TextEditingController(text: user.secondName);
    final surNameController = TextEditingController(text: user.surName);
    final nicknameController = TextEditingController(text: user.nickname);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تعديل الملف الشخصي', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: firstNameController, decoration: const InputDecoration(labelText: 'الاسم الأول')),
              const SizedBox(height: 12),
              TextField(controller: secondNameController, decoration: const InputDecoration(labelText: 'الاسم الثاني')),
              const SizedBox(height: 12),
              TextField(controller: surNameController, decoration: const InputDecoration(labelText: 'اللقب')),
              const SizedBox(height: 12),
              TextField(controller: nicknameController, decoration: const InputDecoration(labelText: 'الكنية')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final updated = user.copyWith(
                firstName: firstNameController.text,
                secondName: secondNameController.text,
                surName: surNameController.text,
                nickname: nicknameController.text,
              );
              context.read<DashboardBloc>().add(UpdateUserProfile(updated));
              Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('حول "مُلازم"', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Text(
            'الحمد لله والصلاة والسلام على رسول الله، وعلى آله وصحبه ومن والاه، أما بعد:\n'
            'فإنَّ العلمَ لا يُنالُ إلا بالملازمة، ولا يُضبطُ إلا بالتقييد، وإنَّ من أعظمِ آفاتِ الطلبِ في هذا الزمانِ تشتتَ الذهنِ وضياعَ الأوقات، وانقطاعَ حبلِ الدروسِ بالغيباتِ التي لا تُستدرك.\n'
            'ومن هنا نشأت فكرة تطبيق "مُلازم"؛ ليكونَ مِعواناً لطالبِ العلمِ في ضبطِ مَجالسه، وتقييدِ حُضورهِ وغيابه، وسدِّ خَللِ ما فاته من فوائد.\n\n'
            'مقاصد التطبيق:\n'
            '• المواظبة: حثُّ النفسِ على شهودِ حلقِ العلمِ وعدمِ الانقطاع.\n'
            '• الاستدراك: تذكيرُ الطالبِ بما فاته من دروسٍ ليسمعَها صوتاً، فلا يذهبُ عليه اتصالُ الكتابِ المشروح.\n'
            '• التقييد: حفظُ أرقامِ الدروسِ وتواريخِها، وتدوينُ ما يفتحُ الله به من فرائدِ الفوائد.\n\n'
            'نرجو أن يكون هذا العملُ خالصاً لوجهِ الله الكريم، نافعاً لإخواننا من طلبةِ العلمِ في الآفاق، ومعيناً لهم على تحصيلِ العلمِ على جادّةِ السلفِ الصالحِ رضي الله عنهم.\n'
            'قُيّد لمصلحةِ طلبةِ العلم\n'
            '(الإصدار الأول التجريبي)',
            style: GoogleFonts.tajawal(fontSize: 14, height: 1.6),
            textAlign: TextAlign.right,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
        ],
      ),
    );
  }

  void _contactDev() async {
    const url = "https://wa.me/967773687374";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFBDBDBD) : AppColors.textSecondary,
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveIconColor = iconColor ?? (isDark ? Colors.white : AppColors.primary);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: effectiveIconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: effectiveIconColor),
        ),
        title: Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: GoogleFonts.tajawal(fontSize: 12)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).brightness == Brightness.dark ? Colors.white38 : Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Future<void> _exportData() async {
    setState(() => _isLoading = true);
    try {
      final userRepository = sl<UserRepository>();
      final courseRepository = sl<CourseRepository>();

      final userResult = await userRepository.getUser();
      final coursesResult = await courseRepository.getCourses();

      Map<String, dynamic> exportData = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'user': null,
        'courses': [],
      };

      userResult.fold((l) {}, (user) {
         if (user != null) {
           exportData['user'] = {
             'firstName': user.firstName,
             'secondName': user.secondName,
             'surName': user.surName,
             'nickname': user.nickname,
             'isDarkMode': user.isDarkMode,
           };
         }
      });

      coursesResult.fold((l) {}, (courses) {
        exportData['courses'] = courses.map((c) => {
          'id': c.id,
          'bookName': c.bookName,
          'teacherName': c.teacherName,
          'teacherTitle': c.teacherTitle,
          'scheduleDays': c.scheduleDays,
          'currentLessonNumber': c.currentLessonNumber,
          'lastCheckInDate': c.lastCheckInDate?.toIso8601String(),
          'reminderTime': c.reminderTime,
          'notes': c.notes.map((n) => {
            'content': n.content, 
            'lesson': n.lessonNumber, 
            'date': n.createdAt.toIso8601String()
          }).toList(),
          'pending': c.pendingLessons.map((p) => {
            'num': p.lessonNumber, 
            'heard': p.isHeard, 
            'date': p.missedDate.toIso8601String(),
            'reason': p.reason,
          }).toList(),
        }).toList();
      });

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final backupDir = Directory('${directory!.path}/Mulaazim_Backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final fileName = 'mulaazim_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${backupDir.path}/$fileName');
      await file.writeAsString(jsonEncode(exportData));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حفظ النسخة الاحتياطية في: ${file.path}'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'مشاركة',
              onPressed: () => Share.shareXFiles([XFile(file.path)], text: 'نسخة احتياطية من تطبيق ملازم'),
            ),
          ),
        );
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل التصدير: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importData() async {
     final result = await FilePicker.platform.pickFiles(
       type: FileType.custom,
       allowedExtensions: ['json'],
     );

     if (result != null) {
       setState(() => _isLoading = true);
       try {
         final file = File(result.files.single.path!);
         final jsonString = await file.readAsString();
         final data = jsonDecode(jsonString);
         
         if (data['version'] != 1) {
            throw Exception('نسخة غير متوافقة');
         }
         
         if (data['user'] != null) {
            final u = data['user'];
            final userModel = UserModel(
               firstName: u['firstName'],
               secondName: u['secondName'],
               nickname: u['nickname'],
               isDarkMode: u['isDarkMode'] ?? false,
            );
            await sl<UserRepository>().saveUser(userModel);
         }
         
         if (data['courses'] != null) {
            final courses = data['courses'] as List;
            for (var c in courses) {
               final course = Course(
                  id: c['id'],
                  bookName: c['bookName'],
                  teacherName: c['teacherName'],
                  teacherTitle: c['teacherTitle'],
                  scheduleDays: List<int>.from(c['scheduleDays']),
                  currentLessonNumber: c['currentLessonNumber'],
                  lastCheckInDate: c['lastCheckInDate'] != null ? DateTime.parse(c['lastCheckInDate']) : null,
                  reminderTime: c['reminderTime'],
                  // Mapping notes and pending would be done here for full restore
               );
               await sl<CourseRepository>().addCourse(course);
            }
         }

         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الاستيراد بنجاح')));
         if (context.mounted) Navigator.pop(context);
        
       } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الاستيراد: $e')));
       } finally {
         setState(() => _isLoading = false);
       }
     }
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('هل أنت متأكد؟'),
        content: const Text('سيتم حذف جميع البيانات ولا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      
      final userResult = await sl<UserRepository>().clearUser();
      final coursesResult = await sl<CourseRepository>().clearCourses();
      
      setState(() => _isLoading = false);
      
      if (context.mounted) {
         if (userResult.isRight() && coursesResult.isRight()) {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
         } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل حذف بعض البيانات')));
         }
      }
    }
  }
}

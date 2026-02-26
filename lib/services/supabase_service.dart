import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // تسجيل الدخول الموحد والتحقق من الدور
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      // 1. التحقق من جدول الطلاب
      final studentResponse = await client
          .from('student')
          .select()
          .eq('stud_username', username)
          .eq('stud_password', password)
          .maybeSingle();
      
      if (studentResponse != null) {
        return {
          'role': 'student',
          'user': Student.fromJson(studentResponse),
        };
      }

      // 2. التحقق من جدول المشرفين
      final supervisorResponse = await client
          .from('supervisor')
          .select()
          .eq('sprvsr_username', username)
          .eq('sprvsr_password', password)
          .maybeSingle();
      
      if (supervisorResponse != null) {
        return {
          'role': 'supervisor',
          'user': Supervisor.fromJson(supervisorResponse),
        };
      }

      // يمكن إضافة باقي الأدوار هنا (عميد، رئيس قسم، إلخ) بنفس الطريقة
      
      return null;
    } catch (e) {
      print('Login Error: $e');
      return null;
    }
  }

  // جلب المجموعات المرتبطة بمشرف معين
  static Future<List<ResearchGroup>> getGroupsBySupervisor(int supervisorId) async {
    try {
      final response = await client
          .from('groups')
          .select()
          .eq('id_sprvsr', supervisorId);
      
      return (response as List).map((json) => ResearchGroup.fromJson(json)).toList();
    } catch (e) {
      print('Fetch Groups Error: $e');
      return [];
    }
  }

  // جلب بيانات المجموعة لطالب معين
  static Future<ResearchGroup?> getGroupByStudent(int studentId) async {
    try {
      // هذا الاستعلام يفترض وجود علاقة في قاعدة البيانات بين الطالب والمجموعة
      final response = await client
          .from('groups')
          .select()
          .filter('id_stud1', 'eq', studentId) // أو id_stud2, id_stud3 حسب المخطط
          .maybeSingle();
      
      if (response == null) return null;
      return ResearchGroup.fromJson(response);
    } catch (e) {
      print('Fetch Student Group Error: $e');
      return null;
    }
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // تسجيل الدخول الموحد والتحقق من الدور
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      // 1. التحقق من جدول الطلاب
      // ملاحظة: في قاعدة البيانات الحالية، يبدو أن تسجيل دخول الطالب يعتمد على البريد الإلكتروني أو رقم الكلية
      // سنحاول المطابقة مع البريد الإلكتروني أو الاسم حالياً بناءً على البيانات المتاحة
      final studentResponse = await client
          .from('student')
          .select()
          .or('stud_email.eq.$username,stud_name.eq.$username')
          .eq('stud_pass', password)
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
          .or('sprvsr_email.eq.$username,sprvsr_username.eq.$username')
          .eq('sprvsr_pass', password)
          .maybeSingle();
      
      if (supervisorResponse != null) {
        return {
          'role': 'supervisor',
          'user': Supervisor.fromJson(supervisorResponse),
        };
      }

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
      final response = await client
          .from('groups')
          .select()
          .or('id_stud1.eq.$studentId,id_stud2.eq.$studentId,id_stud3.eq.$studentId')
          .maybeSingle();
      
      if (response == null) return null;
      return ResearchGroup.fromJson(response);
    } catch (e) {
      print('Fetch Student Group Error: $e');
      return null;
    }
  }
}

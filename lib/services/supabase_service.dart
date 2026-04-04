import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseService {
  static final client = Supabase.instance.client;

  // تسجيل دخول المشرف
  static Future<Map<String, dynamic>?> loginSupervisor(
      String username, String password) async {
    try {
      // محاولة تسجيل الدخول باستخدام اسم المستخدم أو البريد الإلكتروني
      final response = await client
          .from('supervisor')
          .select()
          .or('sprvsr_username.eq.$username,sprvsr_email.eq.$username')
          .eq('sprvsr_password', password)
          .maybeSingle();

      if (response != null) {
        return {
          'user': Supervisor.fromJson(response),
          'role': 'supervisor',
        };
      }
      return null;
    } catch (e) {
      print('Error logging in supervisor: $e');
      return null;
    }
  }

  // جلب المجموعات التابعة للمشرف
  static Future<List<ResearchGroup>> getGroupsBySupervisor(int supervisorId) async {
    try {
      final response = await client
          .from('groups')
          .select()
          .eq('id_sprvsr', supervisorId);

      return (response as List)
          .map((json) => ResearchGroup.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching groups: $e');
      return [];
    }
  }

  // جلب بيانات المشرف بواسطة المعرف
  static Future<Supervisor?> getSupervisorById(int id) async {
    try {
      final response = await client
          .from('supervisor')
          .select()
          .eq('sprvsr_id', id)
          .maybeSingle();

      if (response != null) {
        return Supervisor.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error fetching supervisor: $e');
      return null;
    }
  }

  // جلب بيانات البرنامج بواسطة المعرف
  static Future<Program?> getProgramById(int id) async {
    try {
      final response = await client
          .from('program')
          .select()
          .eq('program_id', id)
          .maybeSingle();

      if (response != null) {
        return Program.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error fetching program: $e');
      return null;
    }
  }

  // جلب بيانات القسم بواسطة المعرف
  static Future<Department?> getDepartmentById(int id) async {
    try {
      final response = await client
          .from('department')
          .select()
          .eq('dep_id', id)
          .maybeSingle();

      if (response != null) {
        return Department.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error fetching department: $e');
      return null;
    }
  }

  // تحديث حالة المجموعة
  static Future<bool> updateGroupStatus(int groupId, String status) async {
    try {
      await client
          .from('groups')
          .update({'group_status': status})
          .eq('group_id', groupId);
      return true;
    } catch (e) {
      print('Error updating group status: $e');
      return false;
    }
  }

  // إضافة تعليق مراجعة
  static Future<bool> addReviewComment(ReviewComment comment) async {
    try {
      await client.from('review_comments').insert(comment.toJson());
      return true;
    } catch (e) {
      print('Error adding review comment: $e');
      return false;
    }
  }

  // تحديث تعليق مراجعة
  static Future<bool> updateReviewComment(ReviewComment comment) async {
    try {
      if (comment.id == null) return false;
      await client
          .from('review_comments')
          .update(comment.toJson())
          .eq('comment_id', comment.id!);
      return true;
    } catch (e) {
      print('Error updating review comment: $e');
      return false;
    }
  }

  // إرسال إشعار
  static Future<bool> sendNotification(Notification notification) async {
    try {
      await client.from('notifications').insert(notification.toJson());
      return true;
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }
}

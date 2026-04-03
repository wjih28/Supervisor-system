import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // تسجيل الدخول للمشرف فقط
  static Future<Map<String, dynamic>?> loginSupervisor(
      String username, String password) async {
    try {
      final trimmedUsername = username.trim();
      print(
          'Attempting supervisor login for username: $trimmedUsername (original: $username) with password: $password');

      final supervisorResponse = await client
          .from('supervisor')
          .select()
          .or('sprvsr_email.eq.$trimmedUsername,sprvsr_username.eq.$trimmedUsername')
          .eq('sprvsr_password', password) // تم تصحيح اسم العمود هنا
          .maybeSingle();

      if (supervisorResponse != null) {
        print(
            'Supervisor login successful: ${supervisorResponse["sprvsr_name"]}');
        return {
          'role': 'supervisor',
          'user': Supervisor.fromJson(supervisorResponse),
        };
      }
      print(
          'Supervisor login failed for username: $trimmedUsername. Response: $supervisorResponse');

      print('Login failed: Invalid username or password for supervisor.');
      return null;
    } catch (e) {
      print('Login Error in SupabaseService: $e');
      return null;
    }
  }

  // جلب المجموعات المرتبطة بمشرف معين
  static Future<List<ResearchGroup>> getGroupsBySupervisor(
      int supervisorId) async {
    try {
      final response =
          await client.from('groups').select().eq('id_sprvsr', supervisorId);

      return (response as List)
          .map((json) => ResearchGroup.fromJson(json))
          .toList();
    } catch (e) {
      print('Fetch Groups Error: $e');
      return [];
    }
  }

  // جلب تفاصيل مجموعة معينة (بواسطة projectId)
  static Future<ResearchGroup?> getProjectById(int projectId) async {
    try {
      final response = await client
          .from('groups')
          .select()
          .eq('group_id', projectId)
          .maybeSingle();

      if (response == null) return null;
      return ResearchGroup.fromJson(response);
    } catch (e) {
      print('Fetch Project By Id Error: $e');
      return null;
    }
  }

  // جلب الطلاب في مجموعة معينة
  static Future<List<Student>> getGroupStudents(int groupId) async {
    try {
      final response =
          await client.from('student').select().eq('id_group', groupId);

      return (response as List).map((json) => Student.fromJson(json)).toList();
    } catch (e) {
      print('Fetch Group Students Error: $e');
      return [];
    }
  }

  // جلب الملاحظات لمشروع معين (ProjectFeedback)
  static Future<List<ProjectFeedback>> getProjectFeedback(int projectId) async {
    try {
      final response = await client
          .from('review_comments')
          .select('*, supervisor(sprvsr_name)')
          .eq('id_group', projectId);

      return (response as List).map((json) {
        final supervisorName = json['supervisor']?['sprvsr_name'];
        return ProjectFeedback.fromJson({
          ...json,
          'supervisor_name': supervisorName,
        });
      }).toList();
    } catch (e) {
      print('Fetch Project Feedback Error: $e');
      return [];
    }
  }

  static Future<bool> addProjectFeedback(
      int projectId, int supervisorId, String stage, String comment) async {
    try {
      await client.from('review_comments').insert({
        'id_group': projectId,
        'id_sprvsr': supervisorId,
        'comment_text': comment,
        'comment_stage': stage,
        'is_resolved': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Add Project Feedback Error: $e');
      return false;
    }
  }

  static Future<bool> resolveFeedback(int feedbackId) async {
    try {
      await client.from('review_comments').update({
        'is_resolved': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('comment_id', feedbackId);
      return true;
    } catch (e) {
      print('Resolve Feedback Error: $e');
      return false;
    }
  }

  // تحديث حالة المجموعة (Group Status)
  static Future<bool> updateGroupStatus(
      int groupId, String status, double progress) async {
    try {
      await client.from('groups').update({
        'group_status': status,
        'group_progress': progress,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('group_id', groupId);
      return true;
    } catch (e) {
      print('Update Group Status Error: $e');
      return false;
    }
  }

  // تحديث مرحلة المشروع (Project Stage)
  static Future<bool> updateProjectStage(int projectId, String stage) async {
    try {
      await client
          .from('groups') // Assuming currentStage is part of the groups table
          .update({
        'current_stage':
            stage, // Assuming a column named 'current_stage' exists in 'groups'
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('group_id', projectId);
      return true;
    } catch (e) {
      print('Update Project Stage Error: $e');
      return false;
    }
  }

  // جلب تفاصيل مجموعة معينة
  static Future<ResearchGroup?> getGroupDetails(int groupId) async {
    try {
      final response = await client
          .from('groups')
          .select()
          .eq('group_id', groupId)
          .maybeSingle();

      if (response == null) return null;
      return ResearchGroup.fromJson(response);
    } catch (e) {
      print('Fetch Group Details Error: $e');
      return null;
    }
  }

  // جلب الملفات المرفوعة لمجموعة
  static Future<List<ResearchFile>> getFilesByGroup(int groupId) async {
    try {
      final response =
          await client.from('research_files').select().eq('id_group', groupId);

      return (response as List)
          .map((json) => ResearchFile.fromJson(json))
          .toList();
    } catch (e) {
      print('Fetch Files By Group Error: $e');
      return [];
    }
  }

  // جلب الملفات حسب المرحلة
  static Future<List<ResearchFile>> getFilesByStage(
      int groupId, String stage) async {
    try {
      final response = await client
          .from('research_files')
          .select()
          .eq('id_group', groupId)
          .eq('file_stage', stage);

      return (response as List)
          .map((json) => ResearchFile.fromJson(json))
          .toList();
    } catch (e) {
      print('Fetch Files By Stage Error: $e');
      return [];
    }
  }

  // تحميل ملف جديد
  static Future<bool> uploadFile(ResearchFile file) async {
    try {
      await client.from('research_files').insert(file.toJson());
      return true;
    } catch (e) {
      print('Upload File Error: $e');
      return false;
    }
  }

  // جلب الملاحظات لمجموعة معينة
  static Future<List<ReviewComment>> getCommentsByGroup(int groupId) async {
    try {
      final response =
          await client.from('review_comments').select().eq('id_group', groupId);

      return (response as List)
          .map((json) => ReviewComment.fromJson(json))
          .toList();
    } catch (e) {
      print('Fetch Comments By Group Error: $e');
      return [];
    }
  }

  // إضافة ملاحظة جديدة
  static Future<bool> addComment(ReviewComment comment) async {
    try {
      await client.from('review_comments').insert(comment.toJson());
      return true;
    } catch (e) {
      print('Add Comment Error: $e');
      return false;
    }
  }

  // تحديث ملاحظة موجودة
  static Future<bool> updateComment(
      int commentId, ReviewComment comment) async {
    try {
      await client
          .from('review_comments')
          .update(comment.toJson())
          .eq('comment_id', commentId);
      return true;
    } catch (e) {
      print('Update Comment Error: $e');
      return false;
    }
  }

  // حذف ملاحظة
  static Future<bool> deleteComment(int commentId) async {
    try {
      await client.from('review_comments').delete().eq('comment_id', commentId);
      return true;
    } catch (e) {
      print('Delete Comment Error: $e');
      return false;
    }
  }

  // جلب مراحل المشروع لمجموعة معينة
  static Future<List<ProjectStage>> getProjectStages(int groupId) async {
    try {
      final response =
          await client.from('project_stages').select().eq('id_group', groupId);

      return (response as List)
          .map((json) => ProjectStage.fromJson(json))
          .toList();
    } catch (e) {
      print('Fetch Project Stages Error: $e');
      return [];
    }
  }

  // تحديث حالة المرحلة
  static Future<bool> updateStageStatus(
      int stageId, String status, double completionPercentage) async {
    try {
      await client.from('project_stages').update({
        'stage_status': status,
        'completion_percentage': completionPercentage,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('stage_id', stageId);
      return true;
    } catch (e) {
      print('Update Stage Status Error: $e');
      return false;
    }
  }

  // جلب الإشعارات لمشرف معين
  static Future<List<Notification>> getNotificationsBySupervisor(
      int supervisorId) async {
    try {
      final response = await client
          .from('notifications')
          .select()
          .eq('id_sprvsr', supervisorId);

      return (response as List)
          .map((json) => Notification.fromJson(json))
          .toList();
    } catch (e) {
      print('Fetch Notifications Error: $e');
      return [];
    }
  }

  // إضافة إشعار جديد
  static Future<bool> addNotification(Notification notification) async {
    try {
      await client.from('notifications').insert(notification.toJson());
      return true;
    } catch (e) {
      print('Add Notification Error: $e');
      return false;
    }
  }

  // تحديث حالة الإشعار (مقروء/غير مقروء)
  static Future<bool> updateNotificationStatus(int notificationId, bool isRead) async {
    try {
      await client.from('notifications').update({
        'is_read': isRead,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('notification_id', notificationId);
      return true;
    } catch (e) {
      print('Update Notification Status Error: $e');
      return false;
    }
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // تسجيل الدخول الموحد والتحقق من الدور
  static Future<Map<String, dynamic>?> login(
      String username, String password) async {
    try {
      // Normalize username input by trimming whitespace
      final trimmedUsername = username.trim();
      print(
          'Attempting login for username: $trimmedUsername (original: $username) with password: $password');

      // 1. التحقق من جدول الطلاب
      print('Checking student table...');
      final studentResponse = await client
          .from('student')
          .select()
          .or('stud_email.eq.$trimmedUsername,stud_name.eq.$trimmedUsername')
          .eq('stud_pass', password)
          .maybeSingle();

      if (studentResponse != null) {
        print('Student login successful: ${studentResponse["stud_name"]}');
        return {
          'role': 'student',
          'user': Student.fromJson(studentResponse),
        };
      }
      print(
          'Student login failed for username: $trimmedUsername. Response: $studentResponse');

      // 2. التحقق من جدول المشرفين
      print('Checking supervisor table...');
      final supervisorResponse = await client
          .from('supervisor')
          .select()
          .or('sprvsr_email.eq.$trimmedUsername,sprvsr_username.eq.$trimmedUsername')
          .eq('sprvsr_pass', password)
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

      print(
          'Login failed: Invalid username or password for both student and supervisor.');
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

  // تحديث حالة المشروع (Group Status)
  static Future<bool> updateProjectStatus(int projectId, String status) async {
    try {
      await client.from('groups').update({
        'group_status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('group_id', projectId);
      return true;
    } catch (e) {
      print('Update Project Status Error: $e');
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

  // تحديث حالة المجموعة
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
        'is_completed': (completionPercentage == 1.0),
      }).eq('stage_id', stageId);
      return true;
    } catch (e) {
      print('Update Stage Status Error: $e');
      return false;
    }
  }

  // جلب الإشعارات لمشرف معين
  static Future<List<Notification>> getNotifications(int supervisorId,
      {bool unreadOnly = false}) async {
    try {
      var query =
          client.from('notifications').select().eq('id_sprvsr', supervisorId);

      if (unreadOnly) {
        query = query.eq('is_read', false);
      }

      final response = await query;
      return (response as List)
          .map((json) => Notification.fromJson(json))
          .toList();
    } catch (e) {
      print('Fetch Notifications Error: $e');
      return [];
    }
  }

  // تحديد الإشعار كمقروء
  static Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      await client
          .from('notifications')
          .update({'is_read': true}).eq('notification_id', notificationId);
      return true;
    } catch (e) {
      print('Mark Notification As Read Error: $e');
      return false;
    }
  }

  // إنشاء إشعار جديد
  static Future<bool> createNotification(Notification notification) async {
    try {
      await client.from('notifications').insert(notification.toJson());
      return true;
    } catch (e) {
      print('Create Notification Error: $e');
      return false;
    }
  }

  // جلب بيانات المشرف
  static Future<Supervisor?> getSupervisorById(int supervisorId) async {
    try {
      final response = await client
          .from('supervisor')
          .select()
          .eq('sprvsr_id', supervisorId)
          .maybeSingle();
      if (response == null) return null;
      return Supervisor.fromJson(response);
    } catch (e) {
      print('Get Supervisor By Id Error: $e');
      return null;
    }
  }

  // جلب بيانات البرنامج
  static Future<Program?> getProgramById(int programId) async {
    try {
      final response = await client
          .from('programs')
          .select()
          .eq('program_id', programId)
          .maybeSingle();
      if (response == null) return null;
      return Program.fromJson(response);
    } catch (e) {
      print('Get Program By Id Error: $e');
      return null;
    }
  }

  // جلب بيانات القسم
  static Future<Department?> getDepartmentById(int departmentId) async {
    try {
      final response = await client
          .from('departments')
          .select()
          .eq('department_id', departmentId)
          .maybeSingle();
      if (response == null) return null;
      return Department.fromJson(response);
    } catch (e) {
      print('Get Department By Id Error: $e');
      return null;
    }
  }

  // جلب إحصائيات المشرف
  static Future<Map<String, dynamic>?> getSupervisorStatistics(
      int supervisorId) async {
    try {
      // هذا يتطلب استعلامات معقدة أو دوال في Supabase
      // حالياً، سنقوم بتقديم بيانات وهمية أو حسابات بسيطة
      final groups = await getGroupsBySupervisor(supervisorId);
      final totalGroups = groups.length;
      final completedGroups =
          groups.where((g) => g.status == 'completed').length;
      final inProgressGroups =
          groups.where((g) => g.status == 'in_progress').length;
      final delayedGroups = groups.where((g) => g.status == 'delayed').length;
      final averageProgress = groups.isNotEmpty
          ? groups.map((g) => g.progress ?? 0.0).reduce((a, b) => a + b) /
              totalGroups
          : 0.0;
      final completionRate =
          totalGroups > 0 ? (completedGroups / totalGroups) : 0.0;

      return {
        'totalGroups': totalGroups,
        'completedGroups': completedGroups,
        'inProgressGroups': inProgressGroups,
        'delayedGroups': delayedGroups,
        'averageProgress': averageProgress,
        'completionRate': completionRate,
      };
    } catch (e) {
      print('Get Supervisor Statistics Error: $e');
      return null;
    }
  }

  // البحث عن مجموعات
  static Future<List<ResearchGroup>> searchGroups(
      int supervisorId, String searchTerm) async {
    try {
      final response = await client
          .from('groups')
          .select()
          .eq('id_sprvsr', supervisorId)
          .ilike('group_name', '%$searchTerm%');

      return (response as List)
          .map((json) => ResearchGroup.fromJson(json))
          .toList();
    } catch (e) {
      print('Search Groups Error: $e');
      return [];
    }
  }

  // تصفية المجموعات حسب الحالة
  static Future<List<ResearchGroup>> filterGroupsByStatus(
      int supervisorId, String status) async {
    try {
      var query = client.from('groups').select().eq('id_sprvsr', supervisorId);

      if (status != 'all') {
        query = query.eq('group_status', status);
      }

      final response = await query;
      return (response as List)
          .map((json) => ResearchGroup.fromJson(json))
          .toList();
    } catch (e) {
      print('Filter Groups By Status Error: $e');
      return [];
    }
  }

  // جلب ملفات المشروع حسب المرحلة
  static Future<List<ProjectFile>> getProjectFiles(int projectId,
      {String? stage}) async {
    try {
      var query =
          client.from('project_files').select().eq('project_id', projectId);

      if (stage != null) {
        query = query.eq('file_stage', stage);
      }

      final response = await query;
      return (response as List)
          .map((item) => ProjectFile.fromJson(item))
          .toList();
    } catch (e) {
      print('Get Project Files Error: $e');
      return [];
    }
  }

  // إضافة ملاحظة من المشرف
  static Future<bool> addSupervisorNote(int fileId, String note) async {
    try {
      await client.from('supervisor_notes').insert({
        'file_id': fileId,
        'note_text': note,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Add Supervisor Note Error: $e');
      return false;
    }
  }
}

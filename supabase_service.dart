import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // ============ المصادقة والتحقق ============

  /// تسجيل الدخول الموحد والتحقق من الدور
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

  // ============ وظائف المجموعات والمشاريع ============

  /// جلب المجموعات المرتبطة بمشرف معين
  static Future<List<ResearchGroup>> getGroupsBySupervisor(int supervisorId) async {
    try {
      final response = await client
          .from('groups')
          .select()
          .eq('id_sprvsr', supervisorId)
          .order('updated_at', ascending: false);
      
      return (response as List).map((json) => ResearchGroup.fromJson(json)).toList();
    } catch (e) {
      print('Fetch Groups Error: $e');
      return [];
    }
  }

  /// جلب بيانات المجموعة لطالب معين
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

  /// جلب تفاصيل مجموعة معينة
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

  // ============ وظائف الملفات ============

  /// جلب الملفات المرفوعة لمجموعة معينة
  static Future<List<ResearchFile>> getFilesByGroup(int groupId) async {
    try {
      final response = await client
          .from('research_files')
          .select()
          .eq('id_group', groupId)
          .order('uploaded_at', ascending: false);
      
      return (response as List).map((json) => ResearchFile.fromJson(json)).toList();
    } catch (e) {
      print('Fetch Files Error: $e');
      return [];
    }
  }

  /// جلب الملفات حسب المرحلة
  static Future<List<ResearchFile>> getFilesByStage(int groupId, String stage) async {
    try {
      final response = await client
          .from('research_files')
          .select()
          .eq('id_group', groupId)
          .eq('file_stage', stage)
          .order('uploaded_at', ascending: false);
      
      return (response as List).map((json) => ResearchFile.fromJson(json)).toList();
    } catch (e) {
      print('Fetch Files By Stage Error: $e');
      return [];
    }
  }

  /// تحميل ملف جديد
  static Future<bool> uploadFile(ResearchFile file) async {
    try {
      await client
          .from('research_files')
          .insert(file.toJson());
      return true;
    } catch (e) {
      print('Upload File Error: $e');
      return false;
    }
  }

  // ============ وظائف الملاحظات والتقييمات ============

  /// جلب الملاحظات لمجموعة معينة
  static Future<List<ReviewComment>> getCommentsByGroup(int groupId) async {
    try {
      final response = await client
          .from('review_comments')
          .select()
          .eq('id_group', groupId)
          .order('created_at', ascending: false);
      
      return (response as List).map((json) => ReviewComment.fromJson(json)).toList();
    } catch (e) {
      print('Fetch Comments Error: $e');
      return [];
    }
  }

  /// إضافة ملاحظة جديدة
  static Future<bool> addComment(ReviewComment comment) async {
    try {
      await client
          .from('review_comments')
          .insert(comment.toJson());
      return true;
    } catch (e) {
      print('Add Comment Error: $e');
      return false;
    }
  }

  /// تحديث ملاحظة موجودة
  static Future<bool> updateComment(int commentId, ReviewComment comment) async {
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

  /// حذف ملاحظة
  static Future<bool> deleteComment(int commentId) async {
    try {
      await client
          .from('review_comments')
          .delete()
          .eq('comment_id', commentId);
      return true;
    } catch (e) {
      print('Delete Comment Error: $e');
      return false;
    }
  }

  // ============ وظائف المراحل والحالات ============

  /// جلب مراحل المشروع
  static Future<List<ProjectStage>> getProjectStages(int groupId) async {
    try {
      final response = await client
          .from('project_stages')
          .select()
          .eq('id_group', groupId)
          .order('start_date', ascending: true);
      
      return (response as List).map((json) => ProjectStage.fromJson(json)).toList();
    } catch (e) {
      print('Fetch Project Stages Error: $e');
      return [];
    }
  }

  /// تحديث حالة المرحلة
  static Future<bool> updateStageStatus(int stageId, String status, double completionPercentage) async {
    try {
      await client
          .from('project_stages')
          .update({
            'stage_status': status,
            'completion_percentage': completionPercentage,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('stage_id', stageId);
      return true;
    } catch (e) {
      print('Update Stage Status Error: $e');
      return false;
    }
  }

  /// تحديث حالة المجموعة
  static Future<bool> updateGroupStatus(int groupId, String status, double progress) async {
    try {
      await client
          .from('groups')
          .update({
            'group_status': status,
            'group_progress': progress,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('group_id', groupId);
      return true;
    } catch (e) {
      print('Update Group Status Error: $e');
      return false;
    }
  }

  // ============ وظائف الإشعارات ============

  /// جلب الإشعارات للمشرف
  static Future<List<Notification>> getNotifications(int supervisorId, {bool unreadOnly = false}) async {
    try {
      var query = client
          .from('notifications')
          .select()
          .eq('id_sprvsr', supervisorId)
          .order('created_at', ascending: false);
      
      if (unreadOnly) {
        query = query.eq('is_read', false);
      }
      
      final response = await query;
      return (response as List).map((json) => Notification.fromJson(json)).toList();
    } catch (e) {
      print('Fetch Notifications Error: $e');
      return [];
    }
  }

  /// تحديد الإشعار كمقروء
  static Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      await client
          .from('notifications')
          .update({'is_read': true})
          .eq('notification_id', notificationId);
      return true;
    } catch (e) {
      print('Mark Notification As Read Error: $e');
      return false;
    }
  }

  /// إنشاء إشعار جديد
  static Future<bool> createNotification(Notification notification) async {
    try {
      await client
          .from('notifications')
          .insert(notification.toJson());
      return true;
    } catch (e) {
      print('Create Notification Error: $e');
      return false;
    }
  }

  // ============ وظائف الإحصائيات والتقارير ============

  /// جلب إحصائيات المشرف
  static Future<Map<String, dynamic>?> getSupervisorStatistics(int supervisorId) async {
    try {
      final groups = await getGroupsBySupervisor(supervisorId);
      
      int totalGroups = groups.length;
      int completedGroups = groups.where((g) => g.status == 'completed').length;
      int inProgressGroups = groups.where((g) => g.status == 'in_progress').length;
      int delayedGroups = groups.where((g) => g.status == 'delayed').length;
      
      double averageProgress = groups.isEmpty 
          ? 0.0 
          : groups.fold(0.0, (sum, g) => sum + (g.progress ?? 0.0)) / groups.length;
      
      return {
        'totalGroups': totalGroups,
        'completedGroups': completedGroups,
        'inProgressGroups': inProgressGroups,
        'delayedGroups': delayedGroups,
        'averageProgress': averageProgress,
        'completionRate': totalGroups == 0 ? 0.0 : (completedGroups / totalGroups) * 100,
      };
    } catch (e) {
      print('Get Statistics Error: $e');
      return null;
    }
  }

  /// جلب الطلاب في مجموعة معينة
  static Future<List<Student>> getStudentsByGroup(int groupId) async {
    try {
      final response = await client
          .from('student')
          .select()
          .eq('id_group', groupId);
      
      return (response as List).map((json) => Student.fromJson(json)).toList();
    } catch (e) {
      print('Fetch Students By Group Error: $e');
      return [];
    }
  }

  // ============ وظائف البحث والتصفية ============

  /// البحث عن مجموعات
  static Future<List<ResearchGroup>> searchGroups(int supervisorId, String searchTerm) async {
    try {
      final response = await client
          .from('groups')
          .select()
          .eq('id_sprvsr', supervisorId)
          .or('group_name.ilike.%$searchTerm%,group_description.ilike.%$searchTerm%');
      
      return (response as List).map((json) => ResearchGroup.fromJson(json)).toList();
    } catch (e) {
      print('Search Groups Error: $e');
      return [];
    }
  }

  /// تصفية المجموعات حسب الحالة
  static Future<List<ResearchGroup>> filterGroupsByStatus(int supervisorId, String status) async {
    try {
      final response = await client
          .from('groups')
          .select()
          .eq('id_sprvsr', supervisorId)
          .eq('group_status', status)
          .order('updated_at', ascending: false);
      
      return (response as List).map((json) => ResearchGroup.fromJson(json)).toList();
    } catch (e) {
      print('Filter Groups By Status Error: $e');
      return [];
    }
  }
}

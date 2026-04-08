import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseService {
  static final client = Supabase.instance.client;

  // تسجيل دخول المشرف
  static Future<Map<String, dynamic>?> loginSupervisor(
      String username, String password) async {
    try {
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

  // جلب بيانات المشروع بواسطة المعرف
  static Future<ResearchGroup?> getProjectById(int id) async {
    try {
      final response = await client
          .from('groups')
          .select()
          .eq('group_id', id)
          .maybeSingle();

      if (response != null) {
        return ResearchGroup.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error fetching project: $e');
      return null;
    }
  }

  // جلب طلاب مجموعة معينة
  static Future<List<Student>> getGroupStudents(int groupId) async {
    try {
      final response = await client
          .from('student')
          .select()
          .eq('id_group', groupId);

      return (response as List)
          .map((json) => Student.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching group students: $e');
      return [];
    }
  }

  // جلب تعليقات وملاحظات مشروع معين
  static Future<List<ProjectFeedback>> getProjectFeedback(int projectId) async {
    try {
      final response = await client
          .from('review_comments')
          .select()
          .eq('id_group', projectId);

      return (response as List)
          .map((json) => ProjectFeedback.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching project feedback: $e');
      return [];
    }
  }

  // جلب ملفات مشروع معين حسب المرحلة
  static Future<List<ProjectFile>> getProjectFiles(int projectId, {String? stage}) async {
    try {
      var query = client.from('research_files').select().eq('id_group', projectId);
      if (stage != null) {
        query = query.eq('file_stage', stage);
      }
      final response = await query;
      return (response as List)
          .map((json) => ProjectFile.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching project files: $e');
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

  // تحديث حالة المجموعة ونسبة الإنجاز
  static Future<bool> updateGroupStatus(int groupId, String status, double progress) async {
    try {
      await client
          .from('groups')
          .update({
            'group_status': status,
            'group_progress': progress,
          })
          .eq('group_id', groupId);
      return true;
    } catch (e) {
      print('Error updating group status: $e');
      return false;
    }
  }

  // تحديث مرحلة المشروع
  static Future<bool> updateProjectStage(int projectId, String stage) async {
    try {
      await client
          .from('groups')
          .update({'current_stage': stage})
          .eq('group_id', projectId);
      return true;
    } catch (e) {
      print('Error updating project stage: $e');
      return false;
    }
  }

  // إضافة ملاحظة مشرف على ملف
  static Future<bool> addSupervisorNote(int fileId, String note) async {
    try {
      await client
          .from('research_files')
          .update({'supervisor_notes': note})
          .eq('file_id', fileId);
      return true;
    } catch (e) {
      print('Error adding supervisor note: $e');
      return false;
    }
    }

  // إضافة ملاحظة/تعليق مراجعة على المشروع
  static Future<bool> addProjectFeedback(int projectId, int supervisorId, String stage, String comment) async {
    try {
      await client.from('review_comments').insert({
        'id_group': projectId,
        'id_sprvsr': supervisorId,
        'comment_text': comment,
        'comment_stage': stage,
        'is_resolved': false,
      });
      return true;
    } catch (e) {
      print('Error adding project feedback: $e');
      return false;
    }
  }

  // حل ملاحظة/تعليق مراجعة
  static Future<bool> resolveFeedback(int feedbackId) async {
    try {
      await client
          .from('review_comments')
          .update({'is_resolved': true})
          .eq('comment_id', feedbackId);
      return true;
    } catch (e) {
      print('Error resolving feedback: $e');
      return false;
    }
  }

  // إضافة تعليق مراجعة (كائن)
  static Future<bool> addReviewComment(ReviewComment comment) async {
    try {
      await client.from('review_comments').insert(comment.toJson());
      return true;
    } catch (e) {
      print('Error adding review comment: $e');
      return false;
    }
  }

  // تحديث تعليق مراجعة (كائن)
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

  // الدوال المضافة لدعم SupervisorProvider
  static Future<Map<String, dynamic>?> getSupervisorStatistics(int supervisorId) async {
    try {
      // هذه دالة وهمية، يجب استبدالها بمنطق جلب الإحصائيات الفعلي من Supabase
      // قد تحتاج إلى استعلامات معقدة أو دوال في Supabase لإنشاء هذه الإحصائيات
      return {
        'totalProjects': 10,
        'completedProjects': 5,
        'inProgressProjects': 3,
        'pendingProjects': 2,
        'pendingReviews': 4,
      };
    } catch (e) {
      print('Error fetching supervisor statistics: $e');
      return null;
    }
  }

  static Future<List<ReviewComment>> getCommentsByGroup(int groupId) async {
    try {
      final response = await client
          .from('review_comments')
          .select()
          .eq('id_group', groupId);
      return (response as List)
          .map((json) => ReviewComment.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching comments by group: $e');
      return [];
    }
  }

  static Future<List<ProjectFile>> getFilesByGroup(int groupId) async {
    try {
      final response = await client
          .from('research_files')
          .select()
          .eq('id_group', groupId);
      return (response as List)
          .map((json) => ProjectFile.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching files by group: $e');
      return [];
    }
  }

  static Future<List<ProjectStage>> getProjectStages(int groupId) async {
    try {
      // هذه دالة وهمية، يجب استبدالها بمنطق جلب مراحل المشروع الفعلي من Supabase
      // قد تحتاج إلى جدول منفصل للمراحل أو استخلاصها من بيانات المشروع
      return [
        ProjectStage(id: 1, name: 'المقترح', status: 'completed', completionPercentage: 1.0),
        ProjectStage(id: 2, name: 'خطة البحث', status: 'in_progress', completionPercentage: 0.7),
        ProjectStage(id: 3, name: 'البحث النهائي', status: 'pending', completionPercentage: 0.0),
      ];
    } catch (e) {
      print('Error fetching project stages: $e');
      return [];
    }
  }

  static Future<bool> addComment(ReviewComment comment) async {
    try {
      await client.from('review_comments').insert(comment.toJson());
      return true;
    } catch (e) {
      print('Error adding comment: $e');
      return false;
    }
  }

  static Future<bool> updateComment(int commentId, ReviewComment comment) async {
    try {
      await client
          .from('review_comments')
          .update(comment.toJson())
          .eq('comment_id', commentId);
      return true;
    } catch (e) {
      print('Error updating comment: $e');
      return false;
    }
  }

  static Future<bool> deleteComment(int commentId) async {
    try {
      await client.from('review_comments').delete().eq('comment_id', commentId);
      return true;
    } catch (e) {
      print('Error deleting comment: $e');
      return false;
    }
  }

  static Future<bool> updateStageStatus(int stageId, String status, double completionPercentage) async {
    try {
      // هذه دالة وهمية، يجب استبدالها بمنطق تحديث حالة المرحلة الفعلي في Supabase
      print('Updating stage $stageId to status $status with $completionPercentage%');
      return true;
    } catch (e) {
      print('Error updating stage status: $e');
      return false;
    }
  }
}

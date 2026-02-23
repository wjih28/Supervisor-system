import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // جلب بيانات الطالب بواسطة اسم المستخدم
  Future<Student?> getStudentByUsername(String username) async {
    final response = await _client
        .from('student')
        .select()
        .eq('stud_username', username)
        .maybeSingle();
    
    if (response == null) return null;
    return Student.fromJson(response);
  }

  // جلب بيانات المشرف بواسطة اسم المستخدم
  Future<Supervisor?> getSupervisorByUsername(String username) async {
    final response = await _client
        .from('supervisor')
        .select()
        .eq('sprvsr_username', username)
        .maybeSingle();
    
    if (response == null) return null;
    return Supervisor.fromJson(response);
  }

  // جلب المجموعات المرتبطة بمشرف معين
  Future<List<ResearchGroup>> getGroupsBySupervisor(int supervisorId) async {
    final response = await _client
        .from('groups')
        .select()
        .eq('id_sprvsr', supervisorId);
    
    return (response as List).map((json) => ResearchGroup.fromJson(json)).toList();
  }
}

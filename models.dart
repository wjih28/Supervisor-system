class Student {
  final int? id;
  final String name;
  final String? email;
  final String? username;
  final int? programId;
  final int? groupId;

  Student({
    this.id,
    required this.name,
    this.email,
    this.username,
    this.programId,
    this.groupId,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['stud_id'],
      name: json['stud_name'],
      email: json['stud_email'],
      username: json['stud_username'],
      programId: json['id_program'],
      groupId: json['id_group'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stud_name': name,
      'stud_email': email,
      'stud_username': username,
      'id_program': programId,
      'id_group': groupId,
    };
  }
}

class Supervisor {
  final int? id;
  final String name;
  final String? email;
  final String? username;
  final bool? isActive;

  Supervisor({
    this.id,
    required this.name,
    this.email,
    this.username,
    this.isActive,
  });

  factory Supervisor.fromJson(Map<String, dynamic> json) {
    return Supervisor(
      id: json['sprvsr_id'],
      name: json['sprvsr_name'],
      email: json['sprvsr_email'],
      username: json['sprvsr_username'],
      isActive: json['sprvsr_isactive'],
    );
  }
}

class ResearchGroup {
  final int? id;
  final String name;
  final int? supervisorId;
  final int? stateId;
  final int? leaderId;
  final String? description;
  final double? progress;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ResearchGroup({
    this.id,
    required this.name,
    this.supervisorId,
    this.stateId,
    this.leaderId,
    this.description,
    this.progress,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ResearchGroup.fromJson(Map<String, dynamic> json) {
    return ResearchGroup(
      id: json['group_id'],
      name: json['group_name'],
      supervisorId: json['id_sprvsr'],
      stateId: json['id_group_state'],
      leaderId: json['group_led_id'],
      description: json['group_description'],
      progress: (json['group_progress'] as num?)?.toDouble() ?? 0.0,
      status: json['group_status'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_name': name,
      'id_sprvsr': supervisorId,
      'id_group_state': stateId,
      'group_led_id': leaderId,
      'group_description': description,
      'group_progress': progress,
      'group_status': status,
    };
  }
}

/// نموذج الملفات المرفوعة
class ResearchFile {
  final int? id;
  final int? groupId;
  final String fileName;
  final String? fileUrl;
  final String? fileType;
  final int? fileSize;
  final String? uploadedBy;
  final DateTime? uploadedAt;
  final String? description;
  final String? stage;

  ResearchFile({
    this.id,
    this.groupId,
    required this.fileName,
    this.fileUrl,
    this.fileType,
    this.fileSize,
    this.uploadedBy,
    this.uploadedAt,
    this.description,
    this.stage,
  });

  factory ResearchFile.fromJson(Map<String, dynamic> json) {
    return ResearchFile(
      id: json['file_id'],
      groupId: json['id_group'],
      fileName: json['file_name'],
      fileUrl: json['file_url'],
      fileType: json['file_type'],
      fileSize: json['file_size'],
      uploadedBy: json['uploaded_by'],
      uploadedAt: json['uploaded_at'] != null ? DateTime.parse(json['uploaded_at']) : null,
      description: json['file_description'],
      stage: json['file_stage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_group': groupId,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_size': fileSize,
      'uploaded_by': uploadedBy,
      'file_description': description,
      'file_stage': stage,
    };
  }
}

/// نموذج الملاحظات والتعليقات
class ReviewComment {
  final int? id;
  final int? groupId;
  final int? supervisorId;
  final String comment;
  final String? commentType; // 'note', 'suggestion', 'issue'
  final int? rating; // 1-5
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isResolved;

  ReviewComment({
    this.id,
    this.groupId,
    this.supervisorId,
    required this.comment,
    this.commentType,
    this.rating,
    this.createdAt,
    this.updatedAt,
    this.isResolved,
  });

  factory ReviewComment.fromJson(Map<String, dynamic> json) {
    return ReviewComment(
      id: json['comment_id'],
      groupId: json['id_group'],
      supervisorId: json['id_sprvsr'],
      comment: json['comment_text'],
      commentType: json['comment_type'],
      rating: json['comment_rating'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      isResolved: json['is_resolved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_group': groupId,
      'id_sprvsr': supervisorId,
      'comment_text': comment,
      'comment_type': commentType,
      'comment_rating': rating,
      'is_resolved': isResolved,
    };
  }
}

/// نموذج حالة المشروع والمراحل
class ProjectStage {
  final int? id;
  final int? groupId;
  final String stageName;
  final String? description;
  final bool? isCompleted;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? dueDate;
  final double? completionPercentage;
  final String? status; // 'pending', 'in_progress', 'completed', 'delayed'

  ProjectStage({
    this.id,
    this.groupId,
    required this.stageName,
    this.description,
    this.isCompleted,
    this.startDate,
    this.endDate,
    this.dueDate,
    this.completionPercentage,
    this.status,
  });

  factory ProjectStage.fromJson(Map<String, dynamic> json) {
    return ProjectStage(
      id: json['stage_id'],
      groupId: json['id_group'],
      stageName: json['stage_name'],
      description: json['stage_description'],
      isCompleted: json['is_completed'] ?? false,
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      completionPercentage: (json['completion_percentage'] as num?)?.toDouble() ?? 0.0,
      status: json['stage_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_group': groupId,
      'stage_name': stageName,
      'stage_description': description,
      'is_completed': isCompleted,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'completion_percentage': completionPercentage,
      'stage_status': status,
    };
  }
}

/// نموذج الإشعارات
class Notification {
  final int? id;
  final int? supervisorId;
  final String title;
  final String? message;
  final String? notificationType; // 'file_upload', 'comment', 'deadline', 'status_change'
  final int? relatedGroupId;
  final bool? isRead;
  final DateTime? createdAt;

  Notification({
    this.id,
    this.supervisorId,
    required this.title,
    this.message,
    this.notificationType,
    this.relatedGroupId,
    this.isRead,
    this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['notification_id'],
      supervisorId: json['id_sprvsr'],
      title: json['notification_title'],
      message: json['notification_message'],
      notificationType: json['notification_type'],
      relatedGroupId: json['id_group'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_sprvsr': supervisorId,
      'notification_title': title,
      'notification_message': message,
      'notification_type': notificationType,
      'id_group': relatedGroupId,
      'is_read': isRead,
    };
  }
}

class Student {
  final int? id;
  final String name;
  final String? email;
  final String? username;
  final int? programId;
  final int? groupId;
  final String? role;

  Student({
    this.id,
    required this.name,
    this.email,
    this.username,
    this.programId,
    this.groupId,
    this.role,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['stud_id'],
      name: json['stud_name'],
      email: json['stud_email'],
      username: json['stud_username'],
      programId: json['id_program'],
      groupId: json['id_group'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stud_name': name,
      'stud_email': email,
      'stud_username': username,
      'id_program': programId,
      'id_group': groupId,
      'role': role,
    };
  }
}

class Supervisor {
  final int? id;
  final String name;
  final String? email;
  final String? password;
  final String? username;
  final bool? isActive;

  Supervisor({
    this.id,
    required this.name,
    this.email,
    this.password,
    this.username,
    this.isActive,
  });

  factory Supervisor.fromJson(Map<String, dynamic> json) {
    return Supervisor(
      id: json["sprvsr_id"],
      name: json["sprvsr_name"],
      email: json["sprvsr_email"],
      password: json["sprvsr_pass"],
      username: json["sprvsr_username"],
      isActive: json["sprvsr_isactive"],
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
  double? progress; // Made mutable
  String? status; // Made mutable
  String? currentStage; // Added currentStage field
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
    this.currentStage, // Added to constructor
    this.createdAt,
    this.updatedAt,
  });

  factory ResearchGroup.fromJson(Map<String, dynamic> json) {
    return ResearchGroup(
      id: json["group_id"],
      name: json["group_name"],
      supervisorId: json["id_sprvsr"],
      stateId: json["id_group_state"],
      leaderId: json["group_led_id"],
      description: json["group_description"],
      progress: (json["group_progress"] as num?)?.toDouble(),
      status: json["group_status"],
      currentStage:
          json["current_stage"], // Assuming current_stage might come from JSON
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : null,
      updatedAt: json["updated_at"] != null
          ? DateTime.parse(json["updated_at"])
          : null,
    );
  }

  ResearchGroup copyWith({
    int? id,
    String? name,
    int? supervisorId,
    int? stateId,
    int? leaderId,
    String? description,
    double? progress,
    String? status,
    String? currentStage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ResearchGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      supervisorId: supervisorId ?? this.supervisorId,
      stateId: stateId ?? this.stateId,
      leaderId: leaderId ?? this.leaderId,
      description: description ?? this.description,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      currentStage: currentStage ?? this.currentStage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ResearchFile {
  final int? id;
  final int? groupId;
  final String fileName;
  final String? fileUrl;
  final String? fileType;
  final int? fileSize;
  final String? uploadedBy;
  final DateTime? uploadedAt;
  final String? supervisorNotes;
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
    this.supervisorNotes,
    this.description,
    this.stage,
  });

  factory ResearchFile.fromJson(Map<String, dynamic> json) {
    return ResearchFile(
      id: json['file_id'],
      groupId: json['id_group'],
      fileName: json['file_name'] ?? '',
      fileUrl: json['file_url'],
      fileType: json['file_type'],
      fileSize: json['file_size'],
      uploadedBy: json['uploaded_by'],
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'])
          : null,
      supervisorNotes: json['supervisor_notes'],
      description: json['file_description'] ?? json['description'],
      stage: json['stage'] ?? json['file_stage'],
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
      'uploaded_at': uploadedAt?.toIso8601String(),
      'supervisor_notes': supervisorNotes,
      'file_description': description,
      'file_stage': stage,
    };
  }
}

class ProjectFile extends ResearchFile {
  ProjectFile({
    super.id,
    super.groupId,
    required super.fileName,
    super.fileUrl,
    super.fileType,
    super.fileSize,
    super.uploadedBy,
    super.uploadedAt,
    super.supervisorNotes,
    super.description,
    super.stage,
  });

  factory ProjectFile.fromJson(Map<String, dynamic> json) {
    return ProjectFile(
      id: json['file_id'],
      groupId: json['id_group'],
      fileName: json['file_name'] ?? '',
      fileUrl: json['file_url'],
      fileType: json['file_type'],
      fileSize: json['file_size'],
      uploadedBy: json['uploaded_by'],
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'])
          : null,
      supervisorNotes: json['supervisor_notes'],
      description: json['file_description'] ?? json['description'],
      stage: json['stage'] ?? json['file_stage'],
    );
  }
}

class ReviewComment {
  final int? id;
  final int? groupId;
  final int? supervisorId;
  final String comment;
  final String? commentType;
  final int? rating;
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
      id: json["comment_id"],
      groupId: json["id_group"],
      supervisorId: json["id_sprvsr"],
      comment: json["comment_text"],
      commentType: json["comment_type"],
      rating: json["comment_rating"],
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : null,
      updatedAt: json["updated_at"] != null
          ? DateTime.parse(json["updated_at"])
          : null,
      isResolved: json["is_resolved"],
    );
  }
}

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
  final String? status;

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
      id: json["stage_id"],
      groupId: json["id_group"],
      stageName: json["stage_name"],
      description: json["stage_description"],
      isCompleted: json["is_completed"],
      startDate: json["start_date"] != null
          ? DateTime.parse(json["start_date"])
          : null,
      endDate:
          json["end_date"] != null ? DateTime.parse(json["end_date"]) : null,
      dueDate:
          json["due_date"] != null ? DateTime.parse(json["due_date"]) : null,
      completionPercentage: (json["completion_percentage"] as num?)?.toDouble(),
      status: json["stage_status"],
    );
  }
}

class Notification {
  final int? id;
  final int? supervisorId;
  final String title;
  final String? message;
  final String? notificationType;
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
      id: json["notification_id"],
      supervisorId: json["id_sprvsr"],
      title: json["notification_title"],
      message: json["notification_message"],
      notificationType: json["notification_type"],
      relatedGroupId: json["id_group"],
      isRead: json["is_read"],
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : null,
    );
  }
}

class ProjectFeedback {
  final int? id;
  final int? projectId;
  final int? supervisorId;
  final String comment;
  final String? notes;
  final String? stage;
  final bool? isResolved;
  final String? supervisorName;
  final DateTime? createdAt;

  ProjectFeedback({
    this.id,
    this.projectId,
    this.supervisorId,
    required this.comment,
    this.notes,
    this.stage,
    this.isResolved,
    this.supervisorName,
    this.createdAt,
  });

  factory ProjectFeedback.fromJson(Map<String, dynamic> json) {
    return ProjectFeedback(
      id: json["comment_id"],
      projectId: json["id_group"],
      supervisorId: json["id_sprvsr"],
      comment: json["comment_text"] ?? '',
      notes: json["comment_text"] ?? '',
      stage: json["comment_stage"] ?? json["stage"],
      isResolved: json["is_resolved"] ?? false,
      supervisorName: json["supervisor_name"],
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : null,
    );
  }
}

class Program {
  final int? id;
  final String name;
  final int? departmentId;

  Program({
    this.id,
    required this.name,
    this.departmentId,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['program_id'],
      name: json['program_name'] ?? json['name'] ?? '',
      departmentId: json['department_id'] ?? json['dep_id'],
    );
  }
}

class Department {
  final int? id;
  final String name;

  Department({
    this.id,
    required this.name,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['dep_id'] ?? json['department_id'],
      name: json['dep_name'] ?? json['name'] ?? '',
    );
  }
}

class HeadOfDepartment {
  final int? id;
  final String name;

  HeadOfDepartment({
    this.id,
    required this.name,
  });

  factory HeadOfDepartment.fromJson(Map<String, dynamic> json) {
    return HeadOfDepartment(
      id: json['hod_id'] ?? json['id'],
      name: json['hod_name'] ?? json['name'] ?? '',
    );
  }
}

class ProgramCoordinator {
  final int? id;
  final String name;

  ProgramCoordinator({
    this.id,
    required this.name,
  });

  factory ProgramCoordinator.fromJson(Map<String, dynamic> json) {
    return ProgramCoordinator(
      id: json['coord_id'] ?? json['id'],
      name: json['coord_name'] ?? json['name'] ?? '',
    );
  }
}

class Dean {
  final int? id;
  final String name;

  Dean({
    this.id,
    required this.name,
  });

  factory Dean.fromJson(Map<String, dynamic> json) {
    return Dean(
      id: json['dean_id'] ?? json['id'],
      name: json['dean_name'] ?? json['name'] ?? '',
    );
  }
}

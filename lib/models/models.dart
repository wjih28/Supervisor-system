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

  ResearchGroup({
    this.id,
    required this.name,
    this.supervisorId,
    this.stateId,
    this.leaderId,
  });

  factory ResearchGroup.fromJson(Map<String, dynamic> json) {
    return ResearchGroup(
      id: json['group_id'],
      name: json['group_name'],
      supervisorId: json['id_sprvsr'],
      stateId: json['id_group_state'],
      leaderId: json['group_led_id'],
    );
  }
}

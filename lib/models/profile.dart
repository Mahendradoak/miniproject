class JobSeekerProfile {
  final String? id;
  final String userId;
  final List<ProfileVersion> profiles;
  final String? activeProfileId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  JobSeekerProfile({
    this.id,
    required this.userId,
    required this.profiles,
    this.activeProfileId,
    this.createdAt,
    this.updatedAt,
  });

  ProfileVersion? get activeProfile {
    try {
      return profiles.firstWhere((p) => p.isActive);
    } catch (e) {
      return profiles.isNotEmpty ? profiles.first : null;
    }
  }

  factory JobSeekerProfile.fromJson(Map<String, dynamic> json) {
    return JobSeekerProfile(
      id: json['_id'],
      userId: json['userId'],
      profiles: (json['profiles'] as List?)
              ?.map((p) => ProfileVersion.fromJson(p))
              .toList() ??
          [],
      activeProfileId: json['activeProfileId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'profiles': profiles.map((p) => p.toJson()).toList(),
      'activeProfileId': activeProfileId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class ProfileVersion {
  final String? id;
  final String name;
  final String? description;
  final List<String> skills;
  final List<WorkExperience> experience;
  final List<Education> education;
  final String? resume;
  final List<String> desiredJobTypes;
  final SalaryRange? desiredSalary;
  final List<String> preferredLocations;
  final String remotePreference;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProfileVersion({
    this.id,
    required this.name,
    this.description,
    this.skills = const [],
    this.experience = const [],
    this.education = const [],
    this.resume,
    this.desiredJobTypes = const [],
    this.desiredSalary,
    this.preferredLocations = const [],
    this.remotePreference = 'any',
    this.isActive = false,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileVersion.fromJson(Map<String, dynamic> json) {
    return ProfileVersion(
      id: json['_id'],
      name: json['name'] ?? 'Unnamed Profile',
      description: json['description'],
      skills: (json['skills'] as List?)?.map((s) => s.toString()).toList() ?? [],
      experience: (json['experience'] as List?)
              ?.map((e) => WorkExperience.fromJson(e))
              .toList() ??
          [],
      education: (json['education'] as List?)
              ?.map((e) => Education.fromJson(e))
              .toList() ??
          [],
      resume: json['resume'],
      desiredJobTypes: (json['desiredJobTypes'] as List?)
              ?.map((t) => t.toString())
              .toList() ??
          [],
      desiredSalary: json['desiredSalary'] != null
          ? SalaryRange.fromJson(json['desiredSalary'])
          : null,
      preferredLocations: (json['preferredLocations'] as List?)
              ?.map((l) => l.toString())
              .toList() ??
          [],
      remotePreference: json['remotePreference'] ?? 'any',
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'description': description,
      'skills': skills,
      'experience': experience.map((e) => e.toJson()).toList(),
      'education': education.map((e) => e.toJson()).toList(),
      'resume': resume,
      'desiredJobTypes': desiredJobTypes,
      if (desiredSalary != null) 'desiredSalary': desiredSalary!.toJson(),
      'preferredLocations': preferredLocations,
      'remotePreference': remotePreference,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  ProfileVersion copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? skills,
    List<WorkExperience>? experience,
    List<Education>? education,
    String? resume,
    List<String>? desiredJobTypes,
    SalaryRange? desiredSalary,
    List<String>? preferredLocations,
    String? remotePreference,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileVersion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      skills: skills ?? this.skills,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      resume: resume ?? this.resume,
      desiredJobTypes: desiredJobTypes ?? this.desiredJobTypes,
      desiredSalary: desiredSalary ?? this.desiredSalary,
      preferredLocations: preferredLocations ?? this.preferredLocations,
      remotePreference: remotePreference ?? this.remotePreference,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class WorkExperience {
  final String? id;
  final String title;
  final String company;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;
  final bool current;

  WorkExperience({
    this.id,
    required this.title,
    required this.company,
    this.startDate,
    this.endDate,
    this.description,
    this.current = false,
  });

  factory WorkExperience.fromJson(Map<String, dynamic> json) {
    return WorkExperience(
      id: json['_id'],
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      description: json['description'],
      current: json['current'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'title': title,
      'company': company,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      'description': description,
      'current': current,
    };
  }
}

class Education {
  final String? id;
  final String degree;
  final String institution;
  final String? field;
  final int? graduationYear;

  Education({
    this.id,
    required this.degree,
    required this.institution,
    this.field,
    this.graduationYear,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['_id'],
      degree: json['degree'] ?? '',
      institution: json['institution'] ?? '',
      field: json['field'],
      graduationYear: json['graduationYear'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'degree': degree,
      'institution': institution,
      'field': field,
      'graduationYear': graduationYear,
    };
  }
}

class SalaryRange {
  final int? min;
  final int? max;
  final String currency;

  SalaryRange({
    this.min,
    this.max,
    this.currency = 'USD',
  });

  factory SalaryRange.fromJson(Map<String, dynamic> json) {
    return SalaryRange(
      min: json['min'],
      max: json['max'],
      currency: json['currency'] ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
      'currency': currency,
    };
  }

  String get formatted {
    if (min != null && max != null) {
      return '\$$min - \$$max $currency';
    } else if (min != null) {
      return '\$$min+ $currency';
    } else if (max != null) {
      return 'Up to \$$max $currency';
    }
    return 'Not specified';
  }
}

class Job {
  final String id;
  final String title;
  final String company;
  final String description;
  final JobRequirements? requirements;
  final String jobType;
  final Salary? salary;
  final Location? location;
  final String remoteType;
  final int? matchScore;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.description,
    this.requirements,
    required this.jobType,
    this.salary,
    this.location,
    required this.remoteType,
    this.matchScore,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      description: json['description'] ?? '',
      requirements: json['requirements'] != null 
          ? JobRequirements.fromJson(json['requirements']) 
          : null,
      jobType: json['jobType'] ?? '',
      salary: json['salary'] != null ? Salary.fromJson(json['salary']) : null,
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
      remoteType: json['remoteType'] ?? '',
      matchScore: json['matchScore'],
    );
  }
}

class JobRequirements {
  final List<String>? skills;
  final Experience? experience;

  JobRequirements({this.skills, this.experience});

  factory JobRequirements.fromJson(Map<String, dynamic> json) {
    return JobRequirements(
      skills: json['skills'] != null ? List<String>.from(json['skills']) : null,
      experience: json['experience'] != null 
          ? Experience.fromJson(json['experience']) 
          : null,
    );
  }
}

class Experience {
  final int? min;
  final int? max;

  Experience({this.min, this.max});

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      min: json['min'],
      max: json['max'],
    );
  }
}

class Salary {
  final int? min;
  final int? max;
  final String? currency;

  Salary({this.min, this.max, this.currency});

  factory Salary.fromJson(Map<String, dynamic> json) {
    return Salary(
      min: json['min'],
      max: json['max'],
      currency: json['currency'],
    );
  }
}

class Location {
  final String? city;
  final String? state;
  final String? country;

  Location({this.city, this.state, this.country});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      city: json['city'],
      state: json['state'],
      country: json['country'],
    );
  }

  String get fullLocation {
    List<String> parts = [];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }
}

enum QuizStatus { DRAFT, PUBLISHED, CLOSED }
enum AccessScope { PUBLIC, CLASSROOM }

class Quiz {
  final String id;
  final String name;
  final String? description;
  final String? subjectId;
  final String? sourceContestId;
  final String? sourceContestName;
  final int durationMinutes;
  final int maxAttempts;
  final int? questionSelectionCount; // MỚI: Số lượng câu hỏi muốn lấy từ contest nguồn
  final bool randomQuestionOrder;
  final bool randomAnswerOrder;
  final String difficulty;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final QuizStatus status;
  final AccessScope accessScope;
  final List<String> classroomIds;
  final int questionCount;
  final DateTime? updatedAt;
  final String? createdBy;

  Quiz({
    required this.id,
    required this.name,
    this.description,
    this.subjectId,
    this.sourceContestId,
    this.sourceContestName,
    required this.durationMinutes,
    required this.maxAttempts,
    this.questionSelectionCount,
    required this.randomQuestionOrder,
    required this.randomAnswerOrder,
    required this.difficulty,
    required this.tags,
    required this.metadata,
    required this.status,
    required this.accessScope,
    this.classroomIds = const [],
    this.questionCount = 0,
    this.updatedAt,
    this.createdBy,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      subjectId: json['subjectId'],
      sourceContestId: json['sourceContestId'],
      sourceContestName: json['sourceContestName'],
      durationMinutes: json['durationMinutes'] ?? 0,
      maxAttempts: json['maxAttempts'] ?? 0,
      questionSelectionCount: json['questionSelectionCount'],
      randomQuestionOrder: json['randomQuestionOrder'] ?? false,
      randomAnswerOrder: json['randomAnswerOrder'] ?? false,
      difficulty: json['difficulty'] ?? 'EASY',
      tags: List<String>.from(json['tags'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      status: _parseStatus(json['status']),
      accessScope: json['accessScope'] == 'PUBLIC' ? AccessScope.PUBLIC : AccessScope.CLASSROOM,
      classroomIds: List<String>.from(json['classroomIds'] ?? []),
      questionCount: json['questionCount'] ?? 0,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy'],
    );
  }

  static QuizStatus _parseStatus(String? status) {
    switch (status) {
      case 'PUBLISHED': return QuizStatus.PUBLISHED;
      case 'CLOSED': return QuizStatus.CLOSED;
      default: return QuizStatus.DRAFT;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'sourceContestId': sourceContestId,
      'durationMinutes': durationMinutes,
      'maxAttempts': maxAttempts,
      'questionSelectionCount': questionSelectionCount,
      'randomQuestionOrder': randomQuestionOrder,
      'randomAnswerOrder': randomAnswerOrder,
      'difficulty': difficulty,
      'tags': tags,
      'metadata': metadata,
      'accessScope': accessScope.name,
      'classroomIds': classroomIds,
    };
  }
}

class KnowledgeIngestRequest {
  final String title;
  final String content;
  final String? classroomId;
  final String sourceType;

  KnowledgeIngestRequest({
    required this.title,
    required this.content,
    this.classroomId,
    this.sourceType = 'TEXT',
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'classroomId': classroomId,
    'sourceType': sourceType,
  };
}

class KnowledgeIngestResponse {
  final String documentId;
  final String status;
  final int chunkCount;

  KnowledgeIngestResponse({
    required this.documentId,
    required this.status,
    required this.chunkCount,
  });

  factory KnowledgeIngestResponse.fromJson(Map<String, dynamic> json) => KnowledgeIngestResponse(
    documentId: json['documentId'] ?? '',
    status: json['status'] ?? '',
    chunkCount: json['chunkCount'] ?? 0,
  );
}

class RagOptions {
  final int topK;
  final double minScore;
  final String? classroomId;

  RagOptions({
    this.topK = 5,
    this.minScore = 0.05,
    this.classroomId,
  });

  Map<String, dynamic> toJson() => {
    'topK': topK,
    'minScore': minScore,
    'classroomId': classroomId,
  };

  factory RagOptions.fromJson(Map<String, dynamic> json) => RagOptions(
    topK: json['topK'] ?? 5,
    minScore: (json['minScore'] ?? 0.05).toDouble(),
    classroomId: json['classroomId'],
  );
}

class AiExamGenerateRequest {
  final String title;
  final String topic;
  final int questionCount;
  final int durationMinutes;
  final String language;
  final String? description;
  final bool useRag;
  final List<String> classroomIds;
  final List<String> questionTypes;
  final Map<String, int> difficultyDistribution;
  final RagOptions? ragOptions;

  AiExamGenerateRequest({
    required this.title,
    required this.topic,
    required this.questionCount,
    required this.durationMinutes,
    this.language = 'vi',
    this.description,
    required this.useRag,
    this.classroomIds = const [],
    this.questionTypes = const ['MULTIPLE_CHOICE'],
    required this.difficultyDistribution,
    this.ragOptions,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'topic': topic,
    'questionCount': questionCount,
    'durationMinutes': durationMinutes,
    'language': language,
    'description': description,
    'useRag': useRag,
    'classroomIds': classroomIds,
    'questionTypes': questionTypes,
    'difficultyDistribution': difficultyDistribution,
    if (ragOptions != null) 'ragOptions': ragOptions!.toJson(),
  };
}

class AiExamGenerateResponse {
  final String jobId;
  final String status;
  final String mode;
  final String? fallbackReason;

  AiExamGenerateResponse({
    required this.jobId,
    required this.status,
    required this.mode,
    this.fallbackReason,
  });

  factory AiExamGenerateResponse.fromJson(Map<String, dynamic> json) => AiExamGenerateResponse(
    jobId: json['jobId'] ?? '',
    status: json['status'] ?? '',
    mode: json['mode'] ?? '',
    fallbackReason: json['fallbackReason'],
  );
}

class AiQuestionDraft {
  final int questionNo;
  final String content;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctOption;
  final String difficulty;
  final String? explanation;
  final String topic;
  final double score;
  final List<String> tags;

  AiQuestionDraft({
    required this.questionNo,
    required this.content,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctOption,
    required this.difficulty,
    this.explanation,
    required this.topic,
    required this.score,
    this.tags = const [],
  });

  factory AiQuestionDraft.fromJson(Map<String, dynamic> json) => AiQuestionDraft(
    questionNo: json['questionNo'] ?? 0,
    content: json['content'] ?? '',
    optionA: json['optionA'] ?? '',
    optionB: json['optionB'] ?? '',
    optionC: json['optionC'] ?? '',
    optionD: json['optionD'] ?? '',
    correctOption: json['correctOption'] ?? '',
    difficulty: json['difficulty'] ?? '',
    explanation: json['explanation'],
    topic: json['topic'] ?? '',
    score: (json['score'] ?? 0).toDouble(),
    tags: List<String>.from(json['tags'] ?? []),
  );
}

class AiExamDraft {
  final String title;
  final String? description;
  final int durationMinutes;
  final String generatedAt;
  final List<AiQuestionDraft> questions;

  AiExamDraft({
    required this.title,
    this.description,
    required this.durationMinutes,
    required this.generatedAt,
    required this.questions,
  });

  factory AiExamDraft.fromJson(Map<String, dynamic> json) => AiExamDraft(
    title: json['title'] ?? '',
    description: json['description'],
    durationMinutes: json['durationMinutes'] ?? 0,
    generatedAt: json['generatedAt'] ?? '',
    questions: (json['questions'] as List?)?.map((e) => AiQuestionDraft.fromJson(e)).toList() ?? [],
  );
}

class AiExamJobResponse {
  final String jobId;
  final String status;
  final String mode;
  final String? fallbackReason;
  final String? approvedContestId;
  final String? errorMessage;
  final int? retrievedContextCount;
  final List<String>? warnings;
  final AiExamDraft? examDraft;

  AiExamJobResponse({
    required this.jobId,
    required this.status,
    required this.mode,
    this.fallbackReason,
    this.approvedContestId,
    this.errorMessage,
    this.retrievedContextCount,
    this.warnings,
    this.examDraft,
  });

  factory AiExamJobResponse.fromJson(Map<String, dynamic> json) => AiExamJobResponse(
    jobId: json['jobId'] ?? '',
    status: json['status'] ?? '',
    mode: json['mode'] ?? '',
    fallbackReason: json['fallbackReason'],
    approvedContestId: json['approvedContestId'],
    errorMessage: json['errorMessage'],
    retrievedContextCount: json['retrievedContextCount'],
    warnings: (json['warnings'] as List?)?.map((e) => e.toString()).toList(),
    examDraft: json['examDraft'] != null ? AiExamDraft.fromJson(json['examDraft']) : null,
  );
}

class AiExamApproveRequest {
  final String contestName;
  final String? contestDescription;
  final int durationMinutes;
  final String startAt;
  final String endAt;
  final List<String> classroomIds;

  AiExamApproveRequest({
    required this.contestName,
    this.contestDescription,
    required this.durationMinutes,
    required this.startAt,
    required this.endAt,
    this.classroomIds = const [],
  });

  Map<String, dynamic> toJson() => {
    'contestName': contestName,
    'contestDescription': contestDescription,
    'durationMinutes': durationMinutes,
    'startAt': startAt,
    'endAt': endAt,
    'classroomIds': classroomIds,
  };
}

class AiExamApproveResponse {
  final String contestId;
  final int createdQuestionCount;
  final String status;

  AiExamApproveResponse({
    required this.contestId,
    required this.createdQuestionCount,
    required this.status,
  });

  factory AiExamApproveResponse.fromJson(Map<String, dynamic> json) => AiExamApproveResponse(
    contestId: json['contestId'] ?? '',
    createdQuestionCount: json['createdQuestionCount'] ?? 0,
    status: json['status'] ?? '',
  );
}

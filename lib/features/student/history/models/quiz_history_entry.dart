import 'package:flutter/material.dart';

enum QuizHistoryStatus { completed, inProgress }

class QuizHistoryEntry {
  final String id;
  final String contestId;
  final String title;
  final String category;
  final double? score;
  final int correctCount;
  final int totalQuestions;
  final QuizHistoryStatus status;
  final DateTime dateTime;
  final IconData icon;
  final Color color;

  QuizHistoryEntry({
    required this.id,
    required this.contestId,
    required this.title,
    required this.category,
    this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.status,
    required this.dateTime,
    required this.icon,
    required this.color,
  });

  factory QuizHistoryEntry.fromJson(Map<String, dynamic> json) {
    // 1. Ánh xạ Status từ DB (COMPLETED, IN_PROGRESS)
    final rawStatus = (json['status'] ?? '').toString().toUpperCase();
    final status = (rawStatus == 'COMPLETED' || rawStatus == 'FINISHED')
        ? QuizHistoryStatus.completed 
        : QuizHistoryStatus.inProgress;

    // 2. Ánh xạ Title (BE trả về contestName)
    final title = json['contestName'] ?? 'Bài thi không tên';
    
    // 3. Ánh xạ Thời gian (Ưu tiên submittedAt, sau đó đến createdAt hoặc startedAt)
    final dateStr = json['submittedAt'] ?? json['createdAt'] ?? json['startedAt'];
    DateTime dateTime;
    try {
      dateTime = dateStr != null ? DateTime.parse(dateStr.toString()).toLocal() : DateTime.now();
    } catch (_) {
      dateTime = DateTime.now();
    }

    final descriptor = title.toLowerCase();

    return QuizHistoryEntry(
      id: (json['submissionId'] ?? json['_id'] ?? json['id'] ?? '').toString(),
      contestId: (json['contestId'] ?? '').toString(),
      title: title,
      category: 'Hệ thống', // Category mặc định
      score: status == QuizHistoryStatus.completed 
          ? (json['totalScore'] ?? 0.0).toDouble() 
          : null,
      correctCount: (json['correctCount'] ?? 0) as int,
      totalQuestions: (json['totalQuestions'] ?? 0) as int,
      status: status,
      dateTime: dateTime,
      icon: _resolveIcon(descriptor),
      color: _resolveColor(descriptor, status),
    );
  }

  static IconData _resolveIcon(String descriptor) {
    if (descriptor.contains('toan')) return Icons.calculate;
    if (descriptor.contains('ly')) return Icons.science;
    return Icons.assignment;
  }

  static Color _resolveColor(String descriptor, QuizHistoryStatus status) {
    if (status == QuizHistoryStatus.inProgress) return Colors.orange;
    if (descriptor.contains('toan')) return Colors.green;
    return Colors.blue;
  }
}

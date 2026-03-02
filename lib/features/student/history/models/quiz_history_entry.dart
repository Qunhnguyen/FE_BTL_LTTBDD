import 'package:flutter/material.dart';

enum QuizHistoryStatus { completed, inProgress }

class QuizHistoryEntry {
  final String id;
  final String title;
  final String category;
  final double? score;
  final double maxScore;
  final QuizHistoryStatus status;
  final DateTime dateTime;
  final IconData icon;
  final Color color;
  final String? remainingTime;

  QuizHistoryEntry({
    required this.id,
    required this.title,
    required this.category,
    this.score,
    this.maxScore = 10.0,
    required this.status,
    required this.dateTime,
    required this.icon,
    required this.color,
    this.remainingTime,
  });
}

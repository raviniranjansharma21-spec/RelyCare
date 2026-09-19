import 'package:flutter/material.dart';
import '../models/identity_match.dart';
import '../core/theme/app_colors.dart';

/// Visual badge displaying patient identity match confidence level and percentage score.
class ConfidenceBadge extends StatelessWidget {
  final double score;
  final MatchConfidence confidenceLevel;

  const ConfidenceBadge({
    super.key,
    required this.score,
    required this.confidenceLevel,
  });

  Color _getBadgeColor() {
    switch (confidenceLevel) {
      case MatchConfidence.high:
        return AppColors.confidenceHigh;
      case MatchConfidence.medium:
        return AppColors.confidenceMedium;
      case MatchConfidence.low:
        return AppColors.confidenceLow;
    }
  }

  String _getConfidenceText() {
    final percentage = (score * 100).toStringAsFixed(0);
    switch (confidenceLevel) {
      case MatchConfidence.high:
        return 'High Confidence ($percentage%) - Suggested Match';
      case MatchConfidence.medium:
        return 'Medium Confidence ($percentage%) - Review Needed';
      case MatchConfidence.low:
        return 'Low Confidence ($percentage%) - Verification Required';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getBadgeColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            confidenceLevel == MatchConfidence.high
                ? Icons.check_circle_outline
                : Icons.warning_amber_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            _getConfidenceText(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

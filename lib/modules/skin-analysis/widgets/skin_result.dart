import 'package:flutter/material.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class ResultTile extends StatelessWidget {
  final Map<String, dynamic> result;

  const ResultTile({required this.result});

  @override
  Widget build(BuildContext context) {
    final Color riskColor = Color(result['riskColorValue']);
    return ListTile(
      leading: Container(
        width: getWidth(context, 24),
        height: getHeight(context, 24),
        decoration: BoxDecoration(
          color: riskColor.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: riskColor, width: 2),
        ),
      ),
      title: Text(
        result['displayLabel'],
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        result['riskLevel'],
        style: TextStyle(color: riskColor),
      ),
      trailing: CircleAvatar(
        backgroundColor: riskColor.withValues(alpha: 0.1),
        child: Text(
          '${(result['confidence'] * 100).toStringAsFixed(0)}%',
          style: TextStyle(color: riskColor),
        ),
      ),
    );
  }
}

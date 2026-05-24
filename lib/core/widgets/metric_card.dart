// import 'package:flutter/material.dart';
// import 'package:skin_sync/core/constants/color_const.dart';
// import 'package:skin_sync/core/widgets/glass_card.dart';
// import 'package:skin_sync/core/widgets/circular_progress_indicator.dart';

// /// A metric card showing a single skin metric (e.g., Acne, Dryness)
// class MetricCard extends StatelessWidget {
//   final String title;
//   final int value; // 0-100
//   final String level; // Low, Medium, High
//   final IconData? icon;
//   final Color? color;
//   final bool isIncreasing;
//   final VoidCallback? onTap;

//   const MetricCard({
//     super.key,
//     required this.title,
//     required this.value,
//     required this.level,
//     this.icon,
//     this.color,
//     this.isIncreasing = false,
//     this.onTap,
//   });

//   Color _getLevelColor() {
//     if (color != null) return color!;
//     switch (level.toLowerCase()) {
//       case 'low':
//         return AppColors.success;
//       case 'medium':
//         return AppColors.warning;
//       case 'high':
//         return AppColors.error;
//       default:
//         return AppColors.primary;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final effectiveColor = _getLevelColor();

//     return AppCard(
//       onTap: onTap,
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               if (icon != null) ...[
//                 Container(
//                   width: 32,
//                   height: 32,
//                   decoration: BoxDecoration(
//                     color: effectiveColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(
//                     icon,
//                     size: 18,
//                     color: effectiveColor,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//               ],
//               Text(
//                 title,
//                 style: theme.textTheme.titleSmall?.copyWith(
//                   color: isDark ? AppColors.textOnPrimary : AppColors.textPrimary,
//                 ),
//               ),
//               const Spacer(),
//               Row(
//                 children: [
//                   Text(
//                     level,
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: effectiveColor,
//                     ),
//                   ),
//                   Icon(
//                     isIncreasing ? Icons.arrow_upward : Icons.arrow_downward,
//                     size: 14,
//                     color: effectiveColor,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 '$value%',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.w700,
//                   color: isDark ? AppColors.textOnPrimary : AppColors.textPrimary,
//                 ),
//               ),
//               MiniCircularIndicator(
//                 progress: value / 100,
//                 size: 36,
//                 color: effectiveColor,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// A compact metric chip for inline display
// class MetricChip extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color? color;

//   const MetricChip({
//     super.key,
//     required this.label,
//     required this.value,
//     this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final effectiveColor = color ?? AppColors.primary;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: effectiveColor.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: effectiveColor.withOpacity(0.2),
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             label,
//             style: theme.textTheme.bodySmall?.copyWith(
//               color: isDark ? AppColors.secondaryLight : AppColors.textSecondary,
//             ),
//           ),
//           const SizedBox(width: 6),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w700,
//               color: effectiveColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// A horizontal list of metric cards
// class MetricsRow extends StatelessWidget {
//   final List<MetricData> metrics;

//   const MetricsRow({
//     super.key,
//     required this.metrics,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: metrics.asMap().entries.map((entry) {
//         final index = entry.key;
//         final metric = entry.value;
//         return Expanded(
//           child: Padding(
//             padding: EdgeInsets.only(
//               left: index == 0 ? 0 : 6,
//               right: index == metrics.length - 1 ? 0 : 6,
//             ),
//             child: MetricCard(
//               title: metric.title,
//               value: metric.value,
//               level: metric.level,
//               icon: metric.icon,
//               color: metric.color,
//               isIncreasing: metric.isIncreasing,
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }

// /// Data model for metrics
// class MetricData {
//   final String title;
//   final int value;
//   final String level;
//   final IconData? icon;
//   final Color? color;
//   final bool isIncreasing;

//   const MetricData({
//     required this.title,
//     required this.value,
//     required this.level,
//     this.icon,
//     this.color,
//     this.isIncreasing = false,
//   });
// }

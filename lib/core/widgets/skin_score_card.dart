// import 'package:flutter/material.dart';
// import 'package:skin_sync/core/constants/color_const.dart';
// import 'package:skin_sync/core/widgets/glass_card.dart';
// import 'package:skin_sync/core/widgets/circular_progress_indicator.dart';

// /// A premium skin health score card
// class SkinScoreCard extends StatelessWidget {
//   final int score; // 0-100
//   final String? lastScanDate;
//   final VoidCallback? onTap;

//   const SkinScoreCard({
//     super.key,
//     required this.score,
//     this.lastScanDate,
//     this.onTap,
//   });

//   Color _getScoreColor() {
//     if (score >= 80) return AppColors.success;
//     if (score >= 60) return AppColors.primary;
//     if (score >= 40) return AppColors.warning;
//     return AppColors.error;
//   }

//   String _getScoreLabel() {
//     if (score >= 80) return 'Excellent';
//     if (score >= 60) return 'Good';
//     if (score >= 40) return 'Fair';
//     return 'Needs Attention';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return GlassCard(
//       onTap: onTap,
//       padding: const EdgeInsets.all(24),
//       child: Row(
//         children: [
//           // Left side - Score info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Your Skin Health',
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     color: isDark ? AppColors.secondaryLight : AppColors.textSecondary,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       '$score',
//                       style: TextStyle(
//                         fontSize: 56,
//                         fontWeight: FontWeight.w700,
//                         color: isDark ? AppColors.textOnPrimary : AppColors.textPrimary,
//                         height: 1,
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 8, left: 2),
//                       child: Text(
//                         '%',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.w600,
//                           color: _getScoreColor(),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: _getScoreColor().withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     _getScoreLabel(),
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: _getScoreColor(),
//                     ),
//                   ),
//                 ),
//                 if (lastScanDate != null) ...[
//                   const SizedBox(height: 12),
//                   Text(
//                     'Last scan: $lastScanDate',
//                     style: theme.textTheme.bodySmall?.copyWith(
//                       color: AppColors.textTertiary,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           // Right side - Circular progress with face icon
//           GradientCircularProgress(
//             progress: score / 100,
//             size: 100,
//             strokeWidth: 8,
//             gradientColors: [
//               _getScoreColor().withOpacity(0.5),
//               _getScoreColor(),
//             ],
//             child: Container(
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 color: (isDark ? AppColors.darkBackground : AppColors.background)
//                     .withOpacity(0.8),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.face_outlined,
//                 size: 32,
//                 color: _getScoreColor(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// A simple score card for no-data state
// class EmptySkinScoreCard extends StatelessWidget {
//   final VoidCallback? onTap;

//   const EmptySkinScoreCard({
//     super.key,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return GlassCard(
//       onTap: onTap,
//       padding: const EdgeInsets.all(24),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Your Skin Health',
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     color: isDark ? AppColors.secondaryLight : AppColors.textSecondary,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'No scan yet',
//                   style: TextStyle(
//                     fontSize: 32,
//                     fontWeight: FontWeight.w700,
//                     color: isDark ? AppColors.textOnPrimary : AppColors.textPrimary,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Tap to analyze your skin',
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     color: AppColors.textTertiary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             width: 100,
//             height: 100,
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.add_a_photo_outlined,
//               size: 40,
//               color: AppColors.primary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

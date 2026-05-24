// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:skin_sync/core/constants/color_const.dart';

// class SkinMetricsChart extends StatelessWidget {
//   final int hydration;
//   final int oiliness;
//   final int texture;
//   final int clarity;

//   const SkinMetricsChart({
//     super.key,
//     required this.hydration,
//     required this.oiliness,
//     required this.texture,
//     required this.clarity,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: AppColors.cardBorder),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Skin Metrics',
//             style: GoogleFonts.playfairDisplay(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               fontStyle: FontStyle.italic,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 16),
//           _MetricRow(
//             label: 'Hydration',
//             value: hydration,
//             color: AppColors.metricHydration,
//           ),
//           const SizedBox(height: 12),
//           _MetricRow(
//             label: 'Oiliness',
//             value: oiliness,
//             color: AppColors.metricOiliness,
//           ),
//           const SizedBox(height: 12),
//           _MetricRow(
//             label: 'Texture',
//             value: texture,
//             color: AppColors.metricTexture,
//           ),
//           const SizedBox(height: 12),
//           _MetricRow(
//             label: 'Clarity',
//             value: clarity,
//             color: AppColors.metricClarity,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _MetricRow extends StatelessWidget {
//   final String label;
//   final int value;
//   final Color color;

//   const _MetricRow({
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         SizedBox(
//           width: 80,
//           child: Text(
//             label,
//             style: GoogleFonts.dmSans(
//               fontSize: 13,
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ),
//         Expanded(
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(4),
//             child: LinearProgressIndicator(
//               value: value / 100,
//               minHeight: 6,
//               backgroundColor: AppColors.cardBorder,
//               valueColor: AlwaysStoppedAnimation<Color>(color),
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         SizedBox(
//           width: 40,
//           child: Text(
//             '$value%',
//             textAlign: TextAlign.right,
//             style: GoogleFonts.dmSans(
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//               color: AppColors.textPrimary,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // Circular metric indicator (for results view)
// class CircularMetricIndicator extends StatelessWidget {
//   final String label;
//   final int value;
//   final Color color;

//   const CircularMetricIndicator({
//     super.key,
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: AppColors.cardBorder),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             label,
//             style: GoogleFonts.dmSans(
//               fontSize: 13,
//               color: AppColors.textSecondary,
//             ),
//           ),
//           const SizedBox(height: 12),
//           SizedBox(
//             width: 60,
//             height: 60,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 // Background circle
//                 SizedBox.expand(
//                   child: CircularProgressIndicator(
//                     value: 1,
//                     strokeWidth: 6,
//                     backgroundColor: AppColors.cardBorder,
//                     valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cardBorder),
//                   ),
//                 ),
//                 // Progress circle
//                 SizedBox.expand(
//                   child: CircularProgressIndicator(
//                     value: value / 100,
//                     strokeWidth: 6,
//                     backgroundColor: Colors.transparent,
//                     valueColor: AlwaysStoppedAnimation<Color>(color),
//                     strokeCap: StrokeCap.round,
//                   ),
//                 ),
//                 // Percentage text
//                 Text(
//                   '$value%',
//                   style: GoogleFonts.dmSans(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w700,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Empty state chart for first-time users
// class EmptySkinMetricsChart extends StatelessWidget {
//   const EmptySkinMetricsChart({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: AppColors.cardBorder),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Skin Metrics',
//             style: GoogleFonts.playfairDisplay(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               fontStyle: FontStyle.italic,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 16),
//           _EmptyMetricRow(label: 'Hydration', color: AppColors.metricHydration),
//           const SizedBox(height: 12),
//           _EmptyMetricRow(label: 'Oiliness', color: AppColors.metricOiliness),
//           const SizedBox(height: 12),
//           _EmptyMetricRow(label: 'Texture', color: AppColors.metricTexture),
//           const SizedBox(height: 12),
//           _EmptyMetricRow(label: 'Clarity', color: AppColors.metricClarity),
//         ],
//       ),
//     );
//   }
// }

// class _EmptyMetricRow extends StatelessWidget {
//   final String label;
//   final Color color;

//   const _EmptyMetricRow({
//     required this.label,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         SizedBox(
//           width: 80,
//           child: Text(
//             label,
//             style: GoogleFonts.dmSans(
//               fontSize: 13,
//               color: AppColors.textTertiary,
//             ),
//           ),
//         ),
//         Expanded(
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(4),
//             child: LinearProgressIndicator(
//               value: 0.15,
//               minHeight: 6,
//               backgroundColor: AppColors.cardBorder,
//               valueColor: AlwaysStoppedAnimation<Color>(
//                 color.withValues(alpha: 0.3),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         SizedBox(
//           width: 40,
//           child: Text(
//             '--',
//             textAlign: TextAlign.right,
//             style: GoogleFonts.dmSans(
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//               color: AppColors.textTertiary,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

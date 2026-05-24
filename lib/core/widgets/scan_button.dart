// import 'package:flutter/material.dart';
// import 'package:skin_sync/core/constants/color_const.dart';
// import 'package:skin_sync/core/widgets/glass_card.dart';

// /// A prominent scan/analyze button
// class ScanButton extends StatelessWidget {
//   final VoidCallback? onTap;
//   final String label;
//   final bool isLoading;

//   const ScanButton({
//     super.key,
//     this.onTap,
//     this.label = 'Scan Your Face with AI',
//     this.isLoading = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return GlassCard(
//       onTap: isLoading ? null : onTap,
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       borderRadius: 16,
//       child: Row(
//         children: [
//           Expanded(
//             child: Text(
//               label,
//               style: theme.textTheme.titleMedium?.copyWith(
//                 color: isDark ? AppColors.textOnPrimary : AppColors.textPrimary,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Container(
//             width: 48,
//             height: 48,
//             decoration: BoxDecoration(
//               color: AppColors.primary,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: isLoading
//                 ? const Padding(
//                     padding: EdgeInsets.all(12),
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     ),
//                   )
//                 : const Icon(
//                     Icons.face_retouching_natural,
//                     color: Colors.white,
//                     size: 24,
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// A large circular capture button for camera screen
// class CaptureButton extends StatelessWidget {
//   final VoidCallback? onTap;
//   final double size;
//   final bool isLoading;

//   const CaptureButton({
//     super.key,
//     this.onTap,
//     this.size = 80,
//     this.isLoading = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: isLoading ? null : onTap,
//       child: Container(
//         width: size,
//         height: size,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: AppColors.primary,
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.primary.withOpacity(0.4),
//               blurRadius: 20,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: isLoading
//             ? const Center(
//                 child: CircularProgressIndicator(
//                   strokeWidth: 3,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               )
//             : const Icon(
//                 Icons.camera_alt,
//                 color: Colors.white,
//                 size: 32,
//               ),
//       ),
//     );
//   }
// }

// /// Camera control buttons (flip, gallery)
// class CameraControlButton extends StatelessWidget {
//   final VoidCallback? onTap;
//   final IconData icon;
//   final double size;

//   const CameraControlButton({
//     super.key,
//     this.onTap,
//     required this.icon,
//     this.size = 56,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: size,
//         height: size,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: isDark
//               ? AppColors.darkSurface.withOpacity(0.8)
//               : Colors.white.withOpacity(0.9),
//           border: Border.all(
//             color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
//           ),
//         ),
//         child: Icon(
//           icon,
//           color: isDark ? AppColors.textOnPrimary : AppColors.textPrimary,
//           size: 24,
//         ),
//       ),
//     );
//   }
// }

// /// A row of camera controls
// class CameraControls extends StatelessWidget {
//   final VoidCallback? onCapture;
//   final VoidCallback? onFlip;
//   final VoidCallback? onGallery;
//   final bool isLoading;

//   const CameraControls({
//     super.key,
//     this.onCapture,
//     this.onFlip,
//     this.onGallery,
//     this.isLoading = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         CameraControlButton(
//           icon: Icons.refresh,
//           onTap: onFlip,
//         ),
//         CaptureButton(
//           onTap: onCapture,
//           isLoading: isLoading,
//         ),
//         CameraControlButton(
//           icon: Icons.photo_library_outlined,
//           onTap: onGallery,
//         ),
//       ],
//     );
//   }
// }

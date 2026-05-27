import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/core/constants/text_styles.dart';
import 'package:skin_sync/core/di/injection_container.dart';
import 'package:skin_sync/core/utils/snackbar_helper.dart';
import 'package:skin_sync/features/home/presentation/bloc/dashboard_bloc.dart';
import 'package:skin_sync/features/home/presentation/bloc/dashboard_event.dart';
import 'package:skin_sync/features/profile/presentation/bloc/personal_details_bloc.dart';
import 'package:skin_sync/features/profile/presentation/widgets/form_group.dart';
import 'package:skin_sync/features/profile/presentation/widgets/save_button.dart';
import 'package:skin_sync/features/profile/presentation/widgets/section_label.dart';
import 'package:skin_sync/features/profile/presentation/widgets/sub_header.dart';

class PersonalDetailsPage extends StatelessWidget {
  const PersonalDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<PersonalDetailsBloc>()..add(const PersonalDetailsLoadRequested()),
      child: const _PersonalDetailsView(),
    );
  }
}

class _PersonalDetailsView extends StatefulWidget {
  const _PersonalDetailsView();

  @override
  State<_PersonalDetailsView> createState() => _PersonalDetailsViewState();
}

class _PersonalDetailsViewState extends State<_PersonalDetailsView> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _allergiesController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  void _syncControllersWithState(PersonalDetailsState state) {
    if (_firstNameController.text != state.firstName) {
      _firstNameController.text = state.firstName;
    }
    if (_lastNameController.text != state.lastName) {
      _lastNameController.text = state.lastName;
    }
    if (_emailController.text != state.email) {
      _emailController.text = state.email;
    }
    if (_locationController.text != state.location) {
      _locationController.text = state.location;
    }
    if (_allergiesController.text != state.allergies) {
      _allergiesController.text = state.allergies;
    }
  }

  String _formatDob(DateTime? dob) {
    if (dob == null) return StringConst.kNotSet;
    return DateFormat('d MMMM yyyy').format(dob);
  }

  Future<void> _selectDate(BuildContext context, DateTime? current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(1998, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && context.mounted) {
      context
          .read<PersonalDetailsBloc>()
          .add(PersonalDetailsDateOfBirthChanged(picked));
    }
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Profile Photo',
              style: AppTextStyles.heading3.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primary,
                ),
              ),
              title: Text('Take Photo', style: AppTextStyles.bodyMedium),
              subtitle: Text(
                'Use your camera',
                style: AppTextStyles.caption,
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                context.read<PersonalDetailsBloc>().add(
                      const PersonalDetailsImagePickRequested(fromCamera: true),
                    );
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.sage.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.sage,
                ),
              ),
              title: Text('Choose from Gallery', style: AppTextStyles.bodyMedium),
              subtitle: Text(
                'Select an existing photo',
                style: AppTextStyles.caption,
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                context.read<PersonalDetailsBloc>().add(
                      const PersonalDetailsImagePickRequested(fromCamera: false),
                    );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _selectGender(BuildContext context, String? current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              StringConst.kSelectGender,
              style: AppTextStyles.heading3.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 16),
            ...['male', 'female', 'non-binary'].map(
              (g) => ListTile(
                title: Text(
                  g[0].toUpperCase() + g.substring(1),
                  style: AppTextStyles.bodyMedium,
                ),
                trailing: current == g
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  context
                      .read<PersonalDetailsBloc>()
                      .add(PersonalDetailsGenderChanged(g));
                  Navigator.pop(sheetContext);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PersonalDetailsBloc, PersonalDetailsState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == PersonalDetailsStatus.loaded) {
          _syncControllersWithState(state);
        }
        if (state.status == PersonalDetailsStatus.success) {
          // Dismiss keyboard/unfocus
          FocusScope.of(context).unfocus();

          // Refresh dashboard to reflect changes
          context.read<DashboardBloc>().add(const RefreshDashboard());

          SnackbarHelper.showSuccess(context, StringConst.kProfileSavedSuccess);
        }
        if (state.status == PersonalDetailsStatus.failure &&
            state.errorMessage != null) {
          SnackbarHelper.showError(context, state.errorMessage!);
        }
      },
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.gender != current.gender ||
          previous.dateOfBirth != current.dateOfBirth ||
          previous.firstName != current.firstName ||
          previous.avatarUrl != current.avatarUrl ||
          previous.localAvatarPath != current.localAvatarPath ||
          previous.isUploadingImage != current.isUploadingImage,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              SubHeader(
                superText: StringConst.kProfile,
                title: StringConst.kPersonalDetails,
                onBack: () => context.pop(),
              ),
              Expanded(
                child: state.status == PersonalDetailsStatus.loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _AvatarCard(
                              userName: state.firstName,
                              avatarUrl: state.avatarUrl,
                              localAvatarPath: state.localAvatarPath,
                              isUploading: state.isUploadingImage,
                              onEditTap: () => _showImagePickerOptions(context),
                            ),
                            const SizedBox(height: 14),
                            const SectionLabel(StringConst.kBasicInfo),
                            const SizedBox(height: 8),
                            FormGroup(rows: [
                              _EditableFormRow(
                                label: StringConst.kFirstName,
                                controller: _firstNameController,
                                onChanged: (v) => context
                                    .read<PersonalDetailsBloc>()
                                    .add(PersonalDetailsFirstNameChanged(v)),
                              ),
                              _EditableFormRow(
                                label: StringConst.kLastName,
                                controller: _lastNameController,
                                hintText: StringConst.kEnterLastName,
                                onChanged: (v) => context
                                    .read<PersonalDetailsBloc>()
                                    .add(PersonalDetailsLastNameChanged(v)),
                              ),
                              _TappableFormRow(
                                label: StringConst.kDateOfBirth,
                                value: _formatDob(state.dateOfBirth),
                                onTap: () =>
                                    _selectDate(context, state.dateOfBirth),
                              ),
                              _TappableFormRow(
                                label: StringConst.kGender,
                                value: state.formattedGender,
                                onTap: () =>
                                    _selectGender(context, state.gender),
                              ),
                            ]),
                            const SizedBox(height: 14),
                            const SectionLabel(StringConst.kContact),
                            const SizedBox(height: 8),
                            FormGroup(rows: [
                              _FormRow(
                                label: StringConst.kMobileNumberField,
                                value: state.formattedPhone,
                                trailing: const _VerifiedBadge(),
                              ),
                              _EditableFormRow(
                                label: StringConst.kEmailAddress,
                                controller: _emailController,
                                hintText: StringConst.kEnterEmail,
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (v) => context
                                    .read<PersonalDetailsBloc>()
                                    .add(PersonalDetailsEmailChanged(v)),
                              ),
                              _EditableFormRow(
                                label: StringConst.kLocation,
                                controller: _locationController,
                                hintText: StringConst.kCityCountry,
                                onChanged: (v) => context
                                    .read<PersonalDetailsBloc>()
                                    .add(PersonalDetailsLocationChanged(v)),
                              ),
                            ]),
                            // TODO: Re-enable Skin Background section when ready
                            // const SizedBox(height: 14),
                            // const SectionLabel(StringConst.kSkinBackground),
                            // const SizedBox(height: 8),
                            // FormGroup(rows: [
                            //   _TappableFormRow(
                            //     label: StringConst.kFitzpatrickScale,
                            //     value:
                            //         state.fitzpatrickScale ?? StringConst.kNotSet,
                            //     onTap: () {},
                            //   ),
                            //   _EditableFormRow(
                            //     label: StringConst.kKnownAllergies,
                            //     controller: _allergiesController,
                            //     hintText: StringConst.kAllergyHint,
                            //     onChanged: (v) => context
                            //         .read<PersonalDetailsBloc>()
                            //         .add(PersonalDetailsAllergiesChanged(v)),
                            //   ),
                            // ]),
                            const SizedBox(height: 24),
                            SaveButton(
                              label: state.status == PersonalDetailsStatus.saving
                                  ? StringConst.kSaving
                                  : StringConst.kSaveChanges,
                              isLoading:
                                  state.status == PersonalDetailsStatus.saving,
                              onTap: () => context
                                  .read<PersonalDetailsBloc>()
                                  .add(const PersonalDetailsSaveRequested()),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AvatarCard extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final String? localAvatarPath;
  final bool isUploading;
  final VoidCallback onEditTap;

  const _AvatarCard({
    required this.userName,
    required this.onEditTap,
    this.avatarUrl,
    this.localAvatarPath,
    this.isUploading = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatarInitial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';
    final hasImage = localAvatarPath != null || avatarUrl != null;

    return GestureDetector(
      onTap: onEditTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder, width: 1.5),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: hasImage
                        ? null
                        : const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFF0D4C2), Color(0xFFEDD8D8)],
                          ),
                    border: Border.all(color: AppColors.cardBorder, width: 2),
                    image: _getDecorationImage(),
                  ),
                  child: hasImage
                      ? null
                      : Center(
                          child: Text(
                            avatarInitial,
                            style: AppTextStyles.heading2.copyWith(
                              fontSize: 22,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                ),
                if (isUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    StringConst.kProfilePhoto,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isUploading
                        ? 'Uploading...'
                        : StringConst.kTapToUpdateAvatar,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF0D4C2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                StringConst.kEdit,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DecorationImage? _getDecorationImage() {
    if (localAvatarPath != null) {
      final file = File(localAvatarPath!);
      if (file.existsSync()) {
        return DecorationImage(
          image: FileImage(file),
          fit: BoxFit.cover,
        );
      }
    }
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return DecorationImage(
        image: NetworkImage(avatarUrl!),
        fit: BoxFit.cover,
      );
    }
    return null;
  }
}

class _FormRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget trailing;

  const _FormRow({
    required this.label,
    required this.value,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}

class _EditableFormRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const _EditableFormRow({
    required this.label,
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              color: AppColors.textTertiary,
              letterSpacing: 0.3,
            ),
          ),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            decoration: InputDecoration(
              hintText: hintText ?? 'Enter $label',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.only(top: 4),
            ),
          ),
        ],
      ),
    );
  }
}

class _TappableFormRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TappableFormRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isNotSet = value == StringConst.kNotSet;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isNotSet
                          ? AppColors.textTertiary.withValues(alpha: 0.5)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFD4E3CC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        StringConst.kVerified,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.sage,
        ),
      ),
    );
  }
}

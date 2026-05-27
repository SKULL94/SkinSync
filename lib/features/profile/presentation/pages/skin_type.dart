import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/core/constants/text_styles.dart';
import 'package:skin_sync/core/di/injection_container.dart';
import 'package:skin_sync/features/profile/presentation/bloc/skin_type_bloc.dart';
import 'package:skin_sync/features/profile/presentation/widgets/info_box.dart';
import 'package:skin_sync/features/profile/presentation/widgets/save_button.dart';
import 'package:skin_sync/features/profile/presentation/widgets/section_label.dart';
import 'package:skin_sync/features/profile/presentation/widgets/sub_header.dart';

class SkinTypeEditorPage extends StatelessWidget {
  const SkinTypeEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SkinTypeBloc>()..add(const SkinTypeLoadRequested()),
      child: const _SkinTypeEditorView(),
    );
  }
}

class _SkinTypeEditorView extends StatelessWidget {
  const _SkinTypeEditorView();

  static const _skinTypes = [
    _SkinTypeData(
      key: 'oily',
      emoji: '💧',
      name: StringConst.kOily,
      desc: StringConst.kOilyDesc,
      fullWidth: false,
    ),
    _SkinTypeData(
      key: 'combo',
      emoji: '⚖️',
      name: StringConst.kCombination,
      desc: StringConst.kComboDesc,
      fullWidth: false,
    ),
    _SkinTypeData(
      key: 'dry',
      emoji: '🌵',
      name: StringConst.kDry,
      desc: StringConst.kDryDesc,
      fullWidth: false,
    ),
    _SkinTypeData(
      key: 'normal',
      emoji: '🌸',
      name: StringConst.kNormal,
      desc: StringConst.kNormalDesc,
      fullWidth: false,
    ),
    _SkinTypeData(
      key: 'sensitive',
      emoji: '🌿',
      name: StringConst.kSensitive,
      desc: StringConst.kSensitiveDesc,
      fullWidth: true,
    ),
  ];

  static const _fitzColors = [
    Color(0xFFFDDCC4),
    Color(0xFFF5C5A3),
    Color(0xFFE8A882),
    Color(0xFFC48A5A),
    Color(0xFF8B5E3C),
    Color(0xFF4A2C1A),
  ];

  static const _fitzLabels = [
    'Type I — Very Light',
    'Type II — Light',
    'Type III — Medium Beige',
    'Type IV — Olive',
    'Type V — Brown',
    'Type VI — Deep',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SkinTypeBloc, SkinTypeState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == SkinTypeStatus.success) {
          context.pop();
        }
      },
      builder: (context, state) {
        if (state.status == SkinTypeStatus.loading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              SubHeader(
                superText: StringConst.kProfile,
                title: StringConst.kMySkinType,
                onBack: () => context.pop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const InfoBox(
                        icon: Icons.info_outline_rounded,
                        text: StringConst.kSkinTypeInfo,
                      ),
                      const SizedBox(height: 14),
                      const SectionLabel(StringConst.kSelectYourSkinType),
                      const SizedBox(height: 8),
                      _buildSkinTypeGrid(context, state),
                      const SizedBox(height: 14),
                      const SectionLabel(StringConst.kSkinTone),
                      const SizedBox(height: 8),
                      _buildFitzpatrickCard(context, state),
                      const SizedBox(height: 24),
                      SaveButton(
                        label: StringConst.kSaveSkinProfile,
                        isLoading: state.status == SkinTypeStatus.saving,
                        onTap: () => context
                            .read<SkinTypeBloc>()
                            .add(const SkinTypeSaveRequested()),
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

  Widget _buildSkinTypeGrid(BuildContext context, SkinTypeState state) {
    final gridCards = _skinTypes.where((t) => !t.fullWidth).toList();
    final fullCard = _skinTypes.firstWhere((t) => t.fullWidth);

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 11,
            mainAxisSpacing: 11,
            childAspectRatio: 1.05,
          ),
          itemCount: gridCards.length,
          itemBuilder: (_, i) {
            final type = gridCards[i];
            return _SkinTypeCard(
              data: type,
              isSelected: state.selectedType == type.key,
              onTap: () => context
                  .read<SkinTypeBloc>()
                  .add(SkinTypeSelected(type.key)),
            );
          },
        ),
        const SizedBox(height: 11),
        _SkinTypeCardFull(
          data: fullCard,
          isSelected: state.selectedType == fullCard.key,
          onTap: () => context
              .read<SkinTypeBloc>()
              .add(SkinTypeSelected(fullCard.key)),
        ),
      ],
    );
  }

  Widget _buildFitzpatrickCard(BuildContext context, SkinTypeState state) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringConst.kFitzpatrickScale,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              color: AppColors.textTertiary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(_fitzColors.length, (i) {
              final sel = state.selectedFitzpatrick == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => context
                      .read<SkinTypeBloc>()
                      .add(SkinTypeFitzpatrickChanged(i)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(left: i == 0 ? 0 : 6),
                    height: 32,
                    decoration: BoxDecoration(
                      color: _fitzColors[i],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: sel ? AppColors.primary : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                color: _fitzColors[i].withValues(alpha: 0.5),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(
            _fitzLabels[state.selectedFitzpatrick],
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkinTypeData {
  final String key;
  final String emoji;
  final String name;
  final String desc;
  final bool fullWidth;

  const _SkinTypeData({
    required this.key,
    required this.emoji,
    required this.name,
    required this.desc,
    required this.fullWidth,
  });
}

class _SkinTypeCard extends StatelessWidget {
  final _SkinTypeData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _SkinTypeCard({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0D4C2) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: const Center(
                    child: Icon(Icons.check, size: 11, color: Colors.white),
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 10),
                Text(
                  data.name,
                  style: AppTextStyles.heading3.copyWith(
                    fontSize: 15,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.desc,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkinTypeCardFull extends StatelessWidget {
  final _SkinTypeData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _SkinTypeCardFull({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0D4C2) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(data.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name,
                    style: AppTextStyles.heading3.copyWith(
                      fontSize: 15,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.desc,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 12),
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Center(
                  child: Icon(Icons.check, size: 11, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

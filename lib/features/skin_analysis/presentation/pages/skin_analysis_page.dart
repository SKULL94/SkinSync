import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skin_sync/core/utils/snackbar_helper.dart';
import 'package:skin_sync/features/skin_analysis/presentation/bloc/skin_analysis_bloc.dart';
import 'package:skin_sync/core/utils/mediaquery.dart';

class SkinAnalysisPage extends StatelessWidget {
  const SkinAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Skin Analysis',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: getResponsiveFontSize(context, 18),
          ),
        ),
        actions: [
          BlocBuilder<SkinAnalysisBloc, SkinAnalysisState>(
            builder: (context, state) {
              if (state.results.isNotEmpty) {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        context.read<SkinAnalysisBloc>().add(
                              const SkinAnalysisShareRequested(),
                            );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: state.status == SkinAnalysisStatus.saving
                          ? null
                          : () {
                              context.read<SkinAnalysisBloc>().add(
                                    const SkinAnalysisSaveRequested(),
                                  );
                            },
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<SkinAnalysisBloc, SkinAnalysisState>(
        listenWhen: (previous, current) =>
            previous.status != current.status,
        listener: (context, state) {
          if (state.status == SkinAnalysisStatus.failure &&
              state.errorMessage != null) {
            SnackbarHelper.showError(context, state.errorMessage!);
          }
          if (state.status == SkinAnalysisStatus.saved) {
            SnackbarHelper.showSuccess(context, 'Analysis saved successfully');
          }
        },
        builder: (context, state) {
          if (state.status == SkinAnalysisStatus.analyzing) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing your skin...'),
                ],
              ),
            );
          }

          if (state.selectedImage != null && state.results.isNotEmpty) {
            return _buildResultsView(context, state, theme);
          }

          return _buildInitialView(context, theme);
        },
      ),
    );
  }

  Widget _buildInitialView(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.face_retouching_natural,
            size: getWidth(context, 100),
            color: theme.colorScheme.primary,
          ),
          SizedBox(height: getHeight(context, 24)),
          Text(
            'Analyze Your Skin',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: getHeight(context, 8)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: getWidth(context, 32)),
            child: Text(
              'Take a clear photo of your skin to get an AI-powered analysis',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(height: getHeight(context, 32)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () => _pickImage(context, ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
              ),
              SizedBox(width: getWidth(context, 16)),
              OutlinedButton.icon(
                onPressed: () => _pickImage(context, ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView(
    BuildContext context,
    SkinAnalysisState state,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(getWidth(context, 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              state.selectedImage!,
              width: double.infinity,
              height: getHeight(context, 250),
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: getHeight(context, 24)),
          Text(
            'Analysis Results',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: getHeight(context, 16)),
          ...state.results.map(
            (result) => _buildResultCard(context, result, theme),
          ),
          SizedBox(height: getHeight(context, 16)),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<SkinAnalysisBloc>().add(const SkinAnalysisReset());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Analyze Another Image'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(
    BuildContext context,
    dynamic result,
    ThemeData theme,
  ) {
    final riskColor = Color(result.riskColorValue);

    return Card(
      margin: EdgeInsets.only(bottom: getHeight(context, 8)),
      child: Padding(
        padding: EdgeInsets.all(getWidth(context, 16)),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: riskColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: getWidth(context, 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.displayLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: getHeight(context, 4)),
                  Text(
                    result.riskLevel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: riskColor,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${(result.confidence * 100).toStringAsFixed(1)}%',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (pickedFile != null && context.mounted) {
      context.read<SkinAnalysisBloc>().add(
            SkinAnalysisImageSelected(File(pickedFile.path)),
          );
    }
  }
}

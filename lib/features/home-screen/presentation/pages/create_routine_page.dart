import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/core/utils/snackbar_helper.dart';
import 'package:skin_sync/features/home-screen/presentation/bloc/routine_bloc.dart';
import 'package:skin_sync/core/utils/mediaquery.dart';

class CreateRoutinePage extends StatefulWidget {
  const CreateRoutinePage({super.key});

  @override
  State<CreateRoutinePage> createState() => _CreateRoutinePageState();
}

class _CreateRoutinePageState extends State<CreateRoutinePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create New Routine',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: getResponsiveFontSize(context, 18),
          ),
        ),
        surfaceTintColor: theme.colorScheme.surface,
      ),
      body: BlocConsumer<RoutineBloc, RoutineState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == RoutineStatus.created) {
            SnackbarHelper.showSuccess(context, 'Routine created successfully');
            context.pop();
          }
          if (state.status == RoutineStatus.failure &&
              state.errorMessage != null) {
            SnackbarHelper.showError(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: getWidth(context, 20),
                vertical: getHeight(context, 20),
              ),
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, theme),
                      SizedBox(height: getHeight(context, 24)),
                      _buildIconUpload(context, state),
                      SizedBox(height: getHeight(context, 24)),
                      _buildFormFields(context, theme),
                      SizedBox(height: getHeight(context, 24)),
                      _buildTimeSelector(context, state, theme),
                      SizedBox(height: getHeight(context, 16)),
                      _buildStartDateSelector(context, state, theme),
                      SizedBox(height: getHeight(context, 16)),
                      _buildEndDateSelector(context, state, theme),
                      SizedBox(height: getHeight(context, 24)),
                      _buildSaveButton(context, state),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Routine Details',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: getHeight(context, 8)),
        Text(
          'Create a personalized skincare routine',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildIconUpload(BuildContext context, RoutineState state) {
    return GestureDetector(
      onTap: () => _pickImage(context),
      child: Container(
        width: getWidth(context, 100),
        height: getWidth(context, 100),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          image: state.localIcon != null
              ? DecorationImage(
                  image: FileImage(state.localIcon!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: state.localIcon == null
            ? Icon(
                Icons.add_a_photo,
                size: getWidth(context, 40),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              )
            : null,
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (pickedFile != null && context.mounted) {
      context.read<RoutineBloc>().add(
            RoutineIconChanged(File(pickedFile.path)),
          );
    }
  }

  Widget _buildFormFields(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Routine Name',
            hintText: 'e.g., Morning Skincare',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a routine name';
            }
            return null;
          },
        ),
        SizedBox(height: getHeight(context, 16)),
        TextFormField(
          controller: _descController,
          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'Describe your routine',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTimeSelector(
    BuildContext context,
    RoutineState state,
    ThemeData theme,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.access_time,
        color: theme.colorScheme.primary,
      ),
      title: const Text('Time'),
      subtitle: Text(state.selectedTime.format(context)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _selectTime(context, state),
    );
  }

  Future<void> _selectTime(BuildContext context, RoutineState state) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: state.selectedTime,
    );
    if (picked != null && context.mounted) {
      context.read<RoutineBloc>().add(RoutineTimeChanged(picked));
    }
  }

  Widget _buildStartDateSelector(
    BuildContext context,
    RoutineState state,
    ThemeData theme,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.calendar_today,
        color: theme.colorScheme.primary,
      ),
      title: const Text('Start Date'),
      subtitle: Text(DateFormat('MMM d, yyyy').format(state.startDate)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _selectStartDate(context, state),
    );
  }

  Future<void> _selectStartDate(
    BuildContext context,
    RoutineState state,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: state.startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && context.mounted) {
      context.read<RoutineBloc>().add(RoutineStartDateChanged(picked));
    }
  }

  Widget _buildEndDateSelector(
    BuildContext context,
    RoutineState state,
    ThemeData theme,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(
        Icons.event,
        color: theme.colorScheme.primary,
      ),
      title: const Text('End Date'),
      subtitle: state.endDate != null
          ? Text(DateFormat('MMM d, yyyy').format(state.endDate!))
          : const Text('No end date'),
      value: state.endDate != null,
      onChanged: (value) {
        if (value) {
          _selectEndDate(context, state);
        } else {
          context.read<RoutineBloc>().add(const RoutineEndDateChanged(null));
        }
      },
    );
  }

  Future<void> _selectEndDate(BuildContext context, RoutineState state) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: state.endDate ?? state.startDate,
      firstDate: state.startDate,
      lastDate: DateTime(2100),
    );
    if (picked != null && context.mounted) {
      context.read<RoutineBloc>().add(RoutineEndDateChanged(picked));
    }
  }

  Widget _buildSaveButton(BuildContext context, RoutineState state) {
    return FilledButton(
      onPressed: state.status == RoutineStatus.creating
          ? null
          : () {
              if (_formKey.currentState!.validate()) {
                context.read<RoutineBloc>().add(
                      RoutineCreateRequested(
                        name: _nameController.text.trim(),
                        description: _descController.text.trim(),
                        time: state.selectedTime,
                        startDate: state.startDate,
                        endDate: state.endDate,
                        iconFile: state.localIcon,
                      ),
                    );
              }
            },
      style: FilledButton.styleFrom(
        minimumSize: Size(double.infinity, getHeight(context, 50)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: state.status == RoutineStatus.creating
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Save Routine'),
    );
  }
}

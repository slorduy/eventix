import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:flutter/material.dart';

class CatalogFilterOption {
  final String id;
  final String name;

  const CatalogFilterOption({required this.id, required this.name});
}

class CatalogFilterSelect extends StatelessWidget {
  final String label;
  final String allLabel;
  final String loadingLabel;
  final String? errorMessage;
  final String? selectedId;
  final List<CatalogFilterOption> options;
  final ValueChanged<String?> onChanged;
  final Widget icon;
  final bool isLoading;

  const CatalogFilterSelect({
    super.key,
    required this.label,
    required this.allLabel,
    required this.loadingLabel,
    required this.errorMessage,
    required this.selectedId,
    required this.options,
    required this.onChanged,
    required this.icon,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) => AppSelect<String?>(
    label: label,
    hintText: isLoading ? loadingLabel : allLabel,
    value: selectedId,
    items: [
      AppSelectItem<String?>(value: null, label: allLabel),
      for (final option in options)
        AppSelectItem<String?>(value: option.id, label: option.name),
    ],
    onChanged: isLoading || errorMessage != null ? null : onChanged,
    isDisabled: isLoading || errorMessage != null,
    errorText: errorMessage,
    prefixIcon: icon,
  );
}

import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/domain/entities/category.dart';
import 'package:eventix/domain/entities/city.dart';
import 'package:eventix/domain/entities/event_filter.dart';
import 'package:eventix/presentation/widgets/catalog_filter_select.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventFilters extends StatefulWidget {
  final EventFilter filter;
  final AsyncValue<List<Category>> categories;
  final AsyncValue<List<City>> cities;
  final ValueChanged<EventFilter> onApply;
  final VoidCallback onClear;
  final VoidCallback onRetryOptions;

  const EventFilters({
    super.key,
    required this.filter,
    required this.categories,
    required this.cities,
    required this.onApply,
    required this.onClear,
    required this.onRetryOptions,
  });

  @override
  State<EventFilters> createState() => _EventFiltersState();
}

class _EventFiltersState extends State<EventFilters> {
  String? _categoryId;
  String? _cityId;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.filter.categoryId;
    _cityId = widget.filter.cityId;
    _dateFrom = widget.filter.dateFrom;
    _dateTo = widget.filter.dateTo;
  }

  @override
  void didUpdateWidget(covariant EventFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter.categoryId != widget.filter.categoryId) {
      _categoryId = widget.filter.categoryId;
    }
    if (oldWidget.filter.cityId != widget.filter.cityId) {
      _cityId = widget.filter.cityId;
    }
    if (oldWidget.filter.dateFrom != widget.filter.dateFrom ||
        oldWidget.filter.dateTo != widget.filter.dateTo) {
      _dateFrom = widget.filter.dateFrom;
      _dateTo = widget.filter.dateTo;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _selectDates() async {
    final today = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(today.year + 10),
      initialDateRange: _dateFrom != null && _dateTo != null
          ? DateTimeRange(start: _dateFrom!, end: _dateTo!)
          : null,
      helpText: 'Selecciona el rango de fechas',
      cancelText: 'Cancelar',
      confirmText: 'Aplicar',
    );

    if (range == null || !mounted) return;
    setState(() {
      _dateFrom = range.start;
      _dateTo = range.end;
    });
  }

  void _apply() {
    widget.onApply(
      EventFilter(
        categoryId: _categoryId,
        cityId: _cityId,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
      ),
    );
  }

  void _clear() {
    setState(() {
      _categoryId = null;
      _cityId = null;
      _dateFrom = null;
      _dateTo = null;
    });
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.categories.asData?.value ?? const <Category>[];
    final cities = widget.cities.asData?.value ?? const <City>[];
    final optionsError = widget.categories.hasError || widget.cities.hasError;

    return AppCard.flat(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.titleMedium('Filtrar eventos'),
          const SizedBox(height: AppSpacing.sm),
          CatalogFilterSelect(
            label: 'Categoría',
            allLabel: 'Todas las categorías',
            loadingLabel: 'Cargando categorías...',
            selectedId: _categoryId,
            options: [
              for (final category in categories)
                CatalogFilterOption(id: category.id, name: category.name),
            ],
            onChanged: (value) => setState(() => _categoryId = value),
            isLoading: widget.categories.isLoading,
            errorMessage: widget.categories.hasError
                ? 'No se pudieron cargar las categorías'
                : null,
            icon: const Icon(Icons.category_outlined),
          ),
          const SizedBox(height: AppSpacing.sm),
          CatalogFilterSelect(
            label: 'Ciudad',
            allLabel: 'Todas las ciudades',
            loadingLabel: 'Cargando ciudades...',
            selectedId: _cityId,
            options: [
              for (final city in cities)
                CatalogFilterOption(id: city.id, name: city.name),
            ],
            onChanged: (value) => setState(() => _cityId = value),
            isLoading: widget.cities.isLoading,
            errorMessage: widget.cities.hasError
                ? 'No se pudieron cargar las ciudades'
                : null,
            icon: const Icon(Icons.location_city_outlined),
          ),
          if (optionsError) ...[
            const SizedBox(height: AppSpacing.sm),
            AppButton.ghost(
              label: 'Reintentar cargar filtros',
              onPressed: widget.onRetryOptions,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          AppButton.outline(
            label: _dateLabel,
            onPressed: _selectDates,
            isFullWidth: true,
            icon: const Icon(Icons.calendar_month_outlined),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppButton.primary(
                  label: 'Aplicar filtros',
                  onPressed: _apply,
                  isFullWidth: true,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppButton.ghost(label: 'Limpiar', onPressed: _clear),
            ],
          ),
        ],
      ),
    );
  }

  String get _dateLabel {
    if (_dateFrom == null || _dateTo == null) return 'Todas las fechas';
    return '${_formatDate(_dateFrom!)} – ${_formatDate(_dateTo!)}';
  }

  static String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}

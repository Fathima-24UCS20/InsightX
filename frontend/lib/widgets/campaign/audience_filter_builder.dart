import 'package:flutter/material.dart';
import '../../models/audience_filter.dart';

/// Lets the user build the audience out of real conditions
/// ("city is Phoenix", "inactive for 60+ days") instead of typing a
/// free-text description. Each condition maps to a filter you can
/// actually run against `customers`/`orders`.
class AudienceFilterBuilder extends StatefulWidget {
  final AudienceFilter initialValue;
  final List<String> cityOptions;
  final List<String> categoryOptions;
  final ValueChanged<AudienceFilter> onChanged;

  const AudienceFilterBuilder({
    super.key,
    required this.initialValue,
    required this.cityOptions,
    required this.categoryOptions,
    required this.onChanged,
  });

  @override
  State<AudienceFilterBuilder> createState() => _AudienceFilterBuilderState();
}

class _AudienceFilterBuilderState extends State<AudienceFilterBuilder> {
  late List<AudienceCondition> _conditions;

  @override
  void initState() {
    super.initState();
    _conditions = List.of(widget.initialValue.conditions);
  }

  void _emit() => widget.onChanged(AudienceFilter(conditions: _conditions));

  void _addCondition() async {
    final condition = await showDialog<AudienceCondition>(
      context: context,
      builder: (_) => _AddConditionDialog(
        cityOptions: widget.cityOptions,
        categoryOptions: widget.categoryOptions,
      ),
    );
    if (condition != null) {
      setState(() => _conditions.add(condition));
      _emit();
    }
  }

  void _removeAt(int index) {
    setState(() => _conditions.removeAt(index));
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Target Audience',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < _conditions.length; i++)
              Chip(
                avatar: const Icon(Icons.people_outline, size: 18),
                label: Text(_conditions[i].toDescription()),
                onDeleted: () => _removeAt(i),
              ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: const Text('Add condition'),
              onPressed: _addCondition,
            ),
          ],
        ),
        if (_conditions.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'No conditions set — campaign will target all customers.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
      ],
    );
  }
}

class _AddConditionDialog extends StatefulWidget {
  final List<String> cityOptions;
  final List<String> categoryOptions;

  const _AddConditionDialog({
    required this.cityOptions,
    required this.categoryOptions,
  });

  @override
  State<_AddConditionDialog> createState() => _AddConditionDialogState();
}

class _AddConditionDialogState extends State<_AddConditionDialog> {
  AudienceField _field = AudienceField.city;
  final _valueController = TextEditingController();
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    final usesDropdown =
        _field == AudienceField.city || _field == AudienceField.category;
    final options =
        _field == AudienceField.city ? widget.cityOptions : widget.categoryOptions;

    return AlertDialog(
      title: const Text('Add audience condition'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<AudienceField>(
            value: _field,
            decoration: const InputDecoration(labelText: 'Field'),
            items: AudienceField.values
                .map((f) => DropdownMenuItem(value: f, child: Text(f.label)))
                .toList(),
            onChanged: (f) => setState(() {
              _field = f!;
              _selectedOption = null;
              _valueController.clear();
            }),
            isExpanded: true,
          ),
          const SizedBox(height: 12),
          if (usesDropdown)
            DropdownButtonFormField<String>(
              value: _selectedOption,
              decoration: const InputDecoration(labelText: 'Value'),
              items: options
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedOption = v),
            )
          else
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _field == AudienceField.inactiveDays
                    ? 'Days since last order'
                    : _field == AudienceField.minOrders
                        ? 'Minimum number of orders'
                        : 'Minimum total spend',
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final value = usesDropdown ? _selectedOption : _valueController.text;
            if (value == null || value.isEmpty) return;
            final operatorLabel = switch (_field) {
              AudienceField.city => 'is',
              AudienceField.category => 'purchased',
              AudienceField.inactiveDays => '≥',
              AudienceField.minOrders => '≥',
              AudienceField.totalSpend => '≥',
            };
            Navigator.pop(
              context,
              AudienceCondition(
                field: _field,
                operatorLabel: operatorLabel,
                value: value,
              ),
            );
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
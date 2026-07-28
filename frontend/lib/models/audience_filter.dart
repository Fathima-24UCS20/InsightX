/// A single condition in the audience builder, e.g.
/// "city = Phoenix" or "inactive for 60+ days".
///
/// Kept generic (field/operator/value) so new filter types can be added
/// without changing the schema — this maps directly to the
/// `target_segment` JSON column on the `campaigns` table.
class AudienceCondition {
  final AudienceField field;
  final String operatorLabel; // e.g. "is", "greater than", "purchased"
  final String value;

  const AudienceCondition({
    required this.field,
    required this.operatorLabel,
    required this.value,
  });

  Map<String, dynamic> toJson() => {
        'field': field.key,
        'operator': operatorLabel,
        'value': value,
      };

  factory AudienceCondition.fromJson(Map<String, dynamic> json) {
    return AudienceCondition(
      field: AudienceField.fromKey(json['field'] as String? ?? ''),
      operatorLabel: json['operator'] as String? ?? 'is',
      value: json['value']?.toString() ?? '',
    );
  }

  /// Human-readable form used both in the UI chip and in the prompt
  /// sent to the generation endpoint, e.g. "city is Phoenix".
  String toDescription() => '${field.label} $operatorLabel $value';
}

enum AudienceField {
  city('city', 'City'),
  category('category', 'Purchased category'),
  inactiveDays('inactive_days', 'Inactive for (days)'),
  minOrders('min_orders', 'Minimum orders'),
  totalSpend('total_spend', 'Total spend at least');

  final String key;
  final String label;
  const AudienceField(this.key, this.label);

  static AudienceField fromKey(String key) {
    return AudienceField.values.firstWhere(
      (f) => f.key == key,
      orElse: () => AudienceField.city,
    );
  }
}

/// The full audience definition for a campaign: a set of structured
/// conditions built from real `customers`/`orders` data, rather than
/// a hand-typed description.
class AudienceFilter {
  final List<AudienceCondition> conditions;

  const AudienceFilter({this.conditions = const []});

  bool get isEmpty => conditions.isEmpty;

  Map<String, dynamic> toJson() => {
        'conditions': conditions.map((c) => c.toJson()).toList(),
      };

  factory AudienceFilter.fromJson(Map<String, dynamic> json) {
    final raw = (json['conditions'] as List?) ?? [];
    return AudienceFilter(
      conditions: raw
          .map((c) => AudienceCondition.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Sent to the LLM prompt and shown in the "Audience" summary card,
  /// e.g. "customers in Phoenix who bought Electronics, inactive 60+ days"
  String toDescription() {
    if (conditions.isEmpty) return 'All customers';
    return conditions.map((c) => c.toDescription()).join(', ');
  }
}
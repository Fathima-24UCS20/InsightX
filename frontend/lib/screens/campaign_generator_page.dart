import 'package:flutter/material.dart';

import '../models/audience_filter.dart';
import '../models/campaign.dart';
import '../models/product.dart';
import '../services/campaign_services.dart';
import '../utils/campaign_pdf.dart';
import '../widgets/campaign/audience_filter_builder.dart';
import '../widgets/campaign/generated_campaign_output.dart';

/// Local design tokens for this page, matching the AI-suite visual
/// language (purple accent, soft cards, rounded inputs). Kept local
/// so this page can be restyled without touching the app-wide theme.
class _Palette {
  static const accent = Color(0xFF6D5FFD);
  static const accentDark = Color(0xFF5A4CE0);
  static const accentSoft = Color(0xFFF1EEFF);
  static const pageBg = Color(0xFFF7F7FB);
  static const cardBg = Colors.white;
  static const border = Color(0xFFE7E6F0);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B6B80);
  static const success = Color(0xFF16A34A);
}

/// Small numbered badge + title used for each section header
/// ("1. Campaign Details", "2. AI Generated Campaign", etc.)
class _SectionHeader extends StatelessWidget {
  final int number;
  final String title;
  const _SectionHeader({required this.number, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: _Palette.accent,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: _Palette.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Shared rounded input decoration so every field in this page
/// looks consistent with the mockup (soft fill, rounded corners,
/// purple focus ring).
InputDecoration _fieldDecoration(String label, {String? hint}) {
  OutlineInputBorder border(Color color, double width) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );
  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFFAFAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: border(_Palette.border, 1),
    enabledBorder: border(_Palette.border, 1),
    focusedBorder: border(_Palette.accent, 1.5),
    labelStyle: const TextStyle(color: _Palette.textSecondary, fontSize: 13),
  );
}

/// Pill-shaped channel selector with a colored platform icon and a
/// checkmark badge when selected — mirrors the channel chips in the
/// reference mockup instead of a plain FilterChip.
class _ChannelChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ChannelChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _Palette.accentSoft : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _Palette.accent : _Palette.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_circle, size: 15, color: _Palette.accent),
              const SizedBox(width: 6),
            ] else ...[
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? _Palette.accentDark : _Palette.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedCampaignsDialog extends StatefulWidget {
  final CampaignService service;
  const _SavedCampaignsDialog({required this.service});

  @override
  State<_SavedCampaignsDialog> createState() => _SavedCampaignsDialogState();
}

class _SavedCampaignsDialogState extends State<_SavedCampaignsDialog> {
  List<Campaign>? _campaigns;
  String? _error;
  bool _loading = true;
  int? _deletingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final campaigns = await widget.service.fetchSavedCampaigns();
      setState(() {
        _campaigns = campaigns;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not load saved campaigns: $e';
        _loading = false;
      });
    }
  }

  Future<void> _delete(Campaign c) async {
    if (c.id == null) return;
    setState(() => _deletingId = c.id);
    try {
      await widget.service.deleteCampaign(c.id!);
      setState(() {
        _campaigns?.removeWhere((x) => x.id == c.id);
        _deletingId = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Campaign deleted.')),
        );
      }
    } catch (e) {
      setState(() => _deletingId = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  Future<void> _confirmDelete(Campaign c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete campaign?'),
        content: Text('This will permanently delete "${c.name}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _delete(c);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Saved Campaigns',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Builder(
                  builder: (_) {
                    if (_loading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (_error != null) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 12),
                            OutlinedButton(onPressed: _load, child: const Text('Retry')),
                          ],
                        ),
                      );
                    }
                    if (_campaigns == null || _campaigns!.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: Text('No saved campaigns yet.')),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: _campaigns!.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final c = _campaigns![i];
                        final isDeleting = _deletingId == c.id;
                        return ListTile(
                          title: Text(c.name),
                          subtitle: Text(
                            '${c.objective.label} · ${c.status.name} · '
                            '${c.createdAt.toLocal().toString().split(' ').first}',
                          ),
                          trailing: isDeleting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _confirmDelete(c),
                                ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CampaignGeneratorPage extends StatefulWidget {
  final CampaignService service;
  const CampaignGeneratorPage({super.key, required this.service});

  @override
  State<CampaignGeneratorPage> createState() => _CampaignGeneratorPageState();
}

class _CampaignGeneratorPageState extends State<CampaignGeneratorPage> {
  // Reference data
  List<Product> _products = [];
  List<String> _cities = [];
  List<String> _categories = [];
  bool _loadingReferenceData = true;
  String? _referenceDataError;

  // Form state
  CampaignObjective _objective = CampaignObjective.brandAwareness;
  CampaignGoal _goal = CampaignGoal.increaseSales;

final _budgetController = TextEditingController();
final _discountController = TextEditingController();

DateTime? _startDate;
DateTime? _endDate;
  Product? _selectedProduct;
  AudienceFilter _audience = const AudienceFilter();
  String _tone = 'Professional';
  final Set<CampaignChannel> _channels = {
    CampaignChannel.facebook,
    CampaignChannel.instagram,
    CampaignChannel.linkedin,
    CampaignChannel.twitter,
  };
  final _additionalInfoController = TextEditingController();
  final _campaignNameController = TextEditingController();

  // Generation state
  GeneratedCampaignContent? _generated;
  bool _generating = false;
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReferenceData();
  }

  Future<void> _loadReferenceData() async {
    setState(() {
      _loadingReferenceData = true;
      _referenceDataError = null;
    });
    try {
      final results = await Future.wait([
        widget.service.fetchProducts(),
        widget.service.fetchCustomerCities(),
        widget.service.fetchProductCategories(),
      ]);
      setState(() {
        _products = results[0] as List<Product>;
        _cities = results[1] as List<String>;
        _categories = results[2] as List<String>;
        _loadingReferenceData = false;
      });
    } catch (e) {
      setState(() {
        _referenceDataError = 'Could not load products/customers: $e';
        _loadingReferenceData = false;
      });
    }
  }

  Campaign _buildDraft() {
    return Campaign(
    name: _campaignNameController.text.isNotEmpty
        ? _campaignNameController.text
        : '${_objective.label} — ${_selectedProduct?.name ?? 'Untitled'}',

    objective: _objective,
    goal: _goal,

    productId: _selectedProduct?.id,
    productLabel: _selectedProduct?.displayLabel ?? '',

    audience: _audience,

    channels: _channels.toList(),

    tone: _tone,

    budget: double.tryParse(
    _budgetController.text.replaceAll(",", ""),
),

    discount: double.tryParse(_discountController.text),

    startDate: _startDate,
    endDate: _endDate,

    additionalInfo: _additionalInfoController.text.isEmpty
        ? null
        : _additionalInfoController.text,

    createdAt: DateTime.now(),
);
  }

  Future<void> _generate() async {
    if (_selectedProduct == null) {
      setState(() => _errorMessage = 'Select a product before generating.');
      return;
    }
    setState(() {
      _generating = true;
      _errorMessage = null;
    });
    try {
      final content = await widget.service.generateCampaign(_buildDraft());
      setState(() => _generated = content);
    } catch (e) {
      setState(() => _errorMessage = 'Generation failed: $e');
    } finally {
      setState(() => _generating = false);
    }
  }

  Future<void> _save() async {
    if (_generated == null) return;
    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    try {
      final draft = _buildDraft();
      final toSave = Campaign(
  name: draft.name,
  objective: draft.objective,
  goal: draft.goal,
  productId: draft.productId,
  productLabel: draft.productLabel,
  audience: draft.audience,
  channels: draft.channels,
  tone: draft.tone,
  additionalInfo: draft.additionalInfo,
  budget: draft.budget,
  discount: draft.discount,
  startDate: draft.startDate,
  endDate: draft.endDate,
  generated: _generated,
  status: CampaignStatus.draft,
  createdAt: draft.createdAt,
);
      await widget.service.saveCampaign(toSave);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Campaign saved.')),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Save failed: $e');
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _download() async {
    final content = _generated;
    if (content == null) return;
    try {
      await downloadCampaignPdf(
        campaignName: _campaignNameController.text,
        content: content,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not generate PDF: $e')),
        );
      }
    }
  }

  Future<void> _showSavedCampaignsDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (dialogContext) => _SavedCampaignsDialog(service: widget.service),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingReferenceData) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_referenceDataError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_referenceDataError!),
            const SizedBox(height: 12),
            FilledButton(onPressed: _loadReferenceData, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Container(
      color: _Palette.pageBg,
      // Single scroll surface for the whole page. Neither panel below
      // forces itself into the remaining viewport height anymore, so
      // there's exactly one scrollbar (the page's) instead of small
      // internal scroll regions inside the cards.
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Campaign Generator',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: _Palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Create data-driven marketing campaigns with the power of AI.',
                        style: TextStyle(color: _Palette.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showSavedCampaignsDialog(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _Palette.accent,
                    side: const BorderSide(color: _Palette.accent),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.folder_open_outlined, size: 18),
                  label: const Text('View Saved Campaigns'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            // IntrinsicHeight so the two side-by-side cards can each size
            // to their own content while still lining up horizontally —
            // no forced equal viewport-filling height, no inner scrolling.
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildForm()),
                  const SizedBox(width: 24),
                  Expanded(flex: 3, child: _buildOutputPanel()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      decoration: BoxDecoration(
        color: _Palette.cardBg,
        borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _Palette.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader(number: 1, title: 'Campaign Details'),
              const SizedBox(height: 20),
              TextField(
                controller: _campaignNameController,
                decoration: _fieldDecoration(
                  'Campaign Name (optional)',
                  hint: 'Defaults to objective + product',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<CampaignObjective>(
                value: _objective,
                decoration: _fieldDecoration('Campaign Objective'),
                icon: const Icon(Icons.keyboard_arrow_down, color: _Palette.textSecondary),
                items: CampaignObjective.values
                    .map((o) => DropdownMenuItem(value: o, child: Text(o.label)))
                    .toList(),
                onChanged: (o) => setState(() => _objective = o!),
              ),
              const SizedBox(height: 16),

DropdownButtonFormField<CampaignGoal>(
  value: _goal,
  decoration: _fieldDecoration('Campaign Goal'),
  icon: const Icon(
    Icons.keyboard_arrow_down,
    color: _Palette.textSecondary,
  ),
  items: CampaignGoal.values
      .map(
        (g) => DropdownMenuItem(
          value: g,
          child: Text(g.label),
        ),
      )
      .toList(),
  onChanged: (g) => setState(() => _goal = g!),
),
              const SizedBox(height: 16),
              // Real product dropdown — pulled from your products table,
              // replacing the free-text field in the original mockup.
              DropdownButtonFormField<Product>(
                value: _selectedProduct,
                decoration: _fieldDecoration('Product / Service'),
                icon: const Icon(Icons.keyboard_arrow_down, color: _Palette.textSecondary),
                items: _products
                    .map((p) => DropdownMenuItem(value: p, child: Text(p.displayLabel)))
                    .toList(),
                onChanged: (p) => setState(() => _selectedProduct = p),
                validator: (p) => p == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              // Structured audience builder — replaces the free-text
              // audience field in the original mockup.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _Palette.border),
                ),
                child: AudienceFilterBuilder(
                  initialValue: _audience,
                  cityOptions: _cities,
                  categoryOptions: _categories,
                  onChanged: (a) => setState(() => _audience = a),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tone,
                decoration: _fieldDecoration('Tone of Voice'),
                icon: const Icon(Icons.keyboard_arrow_down, color: _Palette.textSecondary),
                items: const ['Professional', 'Friendly', 'Bold', 'Playful']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (t) => setState(() => _tone = t!),
              ),
              const SizedBox(height: 16),

Row(
  children: [
    Expanded(
      child: TextField(
        controller: _budgetController,
        keyboardType: TextInputType.number,
        decoration: _fieldDecoration(
          'Budget (₹)',
          hint: '50000',
        ),
      ),
    ),
    const SizedBox(width: 16),
    Expanded(
      child: TextField(
        controller: _discountController,
        keyboardType: TextInputType.number,
        decoration: _fieldDecoration(
          'Discount (%)',
          hint: '10',
        ),
      ),
    ),
  ],
),
const SizedBox(height: 16),

Row(
  children: [
    Expanded(
      child: OutlinedButton.icon(
        icon: const Icon(Icons.calendar_today),
        label: Text(
          _startDate == null
              ? 'Start Date'
              : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
        ),
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2024),
            lastDate: DateTime(2035),
          );

          if (picked != null) {
  setState(() => _startDate = picked);

  if (_endDate != null &&
      _endDate!.isBefore(_startDate!)) {
    _endDate = null;
  }
}
        },
      ),
    ),

    const SizedBox(width: 16),

    Expanded(
      child: OutlinedButton.icon(
        icon: const Icon(Icons.calendar_today),
        label: Text(
          _endDate == null
              ? 'End Date'
              : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
        ),
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _startDate ?? DateTime.now(),
            firstDate: DateTime(2024),
            lastDate: DateTime(2035),
          );

          if (picked != null) {

  if (_startDate != null &&
      picked.isBefore(_startDate!)) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("End Date cannot be before Start Date"),
      ),
    );

    return;
  }

  setState(() {
    _endDate = picked;
  });
}
        },
      ),
    ),
  ],
),
              const SizedBox(height: 20),
              const Text(
                'Campaign Channels',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _Palette.textPrimary),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CampaignChannel.values.map((c) {
                  final selected = _channels.contains(c);
                  return _ChannelChip(
                    label: c.label,
                    icon: _channelIcon(c),
                    color: _channelColor(c),
                    selected: selected,
                    onTap: () => setState(
                        () => selected ? _channels.remove(c) : _channels.add(c)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _additionalInfoController,
                maxLines: 3,
                decoration: _fieldDecoration(
                  'Additional Information (Optional)',
                  hint: 'e.g., Focus on unique features, mention AI insights and automation.',
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: _generating
                        ? null
                        : const LinearGradient(
                            colors: [_Palette.accent, _Palette.accentDark],
                          ),
                    color: _generating ? _Palette.border : null,
                  ),
                  child: FilledButton.icon(
                    onPressed: _generating ? null : _generate,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _generating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.auto_awesome, size: 18),
                    label: Text(
                      _generating ? 'Generating…' : 'Generate Campaign',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  IconData _channelIcon(CampaignChannel c) {
    switch (c.label.toLowerCase()) {
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons.camera_alt_outlined;
      case 'linkedin':
        return Icons.business_center_outlined;
      case 'twitter':
      case 'twitter / x':
      case 'x':
        return Icons.alternate_email;
      case 'email':
        return Icons.mail_outline;
      default:
        return Icons.share_outlined;
    }
  }

  Color _channelColor(CampaignChannel c) {
    switch (c.label.toLowerCase()) {
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'instagram':
        return const Color(0xFFE1306C);
      case 'linkedin':
        return const Color(0xFF0A66C2);
      case 'twitter':
      case 'twitter / x':
      case 'x':
        return const Color(0xFF111111);
      case 'email':
        return const Color(0xFF6B6B80);
      default:
        return _Palette.accent;
    }
  }

  Widget _buildOutputPanel() {
    final boxDecoration = BoxDecoration(
      color: _Palette.cardBg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _Palette.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );

    if (_generated == null) {
      return Container(
        decoration: boxDecoration,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: _Palette.accentSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _generating ? Icons.auto_awesome : Icons.campaign_outlined,
                    color: _Palette.accent,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 16),
                if (_generating) ...[
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.4, color: _Palette.accent),
                  ),
                  const SizedBox(height: 14),
                ],
                Text(
                  _generating
                      ? 'Generating your campaign…'
                      : 'Fill in the form and generate a campaign to see it here.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _Palette.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Container(
      decoration: boxDecoration,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryStrip(),
            const SizedBox(height: 20),
            const _SectionHeader(number: 2, title: 'AI Generated Campaign'),
            const SizedBox(height: 14),
            GeneratedCampaignOutput(
              content: _generated!,
              onRegenerate: _generating ? () {} : _generate,
              onDownload: _download,
              onSave: _saving ? () {} : _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStrip() {
    final items = [
  ('Objective', _objective.label, Icons.track_changes),
  ('Goal', _goal.label, Icons.flag_outlined),
  ('Product', _selectedProduct?.name ?? '-', Icons.shopping_bag_outlined),
  ('Audience', _audience.toDescription(), Icons.people_outline),
  ('Channels', '${_channels.length} selected', Icons.share_outlined),
  (
    'Generated On',
    _generated?.generatedAt.toString().split('.').first ?? '',
    Icons.access_time,
  ),
];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map((i) => Container(
                width: 180,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _Palette.accentSoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _Palette.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(i.$3, size: 18, color: _Palette.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(i.$1,
                              style: const TextStyle(
                                  fontSize: 11, color: _Palette.textSecondary)),
                          const SizedBox(height: 2),
                          Text(i.$2,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _Palette.textPrimary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
  @override
void dispose() {
  _campaignNameController.dispose();
  _additionalInfoController.dispose();
  _budgetController.dispose();
  _discountController.dispose();

  super.dispose();
}  
}
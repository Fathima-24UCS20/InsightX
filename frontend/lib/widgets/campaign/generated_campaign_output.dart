import 'package:flutter/material.dart';
import '../../models/campaign.dart';

// Local palette matching campaign_generator_page.dart's accent theme,
// kept here too so this widget looks consistent wherever it's dropped in.
class _Palette {
  static const accent = Color(0xFF6D5FFD);
  static const accentSoft = Color(0xFFF1EEFF);
  static const border = Color(0xFFE7E6F0);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B6B80);
}

/// Renders the generated campaign's tabs and action buttons.
///
/// IMPORTANT: this widget does NOT scroll internally and does NOT force
/// itself into a fixed height. It sizes to however tall its content is,
/// and relies on the page that hosts it (CampaignGeneratorPage) to be
/// the single scrollable surface. That's what avoids the "scrolling in
/// a tiny box" problem — there is now exactly one scrollbar for the
/// whole page instead of nested scroll regions.
class GeneratedCampaignOutput extends StatefulWidget {
  final GeneratedCampaignContent content;
  final VoidCallback onRegenerate;
  final VoidCallback onDownload;
  final VoidCallback onSave;

  const GeneratedCampaignOutput({
    super.key,
    required this.content,
    required this.onRegenerate,
    required this.onDownload,
    required this.onSave,
  });

  @override
  State<GeneratedCampaignOutput> createState() => _GeneratedCampaignOutputState();
}

class _GeneratedCampaignOutputState extends State<GeneratedCampaignOutput> {
  static const _tabLabels = [
    'Overview',
    'Social Media Posts',
    'Email Copy',
    'Ad Copy',
    'Hashtags',
  ];

  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _TabStrip(
          labels: _tabLabels,
          selected: _selected,
          onSelect: (i) => setState(() => _selected = i),
        ),
        const SizedBox(height: 16),
        // Only the selected tab is built — no TabBarView, no bounded
        // height, no internal scroll view. Content just takes the
        // height it needs.
        IndexedStack(
          index: _selected,
          alignment: Alignment.topLeft,
          sizing: StackFit.passthrough,
          children: [
            Offstage(offstage: _selected != 0, child: _OverviewTab(content: content)),
            Offstage(offstage: _selected != 1, child: _SocialTab(posts: content.socialMediaPosts)),
            Offstage(
              offstage: _selected != 2,
              child: _EmailTab(subject: content.emailSubject, body: content.emailBody),
            ),
            Offstage(offstage: _selected != 3, child: _AdCopyTab(adCopy: content.adCopy)),
            Offstage(offstage: _selected != 4, child: _HashtagsTab(hashtags: content.hashtags)),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: widget.onRegenerate,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Regenerate'),
            ),
            OutlinedButton.icon(
              onPressed: widget.onDownload,
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Download'),
            ),
            FilledButton.icon(
              onPressed: widget.onSave,
              icon: const Icon(Icons.bookmark_outline, size: 18),
              label: const Text('Save Campaign'),
              style: FilledButton.styleFrom(backgroundColor: _Palette.accent),
            ),
          ],
        ),
      ],
    );
  }
}

/// A manual tab strip (replaces Material's TabBar/DefaultTabController)
/// so switching tabs doesn't require a bounded-height TabBarView.
class _TabStrip extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;
  const _TabStrip({required this.labels, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(labels.length, (i) {
          final isSelected = i == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 22),
            child: InkWell(
              onTap: () => onSelect(i),
              child: Container(
                padding: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? _Palette.accent : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? _Palette.accent : _Palette.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final GeneratedCampaignContent content;
  const _OverviewTab({required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_Palette.accent, Color(0xFF8B7CFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('CAMPAIGN HEADLINE',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Text(
                content.headline,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SummaryCard(
          icon: Icons.description_outlined,
          title: 'Campaign Summary',
          body: content.summary,
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          icon: Icons.chat_bubble_outline,
          title: 'Key Message',
          body: content.keyMessage,
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          icon: Icons.flag_outlined,
          title: 'Call to Action',
          body: content.callToAction,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _SummaryCard({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final hasBody = body.trim().isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Palette.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: _Palette.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 17, color: _Palette.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _Palette.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  hasBody ? body : 'Not generated for this campaign.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: hasBody ? _Palette.textPrimary : _Palette.textSecondary,
                    fontStyle: hasBody ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialTab extends StatelessWidget {
  final List<String> posts;
  const _SocialTab({required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const _EmptyState(
        icon: Icons.forum_outlined,
        message: 'No posts generated.',
      );
    }
    // Plain Column instead of ListView — sizes to content so the page
    // (not this widget) owns the scrolling.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < posts.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _Palette.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: _Palette.accentSoft,
                  child: Text('${i + 1}',
                      style: const TextStyle(
                          color: _Palette.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(posts[i],
                      style: const TextStyle(fontSize: 14, height: 1.4)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _EmailTab extends StatelessWidget {
  final String subject;
  final String body;
  const _EmailTab({required this.subject, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Subject',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _Palette.textSecondary)),
        const SizedBox(height: 4),
        Text(subject.isEmpty ? 'Not generated for this campaign.' : subject,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontStyle: subject.isEmpty ? FontStyle.italic : FontStyle.normal,
              color: subject.isEmpty ? _Palette.textSecondary : _Palette.textPrimary,
            )),
        const SizedBox(height: 16),
        const Text('Body',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _Palette.textSecondary)),
        const SizedBox(height: 4),
        Text(body.isEmpty ? 'Not generated for this campaign.' : body,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              fontStyle: body.isEmpty ? FontStyle.italic : FontStyle.normal,
              color: body.isEmpty ? _Palette.textSecondary : _Palette.textPrimary,
            )),
      ],
    );
  }
}

class _AdCopyTab extends StatelessWidget {
  final String adCopy;
  const _AdCopyTab({required this.adCopy});

  @override
  Widget build(BuildContext context) {
    if (adCopy.trim().isEmpty) {
      return const _EmptyState(icon: Icons.ads_click_outlined, message: 'No ad copy generated.');
    }
    return Text(adCopy, style: const TextStyle(fontSize: 14, height: 1.5));
  }
}

class _HashtagsTab extends StatelessWidget {
  final List<String> hashtags;
  const _HashtagsTab({required this.hashtags});

  @override
  Widget build(BuildContext context) {
    if (hashtags.isEmpty) {
      return const _EmptyState(icon: Icons.tag, message: 'No hashtags generated.');
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: hashtags
          .map((h) => Chip(
                label: Text(h),
                backgroundColor: _Palette.accentSoft,
                labelStyle: const TextStyle(color: _Palette.accent, fontWeight: FontWeight.w500),
                side: BorderSide.none,
              ))
          .toList(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: _Palette.textSecondary),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(color: _Palette.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}
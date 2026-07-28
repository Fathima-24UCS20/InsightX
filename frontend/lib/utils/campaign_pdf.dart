import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/campaign.dart';

/// Builds a single PDF combining all five tabs (Overview, Social,
/// Email, Ad Copy, Hashtags) and triggers a download/share sheet.
/// Takes the campaign name and generated content directly rather than
/// a full Campaign object, since this can be called before the
/// campaign is saved (campaign_id may not exist yet).
Future<void> downloadCampaignPdf({
  required String campaignName,
  required GeneratedCampaignContent content,
}) async {
  final doc = pw.Document();
  final title = campaignName.trim().isEmpty ? 'Untitled Campaign' : campaignName.trim();

  doc.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Header(text: title),
        pw.SizedBox(height: 12),

        pw.Text('Overview', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Text('Headline: ${content.headline}'),
        pw.SizedBox(height: 6),
        pw.Text('Summary: ${content.summary}'),
        pw.SizedBox(height: 6),
        pw.Text('Key Message: ${content.keyMessage}'),
        pw.SizedBox(height: 6),
        pw.Text('Call to Action: ${content.callToAction}'),
        pw.SizedBox(height: 16),

        pw.Text('Social Media Posts', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        if (content.socialMediaPosts.isEmpty)
          pw.Text('No posts generated.')
        else
          ...content.socialMediaPosts.map(
            (p) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text(p),
            ),
          ),
        pw.SizedBox(height: 16),

        pw.Text('Email Copy', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Text('Subject: ${content.emailSubject}'),
        pw.SizedBox(height: 6),
        pw.Text(content.emailBody),
        pw.SizedBox(height: 16),

        pw.Text('Ad Copy', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Text(content.adCopy.isEmpty ? 'No ad copy generated.' : content.adCopy),
        pw.SizedBox(height: 16),

        pw.Text('Hashtags', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Text(content.hashtags.isEmpty ? 'No hashtags generated.' : content.hashtags.join('  ')),
      ],
    ),
  );

  final bytes = await doc.save();
  await Printing.sharePdf(
    bytes: bytes,
    filename: '${title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_')}.pdf',
  );
}
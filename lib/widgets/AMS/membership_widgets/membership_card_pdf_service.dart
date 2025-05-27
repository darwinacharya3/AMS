// import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;

class MembershipCardPdfService {
  /// Generate and share a PDF version of the membership card
  static Future<void> generateAndSharePdf({
    required Map<String, dynamic> cardData,
    required String? membershipTypeName,
    required Uint8List? logoImageBytes,
    required Color primaryBlue,
    required Color pinkBackground,
    required Color sloganTextColor,
  }) async {
    try {
      final pdf = pw.Document();
      
      // Load ExtraTech logo image for PDF
      pw.MemoryImage? logoImage;
      if (logoImageBytes != null) {
        logoImage = pw.MemoryImage(logoImageBytes);
      }
      
      // Get profile image for PDF if available
      pw.MemoryImage? profileImage;
      try {
        if (cardData['photo_url'] != null) {
          final http.Response response = await http.get(Uri.parse(cardData['photo_url']));
          if (response.statusCode == 200) {
            profileImage = pw.MemoryImage(response.bodyBytes);
          }
        }
      } catch (e) {
        debugPrint('Error loading profile image for PDF: $e');
      }

      // Get QR code for PDF
      pw.MemoryImage? qrImage;
      try {
        if (cardData['qr_code'] != null) {
          final http.Response response = await http.get(Uri.parse(cardData['qr_code']));
          if (response.statusCode == 200) {
            qrImage = pw.MemoryImage(response.bodyBytes);
          }
        }
      } catch (e) {
        debugPrint('Error loading QR code for PDF: $e');
      }

      // Create the PDF page with membership card
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Container(
                width: 500,
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(16),
                ),
                child: pw.Column(
                  children: [
                    // Main card with blue background
                    pw.Container(
                      color: PdfColor.fromInt(primaryBlue.value),
                      padding: const pw.EdgeInsets.all(20),
                      child: pw.Stack(
                        children: [
                          // Watermark logo (if available)
                          if (logoImage != null)
                            pw.Positioned.fill(
                              child: pw.Opacity(
                                opacity: 0.3,
                                child: pw.Center(
                                  child: pw.Image(logoImage, width: 300),
                                ),
                              ),
                            ),
                            
                          // Card content
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              // Top section - Photo and name
                              pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  // Profile image
                                  pw.Container(
                                    width: 100,
                                    height: 100,
                                    decoration: pw.BoxDecoration(
                                      shape: pw.BoxShape.circle,
                                      color: PdfColors.white,
                                    ),
                                    child: profileImage != null
                                      ? pw.ClipOval(child: pw.Image(profileImage))
                                      : pw.Center(
                                          child: pw.Text('Photo', style: pw.TextStyle(fontSize: 12)),
                                        ),
                                  ),
                                  
                                  pw.SizedBox(width: 20),
                                  
                                  // Name and info section
                                  pw.Expanded(
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        // Name with download icon
                                        pw.Row(
                                          children: [
                                            pw.Expanded(
                                              child: pw.Text(
                                                cardData['name'] ?? 'Member Name',
                                                style: pw.TextStyle(
                                                  color: PdfColors.white,
                                                  fontSize: 24,
                                                  fontWeight: pw.FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            pw.Text(
                                              '↓',
                                              style: pw.TextStyle(
                                                color: PdfColors.white,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        pw.SizedBox(height: 15),
                                        
                                        // Email
                                        pw.Row(
                                          children: [
                                            pw.Text(
                                              '✉',
                                              style: pw.TextStyle(
                                                color: PdfColors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                            pw.SizedBox(width: 8),
                                            pw.Text(
                                              cardData['email'] ?? 'email@example.com',
                                              style: pw.TextStyle(
                                                color: PdfColors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        pw.SizedBox(height: 8),
                                        
                                        // Member type and active status
                                        pw.Row(
                                          children: [
                                            pw.Text(
                                              '👤',
                                              style: pw.TextStyle(
                                                color: PdfColors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                            pw.SizedBox(width: 8),
                                            pw.Text(
                                              membershipTypeName ?? 'Member',
                                              style: pw.TextStyle(
                                                color: PdfColors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                            pw.SizedBox(width: 10),
                                            pw.Container(
                                              padding: const pw.EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration: pw.BoxDecoration(
                                                color: PdfColors.white,
                                                borderRadius: pw.BorderRadius.circular(15),
                                              ),
                                              child: pw.Row(
                                                children: [
                                                  pw.Text(
                                                    '✓',
                                                    style: pw.TextStyle(
                                                      color: PdfColors.green,
                                                      fontSize: 12,
                                                      fontWeight: pw.FontWeight.bold,
                                                    ),
                                                  ),
                                                  pw.SizedBox(width: 4),
                                                  pw.Text(
                                                    'Active',
                                                    style: pw.TextStyle(
                                                      color: PdfColor.fromInt(primaryBlue.value),
                                                      fontSize: 12,
                                                      fontWeight: pw.FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              pw.SizedBox(height: 20),
                              
                              // Bottom section - Details and QR code
                              pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  // Left - Details section
                                  pw.Expanded(
                                    flex: 3,
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        // ID
                                        _buildPdfDetailRow('ID:', cardData['qr_code_no']?.toString() ?? ''),
                                        pw.SizedBox(height: 8),
                                        
                                        // Issued On
                                        _buildPdfDetailRow('Issued On:', _formatDateForPdf(cardData['start_date'])),
                                        pw.SizedBox(height: 8),
                                        
                                        // Expiry
                                        _buildPdfDetailRow(
                                          'Expiry:',
                                          cardData['is_lifetime'] == 1 
                                            ? 'Lifetime' 
                                            : _formatDateForPdf(cardData['expiry_date']),
                                        ),
                                        pw.SizedBox(height: 8),
                                        
                                        // Address
                                        _buildPdfDetailRow('Address:', cardData['address'] ?? 'Not specified'),
                                      ],
                                    ),
                                  ),
                                  
                                  pw.SizedBox(width: 20),
                                  
                                  // Right - QR code
                                  pw.Container(
                                    width: 150,
                                    height: 150,
                                    color: PdfColors.white,
                                    child: qrImage != null
                                      ? pw.Image(qrImage, fit: pw.BoxFit.contain)
                                      : pw.Center(
                                          child: pw.Text(
                                            'QR Code',
                                            style: pw.TextStyle(fontSize: 14),
                                          ),
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Pink footer with slogan
                    pw.Container(
                      width: 500,
                      color: PdfColor.fromInt(pinkBackground.value),
                      padding: const pw.EdgeInsets.symmetric(vertical: 12),
                      child: pw.Center(
                        child: pw.Text(
                          '"मेरो लगानी सिप सिक्नको लागि मात्र नभई एस्टेडिएम बनाउनको लागि पनि"',
                          style: pw.TextStyle(
                            color: PdfColor.fromInt(sloganTextColor.value),
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      // Save and share the PDF
      await Printing.sharePdf(bytes: await pdf.save(), filename: 'membership_card.pdf');
      
    } catch (e) {
      debugPrint('Error in PDF service: $e');
      rethrow; // Rethrow the exception to be caught by the calling code
    }
  }

  /// Helper method to build a detail row in PDF
  static pw.Widget _buildPdfDetailRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            color: PdfColors.white,
            fontWeight: pw.FontWeight.bold,
            fontSize: 16,
          ),
        ),
        pw.Expanded(
          child: pw.Center(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Format a date string for PDF display
  static String _formatDateForPdf(String? dateString) {
    if (dateString == null) return 'Not specified';
    
    try {
      final date = DateTime.parse(dateString);
      final day = date.day.toString().padLeft(2, '0');
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final month = months[date.month - 1];
      final year = date.year;
      
      return '$day $month $year';
    } catch (e) {
      return dateString;
    }
  }
}
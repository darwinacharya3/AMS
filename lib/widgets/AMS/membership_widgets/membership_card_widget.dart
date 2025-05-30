import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Local providers for the card widget
final cardSvgContentProvider = StateProvider.autoDispose<String?>((ref) => null);
final cardMembershipTypeProvider = StateProvider.autoDispose<String?>((ref) => 'Member');
final cardLogoImageBytesProvider = StateProvider.autoDispose<Uint8List?>((ref) => null);
final memberIconBytesProvider = StateProvider.autoDispose<Uint8List?>((ref) => null);
final emailIconBytesProvider = StateProvider.autoDispose<Uint8List?>((ref) => null);
final isDownloadingProvider = StateProvider.autoDispose<bool>((ref) => false);

class MembershipCardDisplay extends ConsumerStatefulWidget {
  final Map<String, dynamic> cardData;
  final List<Map<String, dynamic>>? membershipTypes;

  const MembershipCardDisplay({
    super.key, 
    required this.cardData, 
    this.membershipTypes,
  });
  
  @override
  ConsumerState<MembershipCardDisplay> createState() => _MembershipCardDisplayState();
}

class _MembershipCardDisplayState extends ConsumerState<MembershipCardDisplay> with SingleTickerProviderStateMixin {
  // Colors from design - exactly as specified in your CSS
  final Color primaryBlue = const Color.fromRGBO(39, 94, 174, 1);    // rgb(39 94 174)
  final Color secondaryBlue = const Color.fromRGBO(47, 100, 170, 1); // rgb(47 100 170) 
  final Color pinkColor = const Color.fromRGBO(220, 47, 160, 1);     // rgba(220, 47, 160, 1)
  final Color textColor = Colors.white;
  final Color pinkBackground = const Color(0xD6FFA3E6); // rgba(255, 163, 230, 0.84)
  final Color sloganTextColor = const Color(0xFF1e4c84);

  // Card key for screenshots
  final GlobalKey _cardKey = GlobalKey();
  
  // Animation controller
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize the animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Initialize the fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeIn,
      ),
    );
    
    // Start the animation
    _animationController!.forward();
    
    // Use postFrameCallback to update providers AFTER build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processQrCode();
      _getMembershipTypeName();
      _loadAssets();
    });
    
    // Explicitly allow screenshots
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    // Disable secure display flags
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemStatusBarContrastEnforced: false,
    ));
  }
  
  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
  
  Future<void> _loadAssets() async {
    try {
      // Load watermark logo
      final ByteData logoData = await rootBundle.load('assets/card/oval.png');
      if (mounted) {
        ref.read(cardLogoImageBytesProvider.notifier).state = logoData.buffer.asUint8List();
      }
      
      // Load member icon
      final ByteData memberIconData = await rootBundle.load('assets/card/member_icon.png');
      if (mounted) {
        ref.read(memberIconBytesProvider.notifier).state = memberIconData.buffer.asUint8List();
      }
      
      // Load email icon
      final ByteData emailIconData = await rootBundle.load('assets/card/email_icon.png');
      if (mounted) {
        ref.read(emailIconBytesProvider.notifier).state = emailIconData.buffer.asUint8List();
      }
      
    } catch (e) {
      debugPrint('Error loading assets: $e');
      
      // Try alternate paths if main paths fail
      _tryAlternativeAssetPaths();
    }
  }
  
  Future<void> _tryAlternativeAssetPaths() async {
    try {
      final List<String> possiblePaths = [
        'assets/Oval Logo.png',
        'assets/images/Oval Logo.png',
        'assets/extratech-oval-logo.png',
      ];
      
      for (final path in possiblePaths) {
        try {
          final ByteData data = await rootBundle.load(path);
          if (mounted) {
            ref.read(cardLogoImageBytesProvider.notifier).state = data.buffer.asUint8List();
            break;
          }
        } catch (e) {
          // Continue to next path
        }
      }
    } catch (e) {
      debugPrint('Error loading alternative assets: $e');
    }
  }
  
  void _getMembershipTypeName() {
    final cardTypeId = widget.cardData['card_type_id'];
    String? typeName;
    
    if (cardTypeId != null && widget.membershipTypes != null) {
      for (final type in widget.membershipTypes!) {
        if (type['id'] == cardTypeId) {
          typeName = type['type'];
          break;
        }
      }
    }
    
    if (mounted) {
      ref.read(cardMembershipTypeProvider.notifier).state = 
        typeName ?? widget.cardData['card_type'] ?? 'Member';
    }
  }
  
  void _processQrCode() {
    if (!mounted) return;
    
    if (widget.cardData.containsKey('qr_code')) {
      try {
        final qrCodeData = widget.cardData['qr_code'].toString();
        
        if (qrCodeData.startsWith('data:image/svg+xml;base64,')) {
          final base64String = qrCodeData.split('base64,')[1];
          final bytes = base64Decode(base64String);
          final svgString = utf8.decode(bytes);
          
          ref.read(cardSvgContentProvider.notifier).state = svgString;
        }
      } catch (e) {
        debugPrint('Error processing QR: $e');
      }
    }
  }
  
  void _downloadCard() {
    ref.read(isDownloadingProvider.notifier).state = true;
    
    // Simulate a delay and reset the state
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        ref.read(isDownloadingProvider.notifier).state = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card downloaded successfully')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get state from providers
    final svgContent = ref.watch(cardSvgContentProvider);
    final membershipTypeName = ref.watch(cardMembershipTypeProvider);
    final logoImageBytes = ref.watch(cardLogoImageBytesProvider);
    final memberIconBytes = ref.watch(memberIconBytesProvider);
    final emailIconBytes = ref.watch(emailIconBytesProvider);
    final isDownloading = ref.watch(isDownloadingProvider);
    
    final bool isApproved = widget.cardData['status'] == 1 || widget.cardData['status'] == 4;
    final bool isActive = widget.cardData['is_active'] == 1;
    
    if (!isApproved) {
      return _buildPendingApplicationView();
    }
    
    final screenWidth = MediaQuery.of(context).size.width;
    final double titleSize = screenWidth * 0.05;
    final double subtitleSize = screenWidth * 0.032;
    
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section
        Text(
          'Digital Membership Card',
          style: GoogleFonts.poppins(
            fontSize: titleSize,
            fontWeight: FontWeight.w600,
            color: primaryBlue,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Subtitle with active/inactive status
        Row(
          children: [
            Expanded(
              child: Text(
                'Your Digital Membership Card is ${isActive ? 'Active' : 'Inactive'}. Now, you are eligible to get all the membership benefits of Extratech Oval International Cricket Stadium',
                style: GoogleFonts.poppins(
                  fontSize: subtitleSize,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                isActive ? 'Active' : 'Inactive',
                style: GoogleFonts.poppins(
                  fontSize: subtitleSize,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.green.shade800 : Colors.red.shade800,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Membership Card
        RepaintBoundary(
          key: _cardKey,
          child: Card(
            elevation: 8.0,
            margin: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Main card body with FIXED gradient background matching CSS exactly
                Container(
                  decoration: BoxDecoration(
                    // FIXED: Gradient now matches CSS linear-gradient(157deg, ...)
                    gradient: LinearGradient(
                      transform: GradientRotation(157 * 3.14159 / 180), // Convert 157deg to radians
                      begin: Alignment.bottomLeft,
                      end: Alignment.topLeft,
                     
                      
                      stops: const [0.0, 0.37, 1.0], // Exact stops from CSS
                      colors: [
                        primaryBlue,    // rgb(39 94 174) at 0%
                        secondaryBlue,  // rgb(47 100 170) at 37%
                        pinkColor,      // rgba(220, 47, 160, 1) at 100%
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Stack(
                    children: [
                      // FIXED: OVAL watermark - MUCH LARGER SIZE
                      if (logoImageBytes != null)
                        Positioned(
                          left: -30,    // Extended further left
                          right: 100,   // Reduced right margin for more space
                          top: -20,     // Extended up
                          bottom: -40,  // Extended down
                          child: Opacity(
                            opacity: 0.6, // Slightly more visible
                            child: Center(
                              child: Transform.scale(
                                scale: 0.8, // MUCH larger watermark (increased from default)
                                child: Image.memory(
                                  logoImageBytes,
                                  fit: BoxFit.contain,
                                  color: Colors.white.withOpacity(0.2),
                                  colorBlendMode: BlendMode.srcATop,
                                ),
                              ),
                            ),
                          ),
                        ),
                      
                      // Card content
                      Column(
                        children: [
                          // TOP SECTION - Header with photo, name, email, member type
                          _buildHeaderSection(
                            membershipTypeName, 
                            memberIconBytes, 
                            emailIconBytes,
                            isDownloading,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // BOTTOM SECTION - Details and QR code
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left column - Details section
                              Expanded(
                                flex: 62,
                                child: _buildDetailsSection(),
                              ),
                              
                              const SizedBox(width: 16),
                              
                              // Right column - QR code section
                              Expanded(
                                flex: 38,
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: svgContent != null
                                      ? SvgPicture.string(
                                          svgContent,
                                          fit: BoxFit.contain,
                                        )
                                      : const Center(
                                          child: Icon(
                                            Icons.qr_code,
                                            color: Colors.grey,
                                            size: 50,
                                          ),
                                        ),
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
                Container(
                  width: double.infinity,
                  color: pinkBackground,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  child: Text(
                    '"मेरो लगानी सिप सिक्न मात्र होइन, स्टेडियम बनाउन पनि!"',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: sloganTextColor,
                      height: 1.4,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
    
    // Only apply fade transition if animation controller is initialized
    if (_animationController != null && _fadeAnimation != null) {
      return FadeTransition(
        opacity: _fadeAnimation!,
        child: content,
      );
    }
    
    return content;
  }
  
  Widget _buildPendingApplicationView() {
    return Card(
      elevation: 8.0,
      margin: const EdgeInsets.symmetric(vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          // FIXED: Use the same corrected gradient for consistency
          gradient: LinearGradient(
            transform: GradientRotation(157 * 3.14159 / 180),
            begin: Alignment.bottomLeft,
            end: Alignment.topLeft,
            stops: const [0.0, 0.37, 1.0],
            colors: [
              primaryBlue,
              secondaryBlue,
              pinkColor,
            ],
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(20),
              child: const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Application Submitted',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your membership card application has been submitted successfully and is awaiting approval.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.access_time,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Application Status',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.4,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Under Review',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            height: 1.4,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (widget.cardData['qr_code_no'] != null)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.confirmation_number_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Reference: ${widget.cardData['qr_code_no']}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.4,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeaderSection(
    String? membershipTypeName,
    Uint8List? memberIconBytes,
    Uint8List? emailIconBytes,
    bool isDownloading,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile photo with enhanced white border
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3), // Increased width for more prominent border
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 33, // Reduced to account for thicker border
              backgroundImage: widget.cardData['photo_url'] != null
                ? NetworkImage(widget.cardData['photo_url'])
                : null,
              backgroundColor: Colors.grey[200],
              child: widget.cardData['photo_url'] == null
                ? const Icon(Icons.person, size: 36, color: Colors.grey)
                : null,
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Name, email, member info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Name and download button
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      widget.cardData['name'] ?? 'Member Name',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: isDownloading ? null : _downloadCard,
                    child: isDownloading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.file_download_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                  ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              // Email
              Row(
                children: [
                  emailIconBytes != null
                    ? Image.memory(
                        emailIconBytes,
                        width: 14,
                        height: 14,
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.email_outlined, 
                        color: Colors.white, 
                        size: 14
                      ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.cardData['email'] ?? 'email@example.com',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white,
                        height: 1.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              // Member type - without Active badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  memberIconBytes != null
                    ? Image.memory(
                        memberIconBytes,
                        width: 14,
                        height: 14,
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.person_outline, 
                        color: Colors.white, 
                        size: 14
                      ),
                  const SizedBox(width: 4),
                  Text(
                    membershipTypeName ?? 'Member',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white,
                      height: 1.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    // Use consistent font sizes with more spacing between labels and values
    const double labelSize = 12.0; 
    const double valueSize = 12.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('ID:', widget.cardData['qr_code_no']?.toString() ?? '', labelSize, valueSize),
        const SizedBox(height: 8),
        _buildDetailRow('Issued On:', _formatDate(widget.cardData['start_date']), labelSize, valueSize),
        const SizedBox(height: 8),
        _buildDetailRow('Expires:', _formatExpiryDate(), labelSize, valueSize),
        const SizedBox(height: 8),
        _buildAddressRow('Address:', widget.cardData['address'] ?? 'Not specified', labelSize, valueSize),
      ],
    );
  }
  
  Widget _buildDetailRow(String label, String value, double labelSize, double valueSize) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: labelSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ),
        
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: valueSize,
              color: Colors.white,
              height: 1.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  Widget _buildAddressRow(String label, String value, double labelSize, double valueSize) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: labelSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ),
        
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: valueSize,
              color: Colors.white,
              height: 1.2,
            ),
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.clip,
          ),
        ),
      ],
    );
  }
  
  String _formatExpiryDate() {
    if (widget.cardData['is_lifetime'] == 1) {
      return 'Lifetime';
    }
    return _formatDate(widget.cardData['expiry_date']);
  }
  
  String _formatDate(String? dateString) {
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


















// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// // Local providers for the card widget
// final cardSvgContentProvider = StateProvider.autoDispose<String?>((ref) => null);
// final cardMembershipTypeProvider = StateProvider.autoDispose<String?>((ref) => 'Member');
// final cardLogoImageBytesProvider = StateProvider.autoDispose<Uint8List?>((ref) => null);
// final memberIconBytesProvider = StateProvider.autoDispose<Uint8List?>((ref) => null);
// final emailIconBytesProvider = StateProvider.autoDispose<Uint8List?>((ref) => null);
// final isDownloadingProvider = StateProvider.autoDispose<bool>((ref) => false);

// class MembershipCardDisplay extends ConsumerStatefulWidget {
//   final Map<String, dynamic> cardData;
//   final List<Map<String, dynamic>>? membershipTypes;

//   const MembershipCardDisplay({
//     super.key, 
//     required this.cardData, 
//     this.membershipTypes,
//   });
  
//   @override
//   ConsumerState<MembershipCardDisplay> createState() => _MembershipCardDisplayState();
// }

// class _MembershipCardDisplayState extends ConsumerState<MembershipCardDisplay> with SingleTickerProviderStateMixin {
//   // Colors from design - exactly as specified in your CSS
//   final Color primaryBlue = const Color.fromRGBO(39, 94, 174, 1);    // rgb(39 94 174)
//   final Color secondaryBlue = const Color.fromRGBO(47, 100, 170, 1); // rgb(47 100 170) 
//   final Color pinkColor = const Color.fromRGBO(220, 47, 160, 1);     // rgba(220, 47, 160, 1)
//   final Color textColor = Colors.white;
//   final Color pinkBackground = const Color(0xD6FFA3E6); // rgba(255, 163, 230, 0.84)
//   final Color sloganTextColor = const Color(0xFF1e4c84);

//   // Card key for screenshots
//   final GlobalKey _cardKey = GlobalKey();
  
//   // Animation controller
//   AnimationController? _animationController;
//   Animation<double>? _fadeAnimation;
  
//   @override
//   void initState() {
//     super.initState();
    
//     // Initialize the animation controller
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
    
//     // Initialize the fade animation
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController!,
//         curve: Curves.easeIn,
//       ),
//     );
    
//     // Start the animation
//     _animationController!.forward();
    
//     // Use postFrameCallback to update providers AFTER build is complete
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _processQrCode();
//       _getMembershipTypeName();
//       _loadAssets();
//     });
    
//     // Explicitly allow screenshots
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
//     // Disable secure display flags
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//       systemStatusBarContrastEnforced: false,
//     ));
//   }
  
//   @override
//   void dispose() {
//     _animationController?.dispose();
//     super.dispose();
//   }
  
//   Future<void> _loadAssets() async {
//     try {
//       // Load watermark logo
//       final ByteData logoData = await rootBundle.load('assets/card/oval.png');
//       if (mounted) {
//         ref.read(cardLogoImageBytesProvider.notifier).state = logoData.buffer.asUint8List();
//       }
      
//       // Load member icon
//       final ByteData memberIconData = await rootBundle.load('assets/card/member_icon.png');
//       if (mounted) {
//         ref.read(memberIconBytesProvider.notifier).state = memberIconData.buffer.asUint8List();
//       }
      
//       // Load email icon
//       final ByteData emailIconData = await rootBundle.load('assets/card/email_icon.png');
//       if (mounted) {
//         ref.read(emailIconBytesProvider.notifier).state = emailIconData.buffer.asUint8List();
//       }
      
//     } catch (e) {
//       debugPrint('Error loading assets: $e');
      
//       // Try alternate paths if main paths fail
//       _tryAlternativeAssetPaths();
//     }
//   }
  
//   Future<void> _tryAlternativeAssetPaths() async {
//     try {
//       final List<String> possiblePaths = [
//         'assets/Oval Logo.png',
//         'assets/images/Oval Logo.png',
//         'assets/extratech-oval-logo.png',
//       ];
      
//       for (final path in possiblePaths) {
//         try {
//           final ByteData data = await rootBundle.load(path);
//           if (mounted) {
//             ref.read(cardLogoImageBytesProvider.notifier).state = data.buffer.asUint8List();
//             break;
//           }
//         } catch (e) {
//           // Continue to next path
//         }
//       }
//     } catch (e) {
//       debugPrint('Error loading alternative assets: $e');
//     }
//   }
  
//   void _getMembershipTypeName() {
//     final cardTypeId = widget.cardData['card_type_id'];
//     String? typeName;
    
//     if (cardTypeId != null && widget.membershipTypes != null) {
//       for (final type in widget.membershipTypes!) {
//         if (type['id'] == cardTypeId) {
//           typeName = type['type'];
//           break;
//         }
//       }
//     }
    
//     if (mounted) {
//       ref.read(cardMembershipTypeProvider.notifier).state = 
//         typeName ?? widget.cardData['card_type'] ?? 'Member';
//     }
//   }
  
//   void _processQrCode() {
//     if (!mounted) return;
    
//     if (widget.cardData.containsKey('qr_code')) {
//       try {
//         final qrCodeData = widget.cardData['qr_code'].toString();
        
//         if (qrCodeData.startsWith('data:image/svg+xml;base64,')) {
//           final base64String = qrCodeData.split('base64,')[1];
//           final bytes = base64Decode(base64String);
//           final svgString = utf8.decode(bytes);
          
//           ref.read(cardSvgContentProvider.notifier).state = svgString;
//         }
//       } catch (e) {
//         debugPrint('Error processing QR: $e');
//       }
//     }
//   }
  
//   void _downloadCard() {
//     ref.read(isDownloadingProvider.notifier).state = true;
    
//     // Simulate a delay and reset the state
//     Future.delayed(const Duration(seconds: 1), () {
//       if (mounted) {
//         ref.read(isDownloadingProvider.notifier).state = false;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Card downloaded successfully')),
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Get state from providers
//     final svgContent = ref.watch(cardSvgContentProvider);
//     final membershipTypeName = ref.watch(cardMembershipTypeProvider);
//     final logoImageBytes = ref.watch(cardLogoImageBytesProvider);
//     final memberIconBytes = ref.watch(memberIconBytesProvider);
//     final emailIconBytes = ref.watch(emailIconBytesProvider);
//     final isDownloading = ref.watch(isDownloadingProvider);
    
//     final bool isApproved = widget.cardData['status'] == 1 || widget.cardData['status'] == 4;
//     final bool isActive = widget.cardData['is_active'] == 1;
    
//     if (!isApproved) {
//       return _buildPendingApplicationView();
//     }
    
//     final screenWidth = MediaQuery.of(context).size.width;
//     final double titleSize = screenWidth * 0.05;
//     final double subtitleSize = screenWidth * 0.032;
    
//     Widget content = Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Header section
//         Text(
//           'Digital Membership Card',
//           style: GoogleFonts.poppins(
//             fontSize: titleSize,
//             fontWeight: FontWeight.w600,
//             color: primaryBlue,
//           ),
//         ),
        
//         const SizedBox(height: 8),
        
//         // Subtitle with active/inactive status
//         Row(
//           children: [
//             Expanded(
//               child: Text(
//                 'Your Digital Membership Card is ${isActive ? 'Active' : 'Inactive'}. Now, you are eligible to get all the membership benefits of Extratech Oval International Cricket Stadium',
//                 style: GoogleFonts.poppins(
//                   fontSize: subtitleSize,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: isActive ? Colors.green.shade100 : Colors.red.shade100,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Text(
//                 isActive ? 'Active' : 'Inactive',
//                 style: GoogleFonts.poppins(
//                   fontSize: subtitleSize,
//                   fontWeight: FontWeight.w600,
//                   color: isActive ? Colors.green.shade800 : Colors.red.shade800,
//                 ),
//               ),
//             ),
//           ],
//         ),
        
//         const SizedBox(height: 16),
        
//         // Membership Card
//         RepaintBoundary(
//           key: _cardKey,
//           child: Card(
//             elevation: 8.0,
//             margin: const EdgeInsets.symmetric(vertical: 12),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16.0),
//             ),
//             clipBehavior: Clip.antiAlias,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Main card body with gradient background - DIAGONAL GRADIENT THAT MATCHES FINAL DESIGN
//                 Container(
//                   decoration: BoxDecoration(
//                     // Updated gradient with diagonal direction using GradientRotation
//                     gradient: LinearGradient(
//                       // This will create a top-left to bottom-right diagonal gradient that
//                       // keeps blue in the top-right corner
//                       begin: Alignment(-0.8, -0.8), // Adjusted to keep more blue on top
//                       end: Alignment(0.8, 0.8),     // Adjusted for diagonal flow
//                       stops: const [0.0, 0.65, 0.9], // Adjusted to keep blue longer
//                       colors: [
//                         primaryBlue,
//                         secondaryBlue,
//                         pinkColor,
//                       ],
//                     ),
//                   ),
//                   padding: const EdgeInsets.all(16),
//                   child: Stack(
//                     children: [
//                       // OVAL watermark - POSITIONED HIGHER TO START FROM PHOTO LEVEL
//                       if (logoImageBytes != null)
//                         Positioned(
//                           left: 0,
//                           right: 150, // Keep away from QR code area
//                           top: 0,    // Start from the top (photo level)
//                           bottom: 0,
//                           child: Opacity(
//                             opacity: 0.75, // Match opacity in final design
//                             child: Center(
//                               child: Image.memory(
//                                 logoImageBytes,
//                                 fit: BoxFit.contain,
//                                 color: Colors.white.withOpacity(0.1),
//                                 colorBlendMode: BlendMode.srcATop,
//                               ),
//                             ),
//                           ),
//                         ),
                      
//                       // Card content
//                       Column(
//                         children: [
//                           // TOP SECTION - Header with photo, name, email, member type
//                           _buildHeaderSection(
//                             membershipTypeName, 
//                             memberIconBytes, 
//                             emailIconBytes,
//                             isDownloading,
//                           ),
                          
//                           const SizedBox(height: 16),
                          
//                           // BOTTOM SECTION - Details and QR code
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Left column - Details section
//                               Expanded(
//                                 flex: 62,
//                                 child: _buildDetailsSection(),
//                               ),
                              
//                               const SizedBox(width: 16),
                              
//                               // Right column - QR code section
//                               Expanded(
//                                 flex: 38,
//                                 child: AspectRatio(
//                                   aspectRatio: 1.0,
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(4),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black.withOpacity(0.2),
//                                           blurRadius: 4,
//                                           offset: const Offset(0, 2),
//                                         ),
//                                       ],
//                                     ),
//                                     padding: const EdgeInsets.all(2),
//                                     child: svgContent != null
//                                       ? SvgPicture.string(
//                                           svgContent,
//                                           fit: BoxFit.contain,
//                                         )
//                                       : const Center(
//                                           child: Icon(
//                                             Icons.qr_code,
//                                             color: Colors.grey,
//                                             size: 50,
//                                           ),
//                                         ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
                
//                 // Pink footer with slogan
//                 Container(
//                   width: double.infinity,
//                   color: pinkBackground,
//                   padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
//                   child: Text(
//                     '"मेरो लगानी सिप सिक्न मात्र होइन, स्टेडियम बनाउन पनि!"',
//                     style: GoogleFonts.poppins(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: sloganTextColor,
//                       height: 1.4,
//                       letterSpacing: 0.3,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
    
//     // Only apply fade transition if animation controller is initialized
//     if (_animationController != null && _fadeAnimation != null) {
//       return FadeTransition(
//         opacity: _fadeAnimation!,
//         child: content,
//       );
//     }
    
//     return content;
//   }
  
//   Widget _buildPendingApplicationView() {
//     return Card(
//       elevation: 8.0,
//       margin: const EdgeInsets.symmetric(vertical: 20),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16.0),
//       ),
//       child: Container(
//         decoration: BoxDecoration(
//           // Use the same diagonal gradient for consistency
//           gradient: LinearGradient(
//             transform: const GradientRotation(157*3.14159/180),
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//             stops: const [0.0, 0.37, 1.0],
//             colors: [
//               primaryBlue,
//               secondaryBlue,
//               pinkColor,
//             ],
//           ),
//           borderRadius: BorderRadius.circular(16.0),
//         ),
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 shape: BoxShape.circle,
//               ),
//               padding: const EdgeInsets.all(20),
//               child: const Icon(
//                 Icons.check_circle_outline,
//                 color: Colors.white,
//                 size: 50,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Application Submitted',
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'Your membership card application has been submitted successfully and is awaiting approval.',
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 color: Colors.white.withOpacity(0.9),
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.white.withOpacity(0.3)),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.3),
//                       shape: BoxShape.circle,
//                     ),
//                     padding: const EdgeInsets.all(8),
//                     child: const Icon(
//                       Icons.access_time,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Application Status',
//                           style: GoogleFonts.poppins(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                             color: Colors.white,
//                             height: 1.4,
//                             letterSpacing: 0.3,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           'Under Review',
//                           style: GoogleFonts.poppins(
//                             color: Colors.white.withOpacity(0.9),
//                             fontSize: 14,
//                             height: 1.4,
//                             letterSpacing: 0.3,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             if (widget.cardData['qr_code_no'] != null)
//               Container(
//                 padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(
//                       Icons.confirmation_number_outlined,
//                       size: 16,
//                       color: Colors.white,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Reference: ${widget.cardData['qr_code_no']}',
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         color: Colors.white,
//                         height: 1.4,
//                         letterSpacing: 0.3,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildHeaderSection(
//     String? membershipTypeName,
//     Uint8List? memberIconBytes,
//     Uint8List? emailIconBytes,
//     bool isDownloading,
//   ) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Profile photo with enhanced white border
//         Container(
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(color: Colors.white, width: 3), // Increased width for more prominent border
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.2),
//                 blurRadius: 4,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: CircleAvatar(
//             radius: 36,
//             backgroundColor: Colors.white,
//             child: CircleAvatar(
//               radius: 33, // Reduced to account for thicker border
//               backgroundImage: widget.cardData['photo_url'] != null
//                 ? NetworkImage(widget.cardData['photo_url'])
//                 : null,
//               backgroundColor: Colors.grey[200],
//               child: widget.cardData['photo_url'] == null
//                 ? const Icon(Icons.person, size: 36, color: Colors.grey)
//                 : null,
//             ),
//           ),
//         ),
        
//         const SizedBox(width: 12),
        
//         // Name, email, member info
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // Name and download button
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       widget.cardData['name'] ?? 'Member Name',
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: textColor,
//                         height: 1.4,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: isDownloading ? null : _downloadCard,
//                     child: isDownloading
//                       ? SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                           ),
//                         )
//                       : const Icon(
//                           Icons.file_download_outlined,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                   ),
//                 ],
//               ),
              
//               const SizedBox(height: 4),
              
//               // Email
//               Row(
//                 children: [
//                   emailIconBytes != null
//                     ? Image.memory(
//                         emailIconBytes,
//                         width: 14,
//                         height: 14,
//                         color: Colors.white,
//                       )
//                     : const Icon(
//                         Icons.email_outlined, 
//                         color: Colors.white, 
//                         size: 14
//                       ),
//                   const SizedBox(width: 4),
//                   Expanded(
//                     child: Text(
//                       widget.cardData['email'] ?? 'email@example.com',
//                       style: GoogleFonts.poppins(
//                         fontSize: 11,
//                         color: Colors.white,
//                         height: 1.4,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
              
//               const SizedBox(height: 4),
              
//               // Member type - without Active badge
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   memberIconBytes != null
//                     ? Image.memory(
//                         memberIconBytes,
//                         width: 14,
//                         height: 14,
//                         color: Colors.white,
//                       )
//                     : const Icon(
//                         Icons.person_outline, 
//                         color: Colors.white, 
//                         size: 14
//                       ),
//                   const SizedBox(width: 4),
//                   Text(
//                     membershipTypeName ?? 'Member',
//                     style: GoogleFonts.poppins(
//                       fontSize: 11,
//                       color: Colors.white,
//                       height: 1.4,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDetailsSection() {
//     // Use consistent font sizes with more spacing between labels and values
//     const double labelSize = 12.0; 
//     const double valueSize = 12.0;
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildDetailRow('ID:', widget.cardData['qr_code_no']?.toString() ?? '', labelSize, valueSize),
//         const SizedBox(height: 8),
//         _buildDetailRow('Issued On:', _formatDate(widget.cardData['start_date']), labelSize, valueSize),
//         const SizedBox(height: 8),
//         _buildDetailRow('Expires:', _formatExpiryDate(), labelSize, valueSize),
//         const SizedBox(height: 8),
//         _buildAddressRow('Address:', widget.cardData['address'] ?? 'Not specified', labelSize, valueSize),
//       ],
//     );
//   }
  
//   Widget _buildDetailRow(String label, String value, double labelSize, double valueSize) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         SizedBox(
//           width: 70,
//           child: Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: labelSize,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//               height: 1.4,
//             ),
//           ),
//         ),
        
//         Expanded(
//           child: Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: valueSize,
//               color: Colors.white,
//               height: 1.4,
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
  
//   Widget _buildAddressRow(String label, String value, double labelSize, double valueSize) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           width: 70,
//           child: Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: labelSize,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//               height: 1.4,
//             ),
//           ),
//         ),
        
//         Expanded(
//           child: Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: valueSize,
//               color: Colors.white,
//               height: 1.2,
//             ),
//             softWrap: true,
//             maxLines: 2,
//             overflow: TextOverflow.clip,
//           ),
//         ),
//       ],
//     );
//   }
  
//   String _formatExpiryDate() {
//     if (widget.cardData['is_lifetime'] == 1) {
//       return 'Lifetime';
//     }
//     return _formatDate(widget.cardData['expiry_date']);
//   }
  
//   String _formatDate(String? dateString) {
//     if (dateString == null) return 'Not specified';
    
//     try {
//       final date = DateTime.parse(dateString);
//       final day = date.day.toString().padLeft(2, '0');
//       final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//       final month = months[date.month - 1];
//       final year = date.year;
      
//       return '$day $month $year';
//     } catch (e) {
//       return dateString;
//     }
//   }
// }







// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// // Local providers for the card widget - scoped to just this widget
// final cardSvgContentProvider = StateProvider.autoDispose<String?>((ref) => null);
// final cardMembershipTypeProvider = StateProvider.autoDispose<String?>((ref) => 'Member');
// final cardLogoImageBytesProvider = StateProvider.autoDispose<Uint8List?>((ref) => null);
// final memberIconBytesProvider = StateProvider.autoDispose<Uint8List?>((ref) => null);
// final emailIconBytesProvider = StateProvider.autoDispose<Uint8List?>((ref) => null);
// final activeIconBytesProvider = StateProvider.autoDispose<Uint8List?>((ref) => null);

// class MembershipCardDisplay extends ConsumerStatefulWidget {
//   final Map<String, dynamic> cardData;
//   final List<Map<String, dynamic>>? membershipTypes;

//   const MembershipCardDisplay({
//     super.key, 
//     required this.cardData, 
//     this.membershipTypes,
//   });
  
//   @override
//   ConsumerState<MembershipCardDisplay> createState() => _MembershipCardDisplayState();
// }

// class _MembershipCardDisplayState extends ConsumerState<MembershipCardDisplay> {
//   // Colors from design
//   final Color primaryBlue = const Color(0xFF275eae);
//   final Color secondaryBlue = const Color(0xFF2f64aa);
//   final Color pinkColor = const Color(0xFFdc2fa0);
//   final Color textColor = Colors.white;
//   final Color pinkBackground = const Color(0xD6FFA3E6); // rgba(255, 163, 230, 0.84)
//   final Color sloganTextColor = const Color(0xFF1e4c84);
//   final Color wavyLineColor1 = const Color(0xFF3366CC);
//   final Color wavyLineColor2 = const Color(0xFFAA55CC);
  
//   @override
//   void initState() {
//     super.initState();
    
//     // Use postFrameCallback to update providers AFTER build is complete
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _processQrCode();
//       _getMembershipTypeName();
//       _loadAssets();
//     });
    
//     // Explicitly allow screenshots
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
//     // Disable secure display flags
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//       systemStatusBarContrastEnforced: false,
//     ));
//   }
  
//   Future<void> _loadAssets() async {
//     try {
//       // Load watermark logo
//       final ByteData logoData = await rootBundle.load('assets/card/oval.png');
//       if (mounted) {
//         ref.read(cardLogoImageBytesProvider.notifier).state = logoData.buffer.asUint8List();
//       }
      
//       // Load member icon
//       final ByteData memberIconData = await rootBundle.load('assets/card/member_icon.png');
//       if (mounted) {
//         ref.read(memberIconBytesProvider.notifier).state = memberIconData.buffer.asUint8List();
//       }
      
//       // Load email icon
//       final ByteData emailIconData = await rootBundle.load('assets/card/email_icon.png');
//       if (mounted) {
//         ref.read(emailIconBytesProvider.notifier).state = emailIconData.buffer.asUint8List();
//       }
      
//       // Load active icon
//       final ByteData activeIconData = await rootBundle.load('assets/card/active_icon.png');
//       if (mounted) {
//         ref.read(activeIconBytesProvider.notifier).state = activeIconData.buffer.asUint8List();
//       }
      
//     } catch (e) {
//       debugPrint('Error loading assets: $e');
      
//       // Try alternate paths if main paths fail
//       // This is a fallback mechanism
//     }
//   }
  
//   void _getMembershipTypeName() {
//     // Calculate the value, then update the provider
//     final cardTypeId = widget.cardData['card_type_id'];
//     String? typeName;
    
//     if (cardTypeId != null && widget.membershipTypes != null) {
//       for (final type in widget.membershipTypes!) {
//         if (type['id'] == cardTypeId) {
//           typeName = type['type'];
//           break;
//         }
//       }
//     }
    
//     if (mounted) {
//       ref.read(cardMembershipTypeProvider.notifier).state = 
//         typeName ?? widget.cardData['card_type'] ?? 'Member';
//     }
//   }
  
//   void _processQrCode() {
//     if (!mounted) return;
    
//     if (widget.cardData.containsKey('qr_code')) {
//       try {
//         final qrCodeData = widget.cardData['qr_code'].toString();
        
//         if (qrCodeData.startsWith('data:image/svg+xml;base64,')) {
//           // Extract base64 part
//           final base64String = qrCodeData.split('base64,')[1];
          
//           // Decode base64 to bytes
//           final bytes = base64Decode(base64String);
          
//           // Convert bytes to SVG string
//           final svgString = utf8.decode(bytes);
          
//           ref.read(cardSvgContentProvider.notifier).state = svgString;
//         }
//       } catch (e) {
//         debugPrint('Error processing QR: $e');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Get state from providers
//     final svgContent = ref.watch(cardSvgContentProvider);
//     final membershipTypeName = ref.watch(cardMembershipTypeProvider);
//     final logoImageBytes = ref.watch(cardLogoImageBytesProvider);
//     final memberIconBytes = ref.watch(memberIconBytesProvider);
//     final emailIconBytes = ref.watch(emailIconBytesProvider);
//     final activeIconBytes = ref.watch(activeIconBytesProvider);
    
//     // Update the condition to recognize multiple approved statuses
//     final bool isApproved = widget.cardData['status'] == 1 || widget.cardData['status'] == 4;
//     final bool isActive = widget.cardData['is_active'] == 1;
    
//     if (!isApproved) {
//       return _buildPendingApplicationView();
//     }
    
//     // Calculate available screen width
//     final screenWidth = MediaQuery.of(context).size.width;
//     final double titleSize = screenWidth * 0.05;
//     final double subtitleSize = screenWidth * 0.032;
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Header section
//         Text(
//           'Digital Membership Card',
//           style: GoogleFonts.poppins(
//             fontSize: titleSize,
//             fontWeight: FontWeight.w600,
//             color: primaryBlue,
//           ),
//         ),
        
//         const SizedBox(height: 8),
        
//         // Subtitle with active/inactive status
//         Row(
//           children: [
//             Expanded(
//               child: Text(
//                 'Your Digital Membership Card is ${isActive ? 'Active' : 'Inactive'}. Now, you are eligible to get all the membership benefits of Extratech Oval International Cricket Stadium',
//                 style: GoogleFonts.poppins(
//                   fontSize: subtitleSize,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: isActive ? Colors.green.shade100 : Colors.red.shade100,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Text(
//                 isActive ? 'Active' : 'Inactive',
//                 style: GoogleFonts.poppins(
//                   fontSize: subtitleSize,
//                   fontWeight: FontWeight.w600,
//                   color: isActive ? Colors.green.shade800 : Colors.red.shade800,
//                 ),
//               ),
//             ),
//           ],
//         ),
        
//         const SizedBox(height: 16),
        
//         // Membership Card
//         Card(
//           elevation: 8.0,
//           margin: const EdgeInsets.symmetric(vertical: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16.0),
//           ),
//           clipBehavior: Clip.antiAlias,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Main card body with gradient background
//               Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     stops: const [0.0, 0.37, 1.0],
//                     transform: const GradientRotation(157 * (3.14159 / 180)), // 157 degrees in radians
//                     colors: [
//                       primaryBlue,
//                       secondaryBlue,
//                       pinkColor,
//                     ],
//                   ),
//                 ),
//                 padding: const EdgeInsets.all(16),
//                 child: Stack(
//                   children: [
//                     // Watermark logo in background
//                     if (logoImageBytes != null)
//                       Positioned.fill(
//                         child: Opacity(
//                           opacity: 0.10,
//                           child: Center(
//                             child: Image.memory(
//                               logoImageBytes,
//                               fit: BoxFit.contain,
//                             ),
//                           ),
//                         ),
//                       ),
                    
//                     // Wavy lines decorations
//                     Positioned(
//                       left: 0,
//                       right: 0,
//                       bottom: 50,
//                       height: 100,
//                       child: CustomPaint(
//                         painter: WavyLinesPainter(
//                           color1: wavyLineColor1,
//                           color2: wavyLineColor2,
//                         ),
//                       ),
//                     ),
                    
//                     // Card content
//                     Column(
//                       children: [
//                         // TOP SECTION - Header with photo, name, email, member type
//                         _buildHeaderSection(
//                           membershipTypeName, 
//                           memberIconBytes, 
//                           emailIconBytes, 
//                           activeIconBytes,
//                           isActive,
//                         ),
                        
//                         const SizedBox(height: 16),
                        
//                         // BOTTOM SECTION - Details and QR code
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Left column - Details section (62% width)
//                             Expanded(
//                               flex: 62,
//                               child: _buildDetailsSection(),
//                             ),
                            
//                             // Spacing between text and QR (smaller gap)
//                             const SizedBox(width: 16),
                            
//                             // Right column - QR code section (38% width)
//                             Expanded(
//                               flex: 38,
//                               child: AspectRatio(
//                                 aspectRatio: 1.0,
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(2),
//                                   ),
//                                   padding: const EdgeInsets.all(2),
//                                   child: svgContent != null
//                                     ? SvgPicture.string(
//                                         svgContent,
//                                         fit: BoxFit.contain,
//                                       )
//                                     : const Center(
//                                         child: Icon(
//                                           Icons.qr_code,
//                                           color: Colors.grey,
//                                           size: 50,
//                                         ),
//                                       ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
              
//               // Pink footer with slogan
//               Container(
//                 width: double.infinity,
//                 color: pinkBackground,
//                 padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
//                 child: Text(
//                   '"मेरो लगानी सिप सिक्न मात्र होइन, स्टेडियम बनाउन पनि!"',
//                   style: GoogleFonts.poppins(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: sloganTextColor,
//                     height: 1.4,
//                     letterSpacing: 0.3,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
  
//   Widget _buildPendingApplicationView() {
//     return Card(
//       elevation: 8.0,
//       margin: const EdgeInsets.symmetric(vertical: 20),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16.0),
//       ),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [primaryBlue, primaryBlue.withOpacity(0.8)],
//           ),
//           borderRadius: BorderRadius.circular(16.0),
//         ),
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 shape: BoxShape.circle,
//               ),
//               padding: const EdgeInsets.all(20),
//               child: const Icon(
//                 Icons.check_circle_outline,
//                 color: Colors.white,
//                 size: 50,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Application Submitted',
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'Your membership card application has been submitted successfully and is awaiting approval.',
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 color: Colors.white.withOpacity(0.9),
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.white.withOpacity(0.3)),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.3),
//                       shape: BoxShape.circle,
//                     ),
//                     padding: const EdgeInsets.all(8),
//                     child: const Icon(
//                       Icons.access_time,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Application Status',
//                           style: GoogleFonts.poppins(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                             color: Colors.white,
//                             height: 1.4,
//                             letterSpacing: 0.3,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           'Under Review',
//                           style: GoogleFonts.poppins(
//                             color: Colors.white.withOpacity(0.9),
//                             fontSize: 14,
//                             height: 1.4,
//                             letterSpacing: 0.3,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             if (widget.cardData['qr_code_no'] != null)
//               Container(
//                 padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(
//                       Icons.confirmation_number_outlined,
//                       size: 16,
//                       color: Colors.white,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Reference: ${widget.cardData['qr_code_no']}',
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         color: Colors.white,
//                         height: 1.4,
//                         letterSpacing: 0.3,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildHeaderSection(
//     String? membershipTypeName,
//     Uint8List? memberIconBytes,
//     Uint8List? emailIconBytes,
//     Uint8List? activeIconBytes,
//     bool isActive,
//   ) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Profile photo
//         CircleAvatar(
//           radius: 36,
//           backgroundColor: Colors.white,
//           child: CircleAvatar(
//             radius: 34,
//             backgroundImage: widget.cardData['photo_url'] != null
//               ? NetworkImage(widget.cardData['photo_url'])
//               : null,
//             backgroundColor: Colors.grey[200],
//             child: widget.cardData['photo_url'] == null
//               ? const Icon(Icons.person, size: 36, color: Colors.grey)
//               : null,
//           ),
//         ),
        
//         const SizedBox(width: 12),
        
//         // Name, email, member info
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // Name and download button
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       widget.cardData['name'] ?? 'Member Name',
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: textColor,
//                         height: 1.4,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: (){},
//                     child: const Icon(
//                       Icons.file_download_outlined,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                   ),
//                 ],
//               ),
              
//               const SizedBox(height: 4),
              
//               // Email
//               Row(
//                 children: [
//                   emailIconBytes != null
//                     ? Image.memory(
//                         emailIconBytes,
//                         width: 14,
//                         height: 14,
//                         color: Colors.white,
//                       )
//                     : const Icon(
//                         Icons.email_outlined, 
//                         color: Colors.white, 
//                         size: 14
//                       ),
//                   const SizedBox(width: 4),
//                   Expanded(
//                     child: Text(
//                       widget.cardData['email'] ?? 'email@example.com',
//                       style: GoogleFonts.poppins(
//                         fontSize: 11,
//                         color: Colors.white,
//                         height: 1.4,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
              
//               const SizedBox(height: 4),
              
//               // Member type with active badge
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   memberIconBytes != null
//                     ? Image.memory(
//                         memberIconBytes,
//                         width: 14,
//                         height: 14,
//                         color: Colors.white,
//                       )
//                     : const Icon(
//                         Icons.person_outline, 
//                         color: Colors.white, 
//                         size: 14
//                       ),
//                   const SizedBox(width: 4),
//                   Expanded(
//                     child: Text(
//                       membershipTypeName ?? 'Member',
//                       style: GoogleFonts.poppins(
//                         fontSize: 11,
//                         color: Colors.white,
//                         height: 1.4,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 2,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         activeIconBytes != null
//                           ? Image.memory(
//                               activeIconBytes,
//                               width: 10,
//                               height: 10,
//                               color: isActive ? Colors.green : Colors.red,
//                             )
//                           : Icon(
//                               isActive ? Icons.check_circle : Icons.cancel,
//                               color: isActive ? Colors.green : Colors.red,
//                               size: 10,
//                             ),
//                         const SizedBox(width: 2),
//                         Text(
//                           isActive ? 'Active' : 'Inactive',
//                           style: GoogleFonts.poppins(
//                             color: primaryBlue,
//                             fontSize: 10,
//                             fontWeight: FontWeight.w600,
//                             height: 1.4,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDetailsSection() {
//     // Use consistent font sizes
//     const double labelSize = 12.0; 
//     const double valueSize = 12.0;
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildDetailRow('ID:', widget.cardData['qr_code_no']?.toString() ?? '', labelSize, valueSize),
//         const SizedBox(height: 8),
//         _buildDetailRow('Issued On:', _formatDate(widget.cardData['start_date']), labelSize, valueSize),
//         const SizedBox(height: 8),
//         _buildDetailRow('Expires:', _formatExpiryDate(), labelSize, valueSize),
//         const SizedBox(height: 8),
//         _buildAddressRow('Address:', widget.cardData['address'] ?? 'Not specified', labelSize, valueSize),
//       ],
//     );
//   }
  
//   Widget _buildDetailRow(String label, String value, double labelSize, double valueSize) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         SizedBox(
//           width: 70,
//           child: Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: labelSize,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//               height: 1.4,
//             ),
//           ),
//         ),
        
//         Expanded(
//           child: Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: valueSize,
//               color: Colors.white,
//               height: 1.4,
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
  
//   Widget _buildAddressRow(String label, String value, double labelSize, double valueSize) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           width: 70,
//           child: Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: labelSize,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//               height: 1.4,
//             ),
//           ),
//         ),
        
//         Expanded(
//           child: Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: valueSize,
//               color: Colors.white,
//               height: 1.2,
//             ),
//             softWrap: true,
//             maxLines: 2,
//             overflow: TextOverflow.clip,
//           ),
//         ),
//       ],
//     );
//   }
  
//   String _formatExpiryDate() {
//     if (widget.cardData['is_lifetime'] == 1) {
//       return 'Lifetime';
//     }
//     return _formatDate(widget.cardData['expiry_date']);
//   }
  
//   String _formatDate(String? dateString) {
//     if (dateString == null) return 'Not specified';
    
//     try {
//       final date = DateTime.parse(dateString);
//       final day = date.day.toString().padLeft(2, '0');
//       final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//       final month = months[date.month - 1];
//       final year = date.year;
      
//       return '$day $month $year';
//     } catch (e) {
//       return dateString;
//     }
//   }
// }

// // Custom painter for the decorative wavy lines
// class WavyLinesPainter extends CustomPainter {
//   final Color color1;
//   final Color color2;

//   WavyLinesPainter({required this.color1, required this.color2});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint1 = Paint()
//       ..color = color1.withOpacity(0.3)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.5;

//     final paint2 = Paint()
//       ..color = color2.withOpacity(0.3)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.5;

//     final width = size.width;
//     final height = size.height;

//     // First wavy path (blue)
//     final Path path1 = Path();
//     path1.moveTo(0, height * 0.3);
    
//     for (int i = 0; i < 6; i++) {
//       final x1 = width * (i / 6);
//       final y1 = height * 0.3 + ((i % 2 == 0) ? -8 : 8);
//       final x2 = width * ((i + 1) / 6);
//       final y2 = height * 0.3 + ((i % 2 == 0) ? 8 : -8);
//       path1.quadraticBezierTo(
//         (x1 + x2) / 2, y1 * 1.5, 
//         x2, y2
//       );
//     }
    
//     // Second wavy path (purple)
//     final Path path2 = Path();
//     path2.moveTo(0, height * 0.6);
    
//     for (int i = 0; i < 4; i++) {
//       final x1 = width * (i / 4);
//       final y1 = height * 0.6 + ((i % 2 == 0) ? -10 : 10);
//       final x2 = width * ((i + 1) / 4);
//       final y2 = height * 0.6 + ((i % 2 == 0) ? 10 : -10);
//       path2.quadraticBezierTo(
//         (x1 + x2) / 2, y1 * 1.2, 
//         x2, y2
//       );
//     }

//     // Draw the paths
//     canvas.drawPath(path1, paint1);
//     canvas.drawPath(path2, paint2);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }













// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';


// // Local providers for the card widget - scoped to just this widget
// final cardSvgContentProvider = StateProvider.autoDispose<String?>((ref) => null);
// final cardMembershipTypeProvider = StateProvider.autoDispose<String?>((ref) => 'Member'); // Default value
// final cardLogoImageBytesProvider = StateProvider.autoDispose<Uint8List?>((ref) => null);

// class MembershipCardDisplay extends ConsumerStatefulWidget {
//   final Map<String, dynamic> cardData;
//   final List<Map<String, dynamic>>? membershipTypes;

//   const MembershipCardDisplay({
//     super.key, 
//     required this.cardData, 
//     this.membershipTypes,
//   });
  
//   @override
//   ConsumerState<MembershipCardDisplay> createState() => _MembershipCardDisplayState();
// }

// class _MembershipCardDisplayState extends ConsumerState<MembershipCardDisplay> {
//   // Colors from design
//   final Color primaryBlue = const Color(0xFF487dc7);
//   final Color textColor = Colors.white;
//   final Color pinkBackground = const Color(0xD6FFA3E6); // rgba(255, 163, 230, 0.84)
//   final Color sloganTextColor = const Color(0xFF1e4c84);
//   final Color wavyLineColor1 = const Color(0xFF3366CC); // Darker blue for waves
//   final Color wavyLineColor2 = const Color(0xFFAA55CC); // Purple for waves
  
//   @override
//   void initState() {
//     super.initState();
    
//     // FIXED: Use postFrameCallback to update providers AFTER build is complete
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _processQrCode();
//       _getMembershipTypeName();
//       _loadLogoImage();
//     });
    
//     // Explicitly allow screenshots
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
//     // Disable secure display flags
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//       systemStatusBarContrastEnforced: false,
//     ));
//   }
  
//   Future<void> _loadLogoImage() async {
//     try {
//       // Try to load the Oval Logo.png first
//       final ByteData data = await rootBundle.load('assets/Oval Logo.png');
//       if (mounted) {
//         ref.read(cardLogoImageBytesProvider.notifier).state = data.buffer.asUint8List();
//       }
//     } catch (e) {
//       debugPrint('Error loading logo: $e');
//       // Try alternate paths
//       try {
//         final ByteData data = await rootBundle.load('assets/images/Oval Logo.png');
//         if (mounted) {
//           ref.read(cardLogoImageBytesProvider.notifier).state = data.buffer.asUint8List();
//         }
//       } catch (e) {
//         debugPrint('Error loading logo from first alternate path: $e');
//         try {
//           final ByteData data = await rootBundle.load('assets/extratech-oval-logo.png');
//           if (mounted) {
//             ref.read(cardLogoImageBytesProvider.notifier).state = data.buffer.asUint8List();
//           }
//         } catch (e) {
//           debugPrint('Error loading logo from second alternate path: $e');
//         }
//       }
//     }
//   }
  
//   void _getMembershipTypeName() {
//     // FIXED: First calculate the value, then update the provider once
//     final cardTypeId = widget.cardData['card_type_id'];
//     String? typeName;
    
//     if (cardTypeId != null && widget.membershipTypes != null) {
//       for (final type in widget.membershipTypes!) {
//         if (type['id'] == cardTypeId) {
//           typeName = type['type'];
//           break;
//         }
//       }
//     }
    
//     // If we can't find the type or there are no types, use a default value
//     if (mounted) {
//       ref.read(cardMembershipTypeProvider.notifier).state = 
//         typeName ?? widget.cardData['card_type'] ?? 'Member';
//     }
//   }
  
//   void _processQrCode() {
//     if (!mounted) return;
    
//     if (widget.cardData.containsKey('qr_code')) {
//       try {
//         final qrCodeData = widget.cardData['qr_code'].toString();
        
//         if (qrCodeData.startsWith('data:image/svg+xml;base64,')) {
//           // Extract base64 part
//           final base64String = qrCodeData.split('base64,')[1];
          
//           // Decode base64 to bytes
//           final bytes = base64Decode(base64String);
          
//           // Convert bytes to SVG string
//           final svgString = utf8.decode(bytes);
          
//           ref.read(cardSvgContentProvider.notifier).state = svgString;
//         }
//       } catch (e) {
//         debugPrint('Error processing QR: $e');
//       }
//     }
//   }


//   @override
//   Widget build(BuildContext context) {
//     // Get state from providers
//     final svgContent = ref.watch(cardSvgContentProvider);
//     final membershipTypeName = ref.watch(cardMembershipTypeProvider);
//     final logoImageBytes = ref.watch(cardLogoImageBytesProvider);
    
//     // Update the condition to recognize multiple approved statuses
//     final bool isApproved = widget.cardData['status'] == 1 || widget.cardData['status'] == 4;
    
//     if (!isApproved) {
//       return _buildPendingApplicationView();
//     }
    
//     // If status is approved, show the actual card
//     return Card(
//       elevation: 8.0,
//       margin: const EdgeInsets.symmetric(vertical: 20),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16.0),
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Main card body with blue background
//           Container(
//             color: primaryBlue,
//             padding: const EdgeInsets.all(16),
//             child: Stack(
//               children: [
//                 // Watermark logo - only in left section, not touching QR
//                 if (logoImageBytes != null)
//                   Positioned(
//                     left: 0,
//                     right: 150, // Fixed right limit to avoid QR code area
//                     top: 120, // Below the header section
//                     bottom: 0,
//                     child: Opacity(
//                       opacity: 0.30,
//                       child: Center(
//                         child: Image.memory(
//                           logoImageBytes,
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                     ),
//                   ),
                
//                 // Wavy lines decorations
//                 Positioned(
//                   left: 0,
//                   right: 0,
//                   bottom: 50,
//                   height: 100,
//                   child: CustomPaint(
//                     painter: WavyLinesPainter(
//                       color1: wavyLineColor1,
//                       color2: wavyLineColor2,
//                     ),
//                   ),
//                 ),
                
//                 // Card content
//                 Column(
//                   children: [
//                     // TOP SECTION - Header with photo, name, email, member type
//                     _buildHeaderSection(membershipTypeName),
                    
//                     const SizedBox(height: 16),
                    
//                     // BOTTOM SECTION - Details and QR code
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Left column - Details section (62% width)
//                         Expanded(
//                           flex: 62,
//                           child: _buildDetailsSection(),
//                         ),
                        
//                         // Spacing between text and QR (smaller gap)
//                         const SizedBox(width: 16),
                        
//                         // Right column - QR code section (38% width)
//                         Expanded(
//                           flex: 38,
//                           child: AspectRatio(
//                             aspectRatio: 1.0, // Keep it square
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(2),
//                               ),
//                               padding: const EdgeInsets.all(2),
//                               child: svgContent != null
//                                 ? SvgPicture.string(
//                                     svgContent,
//                                     fit: BoxFit.contain,
//                                   )
//                                 : const Center(
//                                     child: Icon(
//                                       Icons.qr_code,
//                                       color: Colors.grey,
//                                       size: 50,
//                                     ),
//                                   ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
          
//           // Pink footer with slogan
//           Container(
//             width: double.infinity,
//             color: pinkBackground,
//             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
//             child: Text(
//               '"मेरो लगानी सिप सिक्नको लागि मात्र नभई एस्टेडिएम बनाउनको लागि पनि"',
//               style: GoogleFonts.poppins(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: sloganTextColor,
//                 height: 1.4, // Match other text height per debug info
//                 letterSpacing: 0.3, // Match letter spacing per debug info
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildPendingApplicationView() {
//     return Card(
//       elevation: 8.0,
//       margin: const EdgeInsets.symmetric(vertical: 20),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16.0),
//       ),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [primaryBlue, primaryBlue.withOpacity(0.8)],
//           ),
//           borderRadius: BorderRadius.circular(16.0),
//         ),
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 shape: BoxShape.circle,
//               ),
//               padding: const EdgeInsets.all(20),
//               child: const Icon(
//                 Icons.check_circle_outline,
//                 color: Colors.white,
//                 size: 50,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Application Submitted',
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'Your membership card application has been submitted successfully and is awaiting approval.',
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 color: Colors.white.withOpacity(0.9),
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.white.withOpacity(0.3)),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.3),
//                       shape: BoxShape.circle,
//                     ),
//                     padding: const EdgeInsets.all(8),
//                     child: const Icon(
//                       Icons.access_time,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Application Status',
//                           style: GoogleFonts.poppins(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                             color: Colors.white,
//                             height: 1.4,
//                             letterSpacing: 0.3,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           'Under Review',
//                           style: GoogleFonts.poppins(
//                             color: Colors.white.withOpacity(0.9),
//                             fontSize: 14,
//                             height: 1.4,
//                             letterSpacing: 0.3,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             if (widget.cardData['qr_code_no'] != null)
//               Container(
//                 padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(
//                       Icons.confirmation_number_outlined,
//                       size: 16,
//                       color: Colors.white,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Reference: ${widget.cardData['qr_code_no']}',
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         color: Colors.white,
//                         height: 1.4,
//                         letterSpacing: 0.3,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildHeaderSection(String? membershipTypeName) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Profile photo
//         CircleAvatar(
//           radius: 36,
//           backgroundColor: Colors.white,
//           child: CircleAvatar(
//             radius: 34,
//             backgroundImage: widget.cardData['photo_url'] != null
//               ? NetworkImage(widget.cardData['photo_url'])
//               : null,
//             backgroundColor: Colors.grey[200],
//             child: widget.cardData['photo_url'] == null
//               ? const Icon(Icons.person, size: 36, color: Colors.grey)
//               : null,
//           ),
//         ),
        
//         const SizedBox(width: 12),
        
//         // Name, email, member info
//         Expanded(
//           child: SizedBox(
//             height: 72, // Fixed height that works well
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Name and download button
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         widget.cardData['name'] ?? 'Member Name',
//                         style: GoogleFonts.poppins(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: textColor,
//                           height: 1.4,
//                           letterSpacing: 0.3,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: (){},
//                       child: const Icon(
//                         Icons.file_download_outlined,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                     ),
//                   ],
//                 ),
                
//                 // Email
//                 Row(
//                   children: [
//                     const Icon(Icons.email_outlined, 
//                       color: Colors.white, 
//                       size: 14
//                     ),
//                     const SizedBox(width: 4),
//                     Expanded(
//                       child: Text(
//                         widget.cardData['email'] ?? 'email@example.com',
//                         style: GoogleFonts.poppins(
//                           fontSize: 11,
//                           color: Colors.white,
//                           height: 1.4,
//                           letterSpacing: 0.3,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
                
//                 // Member type with active badge
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const Icon(Icons.person_outline, 
//                       color: Colors.white, 
//                       size: 14
//                     ),
//                     const SizedBox(width: 4),
//                     Expanded(
//                       child: Text(
//                         membershipTypeName ?? 'Member',
//                         style: GoogleFonts.poppins(
//                           fontSize: 11,
//                           color: Colors.white,
//                           height: 1.4,
//                           letterSpacing: 0.3,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 2,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(
//                             Icons.check_circle,
//                             color: Colors.green,
//                             size: 10,
//                           ),
//                           const SizedBox(width: 2),
//                           Text(
//                             'Active',
//                             style: GoogleFonts.poppins(
//                               color: primaryBlue,
//                               fontSize: 10,
//                               fontWeight: FontWeight.w600,
//                               height: 1.4,
//                               letterSpacing: 0.3,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDetailsSection() {
//     // Use exactly the font sizes from debug info
//     const double labelSize = 12.0; 
//     const double valueSize = 12.0;
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildDetailRow('ID:', widget.cardData['qr_code_no']?.toString() ?? '', labelSize, valueSize),
//         const SizedBox(height: 8),
//         _buildDetailRow('IssuedOn:', _formatDate(widget.cardData['start_date']), labelSize, valueSize),
//         const SizedBox(height: 8),
//         _buildDetailRow('Expiry:', _formatExpiryDate(), labelSize, valueSize),
//         const SizedBox(height: 8),
//         _buildAddressRow('Address:', widget.cardData['address'] ?? 'Not specified', labelSize, valueSize),
//       ],
//     );
//   }
  
//   Widget _buildDetailRow(String label, String value, double labelSize, double valueSize) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         SizedBox(
//           width: 70, // Exact width per debug info
//           child: Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: labelSize,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//               height: 1.4, // Exact height per debug info
//               letterSpacing: 0.3, // Exact letter spacing per debug info
//             ),
//           ),
//         ),
        
//         Expanded(
//           child: Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: valueSize,
//               color: Colors.white,
//               height: 1.4, // Exact height per debug info
//               letterSpacing: 0.3, // Exact letter spacing per debug info
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis, // Match debug info
//           ),
//         ),
//       ],
//     );
//   }
  
//   Widget _buildAddressRow(String label, String value, double labelSize, double valueSize) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           width: 70, // Exact width per debug info
//           child: Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: labelSize,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//               height: 1.4, // Match other text height
//               letterSpacing: 0.3, // Match letter spacing
//             ),
//           ),
//         ),
        
//         Expanded(
//           child: Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: valueSize,
//               color: Colors.white,
//               height: 1.2, // Exact height per debug info
//               letterSpacing: 0.3, // Exact letter spacing per debug info
//             ),
//             softWrap: true,
//             maxLines: 2,
//             overflow: TextOverflow.clip, // Exact overflow mode per debug info
//           ),
//         ),
//       ],
//     );
//   }
  
//   String _formatExpiryDate() {
//     if (widget.cardData['is_lifetime'] == 1) {
//       return 'Lifetime';
//     }
//     return _formatDate(widget.cardData['expiry_date']);
//   }
  
//   String _formatDate(String? dateString) {
//     if (dateString == null) return 'Not specified';
    
//     try {
//       final date = DateTime.parse(dateString);
//       final day = date.day.toString().padLeft(2, '0');
//       final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//       final month = months[date.month - 1];
//       final year = date.year;
      
//       return '$day $month $year';
//     } catch (e) {
//       return dateString;
//     }
//   }
// }

// // Custom painter for the decorative wavy lines
// class WavyLinesPainter extends CustomPainter {
//   final Color color1;
//   final Color color2;

//   WavyLinesPainter({required this.color1, required this.color2});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint1 = Paint()
//       ..color = color1.withOpacity(0.3)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.5;

//     final paint2 = Paint()
//       ..color = color2.withOpacity(0.3)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.5;

//     final width = size.width;
//     final height = size.height;

//     // First wavy path (blue)
//     final Path path1 = Path();
//     path1.moveTo(0, height * 0.3);
    
//     for (int i = 0; i < 6; i++) {
//       final x1 = width * (i / 6);
//       final y1 = height * 0.3 + ((i % 2 == 0) ? -8 : 8);
//       final x2 = width * ((i + 1) / 6);
//       final y2 = height * 0.3 + ((i % 2 == 0) ? 8 : -8);
//       path1.quadraticBezierTo(
//         (x1 + x2) / 2, y1 * 1.5, 
//         x2, y2
//       );
//     }
    
//     // Second wavy path (purple)
//     final Path path2 = Path();
//     path2.moveTo(0, height * 0.6);
    
//     for (int i = 0; i < 4; i++) {
//       final x1 = width * (i / 4);
//       final y1 = height * 0.6 + ((i % 2 == 0) ? -10 : 10);
//       final x2 = width * ((i + 1) / 4);
//       final y2 = height * 0.6 + ((i % 2 == 0) ? 10 : -10);
//       path2.quadraticBezierTo(
//         (x1 + x2) / 2, y1 * 1.2, 
//         x2, y2
//       );
//     }

//     // Draw the paths
//     canvas.drawPath(path1, paint1);
//     canvas.drawPath(path2, paint2);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }

















// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'membership_card_pdf_service.dart';

// class MembershipCardDisplay extends ConsumerStatefulWidget {
//   final Map<String, dynamic> cardData;
//   final List<Map<String, dynamic>>? membershipTypes;

//   const MembershipCardDisplay({Key? key, required this.cardData, this.membershipTypes}) : super(key: key);
  
//   @override
//   ConsumerState<MembershipCardDisplay> createState() => _MembershipCardDisplayState();
// }

// class _MembershipCardDisplayState extends ConsumerState<MembershipCardDisplay> {
//   bool _hasQrCode = false;
//   String? _svgContent;
//   String _errorMessage = '';
//   String? _membershipTypeName;
//   Uint8List? _logoImageBytes;
  
//   // Colors from design
//   final Color primaryBlue = const Color(0xFF487dc7);
//   final Color textColor = Colors.white;
//   final Color pinkBackground = const Color(0xD6FFA3E6); // rgba(255, 163, 230, 0.84)
//   final Color sloganTextColor = const Color(0xFF1e4c84);
//   final Color wavyLineColor1 = const Color(0xFF3366CC); // Darker blue for waves
//   final Color wavyLineColor2 = const Color(0xFFAA55CC); // Purple for waves
  
//   @override
//   void initState() {
//     super.initState();
//     _processQrCode();
//     _getMembershipTypeName();
//     _loadLogoImage();
    
//     // Explicitly allow screenshots
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
//     // Disable any secure display flags that might prevent screenshots
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//       systemStatusBarContrastEnforced: false,
//     ));
//   }
  
//   Future<void> _loadLogoImage() async {
//     try {
//       // Try to load the Oval Logo.png first
//       final ByteData data = await rootBundle.load('assets/Oval Logo.png');
//       setState(() {
//         _logoImageBytes = data.buffer.asUint8List();
//       });
//     } catch (e) {
//       debugPrint('Error loading logo: $e');
//       // Try alternate paths
//       try {
//         final ByteData data = await rootBundle.load('assets/images/Oval Logo.png');
//         setState(() {
//           _logoImageBytes = data.buffer.asUint8List();
//         });
//       } catch (e) {
//         debugPrint('Error loading logo from first alternate path: $e');
//         try {
//           final ByteData data = await rootBundle.load('assets/extratech-oval-logo.png');
//           setState(() {
//             _logoImageBytes = data.buffer.asUint8List();
//           });
//         } catch (e) {
//           debugPrint('Error loading logo from second alternate path: $e');
//         }
//       }
//     }
//   }
  
//   void _getMembershipTypeName() {
//     // Get card type id from card data
//     final cardTypeId = widget.cardData['card_type_id'];
    
//     if (cardTypeId != null && widget.membershipTypes != null) {
//       for (final type in widget.membershipTypes!) {
//         if (type['id'] == cardTypeId) {
//           setState(() {
//             _membershipTypeName = type['type'];
//           });
//           return;
//         }
//       }
//     }
    
//     // If we can't find the type or there are no types, use a default value
//     setState(() {
//       _membershipTypeName = widget.cardData['card_type'] ?? 'Member';
//     });
//   }
  
//   void _processQrCode() {
//     if (widget.cardData.containsKey('qr_code')) {
//       try {
//         final qrCodeData = widget.cardData['qr_code'].toString();
        
//         if (qrCodeData.startsWith('data:image/svg+xml;base64,')) {
//           // Extract base64 part
//           final base64String = qrCodeData.split('base64,')[1];
          
//           // Decode base64 to bytes
//           final bytes = base64Decode(base64String);
          
//           // Convert bytes to SVG string
//           final svgString = utf8.decode(bytes);
          
//           setState(() {
//             _svgContent = svgString;
//             _hasQrCode = true;
//           });
//         } else {
//           setState(() {
//             _errorMessage = 'Invalid QR format';
//           });
//         }
//       } catch (e) {
//         setState(() {
//           _errorMessage = 'Error processing QR';
//         });
//       }
//     }
//   }

//   Future<void> _generateAndDownloadPDF() async {
//     try {
//       // Use the dedicated PDF service to generate and share the PDF
//       await MembershipCardPdfService.generateAndSharePdf(
//         cardData: widget.cardData,
//         membershipTypeName: _membershipTypeName,
//         logoImageBytes: _logoImageBytes,
//         primaryBlue: primaryBlue,
//         pinkBackground: pinkBackground,
//         sloganTextColor: sloganTextColor,
//       );
//     } catch (e) {
//       debugPrint('Error generating PDF: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error generating PDF: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Update the condition to recognize multiple approved statuses
//     final bool isApproved = widget.cardData['status'] == 1 || widget.cardData['status'] == 4;
    
//     if (!isApproved) {
//       return _buildPendingApplicationView();
//     }
    
//     // If status is approved, show the actual card
//     return Card(
//       elevation: 8.0,
//       margin: const EdgeInsets.symmetric(vertical: 20),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16.0),
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Main card body with blue background
//           Container(
//             color: primaryBlue,
//             padding: const EdgeInsets.all(16),
//             child: Stack(
//               children: [
//                 // Watermark logo - only in left section, not touching QR
//                 if (_logoImageBytes != null)
//                   Positioned(
//                     left: 0,
//                     right: 150, // Fixed right limit to avoid QR code area
//                     top: 120, // Below the header section
//                     bottom: 0,
//                     child: Opacity(
//                       opacity: 0.30,
//                       child: Center(
//                         child: Image.memory(
//                           _logoImageBytes!,
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                     ),
//                   ),
                
//                 // Wavy lines decorations
//                 Positioned(
//                   left: 0,
//                   right: 0,
//                   bottom: 50,
//                   height: 100,
//                   child: CustomPaint(
//                     painter: WavyLinesPainter(
//                       color1: wavyLineColor1,
//                       color2: wavyLineColor2,
//                     ),
//                   ),
//                 ),
                
//                 // Card content
//                 Column(
//                   children: [
//                     // TOP SECTION - Header with photo, name, email, member type
//                     _buildHeaderSection(),
                    
//                     const SizedBox(height: 16),
                    
//                     // BOTTOM SECTION - Details and QR code
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Left column - Details section (62% width)
//                         Expanded(
//                           flex: 62,
//                           child: _buildDetailsSection(),
//                         ),
                        
//                         // Spacing between text and QR (smaller gap)
//                         const SizedBox(width: 16),
                        
//                         // Right column - QR code section (38% width)
//                         Expanded(
//                           flex: 38,
//                           child: AspectRatio(
//                             aspectRatio: 1.0, // Keep it square
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(2),
//                               ),
//                               padding: const EdgeInsets.all(2),
//                               child: _hasQrCode && _svgContent != null
//                                 ? SvgPicture.string(
//                                     _svgContent!,
//                                     fit: BoxFit.contain,
//                                   )
//                                 : const Center(
//                                     child: Icon(
//                                       Icons.qr_code,
//                                       color: Colors.grey,
//                                       size: 50,
//                                     ),
//                                   ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
          
//           // Pink footer with slogan
//           Container(
//             width: double.infinity,
//             color: pinkBackground,
//             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
//             child: Text(
//               '"मेरो लगानी सिप सिक्नको लागि मात्र नभई एस्टेडिएम बनाउनको लागि पनि"',
//               style: GoogleFonts.poppins(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: sloganTextColor,
//                 height: 1.4, // Match other text height per debug info
//                 letterSpacing: 0.3, // Match letter spacing per debug info
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   // The rest of the methods remain largely unchanged, just without setState calls
//   Widget _buildPendingApplicationView() {
//     return Card(
//       elevation: 8.0,
//       margin: const EdgeInsets.symmetric(vertical: 20),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16.0),
//       ),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [primaryBlue, primaryBlue.withOpacity(0.8)],
//           ),
//           borderRadius: BorderRadius.circular(16.0),
//         ),
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 shape: BoxShape.circle,
//               ),
//               padding: const EdgeInsets.all(20),
//               child: const Icon(
//                 Icons.check_circle_outline,
//                 color: Colors.white,
//                 size: 50,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Application Submitted',
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'Your membership card application has been submitted successfully and is awaiting approval.',
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 color: Colors.white.withOpacity(0.9),
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.white.withOpacity(0.3)),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.3),
//                       shape: BoxShape.circle,
//                     ),
//                     padding: const EdgeInsets.all(8),
//                     child: const Icon(
//                       Icons.access_time,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Application Status',
//                           style: GoogleFonts.poppins(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                             color: Colors.white,
//                             height: 1.4,
//                             letterSpacing: 0.3,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           'Under Review',
//                           style: GoogleFonts.poppins(
//                             color: Colors.white.withOpacity(0.9),
//                             fontSize: 14,
//                             height: 1.4,
//                             letterSpacing: 0.3,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             if (widget.cardData['qr_code_no'] != null)
//               Container(
//                 padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(
//                       Icons.confirmation_number_outlined,
//                       size: 16,
//                       color: Colors.white,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Reference: ${widget.cardData['qr_code_no']}',
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         color: Colors.white,
//                         height: 1.4,
//                         letterSpacing: 0.3,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildHeaderSection() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Profile photo
//         CircleAvatar(
//           radius: 36,
//           backgroundColor: Colors.white,
//           child: CircleAvatar(
//             radius: 34,
//             backgroundImage: widget.cardData['photo_url'] != null
//               ? NetworkImage(widget.cardData['photo_url'])
//               : null,
//             backgroundColor: Colors.grey[200],
//             child: widget.cardData['photo_url'] == null
//               ? const Icon(Icons.person, size: 36, color: Colors.grey)
//               : null,
//           ),
//         ),
        
//         const SizedBox(width: 12),
        
//         // Name, email, member info
//         Expanded(
//           child: SizedBox(
//             height: 72, // Fixed height that works well
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Name and download button
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         widget.cardData['name'] ?? 'Member Name',
//                         style: GoogleFonts.poppins(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: textColor,
//                           height: 1.4,
//                           letterSpacing: 0.3,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: _generateAndDownloadPDF,
//                       child: const Icon(
//                         Icons.file_download_outlined,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                     ),
//                   ],
//                 ),
                
//                 // Email
//                 Row(
//                   children: [
//                     const Icon(Icons.email_outlined, 
//                       color: Colors.white, 
//                       size: 14
//                     ),
//                     const SizedBox(width: 4),
//                     Expanded(
//                       child: Text(
//                         widget.cardData['email'] ?? 'email@example.com',
//                         style: GoogleFonts.poppins(
//                           fontSize: 11,
//                           color: Colors.white,
//                           height: 1.4,
//                           letterSpacing: 0.3,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
                
//                 // Member type with active badge
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const Icon(Icons.person_outline, 
//                       color: Colors.white, 
//                       size: 14
//                     ),
//                     const SizedBox(width: 4),
//                     Expanded(
//                       child: Text(
//                         _membershipTypeName ?? 'Member',
//                         style: GoogleFonts.poppins(
//                           fontSize: 11,
//                           color: Colors.white,
//                           height: 1.4,
//                           letterSpacing: 0.3,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 2,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(
//                             Icons.check_circle,
//                             color: Colors.green,
//                             size: 10,
//                           ),
//                           const SizedBox(width: 2),
//                           Text(
//                             'Active',
//                             style: GoogleFonts.poppins(
//                               color: primaryBlue,
//                               fontSize: 10,
//                               fontWeight: FontWeight.w600,
//                               height: 1.4,
//                               letterSpacing: 0.3,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDetailsSection() {
//     // Use exactly the font sizes from debug info
//     const double labelSize = 12.0; 
//     const double valueSize = 12.0;
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildDetailRow('ID:', widget.cardData['qr_code_no']?.toString() ?? '', labelSize, valueSize),
//         const SizedBox(height: 8),
//         _buildDetailRow('IssuedOn:', _formatDate(widget.cardData['start_date']), labelSize, valueSize),
//         const SizedBox(height: 8),
//         _buildDetailRow('Expiry:', _formatExpiryDate(), labelSize, valueSize),
//         const SizedBox(height: 8),
//         _buildAddressRow('Address:', widget.cardData['address'] ?? 'Not specified', labelSize, valueSize),
//       ],
//     );
//   }
  
//   Widget _buildDetailRow(String label, String value, double labelSize, double valueSize) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         SizedBox(
//           width: 70, // Exact width per debug info
//           child: Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: labelSize,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//               height: 1.4, // Exact height per debug info
//               letterSpacing: 0.3, // Exact letter spacing per debug info
//             ),
//           ),
//         ),
        
//         Expanded(
//           child: Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: valueSize,
//               color: Colors.white,
//               height: 1.4, // Exact height per debug info
//               letterSpacing: 0.3, // Exact letter spacing per debug info
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis, // Match debug info
//           ),
//         ),
//       ],
//     );
//   }
  
//   Widget _buildAddressRow(String label, String value, double labelSize, double valueSize) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           width: 70, // Exact width per debug info
//           child: Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: labelSize,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//               height: 1.4, // Match other text height
//               letterSpacing: 0.3, // Match letter spacing
//             ),
//           ),
//         ),
        
//         Expanded(
//           child: Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: valueSize,
//               color: Colors.white,
//               height: 1.2, // Exact height per debug info
//               letterSpacing: 0.3, // Exact letter spacing per debug info
//             ),
//             softWrap: true,
//             maxLines: 2,
//             overflow: TextOverflow.clip, // Exact overflow mode per debug info
//           ),
//         ),
//       ],
//     );
//   }
  
//   String _formatExpiryDate() {
//     if (widget.cardData['is_lifetime'] == 1) {
//       return 'Lifetime';
//     }
//     return _formatDate(widget.cardData['expiry_date']);
//   }
  
//   String _formatDate(String? dateString) {
//     if (dateString == null) return 'Not specified';
    
//     try {
//       final date = DateTime.parse(dateString);
//       final day = date.day.toString().padLeft(2, '0');
//       final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//       final month = months[date.month - 1];
//       final year = date.year;
      
//       return '$day $month $year';
//     } catch (e) {
//       return dateString;
//     }
//   }
// }

// // Custom painter for the decorative wavy lines - remains unchanged
// class WavyLinesPainter extends CustomPainter {
//   final Color color1;
//   final Color color2;

//   WavyLinesPainter({required this.color1, required this.color2});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint1 = Paint()
//       ..color = color1.withOpacity(0.3)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.5;

//     final paint2 = Paint()
//       ..color = color2.withOpacity(0.3)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.5;

//     final width = size.width;
//     final height = size.height;

//     // First wavy path (blue)
//     final Path path1 = Path();
//     path1.moveTo(0, height * 0.3);
    
//     for (int i = 0; i < 6; i++) {
//       final x1 = width * (i / 6);
//       final y1 = height * 0.3 + ((i % 2 == 0) ? -8 : 8);
//       final x2 = width * ((i + 1) / 6);
//       final y2 = height * 0.3 + ((i % 2 == 0) ? 8 : -8);
//       path1.quadraticBezierTo(
//         (x1 + x2) / 2, y1 * 1.5, 
//         x2, y2
//       );
//     }
    
//     // Second wavy path (purple)
//     final Path path2 = Path();
//     path2.moveTo(0, height * 0.6);
    
//     for (int i = 0; i < 4; i++) {
//       final x1 = width * (i / 4);
//       final y1 = height * 0.6 + ((i % 2 == 0) ? -10 : 10);
//       final x2 = width * ((i + 1) / 4);
//       final y2 = height * 0.6 + ((i % 2 == 0) ? 10 : -10);
//       path2.quadraticBezierTo(
//         (x1 + x2) / 2, y1 * 1.2, 
//         x2, y2
//       );
//     }

//     // Draw the paths
//     canvas.drawPath(path1, paint1);
//     canvas.drawPath(path2, paint2);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }


















// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_svg/flutter_svg.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'membership_card_pdf_service.dart';

// // class MembershipCardDisplay extends StatefulWidget {
// //   final Map<String, dynamic> cardData;
// //   final List<Map<String, dynamic>>? membershipTypes;

// //   const MembershipCardDisplay({super.key, required this.cardData, this.membershipTypes});
  
// //   @override
// //   State<MembershipCardDisplay> createState() => _MembershipCardDisplayState();
// // }

// // class _MembershipCardDisplayState extends State<MembershipCardDisplay> {
// //   bool _hasQrCode = false;
// //   String? _svgContent;
// //   String _errorMessage = '';
// //   String? _membershipTypeName;
// //   Uint8List? _logoImageBytes;
  
// //   // Colors from design
// //   final Color primaryBlue = const Color(0xFF487dc7);
// //   final Color textColor = Colors.white;
// //   final Color pinkBackground = const Color(0xD6FFA3E6); // rgba(255, 163, 230, 0.84)
// //   final Color sloganTextColor = const Color(0xFF1e4c84);
// //   final Color wavyLineColor1 = const Color(0xFF3366CC); // Darker blue for waves
// //   final Color wavyLineColor2 = const Color(0xFFAA55CC); // Purple for waves
  
// //   @override
// //   void initState() {
// //     super.initState();
// //     _processQrCode();
// //     _getMembershipTypeName();
// //     _loadLogoImage();
    
// //     // Explicitly allow screenshots
// //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
// //     // Disable any secure display flags that might prevent screenshots
// //     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
// //       systemStatusBarContrastEnforced: false,
// //     ));
// //   }
  
// //   Future<void> _loadLogoImage() async {
// //     try {
// //       // Try to load the Oval Logo.png first
// //       final ByteData data = await rootBundle.load('assets/Oval Logo.png');
// //       setState(() {
// //         _logoImageBytes = data.buffer.asUint8List();
// //       });
// //     } catch (e) {
// //       debugPrint('Error loading logo: $e');
// //       // Try alternate paths
// //       try {
// //         final ByteData data = await rootBundle.load('assets/images/Oval Logo.png');
// //         setState(() {
// //           _logoImageBytes = data.buffer.asUint8List();
// //         });
// //       } catch (e) {
// //         debugPrint('Error loading logo from first alternate path: $e');
// //         try {
// //           final ByteData data = await rootBundle.load('assets/extratech-oval-logo.png');
// //           setState(() {
// //             _logoImageBytes = data.buffer.asUint8List();
// //           });
// //         } catch (e) {
// //           debugPrint('Error loading logo from second alternate path: $e');
// //         }
// //       }
// //     }
// //   }
  
// //   void _getMembershipTypeName() {
// //     // Get card type id from card data
// //     final cardTypeId = widget.cardData['card_type_id'];
    
// //     if (cardTypeId != null && widget.membershipTypes != null) {
// //       for (final type in widget.membershipTypes!) {
// //         if (type['id'] == cardTypeId) {
// //           setState(() {
// //             _membershipTypeName = type['type'];
// //           });
// //           return;
// //         }
// //       }
// //     }
    
// //     // If we can't find the type or there are no types, use a default value
// //     setState(() {
// //       _membershipTypeName = widget.cardData['card_type'] ?? 'Member';
// //     });
// //   }
  
// //   void _processQrCode() {
// //     if (widget.cardData.containsKey('qr_code')) {
// //       try {
// //         final qrCodeData = widget.cardData['qr_code'].toString();
        
// //         if (qrCodeData.startsWith('data:image/svg+xml;base64,')) {
// //           // Extract base64 part
// //           final base64String = qrCodeData.split('base64,')[1];
          
// //           // Decode base64 to bytes
// //           final bytes = base64Decode(base64String);
          
// //           // Convert bytes to SVG string
// //           final svgString = utf8.decode(bytes);
          
// //           setState(() {
// //             _svgContent = svgString;
// //             _hasQrCode = true;
// //           });
// //         } else {
// //           setState(() {
// //             _errorMessage = 'Invalid QR format';
// //           });
// //         }
// //       } catch (e) {
// //         setState(() {
// //           _errorMessage = 'Error processing QR';
// //         });
// //       }
// //     }
// //   }

// //   Future<void> _generateAndDownloadPDF() async {
// //     try {
// //       // Use the dedicated PDF service to generate and share the PDF
// //       await MembershipCardPdfService.generateAndSharePdf(
// //         cardData: widget.cardData,
// //         membershipTypeName: _membershipTypeName,
// //         logoImageBytes: _logoImageBytes,
// //         primaryBlue: primaryBlue,
// //         pinkBackground: pinkBackground,
// //         sloganTextColor: sloganTextColor,
// //       );
// //     } catch (e) {
// //       debugPrint('Error generating PDF: $e');
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text('Error generating PDF: $e'),
// //             backgroundColor: Colors.red,
// //           ),
// //         );
// //       }
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // Update the condition to recognize multiple approved statuses
// //     final bool isApproved = widget.cardData['status'] == 1 || widget.cardData['status'] == 4;
    
// //     if (!isApproved) {
// //       return _buildPendingApplicationView();
// //     }
    
// //     // If status is approved, show the actual card
// //     return Card(
// //       elevation: 8.0,
// //       margin: const EdgeInsets.symmetric(vertical: 20),
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.circular(16.0),
// //       ),
// //       clipBehavior: Clip.antiAlias,
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           // Main card body with blue background
// //           Container(
// //             color: primaryBlue,
// //             padding: const EdgeInsets.all(16),
// //             child: Stack(
// //               children: [
// //                 // Watermark logo - only in left section, not touching QR
// //                 if (_logoImageBytes != null)
// //                   Positioned(
// //                     left: 0,
// //                     right: 150, // Fixed right limit to avoid QR code area
// //                     top: 120, // Below the header section
// //                     bottom: 0,
// //                     child: Opacity(
// //                       opacity: 0.30,
// //                       child: Center(
// //                         child: Image.memory(
// //                           _logoImageBytes!,
// //                           fit: BoxFit.contain,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
                
// //                 // Wavy lines decorations
// //                 Positioned(
// //                   left: 0,
// //                   right: 0,
// //                   bottom: 50,
// //                   height: 100,
// //                   child: CustomPaint(
// //                     painter: WavyLinesPainter(
// //                       color1: wavyLineColor1,
// //                       color2: wavyLineColor2,
// //                     ),
// //                   ),
// //                 ),
                
// //                 // Card content
// //                 Column(
// //                   children: [
// //                     // TOP SECTION - Header with photo, name, email, member type
// //                     _buildHeaderSection(),
                    
// //                     const SizedBox(height: 16),
                    
// //                     // BOTTOM SECTION - Details and QR code
// //                     Row(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         // Left column - Details section (62% width)
// //                         Expanded(
// //                           flex: 62,
// //                           child: _buildDetailsSection(),
// //                         ),
                        
// //                         // Spacing between text and QR (smaller gap)
// //                         const SizedBox(width: 16),
                        
// //                         // Right column - QR code section (38% width)
// //                         Expanded(
// //                           flex: 38,
// //                           child: AspectRatio(
// //                             aspectRatio: 1.0, // Keep it square
// //                             child: Container(
// //                               decoration: BoxDecoration(
// //                                 color: Colors.white,
// //                                 borderRadius: BorderRadius.circular(2),
// //                               ),
// //                               padding: const EdgeInsets.all(2),
// //                               child: _hasQrCode && _svgContent != null
// //                                 ? SvgPicture.string(
// //                                     _svgContent!,
// //                                     fit: BoxFit.contain,
// //                                   )
// //                                 : const Center(
// //                                     child: Icon(
// //                                       Icons.qr_code,
// //                                       color: Colors.grey,
// //                                       size: 50,
// //                                     ),
// //                                   ),
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
          
// //           // Pink footer with slogan
// //           Container(
// //             width: double.infinity,
// //             color: pinkBackground,
// //             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
// //             child: Text(
// //               '"मेरो लगानी सिप सिक्नको लागि मात्र नभई एस्टेडिएम बनाउनको लागि पनि"',
// //               style: GoogleFonts.poppins(
// //                 fontSize: 12,
// //                 fontWeight: FontWeight.w600,
// //                 color: sloganTextColor,
// //                 height: 1.4, // Match other text height per debug info
// //                 letterSpacing: 0.3, // Match letter spacing per debug info
// //               ),
// //               textAlign: TextAlign.center,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
  
// //   Widget _buildPendingApplicationView() {
// //     return Card(
// //       elevation: 8.0,
// //       margin: const EdgeInsets.symmetric(vertical: 20),
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.circular(16.0),
// //       ),
// //       child: Container(
// //         decoration: BoxDecoration(
// //           gradient: LinearGradient(
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //             colors: [primaryBlue, primaryBlue.withOpacity(0.8)],
// //           ),
// //           borderRadius: BorderRadius.circular(16.0),
// //         ),
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Container(
// //               decoration: BoxDecoration(
// //                 color: Colors.white.withOpacity(0.2),
// //                 shape: BoxShape.circle,
// //               ),
// //               padding: const EdgeInsets.all(20),
// //               child: const Icon(
// //                 Icons.check_circle_outline,
// //                 color: Colors.white,
// //                 size: 50,
// //               ),
// //             ),
// //             const SizedBox(height: 20),
// //             Text(
// //               'Application Submitted',
// //               style: GoogleFonts.poppins(
// //                 fontSize: 20,
// //                 fontWeight: FontWeight.bold,
// //                 color: Colors.white,
// //               ),
// //               textAlign: TextAlign.center,
// //             ),
// //             const SizedBox(height: 12),
// //             Text(
// //               'Your membership card application has been submitted successfully and is awaiting approval.',
// //               style: GoogleFonts.poppins(
// //                 fontSize: 14,
// //                 color: Colors.white.withOpacity(0.9),
// //               ),
// //               textAlign: TextAlign.center,
// //             ),
// //             const SizedBox(height: 24),
// //             Container(
// //               padding: const EdgeInsets.all(16),
// //               decoration: BoxDecoration(
// //                 color: Colors.white.withOpacity(0.15),
// //                 borderRadius: BorderRadius.circular(12),
// //                 border: Border.all(color: Colors.white.withOpacity(0.3)),
// //               ),
// //               child: Row(
// //                 children: [
// //                   Container(
// //                     decoration: BoxDecoration(
// //                       color: Colors.white.withOpacity(0.3),
// //                       shape: BoxShape.circle,
// //                     ),
// //                     padding: const EdgeInsets.all(8),
// //                     child: const Icon(
// //                       Icons.access_time,
// //                       color: Colors.white,
// //                       size: 20,
// //                     ),
// //                   ),
// //                   const SizedBox(width: 12),
// //                   Expanded(
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           'Application Status',
// //                           style: GoogleFonts.poppins(
// //                             fontWeight: FontWeight.bold,
// //                             fontSize: 16,
// //                             color: Colors.white,
// //                             height: 1.4,
// //                             letterSpacing: 0.3,
// //                           ),
// //                         ),
// //                         const SizedBox(height: 4),
// //                         Text(
// //                           'Under Review',
// //                           style: GoogleFonts.poppins(
// //                             color: Colors.white.withOpacity(0.9),
// //                             fontSize: 14,
// //                             height: 1.4,
// //                             letterSpacing: 0.3,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             const SizedBox(height: 20),
// //             if (widget.cardData['qr_code_no'] != null)
// //               Container(
// //                 padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white.withOpacity(0.1),
// //                   borderRadius: BorderRadius.circular(8),
// //                 ),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     const Icon(
// //                       Icons.confirmation_number_outlined,
// //                       size: 16,
// //                       color: Colors.white,
// //                     ),
// //                     const SizedBox(width: 8),
// //                     Text(
// //                       'Reference: ${widget.cardData['qr_code_no']}',
// //                       style: GoogleFonts.poppins(
// //                         fontSize: 14,
// //                         color: Colors.white,
// //                         height: 1.4,
// //                         letterSpacing: 0.3,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
  
// //   Widget _buildHeaderSection() {
// //     return Row(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         // Profile photo
// //         CircleAvatar(
// //           radius: 36,
// //           backgroundColor: Colors.white,
// //           child: CircleAvatar(
// //             radius: 34,
// //             backgroundImage: widget.cardData['photo_url'] != null
// //               ? NetworkImage(widget.cardData['photo_url'])
// //               : null,
// //             backgroundColor: Colors.grey[200],
// //             child: widget.cardData['photo_url'] == null
// //               ? const Icon(Icons.person, size: 36, color: Colors.grey)
// //               : null,
// //           ),
// //         ),
        
// //         const SizedBox(width: 12),
        
// //         // Name, email, member info
// //         Expanded(
// //           child: SizedBox(
// //             height: 72, // Fixed height that works well
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 // Name and download button
// //                 Row(
// //                   crossAxisAlignment: CrossAxisAlignment.center,
// //                   children: [
// //                     Expanded(
// //                       child: Text(
// //                         widget.cardData['name'] ?? 'Member Name',
// //                         style: GoogleFonts.poppins(
// //                           fontSize: 18,
// //                           fontWeight: FontWeight.bold,
// //                           color: textColor,
// //                           height: 1.4,
// //                           letterSpacing: 0.3,
// //                         ),
// //                         maxLines: 1,
// //                         overflow: TextOverflow.ellipsis,
// //                       ),
// //                     ),
// //                     GestureDetector(
// //                       onTap: _generateAndDownloadPDF,
// //                       child: const Icon(
// //                         Icons.file_download_outlined,
// //                         color: Colors.white,
// //                         size: 20,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
                
// //                 // Email
// //                 Row(
// //                   children: [
// //                     const Icon(Icons.email_outlined, 
// //                       color: Colors.white, 
// //                       size: 14
// //                     ),
// //                     const SizedBox(width: 4),
// //                     Expanded(
// //                       child: Text(
// //                         widget.cardData['email'] ?? 'email@example.com',
// //                         style: GoogleFonts.poppins(
// //                           fontSize: 11,
// //                           color: Colors.white,
// //                           height: 1.4,
// //                           letterSpacing: 0.3,
// //                         ),
// //                         maxLines: 1,
// //                         overflow: TextOverflow.ellipsis,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
                
// //                 // Member type with active badge
// //                 Row(
// //                   crossAxisAlignment: CrossAxisAlignment.center,
// //                   children: [
// //                     const Icon(Icons.person_outline, 
// //                       color: Colors.white, 
// //                       size: 14
// //                     ),
// //                     const SizedBox(width: 4),
// //                     Expanded(
// //                       child: Text(
// //                         _membershipTypeName ?? 'Member',
// //                         style: GoogleFonts.poppins(
// //                           fontSize: 11,
// //                           color: Colors.white,
// //                           height: 1.4,
// //                           letterSpacing: 0.3,
// //                         ),
// //                         maxLines: 1,
// //                         overflow: TextOverflow.ellipsis,
// //                       ),
// //                     ),
// //                     Container(
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 8,
// //                         vertical: 2,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: Colors.white,
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                       child: Row(
// //                         mainAxisSize: MainAxisSize.min,
// //                         children: [
// //                           const Icon(
// //                             Icons.check_circle,
// //                             color: Colors.green,
// //                             size: 10,
// //                           ),
// //                           const SizedBox(width: 2),
// //                           Text(
// //                             'Active',
// //                             style: GoogleFonts.poppins(
// //                               color: primaryBlue,
// //                               fontSize: 10,
// //                               fontWeight: FontWeight.w600,
// //                               height: 1.4,
// //                               letterSpacing: 0.3,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildDetailsSection() {
// //     // Use exactly the font sizes from debug info
// //     const double labelSize = 12.0; 
// //     const double valueSize = 12.0;
    
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         _buildDetailRow('ID:', widget.cardData['qr_code_no']?.toString() ?? '', labelSize, valueSize),
// //         const SizedBox(height: 8),
// //         _buildDetailRow('IssuedOn:', _formatDate(widget.cardData['start_date']), labelSize, valueSize),
// //         const SizedBox(height: 8),
// //         _buildDetailRow('Expiry:', _formatExpiryDate(), labelSize, valueSize),
// //         const SizedBox(height: 8),
// //         _buildAddressRow('Address:', widget.cardData['address'] ?? 'Not specified', labelSize, valueSize),
// //       ],
// //     );
// //   }
  
// //   Widget _buildDetailRow(String label, String value, double labelSize, double valueSize) {
// //     return Row(
// //       crossAxisAlignment: CrossAxisAlignment.center,
// //       children: [
// //         SizedBox(
// //           width: 70, // Exact width per debug info
// //           child: Text(
// //             label,
// //             style: GoogleFonts.poppins(
// //               fontSize: labelSize,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.white,
// //               height: 1.4, // Exact height per debug info
// //               letterSpacing: 0.3, // Exact letter spacing per debug info
// //             ),
// //           ),
// //         ),
        
// //         Expanded(
// //           child: Text(
// //             value,
// //             style: GoogleFonts.poppins(
// //               fontSize: valueSize,
// //               color: Colors.white,
// //               height: 1.4, // Exact height per debug info
// //               letterSpacing: 0.3, // Exact letter spacing per debug info
// //             ),
// //             maxLines: 1,
// //             overflow: TextOverflow.ellipsis, // Match debug info
// //           ),
// //         ),
// //       ],
// //     );
// //   }
  
// //   Widget _buildAddressRow(String label, String value, double labelSize, double valueSize) {
// //     return Row(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         SizedBox(
// //           width: 70, // Exact width per debug info
// //           child: Text(
// //             label,
// //             style: GoogleFonts.poppins(
// //               fontSize: labelSize,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.white,
// //               height: 1.4, // Match other text height
// //               letterSpacing: 0.3, // Match letter spacing
// //             ),
// //           ),
// //         ),
        
// //         Expanded(
// //           child: Text(
// //             value,
// //             style: GoogleFonts.poppins(
// //               fontSize: valueSize,
// //               color: Colors.white,
// //               height: 1.2, // Exact height per debug info
// //               letterSpacing: 0.3, // Exact letter spacing per debug info
// //             ),
// //             softWrap: true,
// //             maxLines: 2,
// //             overflow: TextOverflow.clip, // Exact overflow mode per debug info
// //           ),
// //         ),
// //       ],
// //     );
// //   }
  
// //   String _formatExpiryDate() {
// //     if (widget.cardData['is_lifetime'] == 1) {
// //       return 'Lifetime';
// //     }
// //     return _formatDate(widget.cardData['expiry_date']);
// //   }
  
// //   String _formatDate(String? dateString) {
// //     if (dateString == null) return 'Not specified';
    
// //     try {
// //       final date = DateTime.parse(dateString);
// //       final day = date.day.toString().padLeft(2, '0');
// //       final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
// //       final month = months[date.month - 1];
// //       final year = date.year;
      
// //       return '$day $month $year';
// //     } catch (e) {
// //       return dateString;
// //     }
// //   }
// // }

// // // Custom painter for the decorative wavy lines
// // class WavyLinesPainter extends CustomPainter {
// //   final Color color1;
// //   final Color color2;

// //   WavyLinesPainter({required this.color1, required this.color2});

// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     final paint1 = Paint()
// //       ..color = color1.withOpacity(0.3)
// //       ..style = PaintingStyle.stroke
// //       ..strokeWidth = 1.5;

// //     final paint2 = Paint()
// //       ..color = color2.withOpacity(0.3)
// //       ..style = PaintingStyle.stroke
// //       ..strokeWidth = 1.5;

// //     final width = size.width;
// //     final height = size.height;

// //     // First wavy path (blue)
// //     final Path path1 = Path();
// //     path1.moveTo(0, height * 0.3);
    
// //     for (int i = 0; i < 6; i++) {
// //       final x1 = width * (i / 6);
// //       final y1 = height * 0.3 + ((i % 2 == 0) ? -8 : 8);
// //       final x2 = width * ((i + 1) / 6);
// //       final y2 = height * 0.3 + ((i % 2 == 0) ? 8 : -8);
// //       path1.quadraticBezierTo(
// //         (x1 + x2) / 2, y1 * 1.5, 
// //         x2, y2
// //       );
// //     }
    
// //     // Second wavy path (purple)
// //     final Path path2 = Path();
// //     path2.moveTo(0, height * 0.6);
    
// //     for (int i = 0; i < 4; i++) {
// //       final x1 = width * (i / 4);
// //       final y1 = height * 0.6 + ((i % 2 == 0) ? -10 : 10);
// //       final x2 = width * ((i + 1) / 4);
// //       final y2 = height * 0.6 + ((i % 2 == 0) ? 10 : -10);
// //       path2.quadraticBezierTo(
// //         (x1 + x2) / 2, y1 * 1.2, 
// //         x2, y2
// //       );
// //     }

// //     // Draw the paths
// //     canvas.drawPath(path1, paint1);
// //     canvas.drawPath(path2, paint2);
// //   }

// //   @override
// //   bool shouldRepaint(CustomPainter oldDelegate) => true;
// // }













// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_svg/flutter_svg.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'membership_card_pdf_service.dart';

// // class MembershipCardDisplay extends StatefulWidget {
// //   final Map<String, dynamic> cardData;
// //   final List<Map<String, dynamic>>? membershipTypes;

// //   const MembershipCardDisplay({super.key, required this.cardData, this.membershipTypes});
  
// //   @override
// //   State<MembershipCardDisplay> createState() => _MembershipCardDisplayState();
// // }

// // class _MembershipCardDisplayState extends State<MembershipCardDisplay> {
// //   bool _hasQrCode = false;
// //   String? _svgContent;
// //   String _errorMessage = '';
// //   String? _membershipTypeName;
// //   Uint8List? _logoImageBytes;
  
// //   // Colors from design
// //   final Color primaryBlue = const Color(0xFF487dc7);
// //   final Color textColor = Colors.white;
// //   final Color pinkBackground = const Color(0xD6FFA3E6); // rgba(255, 163, 230, 0.84)
// //   final Color sloganTextColor = const Color(0xFF1e4c84);
// //   final Color wavyLineColor1 = const Color(0xFF3366CC); // Darker blue for waves
// //   final Color wavyLineColor2 = const Color(0xFFAA55CC); // Purple for waves
  
// //   @override
// //   void initState() {
// //     super.initState();
// //     _processQrCode();
// //     _getMembershipTypeName();
// //     _loadLogoImage();
    
// //     // Explicitly allow screenshots
// //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
// //     // Disable any secure display flags that might prevent screenshots
// //     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
// //       systemStatusBarContrastEnforced: false,
// //     ));
// //   }
  
// //   Future<void> _loadLogoImage() async {
// //     try {
// //       // Try to load the Oval Logo.png first
// //       final ByteData data = await rootBundle.load('assets/Oval Logo.png');
// //       setState(() {
// //         _logoImageBytes = data.buffer.asUint8List();
// //       });
// //     } catch (e) {
// //       debugPrint('Error loading logo: $e');
// //       // Try alternate paths
// //       try {
// //         final ByteData data = await rootBundle.load('assets/images/Oval Logo.png');
// //         setState(() {
// //           _logoImageBytes = data.buffer.asUint8List();
// //         });
// //       } catch (e) {
// //         debugPrint('Error loading logo from first alternate path: $e');
// //         try {
// //           final ByteData data = await rootBundle.load('assets/extratech-oval-logo.png');
// //           setState(() {
// //             _logoImageBytes = data.buffer.asUint8List();
// //           });
// //         } catch (e) {
// //           debugPrint('Error loading logo from second alternate path: $e');
// //         }
// //       }
// //     }
// //   }
  
// //   void _getMembershipTypeName() {
// //     // Get card type id from card data
// //     final cardTypeId = widget.cardData['card_type_id'];
    
// //     if (cardTypeId != null && widget.membershipTypes != null) {
// //       for (final type in widget.membershipTypes!) {
// //         if (type['id'] == cardTypeId) {
// //           setState(() {
// //             _membershipTypeName = type['type'];
// //           });
// //           return;
// //         }
// //       }
// //     }
    
// //     // If we can't find the type or there are no types, use a default value
// //     setState(() {
// //       _membershipTypeName = widget.cardData['card_type'] ?? 'Member';
// //     });
// //   }
  
// //   void _processQrCode() {
// //     if (widget.cardData.containsKey('qr_code')) {
// //       try {
// //         final qrCodeData = widget.cardData['qr_code'].toString();
        
// //         if (qrCodeData.startsWith('data:image/svg+xml;base64,')) {
// //           // Extract base64 part
// //           final base64String = qrCodeData.split('base64,')[1];
          
// //           // Decode base64 to bytes
// //           final bytes = base64Decode(base64String);
          
// //           // Convert bytes to SVG string
// //           final svgString = utf8.decode(bytes);
          
// //           setState(() {
// //             _svgContent = svgString;
// //             _hasQrCode = true;
// //           });
// //         } else {
// //           setState(() {
// //             _errorMessage = 'Invalid QR format';
// //           });
// //         }
// //       } catch (e) {
// //         setState(() {
// //           _errorMessage = 'Error processing QR';
// //         });
// //       }
// //     }
// //   }

// //   Future<void> _generateAndDownloadPDF() async {
// //     try {
// //       // Use the dedicated PDF service to generate and share the PDF
// //       await MembershipCardPdfService.generateAndSharePdf(
// //         cardData: widget.cardData,
// //         membershipTypeName: _membershipTypeName,
// //         logoImageBytes: _logoImageBytes,
// //         primaryBlue: primaryBlue,
// //         pinkBackground: pinkBackground,
// //         sloganTextColor: sloganTextColor,
// //       );
// //     } catch (e) {
// //       debugPrint('Error generating PDF: $e');
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text('Error generating PDF: $e'),
// //             backgroundColor: Colors.red,
// //           ),
// //         );
// //       }
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // Update the condition to recognize multiple approved statuses
// //     final bool isApproved = widget.cardData['status'] == 1 || widget.cardData['status'] == 4;
    
// //     if (!isApproved) {
// //       return _buildPendingApplicationView();
// //     }
    
// //     // If status is approved, show the actual card
// //     return _buildMembershipCard();
// //   }

// //   Widget _buildPendingApplicationView() {
// //     return Card(
// //       elevation: 8.0,
// //       margin: const EdgeInsets.symmetric(vertical: 20),
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.circular(16.0),
// //       ),
// //       child: Container(
// //         decoration: BoxDecoration(
// //           gradient: LinearGradient(
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //             colors: [primaryBlue, primaryBlue.withOpacity(0.8)],
// //           ),
// //           borderRadius: BorderRadius.circular(16.0),
// //         ),
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Container(
// //               decoration: BoxDecoration(
// //                 color: Colors.white.withOpacity(0.2),
// //                 shape: BoxShape.circle,
// //               ),
// //               padding: const EdgeInsets.all(20),
// //               child: const Icon(
// //                 Icons.check_circle_outline,
// //                 color: Colors.white,
// //                 size: 50,
// //               ),
// //             ),
// //             const SizedBox(height: 20),
// //             Text(
// //               'Application Submitted',
// //               style: GoogleFonts.poppins(
// //                 fontSize: 20,
// //                 fontWeight: FontWeight.bold,
// //                 color: Colors.white,
// //               ),
// //               textAlign: TextAlign.center,
// //             ),
// //             const SizedBox(height: 12),
// //             Text(
// //               'Your membership card application has been submitted successfully and is awaiting approval.',
// //               style: GoogleFonts.poppins(
// //                 fontSize: 14,
// //                 color: Colors.white.withOpacity(0.9),
// //               ),
// //               textAlign: TextAlign.center,
// //             ),
// //             const SizedBox(height: 24),
// //             Container(
// //               padding: const EdgeInsets.all(16),
// //               decoration: BoxDecoration(
// //                 color: Colors.white.withOpacity(0.15),
// //                 borderRadius: BorderRadius.circular(12),
// //                 border: Border.all(color: Colors.white.withOpacity(0.3)),
// //               ),
// //               child: Row(
// //                 children: [
// //                   Container(
// //                     decoration: BoxDecoration(
// //                       color: Colors.white.withOpacity(0.3),
// //                       shape: BoxShape.circle,
// //                     ),
// //                     padding: const EdgeInsets.all(8),
// //                     child: const Icon(
// //                       Icons.access_time,
// //                       color: Colors.white,
// //                       size: 20,
// //                     ),
// //                   ),
// //                   const SizedBox(width: 12),
// //                   Expanded(
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           'Application Status',
// //                           style: GoogleFonts.poppins(
// //                             fontWeight: FontWeight.bold,
// //                             fontSize: 16,
// //                             color: Colors.white,
// //                           ),
// //                         ),
// //                         const SizedBox(height: 4),
// //                         Text(
// //                           'Under Review',
// //                           style: GoogleFonts.poppins(
// //                             color: Colors.white.withOpacity(0.9),
// //                             fontSize: 14,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             const SizedBox(height: 20),
// //             if (widget.cardData['qr_code_no'] != null)
// //               Container(
// //                 padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white.withOpacity(0.1),
// //                   borderRadius: BorderRadius.circular(8),
// //                 ),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     const Icon(
// //                       Icons.confirmation_number_outlined,
// //                       size: 16,
// //                       color: Colors.white,
// //                     ),
// //                     const SizedBox(width: 8),
// //                     Text(
// //                       'Reference: ${widget.cardData['qr_code_no']}',
// //                       style: GoogleFonts.poppins(
// //                         fontSize: 14,
// //                         color: Colors.white,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildMembershipCard() {
// //     return Card(
// //       elevation: 8.0,
// //       margin: const EdgeInsets.symmetric(vertical: 20),
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.circular(16.0),
// //       ),
// //       clipBehavior: Clip.antiAlias,
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           // Main card body with blue background
// //           Container(
// //             color: primaryBlue,
// //             padding: const EdgeInsets.all(16),
// //             child: Stack(
// //               children: [
// //                 // Watermark logo - only in left section, not touching QR
// //                 if (_logoImageBytes != null)
// //                   Positioned(
// //                     left: 0,
// //                     right: 150, // Fixed right limit to avoid QR code area
// //                     top: 120, // Below the header section
// //                     bottom: 0,
// //                     child: Opacity(
// //                       opacity: 0.30,
// //                       child: Center(
// //                         child: Image.memory(
// //                           _logoImageBytes!,
// //                           fit: BoxFit.contain,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
                
// //                 // Wavy lines decorations
// //                 Positioned(
// //                   left: 0,
// //                   right: 0,
// //                   bottom: 50,
// //                   height: 100,
// //                   child: CustomPaint(
// //                     painter: WavyLinesPainter(
// //                       color1: wavyLineColor1,
// //                       color2: wavyLineColor2,
// //                     ),
// //                   ),
// //                 ),
                
// //                 // Card content
// //                 Column(
// //                   children: [
// //                     // TOP SECTION - Header with photo, name, email, member type
// //                     _buildHeaderSection(),
                    
// //                     const SizedBox(height: 24),
                    
// //                     // BOTTOM SECTION - Details and QR code
// //                     Row(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         // Left column - Details section (65% width)
// //                         Expanded(
// //                           flex: 65,
// //                           child: _buildDetailsSection(),
// //                         ),
                        
// //                         // Spacing between text and QR (smaller gap)
// //                         const SizedBox(width: 16),
                        
// //                         // Right column - QR code section (35% width)
// //                         Expanded(
// //                           flex: 35,
// //                           child: AspectRatio(
// //                             aspectRatio: 1.0, // Keep it square
// //                             child: Container(
// //                               decoration: BoxDecoration(
// //                                 color: Colors.white,
// //                                 borderRadius: BorderRadius.circular(2),
// //                               ),
// //                               padding: const EdgeInsets.all(2),
// //                               child: _hasQrCode && _svgContent != null
// //                                 ? SvgPicture.string(
// //                                     _svgContent!,
// //                                     fit: BoxFit.contain,
// //                                   )
// //                                 : const Center(
// //                                     child: Icon(
// //                                       Icons.qr_code,
// //                                       color: Colors.grey,
// //                                       size: 50,
// //                                     ),
// //                                   ),
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
          
// //           // Pink footer with slogan
// //           Container(
// //             width: double.infinity,
// //             color: pinkBackground,
// //             padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
// //             child: Text(
// //               '"मेरो लगानी सिप सिक्नको लागि मात्र नभई एस्टेडिएम बनाउनको लागि पनि"',
// //               style: GoogleFonts.poppins(
// //                 fontSize: 14,
// //                 fontWeight: FontWeight.w600,
// //                 color: sloganTextColor,
// //               ),
// //               textAlign: TextAlign.center,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
  
// //   Widget _buildHeaderSection() {
// //     return Row(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         // Profile photo
// //         CircleAvatar(
// //           radius: 40,
// //           backgroundColor: Colors.white,
// //           child: CircleAvatar(
// //             radius: 38,
// //             backgroundImage: widget.cardData['photo_url'] != null
// //               ? NetworkImage(widget.cardData['photo_url'])
// //               : null,
// //             backgroundColor: Colors.grey[200],
// //             child: widget.cardData['photo_url'] == null
// //               ? const Icon(Icons.person, size: 40, color: Colors.grey)
// //               : null,
// //           ),
// //         ),
        
// //         const SizedBox(width: 16),
        
// //         // Name, email, member info
// //         Expanded(
// //           child: SizedBox(
// //             height: 80,
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 // Name and download button
// //                 Row(
// //                   crossAxisAlignment: CrossAxisAlignment.center,
// //                   children: [
// //                     Expanded(
// //                       child: Text(
// //                         widget.cardData['name'] ?? 'Member Name',
// //                         style: GoogleFonts.poppins(
// //                           fontSize: 22,
// //                           fontWeight: FontWeight.bold,
// //                           color: textColor,
// //                         ),
// //                         maxLines: 1,
// //                         overflow: TextOverflow.ellipsis,
// //                       ),
// //                     ),
// //                     GestureDetector(
// //                       onTap: _generateAndDownloadPDF,
// //                       child: const Icon(
// //                         Icons.file_download_outlined,
// //                         color: Colors.white,
// //                         size: 24,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
                
// //                 // Email
// //                 Row(
// //                   children: [
// //                     const Icon(Icons.email_outlined, 
// //                       color: Colors.white, 
// //                       size: 16
// //                     ),
// //                     const SizedBox(width: 6),
// //                     Expanded(
// //                       child: Text(
// //                         widget.cardData['email'] ?? 'email@example.com',
// //                         style: GoogleFonts.poppins(
// //                           fontSize: 12,
// //                           color: Colors.white,
// //                         ),
// //                         maxLines: 1,
// //                         overflow: TextOverflow.ellipsis,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
                
// //                 // Member type with active badge
// //                 Row(
// //                   crossAxisAlignment: CrossAxisAlignment.center,
// //                   children: [
// //                     const Icon(Icons.person_outline, 
// //                       color: Colors.white, 
// //                       size: 16
// //                     ),
// //                     const SizedBox(width: 6),
// //                     Expanded(
// //                       child: Text(
// //                         _membershipTypeName ?? 'Member',
// //                         style: GoogleFonts.poppins(
// //                           fontSize: 12,
// //                           color: Colors.white,
// //                         ),
// //                         maxLines: 1,
// //                         overflow: TextOverflow.ellipsis,
// //                       ),
// //                     ),
// //                     Container(
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 10,
// //                         vertical: 2,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: Colors.white,
// //                         borderRadius: BorderRadius.circular(16),
// //                       ),
// //                       child: Row(
// //                         mainAxisSize: MainAxisSize.min,
// //                         children: [
// //                           const Icon(
// //                             Icons.check_circle,
// //                             color: Colors.green,
// //                             size: 14,
// //                           ),
// //                           const SizedBox(width: 4),
// //                           Text(
// //                             'Active',
// //                             style: GoogleFonts.poppins(
// //                               color: primaryBlue,
// //                               fontSize: 12,
// //                               fontWeight: FontWeight.w600,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildDetailsSection() {
// //     // Use slightly smaller font sizes to ensure all text fits
// //     const double labelSize = 13.0;
// //     const double valueSize = 13.5;
    
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         _buildDetailRow('ID:', widget.cardData['qr_code_no']?.toString() ?? '', labelSize, valueSize),
// //         const SizedBox(height: 12),
// //         _buildDetailRow('IssuedOn:', _formatDate(widget.cardData['start_date']), labelSize, valueSize),
// //         const SizedBox(height: 12),
// //         _buildDetailRow('Expiry:', _formatExpiryDate(), labelSize, valueSize),
// //         const SizedBox(height: 12),
// //         // Special handling for address
// //         _buildAddressRow('Address:', widget.cardData['address'] ?? 'Not specified', labelSize, valueSize),
// //       ],
// //     );
// //   }
  
// //   Widget _buildDetailRow(String label, String value, double labelSize, double valueSize) {
// //     return Row(
// //       crossAxisAlignment: CrossAxisAlignment.center,
// //       children: [
// //         // Label - fixed width
// //         SizedBox(
// //           width: 80, // Wider to match the look in reference
// //           child: Text(
// //             label,
// //             style: GoogleFonts.poppins(
// //               fontSize: labelSize,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.white,
// //             ),
// //           ),
// //         ),
        
// //         // Value - expands to fill available space
// //         Expanded(
// //           child: Text(
// //             value,
// //             style: GoogleFonts.poppins(
// //               fontSize: valueSize,
// //               color: Colors.white,
// //             ),
// //             maxLines: 1,
// //             overflow: TextOverflow.ellipsis,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
  
// //   // Special method for address to ensure it displays completely
// //   Widget _buildAddressRow(String label, String value, double labelSize, double valueSize) {
// //     return Row(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         // Label - fixed width
// //         SizedBox(
// //           width: 80, // Match other labels
// //           child: Text(
// //             label,
// //             style: GoogleFonts.poppins(
// //               fontSize: labelSize,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.white,
// //             ),
// //           ),
// //         ),
        
// //         // Address value - can wrap to multiple lines
// //         Expanded(
// //           child: Text(
// //             value,
// //             style: GoogleFonts.poppins(
// //               fontSize: valueSize,
// //               color: Colors.white,
// //               height: 1.3,
// //             ),
// //             softWrap: true,
// //             maxLines: 2, // Allow up to 2 lines for address
// //           ),
// //         ),
// //       ],
// //     );
// //   }
  
// //   String _formatExpiryDate() {
// //     if (widget.cardData['is_lifetime'] == 1) {
// //       return 'Lifetime';
// //     }
// //     return _formatDate(widget.cardData['expiry_date']);
// //   }
  
// //   String _formatDate(String? dateString) {
// //     if (dateString == null) return 'Not specified';
    
// //     try {
// //       final date = DateTime.parse(dateString);
// //       final day = date.day.toString().padLeft(2, '0');
// //       final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
// //       final month = months[date.month - 1];
// //       final year = date.year;
      
// //       return '$day $month $year';
// //     } catch (e) {
// //       return dateString;
// //     }
// //   }
// // }

// // // Custom painter for the decorative wavy lines
// // class WavyLinesPainter extends CustomPainter {
// //   final Color color1;
// //   final Color color2;

// //   WavyLinesPainter({required this.color1, required this.color2});

// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     // Path for the first wavy line (blue)
// //     final paint1 = Paint()
// //       ..color = color1.withOpacity(0.3)
// //       ..style = PaintingStyle.stroke
// //       ..strokeWidth = 2;

// //     // Path for the second wavy line (purple)
// //     final paint2 = Paint()
// //       ..color = color2.withOpacity(0.3)
// //       ..style = PaintingStyle.stroke
// //       ..strokeWidth = 2;

// //     final width = size.width;
// //     final height = size.height;

// //     // First wavy path (blue)
// //     final Path path1 = Path();
// //     path1.moveTo(0, height * 0.3);
    
// //     // Create first wave
// //     for (int i = 0; i < 6; i++) {
// //       final x1 = width * (i / 6);
// //       final y1 = height * 0.3 + ((i % 2 == 0) ? -10 : 10);
// //       final x2 = width * ((i + 1) / 6);
// //       final y2 = height * 0.3 + ((i % 2 == 0) ? 10 : -10);
// //       path1.quadraticBezierTo(
// //         (x1 + x2) / 2, y1 * 1.5, 
// //         x2, y2
// //       );
// //     }
    
// //     // Second wavy path (purple)
// //     final Path path2 = Path();
// //     path2.moveTo(0, height * 0.6);
    
// //     // Create second wave
// //     for (int i = 0; i < 4; i++) {
// //       final x1 = width * (i / 4);
// //       final y1 = height * 0.6 + ((i % 2 == 0) ? -15 : 15);
// //       final x2 = width * ((i + 1) / 4);
// //       final y2 = height * 0.6 + ((i % 2 == 0) ? 15 : -15);
// //       path2.quadraticBezierTo(
// //         (x1 + x2) / 2, y1 * 1.2, 
// //         x2, y2
// //       );
// //     }

// //     // Draw the paths
// //     canvas.drawPath(path1, paint1);
// //     canvas.drawPath(path2, paint2);
// //   }

// //   @override
// //   bool shouldRepaint(CustomPainter oldDelegate) => true;
// // }





















// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_svg/flutter_svg.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // // import 'package:path_provider/path_provider.dart';
// // import 'package:pdf/pdf.dart';
// // import 'package:pdf/widgets.dart' as pw;
// // import 'package:printing/printing.dart';
// // // import 'dart:io';
// // import 'package:http/http.dart' as http;

// // class MembershipCardDisplay extends StatefulWidget {
// //   final Map<String, dynamic> cardData;
// //   final List<Map<String, dynamic>>? membershipTypes;

// //   const MembershipCardDisplay({super.key, required this.cardData, this.membershipTypes});
  
// //   @override
// //   State<MembershipCardDisplay> createState() => _MembershipCardDisplayState();
// // }

// // class _MembershipCardDisplayState extends State<MembershipCardDisplay> {
// //   bool _hasQrCode = false;
// //   String? _svgContent;
// //   String _errorMessage = '';
// //   String? _membershipTypeName;
// //   Uint8List? _logoImageBytes;
  
// //   // Colors from design
// //   final Color primaryBlue = const Color(0xFF487dc7);
// //   final Color textColor = Colors.white;
// //   final Color pinkBackground = const Color(0xD6FFA3E6); // rgba(255, 163, 230, 0.84)
// //   final Color sloganTextColor = const Color(0xFF1e4c84);
  
// //   @override
// //   void initState() {
// //     super.initState();
// //     _processQrCode();
// //     _getMembershipTypeName();
// //     _loadLogoImage();
    
// //     // Allow screenshots
// //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
// //     // Debug - Log the card status and active status
// //     debugPrint('Card Status: ${widget.cardData['status']}');
// //     debugPrint('Is Active: ${widget.cardData['is_active']}');
// //   }
  
// //   Future<void> _loadLogoImage() async {
// //     try {
// //       final ByteData data = await rootBundle.load('assets/extratech-oval-logo.png');
// //       setState(() {
// //         _logoImageBytes = data.buffer.asUint8List();
// //       });
// //     } catch (e) {
// //       debugPrint('Error loading logo: $e');
// //       // Try alternate path if first one fails
// //       try {
// //         final ByteData data = await rootBundle.load('assets/images/extratech-oval-logo.png');
// //         setState(() {
// //           _logoImageBytes = data.buffer.asUint8List();
// //         });
// //       } catch (e) {
// //         debugPrint('Error loading logo from alternate path: $e');
// //       }
// //     }
// //   }
  
// //   void _getMembershipTypeName() {
// //     // Get card type id from card data
// //     final cardTypeId = widget.cardData['card_type_id'];
    
// //     if (cardTypeId != null && widget.membershipTypes != null) {
// //       for (final type in widget.membershipTypes!) {
// //         if (type['id'] == cardTypeId) {
// //           setState(() {
// //             _membershipTypeName = type['type'];
// //           });
// //           return;
// //         }
// //       }
// //     }
    
// //     // If we can't find the type or there are no types, use a default value
// //     setState(() {
// //       _membershipTypeName = widget.cardData['card_type'] ?? 'Extratech Student';
// //     });
// //   }
  
// //   void _processQrCode() {
// //     if (widget.cardData.containsKey('qr_code')) {
// //       try {
// //         final qrCodeData = widget.cardData['qr_code'].toString();
        
// //         if (qrCodeData.startsWith('data:image/svg+xml;base64,')) {
// //           // Extract base64 part
// //           final base64String = qrCodeData.split('base64,')[1];
          
// //           // Decode base64 to bytes
// //           final bytes = base64Decode(base64String);
          
// //           // Convert bytes to SVG string
// //           final svgString = utf8.decode(bytes);
          
// //           setState(() {
// //             _svgContent = svgString;
// //             _hasQrCode = true;
// //           });
// //         } else {
// //           setState(() {
// //             _errorMessage = 'Invalid QR format';
// //           });
// //         }
// //       } catch (e) {
// //         setState(() {
// //           _errorMessage = 'Error processing QR';
// //         });
// //       }
// //     }
// //   }

// //   Future<void> _generateAndDownloadPDF() async {
// //     try {
// //       final pdf = pw.Document();
      
// //       // Load ExtraTech logo image for PDF
// //       pw.MemoryImage? logoImage;
// //       if (_logoImageBytes != null) {
// //         logoImage = pw.MemoryImage(_logoImageBytes!);
// //       }
      
// //       // Get profile image for PDF if available
// //       pw.MemoryImage? profileImage;
// //       try {
// //         if (widget.cardData['photo_url'] != null) {
// //           final http.Response response = await http.get(Uri.parse(widget.cardData['photo_url']));
// //           if (response.statusCode == 200) {
// //             profileImage = pw.MemoryImage(response.bodyBytes);
// //           }
// //         }
// //       } catch (e) {
// //         debugPrint('Error loading profile image for PDF: $e');
// //       }

// //       // Get QR code for PDF
// //       pw.MemoryImage? qrImage;
// //       try {
// //         if (widget.cardData['qr_code'] != null) {
// //           final http.Response response = await http.get(Uri.parse(widget.cardData['qr_code']));
// //           if (response.statusCode == 200) {
// //             qrImage = pw.MemoryImage(response.bodyBytes);
// //           }
// //         }
// //       } catch (e) {
// //         debugPrint('Error loading QR code for PDF: $e');
// //       }

// //       // Create the PDF page with membership card
// //       pdf.addPage(
// //         pw.Page(
// //           pageFormat: PdfPageFormat.a4,
// //           build: (pw.Context context) {
// //             return pw.Center(
// //               child: pw.Container(
// //                 width: 500,
// //                 decoration: pw.BoxDecoration(
// //                   borderRadius: pw.BorderRadius.circular(16),
// //                 ),
// //                 child: pw.Column(
// //                   children: [
// //                     // Main card with blue background
// //                     pw.Container(
// //                       color: PdfColor.fromInt(primaryBlue.value),
// //                       padding: const pw.EdgeInsets.all(20),
// //                       child: pw.Stack(
// //                         children: [
// //                           // Watermark logo (if available)
// //                           if (logoImage != null)
// //                             pw.Positioned.fill(
// //                               child: pw.Opacity(
// //                                 opacity: 0.3,
// //                                 child: pw.Center(
// //                                   child: pw.Image(logoImage, width: 300),
// //                                 ),
// //                               ),
// //                             ),
                            
// //                           // Card content
// //                           pw.Column(
// //                             crossAxisAlignment: pw.CrossAxisAlignment.start,
// //                             children: [
// //                               // Top section - Photo and name
// //                               pw.Row(
// //                                 crossAxisAlignment: pw.CrossAxisAlignment.start,
// //                                 children: [
// //                                   // Profile image
// //                                   pw.Container(
// //                                     width: 90,
// //                                     height: 90,
// //                                     decoration: pw.BoxDecoration(
// //                                       shape: pw.BoxShape.circle,
// //                                       color: PdfColors.white,
// //                                     ),
// //                                     child: profileImage != null
// //                                       ? pw.ClipOval(child: pw.Image(profileImage))
// //                                       : pw.Center(
// //                                           child: pw.Text('Photo', style: pw.TextStyle(fontSize: 12)),
// //                                         ),
// //                                   ),
                                  
// //                                   pw.SizedBox(width: 20),
                                  
// //                                   // Name and icon
// //                                   pw.Expanded(
// //                                     child: pw.Row(
// //                                       children: [
// //                                         pw.Expanded(
// //                                           child: pw.Text(
// //                                             widget.cardData['name'] ?? 'Member Name',
// //                                             style: pw.TextStyle(
// //                                               color: PdfColors.white,
// //                                               fontSize: 24,
// //                                               fontWeight: pw.FontWeight.bold,
// //                                             ),
// //                                           ),
// //                                         ),
// //                                         pw.Text(
// //                                           '↓',
// //                                           style: pw.TextStyle(
// //                                             color: PdfColors.white,
// //                                             fontSize: 20,
// //                                           ),
// //                                         ),
// //                                       ],
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
                              
// //                               pw.SizedBox(height: 15),
                              
// //                               // Email
// //                               pw.Row(
// //                                 children: [
// //                                   pw.Text(
// //                                     '✉',
// //                                     style: pw.TextStyle(
// //                                       color: PdfColors.white,
// //                                       fontSize: 16,
// //                                     ),
// //                                   ),
// //                                   pw.SizedBox(width: 8),
// //                                   pw.Text(
// //                                     widget.cardData['email'] ?? 'email@example.com',
// //                                     style: pw.TextStyle(
// //                                       color: PdfColors.white,
// //                                       fontSize: 16,
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
                              
// //                               pw.SizedBox(height: 8),
                              
// //                               // Member type and active status
// //                               pw.Row(
// //                                 children: [
// //                                   pw.Text(
// //                                     '👤',
// //                                     style: pw.TextStyle(
// //                                       color: PdfColors.white,
// //                                       fontSize: 16,
// //                                     ),
// //                                   ),
// //                                   pw.SizedBox(width: 8),
// //                                   pw.Text(
// //                                     _membershipTypeName ?? 'Extratech Student',
// //                                     style: pw.TextStyle(
// //                                       color: PdfColors.white,
// //                                       fontSize: 16,
// //                                     ),
// //                                   ),
// //                                   pw.SizedBox(width: 10),
// //                                   pw.Container(
// //                                     padding: const pw.EdgeInsets.symmetric(
// //                                       horizontal: 10,
// //                                       vertical: 4,
// //                                     ),
// //                                     decoration: pw.BoxDecoration(
// //                                       color: PdfColors.white,
// //                                       borderRadius: pw.BorderRadius.circular(15),
// //                                     ),
// //                                     child: pw.Row(
// //                                       children: [
// //                                         pw.Text(
// //                                           '✓',
// //                                           style: pw.TextStyle(
// //                                             color: PdfColors.green,
// //                                             fontSize: 12,
// //                                             fontWeight: pw.FontWeight.bold,
// //                                           ),
// //                                         ),
// //                                         pw.SizedBox(width: 4),
// //                                         pw.Text(
// //                                           'Active',
// //                                           style: pw.TextStyle(
// //                                             color: PdfColor.fromInt(primaryBlue.value),
// //                                             fontSize: 12,
// //                                             fontWeight: pw.FontWeight.bold,
// //                                           ),
// //                                         ),
// //                                       ],
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
                              
// //                               pw.SizedBox(height: 20),
                              
// //                               // Info rows - single column layout
// //                               pw.Column(
// //                                 crossAxisAlignment: pw.CrossAxisAlignment.start,
// //                                 children: [
// //                                   pw.Row(
// //                                     children: [
// //                                       pw.Text(
// //                                         'ID:',
// //                                         style: pw.TextStyle(
// //                                           color: PdfColors.white,
// //                                           fontWeight: pw.FontWeight.bold,
// //                                           fontSize: 16,
// //                                         ),
// //                                       ),
// //                                       pw.SizedBox(width: 70),
// //                                       pw.Text(
// //                                         widget.cardData['qr_code_no']?.toString() ?? '',
// //                                         style: pw.TextStyle(
// //                                           color: PdfColors.white,
// //                                           fontSize: 16,
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
                                  
// //                                   pw.SizedBox(height: 8),
                                  
// //                                   pw.Row(
// //                                     children: [
// //                                       pw.Text(
// //                                         'Issued On:',
// //                                         style: pw.TextStyle(
// //                                           color: PdfColors.white,
// //                                           fontWeight: pw.FontWeight.bold,
// //                                           fontSize: 16,
// //                                         ),
// //                                       ),
// //                                       pw.SizedBox(width: 10),
// //                                       pw.Text(
// //                                         _formatDate(widget.cardData['start_date']),
// //                                         style: pw.TextStyle(
// //                                           color: PdfColors.white,
// //                                           fontSize: 16,
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
                                  
// //                                   pw.SizedBox(height: 8),
                                  
// //                                   pw.Row(
// //                                     children: [
// //                                       pw.Text(
// //                                         'Expiry:',
// //                                         style: pw.TextStyle(
// //                                           color: PdfColors.white,
// //                                           fontWeight: pw.FontWeight.bold,
// //                                           fontSize: 16,
// //                                         ),
// //                                       ),
// //                                       pw.SizedBox(width: 35),
// //                                       pw.Text(
// //                                         widget.cardData['is_lifetime'] == 1 
// //                                           ? 'Lifetime' 
// //                                           : _formatDate(widget.cardData['expiry_date']),
// //                                         style: pw.TextStyle(
// //                                           color: PdfColors.white,
// //                                           fontSize: 16,
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
                                  
// //                                   pw.SizedBox(height: 8),
                                  
// //                                   pw.Row(
// //                                     crossAxisAlignment: pw.CrossAxisAlignment.start,
// //                                     children: [
// //                                       pw.Text(
// //                                         'Address:',
// //                                         style: pw.TextStyle(
// //                                           color: PdfColors.white,
// //                                           fontWeight: pw.FontWeight.bold,
// //                                           fontSize: 16,
// //                                         ),
// //                                       ),
// //                                       pw.SizedBox(width: 20),
// //                                       pw.Expanded(
// //                                         child: pw.Text(
// //                                           widget.cardData['address'] ?? 'Not specified',
// //                                           style: pw.TextStyle(
// //                                             color: PdfColors.white,
// //                                             fontSize: 16,
// //                                           ),
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ],
// //                               ),
                              
// //                               pw.SizedBox(height: 20),
                              
// //                               // QR code - centered at bottom
// //                               pw.Center(
// //                                 child: pw.Container(
// //                                   width: 150,
// //                                   height: 150,
// //                                   color: PdfColors.white,
// //                                   child: qrImage != null
// //                                     ? pw.Image(qrImage, fit: pw.BoxFit.contain)
// //                                     : pw.Center(
// //                                         child: pw.Text(
// //                                           'QR Code',
// //                                           style: pw.TextStyle(fontSize: 14),
// //                                         ),
// //                                       ),
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ],
// //                       ),
// //                     ),
                    
// //                     // Pink footer with slogan
// //                     pw.Container(
// //                       width: 500,
// //                       color: PdfColor.fromInt(pinkBackground.value),
// //                       padding: const pw.EdgeInsets.symmetric(vertical: 12),
// //                       child: pw.Center(
// //                         child: pw.Text(
// //                           '"मेरो लगानी सिप सिक्नको लागि मात्र नभई एस्टेडिएम बनाउनको लागि पनि"',
// //                           style: pw.TextStyle(
// //                             color: PdfColor.fromInt(sloganTextColor.value),
// //                             fontSize: 10,
// //                             fontWeight: pw.FontWeight.bold,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             );
// //           },
// //         ),
// //       );

// //       // Save and share the PDF
// //       await Printing.sharePdf(bytes: await pdf.save(), filename: 'membership_card.pdf');
      
// //     } catch (e) {
// //       debugPrint('Error generating PDF: $e');
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text('Error generating PDF: $e'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // Update the condition to recognize multiple approved statuses
// //     final bool isApproved = widget.cardData['status'] == 1 || widget.cardData['status'] == 4;
    
// //     if (!isApproved) {
// //       return _buildPendingApplicationView();
// //     }
    
// //     // If status is approved, show the actual card
// //     return _buildMembershipCard();
// //   }

// //   Widget _buildPendingApplicationView() {
// //     return LayoutBuilder(
// //       builder: (context, constraints) {
// //         // Adaptive sizing based on available width
// //         final double maxWidth = constraints.maxWidth;
// //         final bool isSmallScreen = maxWidth < 350;
        
// //         final double iconSize = isSmallScreen ? 40.0 : 60.0;
// //         final double titleSize = isSmallScreen ? 18.0 : 22.0;
// //         final double bodyTextSize = isSmallScreen ? 12.0 : 14.0;
// //         final double padding = isSmallScreen ? 16.0 : 24.0;
        
// //         return Card(
// //           elevation: 8.0,
// //           margin: const EdgeInsets.symmetric(vertical: 20),
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(16.0),
// //           ),
// //           child: Container(
// //             decoration: BoxDecoration(
// //               gradient: LinearGradient(
// //                 begin: Alignment.topCenter,
// //                 end: Alignment.bottomCenter,
// //                 colors: [primaryBlue, primaryBlue.withOpacity(0.8)],
// //               ),
// //               borderRadius: BorderRadius.circular(16.0),
// //             ),
// //             padding: EdgeInsets.all(padding),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Container(
// //                   decoration: BoxDecoration(
// //                     color: Colors.white.withOpacity(0.2),
// //                     shape: BoxShape.circle,
// //                   ),
// //                   padding: const EdgeInsets.all(20),
// //                   child: Icon(
// //                     Icons.check_circle_outline,
// //                     color: Colors.white,
// //                     size: iconSize,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 20),
// //                 Text(
// //                   'Application Submitted',
// //                   style: GoogleFonts.poppins(
// //                     fontSize: titleSize,
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.white,
// //                   ),
// //                   textAlign: TextAlign.center,
// //                 ),
// //                 const SizedBox(height: 12),
// //                 Text(
// //                   'Your membership card application has been submitted successfully and is awaiting approval.',
// //                   style: GoogleFonts.poppins(
// //                     fontSize: bodyTextSize,
// //                     color: Colors.white.withOpacity(0.9),
// //                   ),
// //                   textAlign: TextAlign.center,
// //                 ),
// //                 const SizedBox(height: 24),
// //                 Container(
// //                   padding: const EdgeInsets.all(16),
// //                   decoration: BoxDecoration(
// //                     color: Colors.white.withOpacity(0.15),
// //                     borderRadius: BorderRadius.circular(12),
// //                     border: Border.all(color: Colors.white.withOpacity(0.3)),
// //                   ),
// //                   child: Row(
// //                     children: [
// //                       Container(
// //                         decoration: BoxDecoration(
// //                           color: Colors.white.withOpacity(0.3),
// //                           shape: BoxShape.circle,
// //                         ),
// //                         padding: const EdgeInsets.all(8),
// //                         child: const Icon(
// //                           Icons.access_time,
// //                           color: Colors.white,
// //                           size: 20,
// //                         ),
// //                       ),
// //                       const SizedBox(width: 12),
// //                       Expanded(
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Text(
// //                               'Application Status',
// //                               style: GoogleFonts.poppins(
// //                                 fontWeight: FontWeight.bold,
// //                                 fontSize: isSmallScreen ? 14.0 : 16.0,
// //                                 color: Colors.white,
// //                               ),
// //                             ),
// //                             const SizedBox(height: 4),
// //                             Text(
// //                               'Under Review',
// //                               style: GoogleFonts.poppins(
// //                                 color: Colors.white.withOpacity(0.9),
// //                                 fontSize: bodyTextSize,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 const SizedBox(height: 20),
// //                 if (widget.cardData['qr_code_no'] != null)
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white.withOpacity(0.1),
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: Row(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       mainAxisSize: MainAxisSize.min,
// //                       children: [
// //                         Icon(
// //                           Icons.confirmation_number_outlined,
// //                           size: isSmallScreen ? 14.0 : 16.0,
// //                           color: Colors.white.withOpacity(0.9),
// //                         ),
// //                         const SizedBox(width: 8),
// //                         Text(
// //                           'Reference: ${widget.cardData['qr_code_no']}',
// //                           style: GoogleFonts.poppins(
// //                             fontSize: isSmallScreen ? 12.0 : 14.0,
// //                             color: Colors.white.withOpacity(0.9),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //               ],
// //             ),
// //           ),
// //         );
// //       }
// //     );
// //   }

// //   Widget _buildMembershipCard() {
// //     return LayoutBuilder(
// //       builder: (context, constraints) {
// //         // Get available width and adjust layout accordingly
// //         final double maxWidth = constraints.maxWidth;
// //         final bool isSmallScreen = maxWidth < 360;
        
// //         // Adjust sizes based on screen width
// //         final double photoSize = isSmallScreen ? 90.0 : 100.0;
// //         final double qrSize = isSmallScreen ? 140.0 : 150.0;
// //         final double nameSize = isSmallScreen ? 24.0 : 28.0;
// //         final double infoSize = isSmallScreen ? 15.0 : 16.0;
// //         final double detailsSize = isSmallScreen ? 16.0 : 17.0;
// //         final double labelSpace = isSmallScreen ? 10.0 : 20.0;

// //         return Card(
// //           elevation: 8.0,
// //           margin: const EdgeInsets.symmetric(vertical: 20),
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(16.0),
// //           ),
// //           clipBehavior: Clip.antiAlias,
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               // Main card body with blue background
// //               Container(
// //                 color: primaryBlue,
// //                 child: Stack(
// //                   children: [
// //                     // Watermark logo
// //                     if (_logoImageBytes != null)
// //                       Positioned.fill(
// //                         child: Opacity(
// //                           opacity: 0.3,
// //                           child: Center(
// //                             child: Image.memory(
// //                               _logoImageBytes!,
// //                               fit: BoxFit.contain,
// //                             ),
// //                           ),
// //                         ),
// //                       ),
                    
// //                     // Card content
// //                     Padding(
// //                       padding: const EdgeInsets.all(20),
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           // Top section - Profile photo and name
// //                           Row(
// //                             crossAxisAlignment: CrossAxisAlignment.center,
// //                             children: [
// //                               // Profile photo
// //                               CircleAvatar(
// //                                 radius: photoSize / 2,
// //                                 backgroundColor: Colors.white,
// //                                 child: CircleAvatar(
// //                                   radius: (photoSize / 2) - 2,
// //                                   backgroundImage: widget.cardData['photo_url'] != null
// //                                     ? NetworkImage(widget.cardData['photo_url'])
// //                                     : null,
// //                                   backgroundColor: Colors.grey[200],
// //                                   child: widget.cardData['photo_url'] == null
// //                                     ? Icon(Icons.person, size: photoSize / 2, color: Colors.grey)
// //                                     : null,
// //                                 ),
// //                               ),
                              
// //                               const SizedBox(width: 20),
                              
// //                               // Name and download icon
// //                               Expanded(
// //                                 child: Row(
// //                                   children: [
// //                                     // Name - wrapped in Expanded to handle long names
// //                                     Expanded(
// //                                       child: Text(
// //                                         widget.cardData['name'] ?? 'Member Name',
// //                                         style: GoogleFonts.poppins(
// //                                           fontSize: nameSize,
// //                                           fontWeight: FontWeight.bold,
// //                                           color: textColor,
// //                                         ),
// //                                         maxLines: 2,
// //                                         overflow: TextOverflow.ellipsis,
// //                                       ),
// //                                     ),
                                    
// //                                     // Download icon
// //                                     IconButton(
// //                                       icon: const Icon(Icons.file_download_outlined, color: Colors.white),
// //                                       onPressed: _generateAndDownloadPDF,
// //                                       iconSize: 30,
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
                          
// //                           const SizedBox(height: 20),
                          
// //                           // Email row
// //                           Row(
// //                             children: [
// //                               const Icon(
// //                                 Icons.email_outlined,
// //                                 color: Colors.white,
// //                                 size: 24,
// //                               ),
// //                               const SizedBox(width: 10),
// //                               Expanded(
// //                                 child: Text(
// //                                   widget.cardData['email'] ?? 'email@example.com',
// //                                   style: GoogleFonts.poppins(
// //                                     fontSize: infoSize,
// //                                     color: textColor,
// //                                   ),
// //                                   maxLines: 1,
// //                                   overflow: TextOverflow.ellipsis,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
                          
// //                           const SizedBox(height: 10),
                          
// //                           // Member type and Active status
// //                           Row(
// //                             children: [
// //                               const Icon(
// //                                 Icons.person_outline,
// //                                 color: Colors.white,
// //                                 size: 24,
// //                               ),
// //                               const SizedBox(width: 10),
// //                               Expanded(
// //                                 child: Text(
// //                                   _membershipTypeName ?? 'Extratech Student',
// //                                   style: GoogleFonts.poppins(
// //                                     fontSize: infoSize,
// //                                     color: textColor,
// //                                   ),
// //                                 ),
// //                               ),
// //                               Container(
// //                                 padding: const EdgeInsets.symmetric(
// //                                   horizontal: 15,
// //                                   vertical: 6,
// //                                 ),
// //                                 decoration: BoxDecoration(
// //                                   color: Colors.white,
// //                                   borderRadius: BorderRadius.circular(20),
// //                                 ),
// //                                 child: Row(
// //                                   mainAxisSize: MainAxisSize.min,
// //                                   children: [
// //                                     Icon(Icons.check_circle, color: Colors.green, size: 20),
// //                                     const SizedBox(width: 5),
// //                                     Text(
// //                                       'Active',
// //                                       style: GoogleFonts.poppins(
// //                                         color: primaryBlue,
// //                                         fontSize: 14,
// //                                         fontWeight: FontWeight.w600,
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
                          
// //                           const SizedBox(height: 20),
                          
// //                           // Decorative wave line
// //                           Container(
// //                             height: 6,
// //                             decoration: BoxDecoration(
// //                               gradient: LinearGradient(
// //                                 colors: [
// //                                   Colors.white.withOpacity(0.3),
// //                                   Colors.white.withOpacity(0.6),
// //                                   Colors.white.withOpacity(0.3),
// //                                 ],
// //                               ),
// //                               borderRadius: BorderRadius.circular(3),
// //                             ),
// //                           ),
                          
// //                           const SizedBox(height: 20),
                          
// //                           // Details section - ID, Issued On, Expiry, Address
// //                           // ID
// //                           Row(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               SizedBox(
// //                                 width: 100,
// //                                 child: Text(
// //                                   'ID:',
// //                                   style: GoogleFonts.poppins(
// //                                     fontSize: detailsSize,
// //                                     fontWeight: FontWeight.bold,
// //                                     color: textColor,
// //                                   ),
// //                                 ),
// //                               ),
// //                               SizedBox(width: labelSpace),
// //                               Expanded(
// //                                 child: Text(
// //                                   widget.cardData['qr_code_no']?.toString() ?? '',
// //                                   style: GoogleFonts.poppins(
// //                                     fontSize: detailsSize,
// //                                     color: textColor,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
                          
// //                           const SizedBox(height: 12),
                          
// //                           // Issued On
// //                           Row(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               SizedBox(
// //                                 width: 100,
// //                                 child: Text(
// //                                   'Issued On:',
// //                                   style: GoogleFonts.poppins(
// //                                     fontSize: detailsSize,
// //                                     fontWeight: FontWeight.bold,
// //                                     color: textColor,
// //                                   ),
// //                                 ),
// //                               ),
// //                               SizedBox(width: labelSpace),
// //                               Expanded(
// //                                 child: Text(
// //                                   _formatDate(widget.cardData['start_date']),
// //                                   style: GoogleFonts.poppins(
// //                                     fontSize: detailsSize,
// //                                     color: textColor,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
                          
// //                           const SizedBox(height: 12),
                          
// //                           // Expiry
// //                           Row(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               SizedBox(
// //                                 width: 100,
// //                                 child: Text(
// //                                   'Expiry:',
// //                                   style: GoogleFonts.poppins(
// //                                     fontSize: detailsSize,
// //                                     fontWeight: FontWeight.bold,
// //                                     color: textColor,
// //                                   ),
// //                                 ),
// //                               ),
// //                               SizedBox(width: labelSpace),
// //                               Expanded(
// //                                 child: Text(
// //                                   widget.cardData['is_lifetime'] == 1 
// //                                     ? 'Lifetime'
// //                                     : _formatDate(widget.cardData['expiry_date']),
// //                                   style: GoogleFonts.poppins(
// //                                     fontSize: detailsSize,
// //                                     color: textColor,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
                          
// //                           const SizedBox(height: 12),
                          
// //                           // Address
// //                           Row(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               SizedBox(
// //                                 width: 100,
// //                                 child: Text(
// //                                   'Address:',
// //                                   style: GoogleFonts.poppins(
// //                                     fontSize: detailsSize,
// //                                     fontWeight: FontWeight.bold,
// //                                     color: textColor,
// //                                   ),
// //                                 ),
// //                               ),
// //                               SizedBox(width: labelSpace),
// //                               Expanded(
// //                                 child: Text(
// //                                   widget.cardData['address'] ?? 'Not specified',
// //                                   style: GoogleFonts.poppins(
// //                                     fontSize: detailsSize,
// //                                     color: textColor,
// //                                   ),
// //                                   maxLines: 3,
// //                                   overflow: TextOverflow.ellipsis,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
                          
// //                           const SizedBox(height: 25),
                          
// //                           // QR Code - centered at bottom
// //                           Center(
// //                             child: Container(
// //                               width: qrSize,
// //                               height: qrSize,
// //                               decoration: BoxDecoration(
// //                                 color: Colors.white,
// //                                 borderRadius: BorderRadius.circular(10),
// //                               ),
// //                               padding: const EdgeInsets.all(8),
// //                               child: _hasQrCode && _svgContent != null
// //                                 ? SvgPicture.string(
// //                                     _svgContent!,
// //                                     fit: BoxFit.contain,
// //                                   )
// //                                 : Center(
// //                                     child: Icon(
// //                                       Icons.qr_code_2,
// //                                       size: qrSize * 0.6,
// //                                       color: Colors.grey[400],
// //                                     ),
// //                                   ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
              
// //               // Pink footer with slogan
// //               Container(
// //                 width: double.infinity,
// //                 color: pinkBackground,
// //                 padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
// //                 child: Text(
// //                   '"मेरो लगानी सिप सिक्नको लागि मात्र नभई एस्टेडिएम बनाउनको लागि पनि"',
// //                   style: GoogleFonts.poppins(
// //                     fontSize: 14,
// //                     fontWeight: FontWeight.w600,
// //                     color: sloganTextColor,
// //                   ),
// //                   textAlign: TextAlign.center,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         );
// //       }
// //     );
// //   }

// //   String _formatDate(String? dateString) {
// //     if (dateString == null) return 'Not specified';
    
// //     try {
// //       final date = DateTime.parse(dateString);
// //       final day = date.day.toString().padLeft(2, '0');
// //       final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
// //       final month = months[date.month - 1];
// //       final year = date.year;
      
// //       return '$day $month $year';
// //     } catch (e) {
// //       return dateString;
// //     }
// //   }
// // }













// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_svg/flutter_svg.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // // import 'package:path_provider/path_provider.dart';
// // import 'package:pdf/pdf.dart';
// // import 'package:pdf/widgets.dart' as pw;
// // import 'package:printing/printing.dart';
// // // import 'dart:io';
// // import 'package:http/http.dart' as http;

// // class MembershipCardDisplay extends StatefulWidget {
// //   final Map<String, dynamic> cardData;
// //   final List<Map<String, dynamic>>? membershipTypes;

// //   const MembershipCardDisplay({super.key, required this.cardData, this.membershipTypes});
  
// //   @override
// //   State<MembershipCardDisplay> createState() => _MembershipCardDisplayState();
// // }

// // class _MembershipCardDisplayState extends State<MembershipCardDisplay> {
// //   bool _hasQrCode = false;
// //   String? _svgContent;
// //   String _errorMessage = '';
// //   String? _membershipTypeName;
// //   Uint8List? _logoImageBytes;
  
// //   // Colors from design
// //   final Color primaryBlue = const Color(0xFF487dc7);
// //   final Color textColor = Colors.white;
// //   final Color pinkBackground = const Color(0xD6FFA3E6); // rgba(255, 163, 230, 0.84)
// //   final Color sloganTextColor = const Color(0xFF1e4c84);
  
// //   @override
// //   void initState() {
// //     super.initState();
// //     _processQrCode();
// //     _getMembershipTypeName();
// //     _loadLogoImage();
    
// //     // Allow screenshots (ensure no secure display flags are enabled)
// //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
// //     // Debug - Log the card status and active status
// //     debugPrint('Card Status: ${widget.cardData['status']}');
// //     debugPrint('Is Active: ${widget.cardData['is_active']}');
// //   }
  
// //   Future<void> _loadLogoImage() async {
// //     try {
// //       final ByteData data = await rootBundle.load('assets/extratech-oval-logo.png');
// //       setState(() {
// //         _logoImageBytes = data.buffer.asUint8List();
// //       });
// //     } catch (e) {
// //       debugPrint('Error loading logo: $e');
// //       // Try alternate path if first one fails
// //       try {
// //         final ByteData data = await rootBundle.load('assets/images/extratech-oval-logo.png');
// //         setState(() {
// //           _logoImageBytes = data.buffer.asUint8List();
// //         });
// //       } catch (e) {
// //         debugPrint('Error loading logo from alternate path: $e');
// //       }
// //     }
// //   }
  
// //   void _getMembershipTypeName() {
// //     // Get card type id from card data
// //     final cardTypeId = widget.cardData['card_type_id'];
    
// //     if (cardTypeId != null && widget.membershipTypes != null) {
// //       for (final type in widget.membershipTypes!) {
// //         if (type['id'] == cardTypeId) {
// //           setState(() {
// //             _membershipTypeName = type['type'];
// //           });
// //           return;
// //         }
// //       }
// //     }
    
// //     // If we can't find the type or there are no types, use a default value
// //     setState(() {
// //       _membershipTypeName = widget.cardData['card_type'] ?? 'Member';
// //     });
// //   }
  
// //   void _processQrCode() {
// //     if (widget.cardData.containsKey('qr_code')) {
// //       try {
// //         final qrCodeData = widget.cardData['qr_code'].toString();
        
// //         if (qrCodeData.startsWith('data:image/svg+xml;base64,')) {
// //           // Extract base64 part
// //           final base64String = qrCodeData.split('base64,')[1];
          
// //           // Decode base64 to bytes
// //           final bytes = base64Decode(base64String);
          
// //           // Convert bytes to SVG string
// //           final svgString = utf8.decode(bytes);
          
// //           setState(() {
// //             _svgContent = svgString;
// //             _hasQrCode = true;
// //           });
// //         } else {
// //           setState(() {
// //             _errorMessage = 'Invalid QR format';
// //           });
// //         }
// //       } catch (e) {
// //         setState(() {
// //           _errorMessage = 'Error processing QR';
// //         });
// //       }
// //     }
// //   }

// //   Future<void> _generateAndDownloadPDF() async {
// //     try {
// //       final pdf = pw.Document();
      
// //       // Load ExtraTech logo image for PDF
// //       pw.MemoryImage? logoImage;
// //       if (_logoImageBytes != null) {
// //         logoImage = pw.MemoryImage(_logoImageBytes!);
// //       }
      
// //       // Get profile image for PDF if available
// //       pw.MemoryImage? profileImage;
// //       try {
// //         if (widget.cardData['photo_url'] != null) {
// //           final http.Response response = await http.get(Uri.parse(widget.cardData['photo_url']));
// //           if (response.statusCode == 200) {
// //             profileImage = pw.MemoryImage(response.bodyBytes);
// //           }
// //         }
// //       } catch (e) {
// //         debugPrint('Error loading profile image for PDF: $e');
// //       }

// //       // Get QR code for PDF
// //       pw.MemoryImage? qrImage;
// //       try {
// //         if (widget.cardData['qr_code'] != null) {
// //           final http.Response response = await http.get(Uri.parse(widget.cardData['qr_code']));
// //           if (response.statusCode == 200) {
// //             qrImage = pw.MemoryImage(response.bodyBytes);
// //           }
// //         }
// //       } catch (e) {
// //         debugPrint('Error loading QR code for PDF: $e');
// //       }

// //       // Create the PDF page with membership card
// //       pdf.addPage(
// //         pw.Page(
// //           pageFormat: PdfPageFormat.a4,
// //           build: (pw.Context context) {
// //             return pw.Center(
// //               child: pw.Container(
// //                 width: 500,
// //                 decoration: pw.BoxDecoration(
// //                   borderRadius: pw.BorderRadius.circular(16),
// //                 ),
// //                 child: pw.Column(
// //                   children: [
// //                     // Main card with blue background
// //                     pw.Container(
// //                       color: PdfColor.fromInt(primaryBlue.value),
// //                       padding: const pw.EdgeInsets.all(20),
// //                       child: pw.Stack(
// //                         children: [
// //                           // Watermark logo (if available)
// //                           if (logoImage != null)
// //                             pw.Positioned.fill(
// //                               child: pw.Opacity(
// //                                 opacity: 0.3,
// //                                 child: pw.Center(
// //                                   child: pw.Image(logoImage, width: 300),
// //                                 ),
// //                               ),
// //                             ),
                            
// //                           // Card content
// //                           pw.Row(
// //                             crossAxisAlignment: pw.CrossAxisAlignment.start,
// //                             children: [
// //                               // Left - Profile image
// //                               pw.Container(
// //                                 width: 90,
// //                                 height: 90,
// //                                 decoration: pw.BoxDecoration(
// //                                   shape: pw.BoxShape.circle,
// //                                   color: PdfColors.white,
// //                                 ),
// //                                 child: profileImage != null
// //                                   ? pw.ClipOval(child: pw.Image(profileImage))
// //                                   : pw.Center(
// //                                       child: pw.Text('Photo', style: pw.TextStyle(fontSize: 12)),
// //                                     ),
// //                               ),
                              
// //                               pw.SizedBox(width: 20),
                              
// //                               // Middle - Member details
// //                               pw.Expanded(
// //                                 child: pw.Column(
// //                                   crossAxisAlignment: pw.CrossAxisAlignment.start,
// //                                   children: [
// //                                     // Name
// //                                     pw.Row(
// //                                       mainAxisSize: pw.MainAxisSize.max,
// //                                       children: [
// //                                         pw.Expanded(
// //                                           child: pw.Text(
// //                                             widget.cardData['name'] ?? 'Member Name',
// //                                             style: pw.TextStyle(
// //                                               color: PdfColors.white,
// //                                               fontSize: 20,
// //                                               fontWeight: pw.FontWeight.bold,
// //                                             ),
// //                                           ),
// //                                         ),
// //                                         pw.Text(
// //                                           '↓',
// //                                           style: pw.TextStyle(
// //                                             color: PdfColors.white,
// //                                             fontSize: 14,
// //                                           ),
// //                                         ),
// //                                       ],
// //                                     ),
                                    
// //                                     pw.SizedBox(height: 10),
                                    
// //                                     // Email
// //                                     pw.Row(
// //                                       children: [
// //                                         pw.Text(
// //                                           '✉',
// //                                           style: pw.TextStyle(
// //                                             color: PdfColors.white,
// //                                             fontSize: 14,
// //                                           ),
// //                                         ),
// //                                         pw.SizedBox(width: 8),
// //                                         pw.Expanded(
// //                                           child: pw.Text(
// //                                             widget.cardData['email'] ?? 'email@example.com',
// //                                             style: pw.TextStyle(
// //                                               color: PdfColors.white,
// //                                               fontSize: 14,
// //                                             ),
// //                                           ),
// //                                         ),
// //                                       ],
// //                                     ),
                                    
// //                                     pw.SizedBox(height: 8),
                                    
// //                                     // Member type and active status
// //                                     pw.Row(
// //                                       children: [
// //                                         pw.Text(
// //                                           '👤',
// //                                           style: pw.TextStyle(
// //                                             color: PdfColors.white,
// //                                             fontSize: 14,
// //                                           ),
// //                                         ),
// //                                         pw.SizedBox(width: 8),
// //                                         pw.Text(
// //                                           _membershipTypeName ?? 'Member',
// //                                           style: pw.TextStyle(
// //                                             color: PdfColors.white,
// //                                             fontSize: 14,
// //                                           ),
// //                                         ),
// //                                         pw.SizedBox(width: 10),
// //                                         pw.Container(
// //                                           padding: const pw.EdgeInsets.symmetric(
// //                                             horizontal: 8,
// //                                             vertical: 2,
// //                                           ),
// //                                           decoration: pw.BoxDecoration(
// //                                             color: PdfColors.white,
// //                                             borderRadius: pw.BorderRadius.circular(10),
// //                                           ),
// //                                           child: pw.Row(
// //                                             children: [
// //                                               pw.Text(
// //                                                 '✓',
// //                                                 style: pw.TextStyle(
// //                                                   color: PdfColors.green,
// //                                                   fontSize: 10,
// //                                                   fontWeight: pw.FontWeight.bold,
// //                                                 ),
// //                                               ),
// //                                               pw.SizedBox(width: 2),
// //                                               pw.Text(
// //                                                 'Active',
// //                                                 style: pw.TextStyle(
// //                                                   color: PdfColor.fromInt(primaryBlue.value),
// //                                                   fontSize: 10,
// //                                                   fontWeight: pw.FontWeight.bold,
// //                                                 ),
// //                                               ),
// //                                             ],
// //                                           ),
// //                                         ),
// //                                       ],
// //                                     ),
                                    
// //                                     pw.SizedBox(height: 15),
                                    
// //                                     // Info rows
// //                                     pw.Column(
// //                                       children: [
// //                                         _buildPdfInfoRow('ID:', widget.cardData['qr_code_no']?.toString() ?? ''),
// //                                         _buildPdfInfoRow('Issued On:', _formatDate(widget.cardData['start_date'])),
// //                                         _buildPdfInfoRow('Expiry:', widget.cardData['is_lifetime'] == 1 
// //                                             ? 'Lifetime' 
// //                                             : _formatDate(widget.cardData['expiry_date'])),
// //                                         _buildPdfInfoRow('Address:', widget.cardData['address'] ?? 'Not specified'),
// //                                       ],
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
                              
// //                               pw.SizedBox(width: 20),
                              
// //                               // Right - QR code
// //                               pw.Container(
// //                                 width: 100,
// //                                 height: 100,
// //                                 color: PdfColors.white,
// //                                 child: qrImage != null
// //                                   ? pw.Image(qrImage, fit: pw.BoxFit.cover)
// //                                   : pw.Center(
// //                                       child: pw.Text(
// //                                         'QR Code',
// //                                         style: pw.TextStyle(fontSize: 10),
// //                                       ),
// //                                     ),
// //                               ),
// //                             ],
// //                           ),
// //                         ],
// //                       ),
// //                     ),
                    
// //                     // Pink footer with slogan
// //                     pw.Container(
// //                       width: 500,
// //                       color: PdfColor.fromInt(pinkBackground.value),
// //                       padding: const pw.EdgeInsets.symmetric(vertical: 12),
// //                       child: pw.Center(
// //                         child: pw.Text(
// //                           '"मेरो लगानी सिप सिक्नको लागि मात्र नभई एस्टेडिएम बनाउनको लागि पनि"',
// //                           style: pw.TextStyle(
// //                             color: PdfColor.fromInt(sloganTextColor.value),
// //                             fontSize: 10,
// //                             fontWeight: pw.FontWeight.bold,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             );
// //           },
// //         ),
// //       );

// //       // Save and share the PDF
// //       await Printing.sharePdf(bytes: await pdf.save(), filename: 'membership_card.pdf');
      
// //     } catch (e) {
// //       debugPrint('Error generating PDF: $e');
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text('Error generating PDF: $e'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //     }
// //   }

// //   pw.Widget _buildPdfInfoRow(String label, String value) {
// //     return pw.Padding(
// //       padding: const pw.EdgeInsets.only(bottom: 8),
// //       child: pw.Row(
// //         crossAxisAlignment: pw.CrossAxisAlignment.start,
// //         children: [
// //           pw.Container(
// //             width: 70,
// //             child: pw.Text(
// //               label,
// //               style: pw.TextStyle(
// //                 color: PdfColors.white,
// //                 fontWeight: pw.FontWeight.bold,
// //                 fontSize: 12,
// //               ),
// //             ),
// //           ),
// //           pw.SizedBox(width: 5),
// //           pw.Expanded(
// //             child: pw.Text(
// //               value,
// //               style: pw.TextStyle(
// //                 color: PdfColors.white,
// //                 fontSize: 12,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // Update the condition to recognize multiple approved statuses
// //     final bool isApproved = widget.cardData['status'] == 1 || widget.cardData['status'] == 4;
    
// //     if (!isApproved) {
// //       return _buildPendingApplicationView();
// //     }
    
// //     // If status is approved, show the actual card
// //     return _buildMembershipCard();
// //   }

// //   Widget _buildPendingApplicationView() {
// //     return LayoutBuilder(
// //       builder: (context, constraints) {
// //         // Adaptive sizing based on available width
// //         final double maxWidth = constraints.maxWidth;
// //         final bool isSmallScreen = maxWidth < 350;
        
// //         final double iconSize = isSmallScreen ? 40.0 : 60.0;
// //         final double titleSize = isSmallScreen ? 18.0 : 22.0;
// //         final double bodyTextSize = isSmallScreen ? 12.0 : 14.0;
// //         final double padding = isSmallScreen ? 16.0 : 24.0;
        
// //         return Card(
// //           elevation: 8.0,
// //           margin: const EdgeInsets.symmetric(vertical: 20),
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(16.0),
// //           ),
// //           child: Container(
// //             decoration: BoxDecoration(
// //               gradient: LinearGradient(
// //                 begin: Alignment.topCenter,
// //                 end: Alignment.bottomCenter,
// //                 colors: [primaryBlue, primaryBlue.withOpacity(0.8)],
// //               ),
// //               borderRadius: BorderRadius.circular(16.0),
// //             ),
// //             padding: EdgeInsets.all(padding),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Container(
// //                   decoration: BoxDecoration(
// //                     color: Colors.white.withOpacity(0.2),
// //                     shape: BoxShape.circle,
// //                   ),
// //                   padding: const EdgeInsets.all(20),
// //                   child: Icon(
// //                     Icons.check_circle_outline,
// //                     color: Colors.white,
// //                     size: iconSize,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 20),
// //                 Text(
// //                   'Application Submitted',
// //                   style: GoogleFonts.poppins(
// //                     fontSize: titleSize,
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.white,
// //                   ),
// //                   textAlign: TextAlign.center,
// //                 ),
// //                 const SizedBox(height: 12),
// //                 Text(
// //                   'Your membership card application has been submitted successfully and is awaiting approval.',
// //                   style: GoogleFonts.poppins(
// //                     fontSize: bodyTextSize,
// //                     color: Colors.white.withOpacity(0.9),
// //                   ),
// //                   textAlign: TextAlign.center,
// //                 ),
// //                 const SizedBox(height: 24),
// //                 Container(
// //                   padding: const EdgeInsets.all(16),
// //                   decoration: BoxDecoration(
// //                     color: Colors.white.withOpacity(0.15),
// //                     borderRadius: BorderRadius.circular(12),
// //                     border: Border.all(color: Colors.white.withOpacity(0.3)),
// //                   ),
// //                   child: Row(
// //                     children: [
// //                       Container(
// //                         decoration: BoxDecoration(
// //                           color: Colors.white.withOpacity(0.3),
// //                           shape: BoxShape.circle,
// //                         ),
// //                         padding: const EdgeInsets.all(8),
// //                         child: const Icon(
// //                           Icons.access_time,
// //                           color: Colors.white,
// //                           size: 20,
// //                         ),
// //                       ),
// //                       const SizedBox(width: 12),
// //                       Expanded(
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Text(
// //                               'Application Status',
// //                               style: GoogleFonts.poppins(
// //                                 fontWeight: FontWeight.bold,
// //                                 fontSize: isSmallScreen ? 14.0 : 16.0,
// //                                 color: Colors.white,
// //                               ),
// //                             ),
// //                             const SizedBox(height: 4),
// //                             Text(
// //                               'Under Review',
// //                               style: GoogleFonts.poppins(
// //                                 color: Colors.white.withOpacity(0.9),
// //                                 fontSize: bodyTextSize,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 const SizedBox(height: 20),
// //                 if (widget.cardData['qr_code_no'] != null)
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white.withOpacity(0.1),
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: Row(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       mainAxisSize: MainAxisSize.min,
// //                       children: [
// //                         Icon(
// //                           Icons.confirmation_number_outlined,
// //                           size: isSmallScreen ? 14.0 : 16.0,
// //                           color: Colors.white.withOpacity(0.9),
// //                         ),
// //                         const SizedBox(width: 8),
// //                         Text(
// //                           'Reference: ${widget.cardData['qr_code_no']}',
// //                           style: GoogleFonts.poppins(
// //                             fontSize: isSmallScreen ? 12.0 : 14.0,
// //                             color: Colors.white.withOpacity(0.9),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //               ],
// //             ),
// //           ),
// //         );
// //       }
// //     );
// //   }

// //   Widget _buildMembershipCard() {
// //     return LayoutBuilder(
// //       builder: (context, constraints) {
// //         // Get available width and adjust layout accordingly
// //         final double maxWidth = constraints.maxWidth;
// //         final bool isSmallScreen = maxWidth < 350;
// //         final bool isMediumScreen = maxWidth >= 350 && maxWidth < 450;
        
// //         // Adjust photo size based on screen width
// //         final double photoSize = isSmallScreen ? 80.0 : (isMediumScreen ? 90.0 : 100.0);
        
// //         // Adjust QR code size based on screen width
// //         final double qrSize = isSmallScreen ? 90.0 : (isMediumScreen ? 120.0 : 150.0);
        
// //         // Adjust text sizes based on screen width
// //         final double nameSize = isSmallScreen ? 18.0 : (isMediumScreen ? 20.0 : 24.0);
// //         final double infoSize = isSmallScreen ? 12.0 : 14.0;
// //         final double labelSize = isSmallScreen ? 12.0 : 14.0;
        
// //         // Adjust padding based on screen width
// //         final double mainPadding = isSmallScreen ? 12.0 : (isMediumScreen ? 16.0 : 20.0);
// //         final double innerPadding = isSmallScreen ? 8.0 : (isMediumScreen ? 10.0 : 12.0);
        
// //         // Determine layout orientation
// //         final bool useVerticalLayout = maxWidth < 400;

// //         return Card(
// //           elevation: 8.0,
// //           margin: const EdgeInsets.symmetric(vertical: 20),
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(16.0),
// //           ),
// //           clipBehavior: Clip.antiAlias,
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               // Main card body with blue background
// //               Container(
// //                 color: primaryBlue,
// //                 child: Stack(
// //                   children: [
// //                     // Watermark logo
// //                     if (_logoImageBytes != null)
// //                       Positioned.fill(
// //                         child: Opacity(
// //                           opacity: 0.3,
// //                           child: Center(
// //                             child: Image.memory(
// //                               _logoImageBytes!,
// //                               fit: BoxFit.contain,
// //                             ),
// //                           ),
// //                         ),
// //                       ),
                    
// //                     // Card content
// //                     useVerticalLayout
// //                         ? _buildVerticalCardLayout(
// //                             photoSize: photoSize,
// //                             qrSize: qrSize,
// //                             nameSize: nameSize,
// //                             infoSize: infoSize,
// //                             labelSize: labelSize,
// //                             mainPadding: mainPadding,
// //                             innerPadding: innerPadding,
// //                           )
// //                         : _buildHorizontalCardLayout(
// //                             photoSize: photoSize,
// //                             qrSize: qrSize,
// //                             nameSize: nameSize,
// //                             infoSize: infoSize,
// //                             labelSize: labelSize,
// //                             mainPadding: mainPadding,
// //                             innerPadding: innerPadding,
// //                           ),
// //                   ],
// //                 ),
// //               ),
              
// //               // Pink footer with slogan
// //               Container(
// //                 width: double.infinity,
// //                 color: pinkBackground,
// //                 padding: EdgeInsets.symmetric(
// //                   vertical: isSmallScreen ? 10.0 : 15.0, 
// //                   horizontal: isSmallScreen ? 8.0 : 10.0
// //                 ),
// //                 child: FittedBox(
// //                   fit: BoxFit.scaleDown,
// //                   child: Text(
// //                     '"मेरो लगानी सिप सिक्नको लागि मात्र नभई एस्टेडिएम बनाउनको लागि पनि"',
// //                     style: GoogleFonts.poppins(
// //                       fontSize: isSmallScreen ? 12.0 : 14.0,
// //                       fontWeight: FontWeight.w600,
// //                       color: sloganTextColor,
// //                     ),
// //                     textAlign: TextAlign.center,
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         );
// //       }
// //     );
// //   }

// //   Widget _buildVerticalCardLayout({
// //     required double photoSize,
// //     required double qrSize,
// //     required double nameSize,
// //     required double infoSize,
// //     required double labelSize, 
// //     required double mainPadding,
// //     required double innerPadding,
// //   }) {
// //     return Padding(
// //       padding: EdgeInsets.all(mainPadding),
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         crossAxisAlignment: CrossAxisAlignment.center,
// //         children: [
// //           // Top row - Profile image and name/download
// //           Row(
// //             crossAxisAlignment: CrossAxisAlignment.center,
// //             children: [
// //               // Profile image
// //               CircleAvatar(
// //                 radius: photoSize / 2,
// //                 backgroundColor: Colors.white,
// //                 child: CircleAvatar(
// //                   radius: (photoSize / 2) - 2,
// //                   backgroundImage: widget.cardData['photo_url'] != null
// //                     ? NetworkImage(widget.cardData['photo_url'])
// //                     : null,
// //                   backgroundColor: Colors.grey[200],
// //                   child: widget.cardData['photo_url'] == null
// //                     ? Icon(Icons.person, size: photoSize / 2, color: Colors.grey)
// //                     : null,
// //                 ),
// //               ),
              
// //               SizedBox(width: innerPadding),
              
// //               // Name and download button
// //               Expanded(
// //                 child: Row(
// //                   children: [
// //                     Expanded(
// //                       child: Text(
// //                         widget.cardData['name'] ?? 'Member Name',
// //                         style: GoogleFonts.poppins(
// //                           fontSize: nameSize,
// //                           fontWeight: FontWeight.bold,
// //                           color: textColor,
// //                         ),
// //                         maxLines: 2,
// //                         overflow: TextOverflow.ellipsis,
// //                       ),
// //                     ),
// //                     IconButton(
// //                       icon: const Icon(Icons.download_outlined, color: Colors.white),
// //                       onPressed: _generateAndDownloadPDF,
// //                       tooltip: 'Download Card as PDF',
// //                       constraints: BoxConstraints(
// //                         minWidth: photoSize * 0.6,
// //                         minHeight: photoSize * 0.6,
// //                       ),
// //                       padding: EdgeInsets.zero,
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
          
// //           SizedBox(height: innerPadding),
          
// //           // Email
// //           Row(
// //             children: [
// //               const Icon(Icons.email, color: Colors.white, size: 18),
// //               SizedBox(width: innerPadding/2),
// //               Expanded(
// //                 child: Text(
// //                   widget.cardData['email'] ?? 'email@example.com',
// //                   style: GoogleFonts.poppins(
// //                     fontSize: infoSize,
// //                     color: textColor,
// //                   ),
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //               ),
// //             ],
// //           ),
          
// //           SizedBox(height: innerPadding/2),
          
// //           // Member type and Active status
// //           Row(
// //             children: [
// //               const Icon(Icons.person_outline, color: Colors.white, size: 18),
// //               SizedBox(width: innerPadding/2),
// //               Expanded(
// //                 child: Text(
// //                   _membershipTypeName ?? 'Member',
// //                   style: GoogleFonts.poppins(
// //                     fontSize: infoSize,
// //                     color: textColor,
// //                   ),
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //               ),
// //               Container(
// //                 padding: EdgeInsets.symmetric(
// //                   horizontal: innerPadding,
// //                   vertical: innerPadding/3,
// //                 ),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //                 child: Row(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     Icon(Icons.check_circle, color: Colors.green, size: infoSize),
// //                     SizedBox(width: innerPadding/3),
// //                     Text(
// //                       'Active',
// //                       style: GoogleFonts.poppins(
// //                         color: primaryBlue,
// //                         fontSize: infoSize * 0.85,
// //                         fontWeight: FontWeight.w600,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
          
// //           SizedBox(height: innerPadding*1.5),
          
// //           // Divider with wave effect
// //           Stack(
// //             children: [
// //               Container(
// //                 height: 10,
// //                 decoration: BoxDecoration(
// //                   gradient: LinearGradient(
// //                     colors: [
// //                       Colors.white.withOpacity(0.1),
// //                       Colors.white.withOpacity(0.3),
// //                       Colors.white.withOpacity(0.1),
// //                     ],
// //                     begin: Alignment.topLeft,
// //                     end: Alignment.bottomRight,
// //                   ),
// //                   borderRadius: BorderRadius.circular(5),
// //                 ),
// //               ),
// //               Positioned.fill(
// //                 top: 3,
// //                 child: Center(
// //                   child: Container(
// //                     height: 1,
// //                     decoration: BoxDecoration(
// //                       gradient: LinearGradient(
// //                         colors: [
// //                           Colors.white.withOpacity(0),
// //                           Colors.white.withOpacity(0.6),
// //                           Colors.white.withOpacity(0),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
          
// //           SizedBox(height: innerPadding*1.5),
          
// //           // Middle section - Info rows
// //           Padding(
// //             padding: EdgeInsets.symmetric(horizontal: innerPadding/2),
// //             child: Column(
// //               children: [
// //                 _buildInfoRow('ID:', widget.cardData['qr_code_no']?.toString() ?? '', labelSize),
// //                 SizedBox(height: innerPadding/2),
// //                 _buildInfoRow('Issued On:', _formatDate(widget.cardData['start_date']), labelSize),
// //                 SizedBox(height: innerPadding/2),
// //                 _buildInfoRow(
// //                   'Expiry:',
// //                   widget.cardData['is_lifetime'] == 1 ? 'Lifetime' : _formatDate(widget.cardData['expiry_date']),
// //                   labelSize
// //                 ),
// //                 SizedBox(height: innerPadding/2),
// //                 _buildInfoRow('Address:', widget.cardData['address'] ?? 'Not specified', labelSize),
// //               ],
// //             ),
// //           ),
          
// //           SizedBox(height: innerPadding*1.5),
          
// //           // QR code
// //           Container(
// //             height: qrSize,
// //             width: qrSize,
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(8),
// //             ),
// //             padding: EdgeInsets.all(innerPadding/2),
// //             child: _hasQrCode && _svgContent != null
// //               ? SvgPicture.string(
// //                   _svgContent!,
// //                   fit: BoxFit.contain,
// //                 )
// //               : Center(
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Icon(
// //                         Icons.qr_code_2,
// //                         size: qrSize * 0.4,
// //                         color: Colors.grey[400],
// //                       ),
// //                       if (_errorMessage.isNotEmpty)
// //                         Padding(
// //                           padding: EdgeInsets.all(innerPadding/2),
// //                           child: Text(
// //                             'Error loading QR',
// //                             style: GoogleFonts.poppins(
// //                               fontSize: infoSize * 0.8,
// //                               color: Colors.red[300],
// //                             ),
// //                             textAlign: TextAlign.center,
// //                           ),
// //                         ),
// //                     ],
// //                   ),
// //                 ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildHorizontalCardLayout({
// //     required double photoSize,
// //     required double qrSize,
// //     required double nameSize,
// //     required double infoSize,
// //     required double labelSize,
// //     required double mainPadding,
// //     required double innerPadding,
// //   }) {
// //     return Padding(
// //       padding: EdgeInsets.all(mainPadding),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           // Left column - Profile Image
// //           CircleAvatar(
// //             radius: photoSize / 2,
// //             backgroundColor: Colors.white,
// //             child: CircleAvatar(
// //               radius: (photoSize / 2) - 2,
// //               backgroundImage: widget.cardData['photo_url'] != null
// //                 ? NetworkImage(widget.cardData['photo_url'])
// //                 : null,
// //               backgroundColor: Colors.grey[200],
// //               child: widget.cardData['photo_url'] == null
// //                 ? Icon(Icons.person, size: photoSize / 2, color: Colors.grey)
// //                 : null,
// //             ),
// //           ),
          
// //           SizedBox(width: innerPadding*1.5),
          
// //           // Middle column - Member details
// //           Expanded(
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 // Name with download button
// //                 Row(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Expanded(
// //                       child: Text(
// //                         widget.cardData['name'] ?? 'Member Name',
// //                         style: GoogleFonts.poppins(
// //                           fontSize: nameSize,
// //                           fontWeight: FontWeight.bold,
// //                           color: textColor,
// //                         ),
// //                         maxLines: 2,
// //                         overflow: TextOverflow.ellipsis,
// //                       ),
// //                     ),
// //                     IconButton(
// //                       icon: const Icon(Icons.download_outlined, color: Colors.white),
// //                       onPressed: _generateAndDownloadPDF,
// //                       tooltip: 'Download Card as PDF',
// //                       constraints: const BoxConstraints(
// //                         minWidth: 40,
// //                         minHeight: 40,
// //                       ),
// //                       padding: EdgeInsets.zero,
// //                     ),
// //                   ],
// //                 ),
                
// //                 SizedBox(height: innerPadding/2),
                
// //                 // Email
// //                 Row(
// //                   children: [
// //                     const Icon(Icons.email, color: Colors.white, size: 18),
// //                     SizedBox(width: innerPadding/2),
// //                     Expanded(
// //                       child: Text(
// //                         widget.cardData['email'] ?? 'email@example.com',
// //                         style: GoogleFonts.poppins(
// //                           fontSize: infoSize,
// //                           color: textColor,
// //                         ),
// //                         maxLines: 1,
// //                         overflow: TextOverflow.ellipsis,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
                
// //                 SizedBox(height: innerPadding/2),
                
// //                 // Member type and Active status
// //                 Row(
// //                   children: [
// //                     const Icon(Icons.person_outline, color: Colors.white, size: 18),
// //                     SizedBox(width: innerPadding/2),
// //                     Expanded(
// //                       child: Text(
// //                         _membershipTypeName ?? 'Member',
// //                         style: GoogleFonts.poppins(
// //                           fontSize: infoSize,
// //                           color: textColor,
// //                         ),
// //                         maxLines: 1,
// //                         overflow: TextOverflow.ellipsis,
// //                       ),
// //                     ),
// //                     Container(
// //                       padding: EdgeInsets.symmetric(
// //                         horizontal: innerPadding,
// //                         vertical: innerPadding/3,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: Colors.white,
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                       child: Row(
// //                         mainAxisSize: MainAxisSize.min,
// //                         children: [
// //                           Icon(Icons.check_circle, color: Colors.green, size: infoSize),
// //                           SizedBox(width: innerPadding/3),
// //                           Text(
// //                             'Active',
// //                             style: GoogleFonts.poppins(
// //                               color: primaryBlue,
// //                               fontSize: infoSize * 0.85,
// //                               fontWeight: FontWeight.w600,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
                
// //                 SizedBox(height: innerPadding),
                
// //                 // Blue wave decoration
// //                 Stack(
// //                   children: [
// //                     Container(
// //                       height: 10,
// //                       decoration: BoxDecoration(
// //                         gradient: LinearGradient(
// //                           colors: [
// //                             Colors.white.withOpacity(0.1),
// //                             Colors.white.withOpacity(0.3),
// //                             Colors.white.withOpacity(0.1),
// //                           ],
// //                           begin: Alignment.topLeft,
// //                           end: Alignment.bottomRight,
// //                         ),
// //                         borderRadius: BorderRadius.circular(5),
// //                       ),
// //                     ),
// //                     Positioned.fill(
// //                       top: 3,
// //                       child: Center(
// //                         child: Container(
// //                           height: 1,
// //                           decoration: BoxDecoration(
// //                             gradient: LinearGradient(
// //                               colors: [
// //                                 Colors.white.withOpacity(0),
// //                                 Colors.white.withOpacity(0.6),
// //                                 Colors.white.withOpacity(0),
// //                               ],
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
                
// //                 SizedBox(height: innerPadding),
                
// //                 // ID, Issued On, Expiry, Address
// //                 _buildInfoRow('ID:', widget.cardData['qr_code_no']?.toString() ?? '', labelSize),
// //                 SizedBox(height: innerPadding/2),
// //                 _buildInfoRow('Issued On:', _formatDate(widget.cardData['start_date']), labelSize),
// //                 SizedBox(height: innerPadding/2),
// //                 _buildInfoRow(
// //                   'Expiry:', 
// //                   widget.cardData['is_lifetime'] == 1 ? 'Lifetime' : _formatDate(widget.cardData['expiry_date']),
// //                   labelSize
// //                 ),
// //                 SizedBox(height: innerPadding/2),
// //                 _buildInfoRow('Address:', widget.cardData['address'] ?? 'Not specified', labelSize),
// //               ],
// //             ),
// //           ),
          
// //           SizedBox(width: innerPadding*1.5),
          
// //           // Right column - QR Code
// //           Container(
// //             height: qrSize,
// //             width: qrSize,
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(8),
// //             ),
// //             padding: EdgeInsets.all(innerPadding/2),
// //             child: _hasQrCode && _svgContent != null
// //               ? SvgPicture.string(
// //                   _svgContent!,
// //                   fit: BoxFit.contain,
// //                 )
// //               : Center(
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Icon(
// //                         Icons.qr_code_2,
// //                         size: qrSize * 0.4,
// //                         color: Colors.grey[400],
// //                       ),
// //                       if (_errorMessage.isNotEmpty)
// //                         Padding(
// //                           padding: EdgeInsets.all(innerPadding/2),
// //                           child: Text(
// //                             'Error loading QR',
// //                             style: GoogleFonts.poppins(
// //                               fontSize: infoSize * 0.8,
// //                               color: Colors.red[300],
// //                             ),
// //                             textAlign: TextAlign.center,
// //                           ),
// //                         ),
// //                     ],
// //                   ),
// //                 ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildInfoRow(String label, String value, double fontSize) {
// //     return Row(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         SizedBox(
// //           width: 80,
// //           child: Text(
// //             label,
// //             style: GoogleFonts.poppins(
// //               fontWeight: FontWeight.bold,
// //               fontSize: fontSize,
// //               color: textColor,
// //             ),
// //           ),
// //         ),
// //         Expanded(
// //           child: Text(
// //             value,
// //             style: GoogleFonts.poppins(
// //               fontSize: fontSize,
// //               color: textColor,
// //             ),
// //             maxLines: 2,
// //             overflow: TextOverflow.ellipsis,
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   String _formatDate(String? dateString) {
// //     if (dateString == null) return 'Not specified';
    
// //     try {
// //       final date = DateTime.parse(dateString);
// //       final day = date.day.toString().padLeft(2, '0');
// //       final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
// //       final month = months[date.month - 1];
// //       final year = date.year;
      
// //       return '$day $month $year';
// //     } catch (e) {
// //       return dateString;
// //     }
// //   }
// // }


















// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:flutter_svg/flutter_svg.dart';
// // import 'package:ems/services/country_service.dart';

// // class MembershipCardDisplay extends StatefulWidget {
// //   final Map<String, dynamic> cardData;
// //   final List<Map<String, dynamic>>? membershipTypes;

// //   const MembershipCardDisplay({super.key, required this.cardData, this.membershipTypes});
// //   @override
// //   State<MembershipCardDisplay> createState() => _MembershipCardDisplayState();
// // }

// // class _MembershipCardDisplayState extends State<MembershipCardDisplay> {
// //   String _countryName = 'Loading...';
// //   bool _isLoadingCountry = true;
// //   bool _hasQrCode = false;
// //   String? _svgContent;
// //   String _errorMessage = '';
// //   String? _membershipTypeName;
  
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadCountryName();
// //     _processQrCode();
// //     _getMembershipTypeName();
    
// //     // Debug - Log the card status and active status
// //     debugPrint('Card Status: ${widget.cardData['status']}');
// //     debugPrint('Is Active: ${widget.cardData['is_active']}');
// //   }
  
// //   void _getMembershipTypeName() {
// //     // Get card type id from card data
// //     final cardTypeId = widget.cardData['card_type_id'];
    
// //     if (cardTypeId != null && widget.membershipTypes != null) {
// //       for (final type in widget.membershipTypes!) {
// //         if (type['id'] == cardTypeId) {
// //           setState(() {
// //             _membershipTypeName = type['type'];
// //           });
// //           return;
// //         }
// //       }
// //     }
    
// //     // If we can't find the type or there are no types, use a default value
// //     setState(() {
// //       _membershipTypeName = widget.cardData['is_lifetime'] == 1 ? 'Lifetime' : 'Regular';
// //     });
// //   }
  
// //   void _processQrCode() {
// //     if (widget.cardData.containsKey('qr_code')) {
// //       try {
// //         final qrCodeData = widget.cardData['qr_code'].toString();
        
// //         if (qrCodeData.startsWith('data:image/svg+xml;base64,')) {
// //           // Extract base64 part
// //           final base64String = qrCodeData.split('base64,')[1];
          
// //           // Decode base64 to bytes
// //           final bytes = base64Decode(base64String);
          
// //           // Convert bytes to SVG string
// //           final svgString = utf8.decode(bytes);
          
// //           setState(() {
// //             _svgContent = svgString;
// //             _hasQrCode = true;
// //           });
// //         } else {
// //           setState(() {
// //             _errorMessage = 'Invalid QR format';
// //           });
// //         }
// //       } catch (e) {
// //         setState(() {
// //           _errorMessage = 'Error processing QR';
// //         });
// //       }
// //     }
// //   }

// //   Future<void> _loadCountryName() async {
// //     if (widget.cardData['country_id'] != null) {
// //       try {
// //         final countryName = await CountryService.getCountryName(widget.cardData['country_id']);
// //         if (mounted) {
// //           setState(() {
// //             _countryName = countryName;
// //             _isLoadingCountry = false;
// //           });
// //         }
// //       } catch (e) {
// //         if (mounted) {
// //           setState(() {
// //             _countryName = 'Unknown';
// //             _isLoadingCountry = false;
// //           });
// //         }
// //       }
// //     } else {
// //       setState(() {
// //         _countryName = 'Not specified';
// //         _isLoadingCountry = false;
// //       });
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // Get screen dimensions for responsive sizing
// //     final Size screenSize = MediaQuery.of(context).size;
// //     // final double screenWidth = screenSize.width;
// //     // final double screenHeight = screenSize.height;
    
// //     // Update the condition to recognize multiple approved statuses
// //     // Status 1 and Status 4 are both considered approved
// //     final bool isApproved = widget.cardData['status'] == 1 || widget.cardData['status'] == 4;
    
// //     if (!isApproved) {
// //       return _buildPendingApplicationView(screenSize);
// //     }
    
// //     // If status is approved, show the actual card
// //     return _buildApprovedCardView(screenSize);
// //   }

// //   Widget _buildPendingApplicationView(Size screenSize) {
// //     final double screenWidth = screenSize.width;
// //     final double screenHeight = screenSize.height;
    
// //     // Calculate responsive values
// //     final double iconSize = screenWidth * 0.2;  // 20% of screen width
// //     final double titleSize = screenWidth * 0.055; // 5.5% of screen width
// //     final double bodyTextSize = screenWidth * 0.04; // 4% of screen width
// //     final double smallTextSize = screenWidth * 0.035; // 3.5% of screen width
    
// //     final double verticalSpace = screenHeight * 0.02; // 2% of screen height
// //     final double smallVerticalSpace = screenHeight * 0.01; // 1% of screen height
    
// //     final double horizontalPadding = screenWidth * 0.05; // 5% of screen width
// //     final double cardPadding = screenWidth * 0.06; // 6% of screen width
// //     final double borderRadius = screenWidth * 0.04; // 4% of screen width
    
// //     return Container(
// //       margin: EdgeInsets.symmetric(
// //         vertical: verticalSpace, 
// //         horizontal: horizontalPadding * 0.8
// //       ),
// //       child: Card(
// //         elevation: 8.0,
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(borderRadius),
// //         ),
// //         child: Container(
// //           padding: EdgeInsets.all(cardPadding),
// //           decoration: BoxDecoration(
// //             borderRadius: BorderRadius.circular(borderRadius),
// //             color: Colors.white,
// //           ),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Container(
// //                 decoration: BoxDecoration(
// //                   color: Colors.blue.shade50,
// //                   shape: BoxShape.circle,
// //                 ),
// //                 padding: EdgeInsets.all(screenWidth * 0.06),
// //                 child: Icon(
// //                   Icons.check_circle_outline,
// //                   color: const Color(0xFF205EB5),
// //                   size: iconSize,
// //                 ),
// //               ),
// //               SizedBox(height: verticalSpace),
// //               Text(
// //                 'Application Submitted',
// //                 style: GoogleFonts.poppins(
// //                   fontSize: titleSize,
// //                   fontWeight: FontWeight.bold,
// //                   color: const Color(0xFF111213),
// //                 ),
// //                 textAlign: TextAlign.center,
// //               ),
// //               SizedBox(height: smallVerticalSpace),
// //               Text(
// //                 'Your membership card application has been submitted successfully and is awaiting approval.',
// //                 style: GoogleFonts.poppins(
// //                   fontSize: bodyTextSize,
// //                   color: Colors.grey[700],
// //                 ),
// //                 textAlign: TextAlign.center,
// //               ),
// //               SizedBox(height: verticalSpace),
// //               Container(
// //                 padding: EdgeInsets.all(horizontalPadding),
// //                 decoration: BoxDecoration(
// //                   color: Colors.orange.shade50,
// //                   borderRadius: BorderRadius.circular(borderRadius * 0.75),
// //                   border: Border.all(color: Colors.orange.shade200),
// //                 ),
// //                 child: Row(
// //                   children: [
// //                     Container(
// //                       decoration: BoxDecoration(
// //                         color: Colors.orange.shade100,
// //                         shape: BoxShape.circle,
// //                       ),
// //                       padding: EdgeInsets.all(screenWidth * 0.02),
// //                       child: Icon(
// //                         Icons.access_time,
// //                         color: Colors.orange[800],
// //                         size: screenWidth * 0.05,
// //                       ),
// //                     ),
// //                     SizedBox(width: horizontalPadding * 0.8),
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             'Application Status',
// //                             style: GoogleFonts.poppins(
// //                               fontWeight: FontWeight.bold,
// //                               fontSize: bodyTextSize,
// //                               color: Colors.orange[800],
// //                             ),
// //                           ),
// //                           SizedBox(height: smallVerticalSpace * 0.4),
// //                           Text(
// //                             'Under Review',
// //                             style: GoogleFonts.poppins(
// //                               color: Colors.grey[700],
// //                               fontSize: smallTextSize,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               SizedBox(height: verticalSpace),
// //               Text(
// //                 'You will be notified when your application is approved. Your membership card will be available here after approval.',
// //                 style: GoogleFonts.poppins(
// //                   fontSize: smallTextSize,
// //                   color: Colors.grey[600],
// //                 ),
// //                 textAlign: TextAlign.center,
// //               ),
// //               SizedBox(height: smallVerticalSpace),
// //               // Application reference number if available
// //               if (widget.cardData['qr_code_no'] != null)
// //                 Container(
// //                   padding: EdgeInsets.symmetric(
// //                     vertical: verticalSpace * 0.6, 
// //                     horizontal: horizontalPadding * 0.8
// //                   ),
// //                   decoration: BoxDecoration(
// //                     color: Colors.grey.shade100,
// //                     borderRadius: BorderRadius.circular(borderRadius * 0.5),
// //                   ),
// //                   child: Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Icon(
// //                         Icons.confirmation_number_outlined,
// //                         size: screenWidth * 0.04,
// //                         color: Colors.grey[700],
// //                       ),
// //                       SizedBox(width: screenWidth * 0.02),
// //                       Text(
// //                         'Reference: ${widget.cardData['qr_code_no']}',
// //                         style: GoogleFonts.poppins(
// //                           fontSize: smallTextSize,
// //                           color: Colors.grey[700],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildApprovedCardView(Size screenSize) {
// //     final double screenWidth = screenSize.width;
// //     final double screenHeight = screenSize.height;
    
// //     // Calculate responsive values
// //     // final double headingSize = screenWidth * 0.045; // 4.5% of screen width
// //     // final double normalTextSize = screenWidth * 0.035; // 3.5% of screen width
// //     // final double smallTextSize = screenWidth * 0.03; // 3% of screen width
    
// //     final double verticalSpace = screenHeight * 0.02; // 2% of screen height
// //     // final double smallVerticalSpace = screenHeight * 0.008; // 0.8% of screen height
    
// //     final double cardPadding = screenWidth * 0.05; // 5% of screen width
// //     final double borderRadius = screenWidth * 0.04; // 4% of screen width
    
// //     // Calculate card sizes
// //     final double cardWidth = screenWidth - (cardPadding * 1.6);
// //     // final double avatarSize = screenWidth * 0.175; // 17.5% of screen width
// //     // final double qrCodeSize = screenWidth * 0.25; // 25% of screen width
    
// //     return Container(
// //       width: cardWidth,
// //       margin: EdgeInsets.symmetric(vertical: verticalSpace),
// //       child: Card(
// //         elevation: 8.0,
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(borderRadius),
// //         ),
// //         child: Container(
// //           padding: EdgeInsets.all(cardPadding * 0.8),
// //           decoration: BoxDecoration(
// //             borderRadius: BorderRadius.circular(borderRadius),
// //             color: Colors.white,
// //           ),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               _buildProfileSection(cardWidth, screenSize),
              
// //               SizedBox(height: verticalSpace * 0.8),
// //               Divider(height: 1, thickness: 1),
// //               SizedBox(height: verticalSpace * 0.8),
              
// //               _buildDetailsSection(cardWidth, screenSize),
              
// //               SizedBox(height: verticalSpace * 0.8),
// //               Divider(height: 1, thickness: 1),
// //               SizedBox(height: verticalSpace * 0.8),
              
// //               _buildValiditySection(screenSize),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildProfileSection(double availableWidth, Size screenSize) {
// //     final double screenWidth = screenSize.width;
    
// //     // Calculate responsive values
// //     final double nameSize = screenWidth * 0.045; // 4.5% of screen width
// //     final double infoSize = screenWidth * 0.03; // 3% of screen width
// //     final double iconSize = screenWidth * 0.035; // 3.5% of screen width
// //     final double avatarSize = screenWidth * 0.175; // 17.5% of screen width
// //     final double badgeTextSize = screenWidth * 0.025; // 2.5% of screen width
    
// //     // Check if the card is active based on is_active value
// //     final bool isActive = widget.cardData['is_active'] == 1;
    
// //     return Row(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         // Added proper error handling for profile image
// //         widget.cardData['photo_url'] != null
// //             ? CircleAvatar(
// //                 radius: avatarSize / 2,
// //                 backgroundColor: Colors.grey[200],
// //                 backgroundImage: NetworkImage(widget.cardData['photo_url']),
// //                 onBackgroundImageError: (exception, stackTrace) {
// //                   debugPrint('Error loading profile image: $exception');
// //                 },
// //                 child: const SizedBox.shrink(),
// //               )
// //             : CircleAvatar(
// //                 radius: avatarSize / 2,
// //                 backgroundColor: Colors.grey[200],
// //                 child: Icon(
// //                   Icons.person,
// //                   size: avatarSize / 2,
// //                   color: Color(0xFF205EB5),
// //                 ),
// //               ),
// //         SizedBox(width: screenWidth * 0.04),
// //         Expanded(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text(
// //                 widget.cardData['name'] ?? 'User Name',
// //                 style: GoogleFonts.poppins(
// //                   fontSize: nameSize,
// //                   fontWeight: FontWeight.bold,
// //                   color: Color(0xFF205EB5),
// //                 ),
// //                 maxLines: 1,
// //                 overflow: TextOverflow.ellipsis,
// //               ),
// //               SizedBox(height: screenSize.height * 0.005),
// //               Row(
// //                 children: [
// //                   Icon(
// //                     Icons.email,
// //                     size: iconSize,
// //                     color: Color(0xFF205EB5),
// //                   ),
// //                   SizedBox(width: screenWidth * 0.01),
// //                   Expanded(
// //                     child: Text(
// //                       widget.cardData['email'] ?? 'email@example.com',
// //                       style: GoogleFonts.poppins(
// //                         fontSize: infoSize,
// //                         color: Colors.grey[700],
// //                       ),
// //                       overflow: TextOverflow.ellipsis,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               SizedBox(height: screenSize.height * 0.005),
// //               Row(
// //                 children: [
// //                   Icon(
// //                     Icons.card_membership,
// //                     size: iconSize,
// //                     color: Color(0xFF205EB5),
// //                   ),
// //                   SizedBox(width: screenWidth * 0.01),
// //                   Flexible(
// //                     child: Text(
// //                       _membershipTypeName ?? 'Membership Type',
// //                       style: GoogleFonts.poppins(
// //                         fontSize: infoSize,
// //                         color: Colors.grey[700],
// //                       ),
// //                       overflow: TextOverflow.ellipsis,
// //                     ),
// //                   ),
// //                   SizedBox(width: screenWidth * 0.02),
// //                   // UPDATED: Changed the status badge to be dynamic based on is_active
// //                   Container(
// //                     padding: EdgeInsets.symmetric(
// //                       horizontal: screenWidth * 0.015,
// //                       vertical: screenWidth * 0.005,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       color: isActive ? Colors.green : Colors.red,
// //                       borderRadius: BorderRadius.circular(screenWidth * 0.025),
// //                     ),
// //                     child: Text(
// //                       isActive ? 'Active' : 'Inactive',
// //                       style: GoogleFonts.poppins(
// //                         color: Colors.white,
// //                         fontSize: badgeTextSize,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               SizedBox(height: screenSize.height * 0.005),
// //               Row(
// //                 children: [
// //                   Icon(
// //                     Icons.location_on,
// //                     size: iconSize,
// //                     color: Color(0xFF205EB5),
// //                   ),
// //                   SizedBox(width: screenWidth * 0.01),
// //                   Expanded(
// //                     child: Text(
// //                       widget.cardData['address'] ?? 'No address',
// //                       style: GoogleFonts.poppins(
// //                         fontSize: infoSize,
// //                         color: Colors.grey[700],
// //                       ),
// //                       overflow: TextOverflow.ellipsis,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildDetailsSection(double availableWidth, Size screenSize) {
// //     // final double screenWidth = screenSize.width;
// //     final double screenHeight = screenSize.height;
    
// //     // Calculate responsive values
// //     // final double labelSize = screenWidth * 0.035; // 3.5% of screen width
// //     // final double valueSize = screenWidth * 0.035; // 3.5% of screen width
// //     final double verticalSpace = screenHeight * 0.012; // 1.2% of screen height
    
// //     return Row(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Expanded(
// //           flex: 65,
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               _buildInfoRow('ID:', widget.cardData['qr_code_no'].toString(), screenSize),  
// //               SizedBox(height: verticalSpace),
// //               _buildInfoRow('D.O.B:', _formatDate(widget.cardData['dob']).toString(), screenSize),
// //               SizedBox(height: verticalSpace),
// //               _buildNationalityRow(
// //                 _isLoadingCountry ? 'Loading...' : _countryName,
// //                 screenSize
// //               ),
// //             ],
// //           ),
// //         ),
        
// //         Expanded(
// //           flex: 35,
// //           child: _buildQrCode(screenSize),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildValiditySection(Size screenSize) {
// //     final double screenWidth = screenSize.width;
// //     final double screenHeight = screenSize.height;
    
// //     // Calculate responsive values
// //     final double titleSize = screenWidth * 0.04; // 4% of screen width
// //     final double labelSize = screenWidth * 0.032; // 3.2% of screen width
// //     final double valueSize = screenWidth * 0.035; // 3.5% of screen width
// //     final double verticalSpace = screenHeight * 0.01; // 1% of screen height
// //     final double horizontalPadding = screenWidth * 0.03; // 3% of screen width
// //     final double borderRadius = screenWidth * 0.02; // 2% of screen width
    
// //     final startDate = _formatDate(widget.cardData['start_date']);
// //     final expiryDate = _formatDate(widget.cardData['expiry_date']);
// //     final isLifetime = widget.cardData['is_lifetime'] == 1;
    
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'Membership Validity:',
// //           style: GoogleFonts.poppins(
// //             fontSize: titleSize,
// //             fontWeight: FontWeight.bold,
// //             color: Color(0xFF205EB5),
// //           ),
// //         ),
// //         SizedBox(height: verticalSpace),
        
// //         Row(
// //           children: [
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     'Start Date:',
// //                     style: GoogleFonts.poppins(
// //                       fontSize: labelSize,
// //                       fontWeight: FontWeight.bold,
// //                       color: Color(0xFF111213),
// //                     ),
// //                   ),
// //                   SizedBox(height: verticalSpace * 0.5),
// //                   Container(
// //                     padding: EdgeInsets.symmetric(
// //                       horizontal: horizontalPadding, 
// //                       vertical: verticalSpace
// //                     ),
// //                     decoration: BoxDecoration(
// //                       color: Colors.grey[100],
// //                       borderRadius: BorderRadius.circular(borderRadius),
// //                     ),
// //                     child: Text(
// //                       startDate ?? 'Not specified',
// //                       style: GoogleFonts.poppins(
// //                         fontSize: valueSize,
// //                         color: Color(0xFF111213),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             SizedBox(width: horizontalPadding),
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     'Expiry Date:',
// //                     style: GoogleFonts.poppins(
// //                       fontSize: labelSize,
// //                       fontWeight: FontWeight.bold,
// //                       color: Color(0xFF111213),
// //                     ),
// //                   ),
// //                   SizedBox(height: verticalSpace * 0.5),
// //                   Container(
// //                     padding: EdgeInsets.symmetric(
// //                       horizontal: horizontalPadding, 
// //                       vertical: verticalSpace
// //                     ),
// //                     decoration: BoxDecoration(
// //                       color: Colors.grey[100],
// //                       borderRadius: BorderRadius.circular(borderRadius),
// //                       border: isLifetime ? Border.all(color: Colors.green, width: 1.5) : null,
// //                     ),
// //                     child: Row(
// //                       children: [
// //                         Expanded(
// //                           child: Text(
// //                             isLifetime ? 'Lifetime' : (expiryDate ?? 'Not specified'),
// //                             style: GoogleFonts.poppins(
// //                               fontSize: valueSize,
// //                               color: isLifetime ? Colors.green : Color(0xFF111213),
// //                               fontWeight: isLifetime ? FontWeight.bold : FontWeight.normal,
// //                             ),
// //                           ),
// //                         ),
// //                         if (isLifetime)
// //                           Icon(
// //                             Icons.check_circle_outline,
// //                             color: Colors.green,
// //                             size: screenWidth * 0.04,
// //                           ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildInfoRow(String label, String value, Size screenSize) {
// //     final double screenWidth = screenSize.width;
    
// //     // Calculate responsive values
// //     final double labelSize = screenWidth * 0.035; // 3.5% of screen width
// //     final double valueSize = screenWidth * 0.035; // 3.5% of screen width
// //     final double labelWidth = screenWidth * 0.16; // 16% of screen width
    
// //     return Row(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         SizedBox(
// //           width: labelWidth,
// //           child: Text(
// //             label,
// //             style: GoogleFonts.poppins(
// //               fontWeight: FontWeight.bold,
// //               fontSize: labelSize,
// //               color: Color(0xFF205EB5),
// //             ),
// //           ),
// //         ),
// //         Expanded(
// //           child: Text(
// //             value,
// //             style: GoogleFonts.poppins(
// //               fontSize: valueSize,
// //               color: Color(0xFF111213),
// //             ),
// //             overflow: TextOverflow.ellipsis,
// //             maxLines: 2,
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildNationalityRow(String value, Size screenSize) {
// //     final double screenWidth = screenSize.width;
    
// //     // Calculate responsive values
// //     final double labelSize = screenWidth * 0.035; // 3.5% of screen width
// //     final double valueSize = screenWidth * 0.035; // 3.5% of screen width
    
// //     return Row(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'Nationality:',
// //           style: GoogleFonts.poppins(
// //             fontWeight: FontWeight.bold,
// //             fontSize: labelSize,
// //             color: Color(0xFF205EB5),
// //           ),
// //         ),
// //         SizedBox(width: screenWidth * 0.01),
// //         Expanded(
// //           child: Text(
// //             value,
// //             style: GoogleFonts.poppins(
// //               fontSize: valueSize,
// //               color: Colors.black87,
// //             ),
// //             overflow: TextOverflow.ellipsis,
// //             maxLines: 2,
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildQrCode(Size screenSize) {
// //     final double screenWidth = screenSize.width;
// //     final double qrSize = screenWidth * 0.28; // 28% of screen width
    
// //     return Container(
// //       height: qrSize,
// //       width: qrSize,
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(screenWidth * 0.02),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.1),
// //             spreadRadius: 1,
// //             blurRadius: 3,
// //             offset: const Offset(0, 1),
// //           ),
// //         ],
// //       ),
// //       child: ClipRRect(
// //         borderRadius: BorderRadius.circular(screenWidth * 0.02),
// //         child: _hasQrCode && _svgContent != null
// //             ? SvgPicture.string(
// //                 _svgContent!,
// //                 fit: BoxFit.contain,
// //               )
// //             : Center(
// //                 child: Column(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     Icon(
// //                       Icons.qr_code_2,
// //                       size: screenWidth * 0.1,
// //                       color: Colors.grey[400],
// //                     ),
// //                     if (_errorMessage.isNotEmpty)
// //                       Padding(
// //                         padding: EdgeInsets.all(screenWidth * 0.01),
// //                         child: Text(
// //                           'Error loading QR',
// //                           style: GoogleFonts.poppins(
// //                             fontSize: screenWidth * 0.025,
// //                             color: Colors.red[300],
// //                           ),
// //                           textAlign: TextAlign.center,
// //                         ),
// //                       ),
// //                   ],
// //                 ),
// //               ),
// //       ),
// //     );
// //   }

// //   String? _formatDate(String? dateString) {
// //     if (dateString == null) return null;
// //     try {
// //       final date = DateTime.parse(dateString);
// //       final day = date.day.toString().padLeft(2, '0');
// //       final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
// //       final month = months[date.month - 1];
// //       final year = date.year.toString();
// //       return '$day $month. $year';
// //     } catch (e) {
// //       return dateString;
// //     }
// //   }
// // }













// // // import 'dart:convert';
// // // import 'package:flutter/material.dart';
// // // import 'package:google_fonts/google_fonts.dart';
// // // import 'package:flutter_svg/flutter_svg.dart';
// // // import 'package:ems/services/country_service.dart';

// // // class MembershipCardDisplay extends StatefulWidget {
// // //   final Map<String, dynamic> cardData;
// // //   final List<Map<String, dynamic>>? membershipTypes;

// // //   const MembershipCardDisplay({super.key, required this.cardData, this.membershipTypes});
// // //   @override
// // //   State<MembershipCardDisplay> createState() => _MembershipCardDisplayState();
// // // }

// // // class _MembershipCardDisplayState extends State<MembershipCardDisplay> {
// // //   String _countryName = 'Loading...';
// // //   bool _isLoadingCountry = true;
// // //   bool _hasQrCode = false;
// // //   String? _svgContent;
// // //   String _errorMessage = '';
// // //   String? _membershipTypeName;
  
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadCountryName();
// // //     _processQrCode();
// // //     _getMembershipTypeName();
    
// // //     // Debug - Log the card status and active status
// // //     debugPrint('Card Status: ${widget.cardData['status']}');
// // //     debugPrint('Is Active: ${widget.cardData['is_active']}');
// // //   }
  
// // //   void _getMembershipTypeName() {
// // //     // Get card type id from card data
// // //     final cardTypeId = widget.cardData['card_type_id'];
    
// // //     if (cardTypeId != null && widget.membershipTypes != null) {
// // //       for (final type in widget.membershipTypes!) {
// // //         if (type['id'] == cardTypeId) {
// // //           setState(() {
// // //             _membershipTypeName = type['type'];
// // //           });
// // //           return;
// // //         }
// // //       }
// // //     }
    
// // //     // If we can't find the type or there are no types, use a default value
// // //     setState(() {
// // //       _membershipTypeName = widget.cardData['is_lifetime'] == 1 ? 'Lifetime' : 'Regular';
// // //     });
// // //   }
  
// // //   void _processQrCode() {
// // //     if (widget.cardData.containsKey('qr_code')) {
// // //       try {
// // //         final qrCodeData = widget.cardData['qr_code'].toString();
        
// // //         if (qrCodeData.startsWith('data:image/svg+xml;base64,')) {
// // //           // Extract base64 part
// // //           final base64String = qrCodeData.split('base64,')[1];
          
// // //           // Decode base64 to bytes
// // //           final bytes = base64Decode(base64String);
          
// // //           // Convert bytes to SVG string
// // //           final svgString = utf8.decode(bytes);
          
// // //           setState(() {
// // //             _svgContent = svgString;
// // //             _hasQrCode = true;
// // //           });
// // //         } else {
// // //           setState(() {
// // //             _errorMessage = 'Invalid QR format';
// // //           });
// // //         }
// // //       } catch (e) {
// // //         setState(() {
// // //           _errorMessage = 'Error processing QR';
// // //         });
// // //       }
// // //     }
// // //   }

// // //   Future<void> _loadCountryName() async {
// // //     if (widget.cardData['country_id'] != null) {
// // //       try {
// // //         final countryName = await CountryService.getCountryName(widget.cardData['country_id']);
// // //         if (mounted) {
// // //           setState(() {
// // //             _countryName = countryName;
// // //             _isLoadingCountry = false;
// // //           });
// // //         }
// // //       } catch (e) {
// // //         if (mounted) {
// // //           setState(() {
// // //             _countryName = 'Unknown';
// // //             _isLoadingCountry = false;
// // //           });
// // //         }
// // //       }
// // //     } else {
// // //       setState(() {
// // //         _countryName = 'Not specified';
// // //         _isLoadingCountry = false;
// // //       });
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     // Update the condition to recognize multiple approved statuses
// // //     // Status 1 and Status 4 are both considered approved
// // //     final bool isApproved = widget.cardData['status'] == 1 || widget.cardData['status'] == 4;
    
// // //     if (!isApproved) {
// // //       return _buildPendingApplicationView();
// // //     }
    
// // //     // If status is approved, show the actual card
// // //     return _buildApprovedCardView();
// // //   }

// // //   Widget _buildPendingApplicationView() {
// // //     return Container(
// // //       margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
// // //       child: Card(
// // //         elevation: 8.0,
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(16.0),
// // //         ),
// // //         child: Container(
// // //           padding: const EdgeInsets.all(24.0),
// // //           decoration: BoxDecoration(
// // //             borderRadius: BorderRadius.circular(16.0),
// // //             color: Colors.white,
// // //           ),
// // //           child: Column(
// // //             mainAxisAlignment: MainAxisAlignment.center,
// // //             children: [
// // //               Container(
// // //                 decoration: BoxDecoration(
// // //                   color: Colors.blue.shade50,
// // //                   shape: BoxShape.circle,
// // //                 ),
// // //                 padding: const EdgeInsets.all(24.0),
// // //                 child: Icon(
// // //                   Icons.check_circle_outline,
// // //                   color: const Color(0xFF205EB5),
// // //                   size: 80,
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 24),
// // //               Text(
// // //                 'Application Submitted',
// // //                 style: GoogleFonts.poppins(
// // //                   fontSize: 24,
// // //                   fontWeight: FontWeight.bold,
// // //                   color: const Color(0xFF111213),
// // //                 ),
// // //                 textAlign: TextAlign.center,
// // //               ),
// // //               const SizedBox(height: 16),
// // //               Text(
// // //                 'Your membership card application has been submitted successfully and is awaiting approval.',
// // //                 style: GoogleFonts.poppins(
// // //                   fontSize: 16,
// // //                   color: Colors.grey[700],
// // //                 ),
// // //                 textAlign: TextAlign.center,
// // //               ),
// // //               const SizedBox(height: 24),
// // //               Container(
// // //                 padding: const EdgeInsets.all(16),
// // //                 decoration: BoxDecoration(
// // //                   color: Colors.orange.shade50,
// // //                   borderRadius: BorderRadius.circular(12),
// // //                   border: Border.all(color: Colors.orange.shade200),
// // //                 ),
// // //                 child: Row(
// // //                   children: [
// // //                     Container(
// // //                       decoration: BoxDecoration(
// // //                         color: Colors.orange.shade100,
// // //                         shape: BoxShape.circle,
// // //                       ),
// // //                       padding: const EdgeInsets.all(8),
// // //                       child: Icon(
// // //                         Icons.access_time,
// // //                         color: Colors.orange[800],
// // //                       ),
// // //                     ),
// // //                     const SizedBox(width: 16),
// // //                     Expanded(
// // //                       child: Column(
// // //                         crossAxisAlignment: CrossAxisAlignment.start,
// // //                         children: [
// // //                           Text(
// // //                             'Application Status',
// // //                             style: GoogleFonts.poppins(
// // //                               fontWeight: FontWeight.bold,
// // //                               color: Colors.orange[800],
// // //                             ),
// // //                           ),
// // //                           const SizedBox(height: 4),
// // //                           Text(
// // //                             'Under Review',
// // //                             style: GoogleFonts.poppins(
// // //                               color: Colors.grey[700],
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 24),
// // //               Text(
// // //                 'You will be notified when your application is approved. Your membership card will be available here after approval.',
// // //                 style: GoogleFonts.poppins(
// // //                   fontSize: 14,
// // //                   color: Colors.grey[600],
// // //                 ),
// // //                 textAlign: TextAlign.center,
// // //               ),
// // //               const SizedBox(height: 16),
// // //               // Application reference number if available
// // //               if (widget.cardData['qr_code_no'] != null)
// // //                 Container(
// // //                   padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
// // //                   decoration: BoxDecoration(
// // //                     color: Colors.grey.shade100,
// // //                     borderRadius: BorderRadius.circular(8),
// // //                   ),
// // //                   child: Row(
// // //                     mainAxisAlignment: MainAxisAlignment.center,
// // //                     children: [
// // //                       Icon(
// // //                         Icons.confirmation_number_outlined,
// // //                         size: 16,
// // //                         color: Colors.grey[700],
// // //                       ),
// // //                       const SizedBox(width: 8),
// // //                       Text(
// // //                         'Reference: ${widget.cardData['qr_code_no']}',
// // //                         style: GoogleFonts.poppins(
// // //                           fontSize: 14,
// // //                           color: Colors.grey[700],
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildApprovedCardView() {
// // //     final screenWidth = MediaQuery.of(context).size.width;
    
// // //     return LayoutBuilder(
// // //       builder: (context, constraints) {
// // //         final cardWidth = screenWidth - 32;
        
// // //         return Container(
// // //           width: cardWidth,
// // //           margin: const EdgeInsets.symmetric(vertical: 16.0),
// // //           child: Card(
// // //             elevation: 8.0,
// // //             shape: RoundedRectangleBorder(
// // //               borderRadius: BorderRadius.circular(16.0),
// // //             ),
// // //             child: Container(
// // //               padding: const EdgeInsets.all(20.0),
// // //               decoration: BoxDecoration(
// // //                 borderRadius: BorderRadius.circular(16.0),
// // //                 color: Colors.white,
// // //               ),
// // //               child: Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   _buildProfileSection(cardWidth),
                  
// // //                   const SizedBox(height: 16),
// // //                   const Divider(height: 1),
// // //                   const SizedBox(height: 16),
                  
// // //                   _buildDetailsSection(cardWidth),
                  
// // //                   const SizedBox(height: 16),
// // //                   const Divider(height: 1),
// // //                   const SizedBox(height: 16),
                  
// // //                   _buildValiditySection(),
// // //                 ],
// // //               ),
// // //             ),
// // //           ),
// // //         );
// // //       },
// // //     );
// // //   }

// // //   Widget _buildProfileSection(double availableWidth) {
// // //     // Check if the card is active based on is_active value
// // //     final bool isActive = widget.cardData['is_active'] == 1;
    
// // //     return Row(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         // Added proper error handling for profile image
// // //         widget.cardData['photo_url'] != null
// // //             ? CircleAvatar(
// // //                 radius: 35,
// // //                 backgroundColor: Colors.grey[200],
// // //                 backgroundImage: NetworkImage(widget.cardData['photo_url']),
// // //                 onBackgroundImageError: (exception, stackTrace) {
// // //                   debugPrint('Error loading profile image: $exception');
// // //                 },
// // //                 child: const SizedBox.shrink(),
// // //               )
// // //             : CircleAvatar(
// // //                 radius: 35,
// // //                 backgroundColor: Colors.grey[200],
// // //                 child: Icon(
// // //                   Icons.person,
// // //                   size: 35,
// // //                   color: Color(0xFF205EB5),
// // //                 ),
// // //               ),
// // //         const SizedBox(width: 16),
// // //         Expanded(
// // //           child: Column(
// // //             crossAxisAlignment: CrossAxisAlignment.start,
// // //             children: [
// // //               Text(
// // //                 widget.cardData['name'] ?? 'User Name',
// // //                 style: GoogleFonts.poppins(
// // //                   fontSize: 20,
// // //                   fontWeight: FontWeight.bold,
// // //                   color: Color(0xFF205EB5),
// // //                 ),
// // //                 maxLines: 1,
// // //                 overflow: TextOverflow.ellipsis,
// // //               ),
// // //               const SizedBox(height: 4),
// // //               Row(
// // //                 children: [
// // //                   Icon(
// // //                     Icons.email,
// // //                     size: 14,
// // //                     color: Color(0xFF205EB5),
// // //                   ),
// // //                   const SizedBox(width: 4),
// // //                   Expanded(
// // //                     child: Text(
// // //                       widget.cardData['email'] ?? 'email@example.com',
// // //                       style: GoogleFonts.poppins(
// // //                         fontSize: 12,
// // //                         color: Colors.grey[700],
// // //                       ),
// // //                       overflow: TextOverflow.ellipsis,
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //               const SizedBox(height: 4),
// // //               Row(
// // //                 children: [
// // //                   Icon(
// // //                     Icons.card_membership,
// // //                     size: 14,
// // //                     color: Color(0xFF205EB5),
// // //                   ),
// // //                   const SizedBox(width: 4),
// // //                   Flexible(
// // //                     child: Text(
// // //                       _membershipTypeName ?? 'Membership Type',
// // //                       style: GoogleFonts.poppins(
// // //                         fontSize: 12,
// // //                         color: Colors.grey[700],
// // //                       ),
// // //                       overflow: TextOverflow.ellipsis,
// // //                     ),
// // //                   ),
// // //                   const SizedBox(width: 8),
// // //                   // UPDATED: Changed the status badge to be dynamic based on is_active
// // //                   Container(
// // //                     padding: const EdgeInsets.symmetric(
// // //                       horizontal: 6,
// // //                       vertical: 2,
// // //                     ),
// // //                     decoration: BoxDecoration(
// // //                       color: isActive ? Colors.green : Colors.red,
// // //                       borderRadius: BorderRadius.circular(10),
// // //                     ),
// // //                     child: Text(
// // //                       isActive ? 'Active' : 'Inactive',
// // //                       style: GoogleFonts.poppins(
// // //                         color: Colors.white,
// // //                         fontSize: 10,
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //               const SizedBox(height: 4),
// // //               Row(
// // //                 children: [
// // //                   Icon(
// // //                     Icons.location_on,
// // //                     size: 14,
// // //                     color: Color(0xFF205EB5),
// // //                   ),
// // //                   const SizedBox(width: 4),
// // //                   Expanded(
// // //                     child: Text(
// // //                       widget.cardData['address'] ?? 'No address',
// // //                       style: GoogleFonts.poppins(
// // //                         fontSize: 12,
// // //                         color: Colors.grey[700],
// // //                       ),
// // //                       overflow: TextOverflow.ellipsis,
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildDetailsSection(double availableWidth) {
// // //     return Row(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         Expanded(
// // //           flex: 65,
// // //           child: Column(
// // //             crossAxisAlignment: CrossAxisAlignment.start,
// // //             children: [
// // //               _buildInfoRow('ID:', widget.cardData['qr_code_no'].toString()),  
// // //               const SizedBox(height: 12),
// // //               _buildInfoRow('D.O.B:', _formatDate(widget.cardData['dob']).toString()),
// // //               const SizedBox(height: 12),
// // //               _buildNationalityRow(
// // //                 _isLoadingCountry ? 'Loading...' : _countryName
// // //               ),
// // //             ],
// // //           ),
// // //         ),
        
// // //         Expanded(
// // //           flex: 35,
// // //           child: _buildQrCode(),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildValiditySection() {
// // //     final startDate = _formatDate(widget.cardData['start_date']);
// // //     final expiryDate = _formatDate(widget.cardData['expiry_date']);
// // //     final isLifetime = widget.cardData['is_lifetime'] == 1;
    
// // //     return Column(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         Text(
// // //           'Membership Validity:',
// // //           style: GoogleFonts.poppins(
// // //             fontSize: 16,
// // //             fontWeight: FontWeight.bold,
// // //             color: Color(0xFF205EB5),
// // //           ),
// // //         ),
// // //         const SizedBox(height: 8),
        
// // //         Row(
// // //           children: [
// // //             Expanded(
// // //               child: Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   Text(
// // //                     'Start Date:',
// // //                     style: GoogleFonts.poppins(
// // //                       fontSize: 13,
// // //                       fontWeight: FontWeight.bold,
// // //                       color: Color(0xFF111213),
// // //                     ),
// // //                   ),
// // //                   const SizedBox(height: 2),
// // //                   Container(
// // //                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// // //                     decoration: BoxDecoration(
// // //                       color: Colors.grey[100],
// // //                       borderRadius: BorderRadius.circular(8),
// // //                     ),
// // //                     child: Text(
// // //                       startDate ?? 'Not specified',
// // //                       style: GoogleFonts.poppins(
// // //                         fontSize: 14,
// // //                         color: Color(0xFF111213),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //             const SizedBox(width: 12),
// // //             Expanded(
// // //               child: Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   Text(
// // //                     'Expiry Date:',
// // //                     style: GoogleFonts.poppins(
// // //                       fontSize: 13,
// // //                       fontWeight: FontWeight.bold,
// // //                       color: Color(0xFF111213),
// // //                     ),
// // //                   ),
// // //                   const SizedBox(height: 2),
// // //                   Container(
// // //                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// // //                     decoration: BoxDecoration(
// // //                       color: Colors.grey[100],
// // //                       borderRadius: BorderRadius.circular(8),
// // //                       border: isLifetime ? Border.all(color: Colors.green, width: 1.5) : null,
// // //                     ),
// // //                     child: Row(
// // //                       children: [
// // //                         Expanded(
// // //                           child: Text(
// // //                             isLifetime ? 'Lifetime' : (expiryDate ?? 'Not specified'),
// // //                             style: GoogleFonts.poppins(
// // //                               fontSize: 14,
// // //                               color: isLifetime ? Colors.green : Color(0xFF111213),
// // //                               fontWeight: isLifetime ? FontWeight.bold : FontWeight.normal,
// // //                             ),
// // //                           ),
// // //                         ),
// // //                         if (isLifetime)
// // //                           Icon(
// // //                             Icons.check_circle_outline,
// // //                             color: Colors.green,
// // //                             size: 16,
// // //                           ),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildInfoRow(String label, String value) {
// // //     return Row(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         SizedBox(
// // //           width: 65,
// // //           child: Text(
// // //             label,
// // //             style: GoogleFonts.poppins(
// // //               fontWeight: FontWeight.bold,
// // //               fontSize: 14,
// // //               color: Color(0xFF205EB5),
// // //             ),
// // //           ),
// // //         ),
// // //         Expanded(
// // //           child: Text(
// // //             value,
// // //             style: GoogleFonts.poppins(
// // //               fontSize: 14,
// // //               color: Color(0xFF111213),
// // //             ),
// // //             overflow: TextOverflow.ellipsis,
// // //             maxLines: 2,
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildNationalityRow(String value) {
// // //     return Row(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         Text(
// // //           'Nationality:',
// // //           style: GoogleFonts.poppins(
// // //             fontWeight: FontWeight.bold,
// // //             fontSize: 14,
// // //             color: Color(0xFF205EB5),
// // //           ),
// // //         ),
// // //         const SizedBox(width: 4),
// // //         Expanded(
// // //           child: Text(
// // //             value,
// // //             style: GoogleFonts.poppins(
// // //               fontSize: 14,
// // //               color: Colors.black87,
// // //             ),
// // //             overflow: TextOverflow.ellipsis,
// // //             maxLines: 2,
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildQrCode() {
// // //     return Container(
// // //       height: 110,
// // //       width: 110,
// // //       decoration: BoxDecoration(
// // //         color: Colors.white,
// // //         borderRadius: BorderRadius.circular(8),
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: Colors.black.withOpacity(0.1),
// // //             spreadRadius: 1,
// // //             blurRadius: 3,
// // //             offset: const Offset(0, 1),
// // //           ),
// // //         ],
// // //       ),
// // //       child: ClipRRect(
// // //         borderRadius: BorderRadius.circular(8),
// // //         child: _hasQrCode && _svgContent != null
// // //             ? SvgPicture.string(
// // //                 _svgContent!,
// // //                 fit: BoxFit.contain,
// // //               )
// // //             : Center(
// // //                 child: Column(
// // //                   mainAxisAlignment: MainAxisAlignment.center,
// // //                   children: [
// // //                     Icon(
// // //                       Icons.qr_code_2,
// // //                       size: 40,
// // //                       color: Colors.grey[400],
// // //                     ),
// // //                     if (_errorMessage.isNotEmpty)
// // //                       Padding(
// // //                         padding: const EdgeInsets.all(4.0),
// // //                         child: Text(
// // //                           'Error loading QR',
// // //                           style: GoogleFonts.poppins(
// // //                             fontSize: 9,
// // //                             color: Colors.red[300],
// // //                           ),
// // //                           textAlign: TextAlign.center,
// // //                         ),
// // //                       ),
// // //                   ],
// // //                 ),
// // //               ),
// // //       ),
// // //     );
// // //   }

// // //   String? _formatDate(String? dateString) {
// // //     if (dateString == null) return null;
// // //     try {
// // //       final date = DateTime.parse(dateString);
// // //       final day = date.day.toString().padLeft(2, '0');
// // //       final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
// // //       final month = months[date.month - 1];
// // //       final year = date.year.toString();
// // //       return '$day $month. $year';
// // //     } catch (e) {
// // //       return dateString;
// // //     }
// // //   }
// // // }












// // // import 'dart:convert';
// // // import 'package:flutter/material.dart';
// // // import 'package:google_fonts/google_fonts.dart';
// // // import 'package:flutter_svg/flutter_svg.dart';
// // // import 'package:ems/services/country_service.dart';

// // // class MembershipCardDisplay extends StatefulWidget {
// // //   final Map<String, dynamic> cardData;
// // //   final List<Map<String, dynamic>>? membershipTypes;

// // //   const MembershipCardDisplay({super.key, required this.cardData, this.membershipTypes});
// // //   @override
// // //   State<MembershipCardDisplay> createState() => _MembershipCardDisplayState();
// // // }

// // // class _MembershipCardDisplayState extends State<MembershipCardDisplay> {
// // //   String _countryName = 'Loading...';
// // //   bool _isLoadingCountry = true;
// // //   bool _hasQrCode = false;
// // //   String? _svgContent;
// // //   String _errorMessage = '';
// // //   String? _membershipTypeName;
  
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadCountryName();
// // //     _processQrCode();
// // //     _getMembershipTypeName();
// // //   }
  
// // //   void _getMembershipTypeName() {
// // //     // Get card type id from card data
// // //     final cardTypeId = widget.cardData['card_type_id'];
    
// // //     if (cardTypeId != null && widget.membershipTypes != null) {
// // //       for (final type in widget.membershipTypes!) {
// // //         if (type['id'] == cardTypeId) {
// // //           setState(() {
// // //             _membershipTypeName = type['type'];
// // //           });
// // //           return;
// // //         }
// // //       }
// // //     }
    
// // //     // If we can't find the type or there are no types, use a default value
// // //     setState(() {
// // //       _membershipTypeName = widget.cardData['is_lifetime'] == 1 ? 'Lifetime' : 'Regular';
// // //     });
// // //   }
  
// // //   void _processQrCode() {
// // //     if (widget.cardData.containsKey('qr_code')) {
// // //       try {
// // //         final qrCodeData = widget.cardData['qr_code'].toString();
        
// // //         if (qrCodeData.startsWith('data:image/svg+xml;base64,')) {
// // //           // Extract base64 part
// // //           final base64String = qrCodeData.split('base64,')[1];
          
// // //           // Decode base64 to bytes
// // //           final bytes = base64Decode(base64String);
          
// // //           // Convert bytes to SVG string
// // //           final svgString = utf8.decode(bytes);
          
// // //           setState(() {
// // //             _svgContent = svgString;
// // //             _hasQrCode = true;
// // //           });
// // //         } else {
// // //           setState(() {
// // //             _errorMessage = 'Invalid QR format';
// // //           });
// // //         }
// // //       } catch (e) {
// // //         setState(() {
// // //           _errorMessage = 'Error processing QR';
// // //         });
// // //       }
// // //     }
// // //   }

// // //   Future<void> _loadCountryName() async {
// // //     if (widget.cardData['country_id'] != null) {
// // //       try {
// // //         final countryName = await CountryService.getCountryName(widget.cardData['country_id']);
// // //         if (mounted) {
// // //           setState(() {
// // //             _countryName = countryName;
// // //             _isLoadingCountry = false;
// // //           });
// // //         }
// // //       } catch (e) {
// // //         if (mounted) {
// // //           setState(() {
// // //             _countryName = 'Unknown';
// // //             _isLoadingCountry = false;
// // //           });
// // //         }
// // //       }
// // //     } else {
// // //       setState(() {
// // //         _countryName = 'Not specified';
// // //         _isLoadingCountry = false;
// // //       });
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     // Check if application is still pending (status != 1)
// // //     final bool isPending = widget.cardData['status'] != 1;
    
// // //     if (isPending) {
// // //       return _buildPendingApplicationView();
// // //     }
    
// // //     // If status is 1 (approved), show the actual card
// // //     return _buildApprovedCardView();
// // //   }

// // //   Widget _buildPendingApplicationView() {
// // //     return Container(
// // //       margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
// // //       child: Card(
// // //         elevation: 8.0,
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(16.0),
// // //         ),
// // //         child: Container(
// // //           padding: const EdgeInsets.all(24.0),
// // //           decoration: BoxDecoration(
// // //             borderRadius: BorderRadius.circular(16.0),
// // //             color: Colors.white,
// // //           ),
// // //           child: Column(
// // //             mainAxisAlignment: MainAxisAlignment.center,
// // //             children: [
// // //               Container(
// // //                 decoration: BoxDecoration(
// // //                   color: Colors.blue.shade50,
// // //                   shape: BoxShape.circle,
// // //                 ),
// // //                 padding: const EdgeInsets.all(24.0),
// // //                 child: Icon(
// // //                   Icons.check_circle_outline,
// // //                   color: const Color(0xFF205EB5),
// // //                   size: 80,
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 24),
// // //               Text(
// // //                 'Application Submitted',
// // //                 style: GoogleFonts.poppins(
// // //                   fontSize: 24,
// // //                   fontWeight: FontWeight.bold,
// // //                   color: const Color(0xFF111213),
// // //                 ),
// // //                 textAlign: TextAlign.center,
// // //               ),
// // //               const SizedBox(height: 16),
// // //               Text(
// // //                 'Your membership card application has been submitted successfully and is awaiting approval.',
// // //                 style: GoogleFonts.poppins(
// // //                   fontSize: 16,
// // //                   color: Colors.grey[700],
// // //                 ),
// // //                 textAlign: TextAlign.center,
// // //               ),
// // //               const SizedBox(height: 24),
// // //               Container(
// // //                 padding: const EdgeInsets.all(16),
// // //                 decoration: BoxDecoration(
// // //                   color: Colors.orange.shade50,
// // //                   borderRadius: BorderRadius.circular(12),
// // //                   border: Border.all(color: Colors.orange.shade200),
// // //                 ),
// // //                 child: Row(
// // //                   children: [
// // //                     Container(
// // //                       decoration: BoxDecoration(
// // //                         color: Colors.orange.shade100,
// // //                         shape: BoxShape.circle,
// // //                       ),
// // //                       padding: const EdgeInsets.all(8),
// // //                       child: Icon(
// // //                         Icons.access_time,
// // //                         color: Colors.orange[800],
// // //                       ),
// // //                     ),
// // //                     const SizedBox(width: 16),
// // //                     Expanded(
// // //                       child: Column(
// // //                         crossAxisAlignment: CrossAxisAlignment.start,
// // //                         children: [
// // //                           Text(
// // //                             'Application Status',
// // //                             style: GoogleFonts.poppins(
// // //                               fontWeight: FontWeight.bold,
// // //                               color: Colors.orange[800],
// // //                             ),
// // //                           ),
// // //                           const SizedBox(height: 4),
// // //                           Text(
// // //                             'Under Review',
// // //                             style: GoogleFonts.poppins(
// // //                               color: Colors.grey[700],
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 24),
// // //               Text(
// // //                 'You will be notified when your application is approved. Your membership card will be available here after approval.',
// // //                 style: GoogleFonts.poppins(
// // //                   fontSize: 14,
// // //                   color: Colors.grey[600],
// // //                 ),
// // //                 textAlign: TextAlign.center,
// // //               ),
// // //               const SizedBox(height: 16),
// // //               // Application reference number if available
// // //               if (widget.cardData['qr_code_no'] != null)
// // //                 Container(
// // //                   padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
// // //                   decoration: BoxDecoration(
// // //                     color: Colors.grey.shade100,
// // //                     borderRadius: BorderRadius.circular(8),
// // //                   ),
// // //                   child: Row(
// // //                     mainAxisAlignment: MainAxisAlignment.center,
// // //                     children: [
// // //                       Icon(
// // //                         Icons.confirmation_number_outlined,
// // //                         size: 16,
// // //                         color: Colors.grey[700],
// // //                       ),
// // //                       const SizedBox(width: 8),
// // //                       Text(
// // //                         'Reference: ${widget.cardData['qr_code_no']}',
// // //                         style: GoogleFonts.poppins(
// // //                           fontSize: 14,
// // //                           color: Colors.grey[700],
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildApprovedCardView() {
// // //     final screenWidth = MediaQuery.of(context).size.width;
    
// // //     return LayoutBuilder(
// // //       builder: (context, constraints) {
// // //         final cardWidth = screenWidth - 32;
        
// // //         return Container(
// // //           width: cardWidth,
// // //           margin: const EdgeInsets.symmetric(vertical: 16.0),
// // //           child: Card(
// // //             elevation: 8.0,
// // //             shape: RoundedRectangleBorder(
// // //               borderRadius: BorderRadius.circular(16.0),
// // //             ),
// // //             child: Container(
// // //               padding: const EdgeInsets.all(20.0),
// // //               decoration: BoxDecoration(
// // //                 borderRadius: BorderRadius.circular(16.0),
// // //                 color: Colors.white,
// // //               ),
// // //               child: Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   _buildProfileSection(cardWidth),
                  
// // //                   const SizedBox(height: 16),
// // //                   const Divider(height: 1),
// // //                   const SizedBox(height: 16),
                  
// // //                   _buildDetailsSection(cardWidth),
                  
// // //                   const SizedBox(height: 16),
// // //                   const Divider(height: 1),
// // //                   const SizedBox(height: 16),
                  
// // //                   _buildValiditySection(),
// // //                 ],
// // //               ),
// // //             ),
// // //           ),
// // //         );
// // //       },
// // //     );
// // //   }

// // //   Widget _buildProfileSection(double availableWidth) {
// // //     return Row(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         widget.cardData['photo_url'] != null
// // //             ? CircleAvatar(
// // //                 radius: 35,
// // //                 backgroundImage: NetworkImage(widget.cardData['photo_url']),
// // //               )
// // //             : CircleAvatar(
// // //                 radius: 35,
// // //                 backgroundColor: Colors.grey[200],
// // //                 child: Icon(
// // //                   Icons.person,
// // //                   size: 35,
// // //                   color: Color(0xFF205EB5),
// // //                 ),
// // //               ),
// // //         const SizedBox(width: 16),
// // //         Expanded(
// // //           child: Column(
// // //             crossAxisAlignment: CrossAxisAlignment.start,
// // //             children: [
// // //               Text(
// // //                 widget.cardData['name'] ?? 'User Name',
// // //                 style: GoogleFonts.poppins(
// // //                   fontSize: 20,
// // //                   fontWeight: FontWeight.bold,
// // //                   color: Color(0xFF205EB5),
// // //                 ),
// // //                 maxLines: 1,
// // //                 overflow: TextOverflow.ellipsis,
// // //               ),
// // //               const SizedBox(height: 4),
// // //               Row(
// // //                 children: [
// // //                   Icon(
// // //                     Icons.email,
// // //                     size: 14,
// // //                     color: Color(0xFF205EB5),
// // //                   ),
// // //                   const SizedBox(width: 4),
// // //                   Expanded(
// // //                     child: Text(
// // //                       widget.cardData['email'] ?? 'email@example.com',
// // //                       style: GoogleFonts.poppins(
// // //                         fontSize: 12,
// // //                         color: Colors.grey[700],
// // //                       ),
// // //                       overflow: TextOverflow.ellipsis,
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //               const SizedBox(height: 4),
// // //               Row(
// // //                 children: [
// // //                   Icon(
// // //                     Icons.card_membership,
// // //                     size: 14,
// // //                     color: Color(0xFF205EB5),
// // //                   ),
// // //                   const SizedBox(width: 4),
// // //                   Flexible(
// // //                     child: Text(
// // //                       _membershipTypeName ?? 'Membership Type',
// // //                       style: GoogleFonts.poppins(
// // //                         fontSize: 12,
// // //                         color: Colors.grey[700],
// // //                       ),
// // //                       overflow: TextOverflow.ellipsis,
// // //                     ),
// // //                   ),
// // //                   const SizedBox(width: 8),
// // //                   Container(
// // //                     padding: const EdgeInsets.symmetric(
// // //                       horizontal: 6,
// // //                       vertical: 2,
// // //                     ),
// // //                     decoration: BoxDecoration(
// // //                       color: Colors.green,
// // //                       borderRadius: BorderRadius.circular(10),
// // //                     ),
// // //                     child: Text(
// // //                       'Active',
// // //                       style: GoogleFonts.poppins(
// // //                         color: Colors.white,
// // //                         fontSize: 10,
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //               const SizedBox(height: 4),
// // //               Row(
// // //                 children: [
// // //                   Icon(
// // //                     Icons.location_on,
// // //                     size: 14,
// // //                     color: Color(0xFF205EB5),
// // //                   ),
// // //                   const SizedBox(width: 4),
// // //                   Expanded(
// // //                     child: Text(
// // //                       widget.cardData['address'] ?? 'No address',
// // //                       style: GoogleFonts.poppins(
// // //                         fontSize: 12,
// // //                         color: Colors.grey[700],
// // //                       ),
// // //                       overflow: TextOverflow.ellipsis,
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildDetailsSection(double availableWidth) {
// // //     return Row(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         Expanded(
// // //           flex: 65,
// // //           child: Column(
// // //             crossAxisAlignment: CrossAxisAlignment.start,
// // //             children: [
// // //               _buildInfoRow('ID:', widget.cardData['qr_code_no'].toString()),  
// // //               const SizedBox(height: 12),
// // //               _buildInfoRow('D.O.B:', _formatDate(widget.cardData['dob']).toString()),
// // //               const SizedBox(height: 12),
// // //               _buildNationalityRow(
// // //                 _isLoadingCountry ? 'Loading...' : _countryName
// // //               ),
// // //             ],
// // //           ),
// // //         ),
        
// // //         Expanded(
// // //           flex: 35,
// // //           child: _buildQrCode(),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildValiditySection() {
// // //     final startDate = _formatDate(widget.cardData['start_date']);
// // //     final expiryDate = _formatDate(widget.cardData['expiry_date']);
// // //     final isLifetime = widget.cardData['is_lifetime'] == 1;
    
// // //     return Column(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         Text(
// // //           'Membership Validity:',
// // //           style: GoogleFonts.poppins(
// // //             fontSize: 16,
// // //             fontWeight: FontWeight.bold,
// // //             color: Color(0xFF205EB5),
// // //           ),
// // //         ),
// // //         const SizedBox(height: 8),
        
// // //         Row(
// // //           children: [
// // //             Expanded(
// // //               child: Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   Text(
// // //                     'Start Date:',
// // //                     style: GoogleFonts.poppins(
// // //                       fontSize: 13,
// // //                       fontWeight: FontWeight.bold,
// // //                       color: Color(0xFF111213),
// // //                     ),
// // //                   ),
// // //                   const SizedBox(height: 2),
// // //                   Container(
// // //                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// // //                     decoration: BoxDecoration(
// // //                       color: Colors.grey[100],
// // //                       borderRadius: BorderRadius.circular(8),
// // //                     ),
// // //                     child: Text(
// // //                       startDate ?? 'Not specified',
// // //                       style: GoogleFonts.poppins(
// // //                         fontSize: 14,
// // //                         color: Color(0xFF111213),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //             const SizedBox(width: 12),
// // //             Expanded(
// // //               child: Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   Text(
// // //                     'Expiry Date:',
// // //                     style: GoogleFonts.poppins(
// // //                       fontSize: 13,
// // //                       fontWeight: FontWeight.bold,
// // //                       color: Color(0xFF111213),
// // //                     ),
// // //                   ),
// // //                   const SizedBox(height: 2),
// // //                   Container(
// // //                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// // //                     decoration: BoxDecoration(
// // //                       color: Colors.grey[100],
// // //                       borderRadius: BorderRadius.circular(8),
// // //                       border: isLifetime ? Border.all(color: Colors.green, width: 1.5) : null,
// // //                     ),
// // //                     child: Row(
// // //                       children: [
// // //                         Expanded(
// // //                           child: Text(
// // //                             isLifetime ? 'Lifetime' : (expiryDate ?? 'Not specified'),
// // //                             style: GoogleFonts.poppins(
// // //                               fontSize: 14,
// // //                               color: isLifetime ? Colors.green : Color(0xFF111213),
// // //                               fontWeight: isLifetime ? FontWeight.bold : FontWeight.normal,
// // //                             ),
// // //                           ),
// // //                         ),
// // //                         if (isLifetime)
// // //                           Icon(
// // //                             Icons.check_circle_outline,
// // //                             color: Colors.green,
// // //                             size: 16,
// // //                           ),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildInfoRow(String label, String value) {
// // //     return Row(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         SizedBox(
// // //           width: 65,
// // //           child: Text(
// // //             label,
// // //             style: GoogleFonts.poppins(
// // //               fontWeight: FontWeight.bold,
// // //               fontSize: 14,
// // //               color: Color(0xFF205EB5),
// // //             ),
// // //           ),
// // //         ),
// // //         Expanded(
// // //           child: Text(
// // //             value,
// // //             style: GoogleFonts.poppins(
// // //               fontSize: 14,
// // //               color: Color(0xFF111213),
// // //             ),
// // //             overflow: TextOverflow.ellipsis,
// // //             maxLines: 2,
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildNationalityRow(String value) {
// // //     return Row(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         Text(
// // //           'Nationality:',
// // //           style: GoogleFonts.poppins(
// // //             fontWeight: FontWeight.bold,
// // //             fontSize: 14,
// // //             color: Color(0xFF205EB5),
// // //           ),
// // //         ),
// // //         const SizedBox(width: 4),
// // //         Expanded(
// // //           child: Text(
// // //             value,
// // //             style: GoogleFonts.poppins(
// // //               fontSize: 14,
// // //               color: Colors.black87,
// // //             ),
// // //             overflow: TextOverflow.ellipsis,
// // //             maxLines: 2,
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildQrCode() {
// // //     return Container(
// // //       height: 110,
// // //       width: 110,
// // //       decoration: BoxDecoration(
// // //         color: Colors.white,
// // //         borderRadius: BorderRadius.circular(8),
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: Colors.black.withOpacity(0.1),
// // //             spreadRadius: 1,
// // //             blurRadius: 3,
// // //             offset: const Offset(0, 1),
// // //           ),
// // //         ],
// // //       ),
// // //       child: ClipRRect(
// // //         borderRadius: BorderRadius.circular(8),
// // //         child: _hasQrCode && _svgContent != null
// // //             ? SvgPicture.string(
// // //                 _svgContent!,
// // //                 fit: BoxFit.contain,
// // //               )
// // //             : Center(
// // //                 child: Column(
// // //                   mainAxisAlignment: MainAxisAlignment.center,
// // //                   children: [
// // //                     Icon(
// // //                       Icons.qr_code_2,
// // //                       size: 40,
// // //                       color: Colors.grey[400],
// // //                     ),
// // //                     if (_errorMessage.isNotEmpty)
// // //                       Padding(
// // //                         padding: const EdgeInsets.all(4.0),
// // //                         child: Text(
// // //                           'Error loading QR',
// // //                           style: GoogleFonts.poppins(
// // //                             fontSize: 9,
// // //                             color: Colors.red[300],
// // //                           ),
// // //                           textAlign: TextAlign.center,
// // //                         ),
// // //                       ),
// // //                   ],
// // //                 ),
// // //               ),
// // //       ),
// // //     );
// // //   }

// // //   String? _formatDate(String? dateString) {
// // //     if (dateString == null) return null;
// // //     try {
// // //       final date = DateTime.parse(dateString);
// // //       final day = date.day.toString().padLeft(2, '0');
// // //       final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
// // //       final month = months[date.month - 1];
// // //       final year = date.year.toString();
// // //       return '$day $month. $year';
// // //     } catch (e) {
// // //       return dateString;
// // //     }
// // //   }
// // // }


















// // // import 'dart:convert';
// // // import 'package:flutter/material.dart';
// // // import 'package:google_fonts/google_fonts.dart';
// // // import 'package:flutter_svg/flutter_svg.dart';
// // // import 'package:ems/services/country_service.dart';

// // // class MembershipCardDisplay extends StatefulWidget {
// // //   final Map<String, dynamic> cardData;
// // //   final List<Map<String, dynamic>>? membershipTypes;

// // //   const MembershipCardDisplay({super.key, required this.cardData, this.membershipTypes});
// // //   @override
// // //   State<MembershipCardDisplay> createState() => _MembershipCardDisplayState();
// // // }

// // // class _MembershipCardDisplayState extends State<MembershipCardDisplay> {
// // //   String _countryName = 'Loading...';
// // //   bool _isLoadingCountry = true;
// // //   bool _hasQrCode = false;
// // //   String? _svgContent;
// // //   String _errorMessage = '';
// // //   String? _membershipTypeName;
  
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadCountryName();
// // //     _processQrCode();
// // //     _getMembershipTypeName();
// // //   }
  
// // //   void _getMembershipTypeName() {
// // //     // Get card type id from card data
// // //     final cardTypeId = widget.cardData['card_type_id'];
    
// // //     if (cardTypeId != null && widget.membershipTypes != null) {
// // //       for (final type in widget.membershipTypes!) {
// // //         if (type['id'] == cardTypeId) {
// // //           setState(() {
// // //             _membershipTypeName = type['type'];
// // //           });
// // //           return;
// // //         }
// // //       }
// // //     }
    
// // //     // If we can't find the type or there are no types, use a default value
// // //     setState(() {
// // //       _membershipTypeName = widget.cardData['is_lifetime'] == 1 ? 'Lifetime' : 'Regular';
// // //     });
// // //   }
  
// // //   void _processQrCode() {
// // //     if (widget.cardData.containsKey('qr_code')) {
// // //       try {
// // //         final qrCodeData = widget.cardData['qr_code'].toString();
        
// // //         if (qrCodeData.startsWith('data:image/svg+xml;base64,')) {
// // //           // Extract base64 part
// // //           final base64String = qrCodeData.split('base64,')[1];
          
// // //           // Decode base64 to bytes
// // //           final bytes = base64Decode(base64String);
          
// // //           // Convert bytes to SVG string
// // //           final svgString = utf8.decode(bytes);
          
// // //           setState(() {
// // //             _svgContent = svgString;
// // //             _hasQrCode = true;
// // //           });
// // //         } else {
// // //           setState(() {
// // //             _errorMessage = 'Invalid QR format';
// // //           });
// // //         }
// // //       } catch (e) {
// // //         setState(() {
// // //           _errorMessage = 'Error processing QR';
// // //         });
// // //       }
// // //     }
// // //   }

// // //   Future<void> _loadCountryName() async {
// // //     if (widget.cardData['country_id'] != null) {
// // //       try {
// // //         final countryName = await CountryService.getCountryName(widget.cardData['country_id']);
// // //         if (mounted) {
// // //           setState(() {
// // //             _countryName = countryName;
// // //             _isLoadingCountry = false;
// // //           });
// // //         }
// // //       } catch (e) {
// // //         if (mounted) {
// // //           setState(() {
// // //             _countryName = 'Unknown';
// // //             _isLoadingCountry = false;
// // //           });
// // //         }
// // //       }
// // //     } else {
// // //       setState(() {
// // //         _countryName = 'Not specified';
// // //         _isLoadingCountry = false;
// // //       });
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final screenWidth = MediaQuery.of(context).size.width;
    
// // //     return LayoutBuilder(
// // //       builder: (context, constraints) {
// // //         final cardWidth = screenWidth - 32;
        
// // //         return Container(
// // //           width: cardWidth,
// // //           margin: const EdgeInsets.symmetric(vertical: 16.0),
// // //           child: Card(
// // //             elevation: 8.0,
// // //             shape: RoundedRectangleBorder(
// // //               borderRadius: BorderRadius.circular(16.0),
// // //             ),
// // //             child: Container(
// // //               padding: const EdgeInsets.all(20.0),
// // //               decoration: BoxDecoration(
// // //                 borderRadius: BorderRadius.circular(16.0),
// // //                 color: Colors.white,
// // //               ),
// // //               child: Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   _buildProfileSection(cardWidth),
                  
// // //                   const SizedBox(height: 16),
// // //                   const Divider(height: 1),
// // //                   const SizedBox(height: 16),
                  
// // //                   _buildDetailsSection(cardWidth),
                  
// // //                   const SizedBox(height: 16),
// // //                   const Divider(height: 1),
// // //                   const SizedBox(height: 16),
                  
// // //                   _buildValiditySection(),
// // //                 ],
// // //               ),
// // //             ),
// // //           ),
// // //         );
// // //       },
// // //     );
// // //   }

// // //   Widget _buildProfileSection(double availableWidth) {
// // //     return Row(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         widget.cardData['photo_url'] != null
// // //             ? CircleAvatar(
// // //                 radius: 35,
// // //                 backgroundImage: NetworkImage(widget.cardData['photo_url']),
// // //               )
// // //             : CircleAvatar(
// // //                 radius: 35,
// // //                 backgroundColor: Colors.grey[200],
// // //                 child: Icon(
// // //                   Icons.person,
// // //                   size: 35,
// // //                   color: Colors.grey[400],
// // //                 ),
// // //               ),
// // //         const SizedBox(width: 16),
// // //         Expanded(
// // //           child: Column(
// // //             crossAxisAlignment: CrossAxisAlignment.start,
// // //             children: [
// // //               Text(
// // //                 widget.cardData['name'] ?? 'User Name',
// // //                 style: GoogleFonts.poppins(
// // //                   fontSize: 20,
// // //                   fontWeight: FontWeight.bold,
// // //                   color: Color(0xFF111213),
// // //                 ),
// // //                 maxLines: 1,
// // //                 overflow: TextOverflow.ellipsis,
// // //               ),
// // //               const SizedBox(height: 4),
// // //               Row(
// // //                 children: [
// // //                   Icon(
// // //                     Icons.email,
// // //                     size: 14,
// // //                     color: Colors.grey[700],
// // //                   ),
// // //                   const SizedBox(width: 4),
// // //                   Expanded(
// // //                     child: Text(
// // //                       widget.cardData['email'] ?? 'email@example.com',
// // //                       style: GoogleFonts.poppins(
// // //                         fontSize: 12,
// // //                         color: Colors.grey[700],
// // //                       ),
// // //                       overflow: TextOverflow.ellipsis,
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //               const SizedBox(height: 4),
// // //               Row(
// // //                 children: [
// // //                   Icon(
// // //                     Icons.card_membership,
// // //                     size: 14,
// // //                     color: Colors.grey[700],
// // //                   ),
// // //                   const SizedBox(width: 4),
// // //                   Flexible(
// // //                     child: Text(
// // //                       _membershipTypeName ?? 'Membership Type',
// // //                       style: GoogleFonts.poppins(
// // //                         fontSize: 12,
// // //                         color: Colors.grey[700],
// // //                       ),
// // //                       overflow: TextOverflow.ellipsis,
// // //                     ),
// // //                   ),
// // //                   const SizedBox(width: 8),
// // //                   Container(
// // //                     padding: const EdgeInsets.symmetric(
// // //                       horizontal: 6,
// // //                       vertical: 2,
// // //                     ),
// // //                     decoration: BoxDecoration(
// // //                       color: widget.cardData['status'] == 1 ? Colors.green : Colors.orange,
// // //                       borderRadius: BorderRadius.circular(10),
// // //                     ),
// // //                     child: Text(
// // //                       widget.cardData['status'] == 1 ? 'Active' : 'Inactive',
// // //                       style: GoogleFonts.poppins(
// // //                         color: Colors.white,
// // //                         fontSize: 10,
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //               const SizedBox(height: 4),
// // //               Row(
// // //                 children: [
// // //                   Icon(
// // //                     Icons.location_on,
// // //                     size: 14,
// // //                     color: Colors.grey[700],
// // //                   ),
// // //                   const SizedBox(width: 4),
// // //                   Expanded(
// // //                     child: Text(
// // //                       widget.cardData['address'] ?? 'No address',
// // //                       style: GoogleFonts.poppins(
// // //                         fontSize: 12,
// // //                         color: Colors.grey[700],
// // //                       ),
// // //                       overflow: TextOverflow.ellipsis,
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildDetailsSection(double availableWidth) {
// // //     return Row(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         Expanded(
// // //           flex: 65,
// // //           child: Column(
// // //             crossAxisAlignment: CrossAxisAlignment.start,
// // //             children: [
// // //               _buildInfoRow('ID:', widget.cardData['qr_code_no']?.toString() ?? '10000002'),
// // //               const SizedBox(height: 12),
// // //               _buildInfoRow('D.O.B:', _formatDate(widget.cardData['dob']) ?? '01 Jan. 1970'),
// // //               const SizedBox(height: 12),
// // //               _buildNationalityRow(
// // //                 _isLoadingCountry ? 'Loading...' : _countryName
// // //               ),
// // //             ],
// // //           ),
// // //         ),
        
// // //         Expanded(
// // //           flex: 35,
// // //           child: _buildQrCode(),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildValiditySection() {
// // //     final startDate = _formatDate(widget.cardData['start_date']);
// // //     final expiryDate = _formatDate(widget.cardData['expiry_date']);
// // //     final isLifetime = widget.cardData['is_lifetime'] == 1;
    
// // //     return Column(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         Text(
// // //           'Membership Validity:',
// // //           style: GoogleFonts.poppins(
// // //             fontSize: 16,
// // //             fontWeight: FontWeight.bold,
// // //             color: Color(0xFF111213),
// // //           ),
// // //         ),
// // //         const SizedBox(height: 8),
        
// // //         Row(
// // //           children: [
// // //             Expanded(
// // //               child: Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   Text(
// // //                     'Start Date:',
// // //                     style: GoogleFonts.poppins(
// // //                       fontSize: 13,
// // //                       fontWeight: FontWeight.bold,
// // //                       color: Color(0xFF111213),
// // //                     ),
// // //                   ),
// // //                   const SizedBox(height: 2),
// // //                   Container(
// // //                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// // //                     decoration: BoxDecoration(
// // //                       color: Colors.grey[100],
// // //                       borderRadius: BorderRadius.circular(8),
// // //                     ),
// // //                     child: Text(
// // //                       startDate ?? 'Not specified',
// // //                       style: GoogleFonts.poppins(
// // //                         fontSize: 14,
// // //                         color: Color(0xFF111213),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //             const SizedBox(width: 12),
// // //             Expanded(
// // //               child: Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   Text(
// // //                     'Expiry Date:',
// // //                     style: GoogleFonts.poppins(
// // //                       fontSize: 13,
// // //                       fontWeight: FontWeight.bold,
// // //                       color: Color(0xFF111213),
// // //                     ),
// // //                   ),
// // //                   const SizedBox(height: 2),
// // //                   Container(
// // //                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// // //                     decoration: BoxDecoration(
// // //                       color: Colors.grey[100],
// // //                       borderRadius: BorderRadius.circular(8),
// // //                       border: isLifetime ? Border.all(color: Colors.green, width: 1.5) : null,
// // //                     ),
// // //                     child: Row(
// // //                       children: [
// // //                         Expanded(
// // //                           child: Text(
// // //                             isLifetime ? 'Lifetime' : (expiryDate ?? 'Not specified'),
// // //                             style: GoogleFonts.poppins(
// // //                               fontSize: 14,
// // //                               color: isLifetime ? Colors.green : Color(0xFF111213),
// // //                               fontWeight: isLifetime ? FontWeight.bold : FontWeight.normal,
// // //                             ),
// // //                           ),
// // //                         ),
// // //                         if (isLifetime)
// // //                           Icon(
// // //                             Icons.check_circle_outline,
// // //                             color: Colors.green,
// // //                             size: 16,
// // //                           ),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildInfoRow(String label, String value) {
// // //     return Row(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         SizedBox(
// // //           width: 65,
// // //           child: Text(
// // //             label,
// // //             style: GoogleFonts.poppins(
// // //               fontWeight: FontWeight.bold,
// // //               fontSize: 14,
// // //               color: Color(0xFF111213),
// // //             ),
// // //           ),
// // //         ),
// // //         Expanded(
// // //           child: Text(
// // //             value,
// // //             style: GoogleFonts.poppins(
// // //               fontSize: 14,
// // //               color: Color(0xFF111213),
// // //             ),
// // //             overflow: TextOverflow.ellipsis,
// // //             maxLines: 2,
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildNationalityRow(String value) {
// // //     return Row(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         Text(
// // //           'Nationality:',
// // //           style: GoogleFonts.poppins(
// // //             fontWeight: FontWeight.bold,
// // //             fontSize: 14,
// // //             color: Color(0xFF111213),
// // //           ),
// // //         ),
// // //         const SizedBox(width: 4),
// // //         Expanded(
// // //           child: Text(
// // //             value,
// // //             style: GoogleFonts.poppins(
// // //               fontSize: 14,
// // //               color: Colors.black87,
// // //             ),
// // //             overflow: TextOverflow.ellipsis,
// // //             maxLines: 2,
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildQrCode() {
// // //     return Container(
// // //       height: 110,
// // //       width: 110,
// // //       decoration: BoxDecoration(
// // //         color: Colors.white,
// // //         borderRadius: BorderRadius.circular(8),
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: Colors.black.withOpacity(0.1),
// // //             spreadRadius: 1,
// // //             blurRadius: 3,
// // //             offset: const Offset(0, 1),
// // //           ),
// // //         ],
// // //       ),
// // //       child: ClipRRect(
// // //         borderRadius: BorderRadius.circular(8),
// // //         child: _hasQrCode && _svgContent != null
// // //             ? SvgPicture.string(
// // //                 _svgContent!,
// // //                 fit: BoxFit.contain,
// // //               )
// // //             : Center(
// // //                 child: Column(
// // //                   mainAxisAlignment: MainAxisAlignment.center,
// // //                   children: [
// // //                     Icon(
// // //                       Icons.qr_code_2,
// // //                       size: 40,
// // //                       color: Colors.grey[400],
// // //                     ),
// // //                     if (_errorMessage.isNotEmpty)
// // //                       Padding(
// // //                         padding: const EdgeInsets.all(4.0),
// // //                         child: Text(
// // //                           'Error loading QR',
// // //                           style: GoogleFonts.poppins(
// // //                             fontSize: 9,
// // //                             color: Colors.red[300],
// // //                           ),
// // //                           textAlign: TextAlign.center,
// // //                         ),
// // //                       ),
// // //                   ],
// // //                 ),
// // //               ),
// // //       ),
// // //     );
// // //   }

// // //   String? _formatDate(String? dateString) {
// // //     if (dateString == null) return null;
// // //     try {
// // //       final date = DateTime.parse(dateString);
// // //       final day = date.day.toString().padLeft(2, '0');
// // //       final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
// // //       final month = months[date.month - 1];
// // //       final year = date.year.toString();
// // //       return '$day $month. $year';
// // //     } catch (e) {
// // //       return dateString;
// // //     }
// // //   }
// // // }













// // // import 'dart:convert';
// // // import 'dart:developer' as developer;
// // // import 'package:flutter/material.dart';
// // // import 'package:google_fonts/google_fonts.dart';
// // // import 'package:flutter_svg/flutter_svg.dart';
// // // import 'package:ems/services/country_service.dart';

// // // class MembershipCardDisplay extends StatefulWidget {
// // //   final Map<String, dynamic> cardData;
// // //   final List<Map<String, dynamic>>? membershipTypes;

// // //   const MembershipCardDisplay({
// // //     Key? key, 
// // //     required this.cardData,
// // //     this.membershipTypes,
// // //   }) : super(key: key);

// // //   @override
// // //   State<MembershipCardDisplay> createState() => _MembershipCardDisplayState();
// // // }

// // // class _MembershipCardDisplayState extends State<MembershipCardDisplay> {
// // //   String _countryName = 'Loading...';
// // //   bool _isLoadingCountry = true;
// // //   bool _hasQrCode = false;
// // //   String? _svgContent;
// // //   String _errorMessage = '';
// // //   String? _membershipTypeName;
  
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadCountryName();
// // //     _processQrCode();
// // //     _getMembershipTypeName();
// // //   }
  
// // //   void _getMembershipTypeName() {
// // //     // Get card type id from card data
// // //     final cardTypeId = widget.cardData['card_type_id'];
    
// // //     if (cardTypeId != null && widget.membershipTypes != null) {
// // //       for (final type in widget.membershipTypes!) {
// // //         if (type['id'] == cardTypeId) {
// // //           setState(() {
// // //             _membershipTypeName = type['type'];
// // //           });
// // //           return;
// // //         }
// // //       }
// // //     }
    
// // //     // If we can't find the type or there are no types, use a default value
// // //     setState(() {
// // //       _membershipTypeName = widget.cardData['is_lifetime'] == 1 ? 'Lifetime' : 'Regular';
// // //     });
// // //   }
  
// // //   void _processQrCode() {
// // //     // Debug what data we have
// // //     developer.log('Processing card data with keys: ${widget.cardData.keys.join(", ")}');
    
// // //     if (widget.cardData.containsKey('qr_code')) {
// // //       try {
// // //         final qrCodeData = widget.cardData['qr_code'].toString();
// // //         developer.log('QR code data found: ${qrCodeData.substring(0, 50)}...');
        
// // //         if (qrCodeData.startsWith('data:image/svg+xml;base64,')) {
// // //           // Extract base64 part
// // //           final base64String = qrCodeData.split('base64,')[1];
          
// // //           // Decode base64 to bytes
// // //           final bytes = base64Decode(base64String);
          
// // //           // Convert bytes to SVG string
// // //           final svgString = utf8.decode(bytes);
          
// // //           setState(() {
// // //             _svgContent = svgString;
// // //             _hasQrCode = true;
// // //           });
          
// // //           developer.log('SVG content extracted successfully');
// // //         } else {
// // //           setState(() {
// // //             _errorMessage = 'Invalid QR format';
// // //           });
// // //           developer.log('QR code is not in expected SVG format');
// // //         }
// // //       } catch (e) {
// // //         setState(() {
// // //           _errorMessage = 'Error: ${e.toString()}';
// // //         });
// // //         developer.log('Error processing QR code: $e');
// // //       }
// // //     } else {
// // //       developer.log('No qr_code field found in card data');
// // //     }
// // //   }

// // //   Future<void> _loadCountryName() async {
// // //     if (widget.cardData['country_id'] != null) {
// // //       try {
// // //         final countryName = await CountryService.getCountryName(widget.cardData['country_id']);
// // //         if (mounted) {
// // //           setState(() {
// // //             _countryName = countryName;
// // //             _isLoadingCountry = false;
// // //           });
// // //         }
// // //       } catch (e) {
// // //         debugPrint('Error loading country name: $e');
// // //         if (mounted) {
// // //           setState(() {
// // //             _countryName = 'Unknown';
// // //             _isLoadingCountry = false;
// // //           });
// // //         }
// // //       }
// // //     } else {
// // //       setState(() {
// // //         _countryName = 'Not specified';
// // //         _isLoadingCountry = false;
// // //       });
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final screenWidth = MediaQuery.of(context).size.width;
    
// // //     return LayoutBuilder(
// // //       builder: (context, constraints) {
// // //         final cardWidth = screenWidth - 32;
        
// // //         return Container(
// // //           width: cardWidth,
// // //           margin: const EdgeInsets.symmetric(vertical: 16.0),
// // //           child: Card(
// // //             elevation: 8.0,
// // //             shape: RoundedRectangleBorder(
// // //               borderRadius: BorderRadius.circular(16.0),
// // //             ),
// // //             child: Container(
// // //               padding: const EdgeInsets.all(20.0),
// // //               decoration: BoxDecoration(
// // //                 borderRadius: BorderRadius.circular(16.0),
// // //                 color: Colors.white,
// // //               ),
// // //               child: Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   // Top section with profile and details
// // //                   _buildProfileSection(cardWidth),
                  
// // //                   const SizedBox(height: 16),
// // //                   const Divider(height: 1),
// // //                   const SizedBox(height: 16),
                  
// // //                   // Bottom section with details and QR code
// // //                   _buildDetailsSection(cardWidth),
                  
// // //                   const SizedBox(height: 16),
// // //                   const Divider(height: 1),
// // //                   const SizedBox(height: 16),
                  
// // //                   // Membership validity section
// // //                   _buildValiditySection(),
// // //                 ],
// // //               ),
// // //             ),
// // //           ),
// // //         );
// // //       },
// // //     );
// // //   }

// // //   Widget _buildProfileSection(double availableWidth) {
// // //     return Row(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         widget.cardData['photo_url'] != null
// // //             ? CircleAvatar(
// // //                 radius: 35,
// // //                 backgroundImage: NetworkImage(widget.cardData['photo_url']),
// // //               )
// // //             : CircleAvatar(
// // //                 radius: 35,
// // //                 backgroundColor: Colors.grey[200],
// // //                 child: Icon(
// // //                   Icons.person,
// // //                   size: 35,
// // //                   color: Colors.grey[400],
// // //                 ),
// // //               ),
// // //         const SizedBox(width: 16),
// // //         Expanded(
// // //           child: Column(
// // //             crossAxisAlignment: CrossAxisAlignment.start,
// // //             children: [
// // //               Text(
// // //                 widget.cardData['name'] ?? 'User Name',
// // //                 style: GoogleFonts.poppins(
// // //                   fontSize: 20,
// // //                   fontWeight: FontWeight.bold,
// // //                   color: Colors.black,
// // //                 ),
// // //                 maxLines: 1,
// // //                 overflow: TextOverflow.ellipsis,
// // //               ),
// // //               const SizedBox(height: 4),
// // //               Row(
// // //                 children: [
// // //                   Icon(
// // //                     Icons.email,
// // //                     size: 14,
// // //                     color: Colors.grey[700],
// // //                   ),
// // //                   const SizedBox(width: 4),
// // //                   Expanded(
// // //                     child: Text(
// // //                       widget.cardData['email'] ?? 'email@example.com',
// // //                       style: GoogleFonts.poppins(
// // //                         fontSize: 12,
// // //                         color: Colors.grey[700],
// // //                       ),
// // //                       overflow: TextOverflow.ellipsis,
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //               const SizedBox(height: 4),
// // //               Row(
// // //                 children: [
// // //                   Icon(
// // //                     Icons.card_membership,  // Changed icon to be appropriate for membership type
// // //                     size: 14,
// // //                     color: Colors.grey[700],
// // //                   ),
// // //                   const SizedBox(width: 4),
// // //                   Flexible(
// // //                     child: Text(
// // //                       _membershipTypeName ?? 'Membership Type',  // Display membership type instead of address
// // //                       style: GoogleFonts.poppins(
// // //                         fontSize: 12,
// // //                         color: Colors.grey[700],
// // //                       ),
// // //                       overflow: TextOverflow.ellipsis,
// // //                     ),
// // //                   ),
// // //                   const SizedBox(width: 8),
// // //                   Container(
// // //                     padding: const EdgeInsets.symmetric(
// // //                       horizontal: 6,
// // //                       vertical: 2,
// // //                     ),
// // //                     decoration: BoxDecoration(
// // //                       color: widget.cardData['status'] == 1 ? Colors.green : Colors.orange,
// // //                       borderRadius: BorderRadius.circular(10),
// // //                     ),
// // //                     child: Text(
// // //                       widget.cardData['status'] == 1 ? 'Active' : 'Inactive',
// // //                       style: GoogleFonts.poppins(
// // //                         color: Colors.white,
// // //                         fontSize: 10,
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //               // Show address as well since it's useful information
// // //               const SizedBox(height: 4),
// // //               Row(
// // //                 children: [
// // //                   Icon(
// // //                     Icons.location_on,
// // //                     size: 14,
// // //                     color: Colors.grey[700],
// // //                   ),
// // //                   const SizedBox(width: 4),
// // //                   Expanded(
// // //                     child: Text(
// // //                       widget.cardData['address'] ?? 'No address',
// // //                       style: GoogleFonts.poppins(
// // //                         fontSize: 12,
// // //                         color: Colors.grey[700],
// // //                       ),
// // //                       overflow: TextOverflow.ellipsis,
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildDetailsSection(double availableWidth) {
// // //     return Row(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         Expanded(
// // //           flex: 65,
// // //           child: Column(
// // //             crossAxisAlignment: CrossAxisAlignment.start,
// // //             children: [
// // //               _buildInfoRow('ID:', widget.cardData['qr_code_no']?.toString() ?? '10000002'),
// // //               const SizedBox(height: 12),
// // //               _buildInfoRow('D.O.B:', _formatDate(widget.cardData['dob']) ?? '01 Jan. 1970'),
// // //               const SizedBox(height: 12),
// // //               _buildNationalityRow(
// // //                 _isLoadingCountry ? 'Loading...' : _countryName
// // //               ),
// // //             ],
// // //           ),
// // //         ),
        
// // //         Expanded(
// // //           flex: 35,
// // //           child: _buildQrCode(),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildValiditySection() {
// // //     final startDate = _formatDate(widget.cardData['start_date']);
// // //     final expiryDate = _formatDate(widget.cardData['expiry_date']);
// // //     final isLifetime = widget.cardData['is_lifetime'] == 1;
    
// // //     return Column(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         Text(
// // //           'Membership Validity:',
// // //           style: GoogleFonts.poppins(
// // //             fontSize: 16,
// // //             fontWeight: FontWeight.bold,
// // //             color: Colors.black87,
// // //           ),
// // //         ),
// // //         const SizedBox(height: 8),
        
// // //         Row(
// // //           children: [
// // //             Expanded(
// // //               child: Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   Text(
// // //                     'Start Date:',
// // //                     style: GoogleFonts.poppins(
// // //                       fontSize: 13,
// // //                       fontWeight: FontWeight.bold,
// // //                       color: Colors.black87,
// // //                     ),
// // //                   ),
// // //                   const SizedBox(height: 2),
// // //                   Container(
// // //                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// // //                     decoration: BoxDecoration(
// // //                       color: Colors.grey[100],
// // //                       borderRadius: BorderRadius.circular(8),
// // //                     ),
// // //                     child: Text(
// // //                       startDate ?? 'Not specified',
// // //                       style: GoogleFonts.poppins(
// // //                         fontSize: 14,
// // //                         color: Colors.black87,
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //             const SizedBox(width: 12),
// // //             Expanded(
// // //               child: Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   Text(
// // //                     'Expiry Date:',
// // //                     style: GoogleFonts.poppins(
// // //                       fontSize: 13,
// // //                       fontWeight: FontWeight.bold,
// // //                       color: Colors.black87,
// // //                     ),
// // //                   ),
// // //                   const SizedBox(height: 2),
// // //                   Container(
// // //                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// // //                     decoration: BoxDecoration(
// // //                       color: Colors.grey[100],
// // //                       borderRadius: BorderRadius.circular(8),
// // //                       border: isLifetime ? Border.all(color: Colors.green, width: 1.5) : null,
// // //                     ),
// // //                     child: Row(
// // //                       children: [
// // //                         Expanded(
// // //                           child: Text(
// // //                             isLifetime ? 'Lifetime' : (expiryDate ?? 'Not specified'),
// // //                             style: GoogleFonts.poppins(
// // //                               fontSize: 14,
// // //                               color: isLifetime ? Colors.green : Colors.black87,
// // //                               fontWeight: isLifetime ? FontWeight.bold : FontWeight.normal,
// // //                             ),
// // //                           ),
// // //                         ),
// // //                         if (isLifetime)
// // //                           Icon(
// // //                             Icons.check_circle_outline,
// // //                             color: Colors.green,
// // //                             size: 16,
// // //                           ),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildInfoRow(String label, String value) {
// // //     return Row(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         SizedBox(
// // //           width: 65,
// // //           child: Text(
// // //             label,
// // //             style: GoogleFonts.poppins(
// // //               fontWeight: FontWeight.bold,
// // //               fontSize: 14,
// // //               color: Colors.black87,
// // //             ),
// // //           ),
// // //         ),
// // //         Expanded(
// // //           child: Text(
// // //             value,
// // //             style: GoogleFonts.poppins(
// // //               fontSize: 14,
// // //               color: Colors.black87,
// // //             ),
// // //             overflow: TextOverflow.ellipsis,
// // //             maxLines: 2,
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildNationalityRow(String value) {
// // //     return Row(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         Text(
// // //           'Nationality:',
// // //           style: GoogleFonts.poppins(
// // //             fontWeight: FontWeight.bold,
// // //             fontSize: 14,
// // //             color: Colors.black87,
// // //           ),
// // //         ),
// // //         const SizedBox(width: 4),
// // //         Expanded(
// // //           child: Text(
// // //             value,
// // //             style: GoogleFonts.poppins(
// // //               fontSize: 14,
// // //               color: Colors.black87,
// // //             ),
// // //             overflow: TextOverflow.ellipsis,
// // //             maxLines: 2,
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildQrCode() {
// // //     return Container(
// // //       height: 110,
// // //       width: 110,
// // //       decoration: BoxDecoration(
// // //         color: Colors.white,
// // //         borderRadius: BorderRadius.circular(8),
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: Colors.black.withOpacity(0.1),
// // //             spreadRadius: 1,
// // //             blurRadius: 3,
// // //             offset: const Offset(0, 1),
// // //           ),
// // //         ],
// // //       ),
// // //       child: ClipRRect(
// // //         borderRadius: BorderRadius.circular(8),
// // //         child: _hasQrCode && _svgContent != null
// // //             ? SvgPicture.string(
// // //                 _svgContent!,
// // //                 fit: BoxFit.contain,
// // //               )
// // //             : Center(
// // //                 child: Column(
// // //                   mainAxisAlignment: MainAxisAlignment.center,
// // //                   children: [
// // //                     Icon(
// // //                       Icons.qr_code_2,
// // //                       size: 40,
// // //                       color: Colors.grey[400],
// // //                     ),
// // //                     if (_errorMessage.isNotEmpty)
// // //                       Padding(
// // //                         padding: const EdgeInsets.all(4.0),
// // //                         child: Text(
// // //                           'Error loading QR',
// // //                           style: GoogleFonts.poppins(
// // //                             fontSize: 9,
// // //                             color: Colors.red[300],
// // //                           ),
// // //                           textAlign: TextAlign.center,
// // //                         ),
// // //                       ),
// // //                   ],
// // //                 ),
// // //               ),
// // //       ),
// // //     );
// // //   }

// // //   String? _formatDate(String? dateString) {
// // //     if (dateString == null) return null;
// // //     try {
// // //       final date = DateTime.parse(dateString);
// // //       final day = date.day.toString().padLeft(2, '0');
// // //       final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
// // //       final month = months[date.month - 1];
// // //       final year = date.year.toString();
// // //       return '$day $month. $year';
// // //     } catch (e) {
// // //       return dateString;
// // //     }
// // //   }
// // // }



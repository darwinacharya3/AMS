import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ems/models/user_detail.dart';

class PassportCopiesWidget extends StatelessWidget {
  final UserDetail? userDetail;

  const PassportCopiesWidget({
    super.key,
    required this.userDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildSubHeader(),
          _buildPassportImages(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Passport Copies',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSubHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Text(
        'Click on file to see larger size.',
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: const Color.fromARGB(255, 227, 10, 169),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPassportImages(BuildContext context) {
    // Check if userDetail is null or URLs are empty
    if (userDetail == null || 
        (userDetail!.passportFrontPage.isEmpty && userDetail!.passportBackPage.isEmpty)) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No passport images available',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (userDetail!.passportFrontPage.isNotEmpty)
            _buildPassportImageItem(
              context,
              userDetail!.passportFrontPage,
              'Front Page',
            ),
          if (userDetail!.passportBackPage.isNotEmpty)
            _buildPassportImageItem(
              context,
              userDetail!.passportBackPage,
              'Back Page',
            ),
        ],
      ),
    );
  }

  Widget _buildPassportImageItem(BuildContext context, String imageUrl, String label) {
    return GestureDetector(
      onTap: () => _showEnlargedImage(context, imageUrl, label),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue[50],
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  // Handle image load errors silently
                }
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showEnlargedImage(BuildContext context, String imageUrl, String label) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Passport $label',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: const Color.fromARGB(255, 227, 10, 169),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Unable to load image',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}













// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class PassportCopiesWidget extends StatelessWidget{

//   const PassportCopiesWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 5,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildHeader(),
//           _buildSubHeader() 
          
//         ],
//       ),
//     );
    
//   }

//   Widget _buildHeader(){
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Text(
//         'Passport Copies',
//         style: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
      
//       );
//   }
// }

// Widget _buildSubHeader(){
//   return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       color: Colors.blue[50],
//       child: Text(
//         'Click on file to see larger size.',
//         style: GoogleFonts.poppins(
//           fontSize: 16,
//           color: const Color.fromARGB(255, 227, 10, 169),
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//   );
// }
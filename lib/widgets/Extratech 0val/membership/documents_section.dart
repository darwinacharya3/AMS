import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class DocumentsSection extends StatefulWidget {
  final Map<String, dynamic> formData;

  const DocumentsSection({
    Key? key,
    required this.formData,
  }) : super(key: key);

  @override
  State<DocumentsSection> createState() => _DocumentsSectionState();
}

class _DocumentsSectionState extends State<DocumentsSection> {
  File? _profilePhotoFile;
  File? _citizenshipFrontFile;
  File? _citizenshipBackFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(String fieldName) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        switch (fieldName) {
          case 'profile':
            _profilePhotoFile = File(image.path);
            widget.formData['profilePhotoPath'] = image.path;
            break;
          case 'citizenshipFront':
            _citizenshipFrontFile = File(image.path);
            widget.formData['citizenshipFrontPath'] = image.path;
            break;
          case 'citizenshipBack':
            _citizenshipBackFile = File(image.path);
            widget.formData['citizenshipBackPath'] = image.path;
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Documents',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF205EB5),
          ),
        ),
        const SizedBox(height: 12),

        // Documents - Responsive layout for file uploads
        if (isSmallScreen)
          Column(
            children: [
              _buildFileUploadField(
                label: 'Your Photo',
                icon: Icons.person,
                file: _profilePhotoFile,
                onTap: () => _pickImage('profile'),
              ),
              const SizedBox(height: 12),
              _buildFileUploadField(
                label: 'Citizenship Front Photo',
                icon: Icons.card_membership,
                file: _citizenshipFrontFile,
                onTap: () => _pickImage('citizenshipFront'),
              ),
              const SizedBox(height: 12),
              _buildFileUploadField(
                label: 'Citizenship Back Photo',
                icon: Icons.card_membership,
                file: _citizenshipBackFile,
                onTap: () => _pickImage('citizenshipBack'),
              ),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildFileUploadField(
                  label: 'Your Photo',
                  icon: Icons.person,
                  file: _profilePhotoFile,
                  onTap: () => _pickImage('profile'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFileUploadField(
                  label: 'Citizenship Front Photo',
                  icon: Icons.card_membership,
                  file: _citizenshipFrontFile,
                  onTap: () => _pickImage('citizenshipFront'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFileUploadField(
                  label: 'Citizenship Back Photo',
                  icon: Icons.card_membership,
                  file: _citizenshipBackFile,
                  onTap: () => _pickImage('citizenshipBack'),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildFileUploadField({
    required String label,
    required IconData icon,
    required File? file,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF205EB5),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              if (file != null)
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                    image: DecorationImage(
                      image: FileImage(file),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Row(
                children: [
                  TextButton(
                    onPressed: onTap,
                    child: const Text('Choose File'),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        file != null ? file.path.split('/').last : 'No file chosen',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
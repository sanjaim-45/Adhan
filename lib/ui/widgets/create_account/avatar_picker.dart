import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AvatarPicker extends StatefulWidget {
  final Function(File?) onImageSelected;
  final File? initialImageFile;
  const AvatarPicker({
    super.key,
    required this.onImageSelected,
    this.initialImageFile,
  });

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialImageFile;
  }

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final List<String> _allowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'tiff',
    'webp',
    'avif',
  ];

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        // Check file extension
        final extension = pickedFile.path.split('.').last.toLowerCase();

        if (!_allowedExtensions.contains(extension)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please select a valid image format (JPG, PNG, GIF, BMP, TIFF, WEBP, AVIF)',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        // Verify the image can be loaded
        try {
          final image = FileImage(File(pickedFile.path));
          await image.resolve(ImageConfiguration.empty);

          setState(() {
            _selectedImage = File(pickedFile.path);
          });
          widget.onImageSelected(_selectedImage);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('The selected image is corrupted or invalid'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to pick image: $e"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black, // Specify your border color here
                width: 3, // Specify the border width
              ),
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  _selectedImage != null
                      ? FileImage(_selectedImage!) as ImageProvider
                      : const NetworkImage(
                        "https://t3.ftcdn.net/jpg/06/19/26/46/360_F_619264680_x2PBdGLF54sFe7kTBtAvZnPyXgvaRw0Y.jpg",
                      ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

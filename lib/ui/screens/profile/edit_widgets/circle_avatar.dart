import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AvatarWidget extends StatefulWidget {
  final String? initialImageUrl;
  final Function(File)? onImageSelected;

  const AvatarWidget({Key? key, this.initialImageUrl, this.onImageSelected})
    : super(key: key);

  @override
  _AvatarWidgetState createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget> {
  File? _selectedImage;
  String? _networkImageUrl;

  @override
  void initState() {
    super.initState();
    _networkImageUrl = widget.initialImageUrl;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _networkImageUrl =
            null; // Clear the network image when a new one is selected
      });

      if (widget.onImageSelected != null) {
        widget.onImageSelected!(_selectedImage!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.green.shade50,
          backgroundImage:
              _selectedImage != null
                  ? FileImage(_selectedImage!)
                  : _networkImageUrl != null
                  ? NetworkImage(_networkImageUrl!)
                  : null,
          child:
              _selectedImage == null && _networkImageUrl == null
                  ? Icon(Icons.person, size: 40, color: Colors.green.shade200)
                  : null,
        ),
        Positioned(
          bottom: 4,
          left: 55,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2D7C3F),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(
                Icons.camera_alt,
                size: 13,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

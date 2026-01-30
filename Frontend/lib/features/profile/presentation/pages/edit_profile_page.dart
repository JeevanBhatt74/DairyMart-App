import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/services/image/profile_image_service.dart';
import '../../../../core/services/storage/user_session_service.dart';
import '../providers/profile_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _nameController = TextEditingController(text: "Jeevan Bhatt");
  final _phoneController = TextEditingController(text: "+977 9812345678");
  
  // We usually don't allow editing email easily, so we just display it
  final String _email = "jeevan@dairymart.com";
  
  final ProfileImageService _imageService = ProfileImageService();
  bool _isUploadingImage = false;
  bool _showTokenWarning = false;

  @override
  void initState() {
    super.initState();
    // For testing: Print current token status
    _checkTokenStatus();
  }

  /// Check if user has a valid token
  Future<void> _checkTokenStatus() async {
    final userSessionService = UserSessionService();
    final token = await userSessionService.getToken();
    if (token == null) {
      print('⚠️ WARNING: No auth token found! User must login first.');
      setState(() {
        _showTokenWarning = true;
      });
    } else {
      print('✅ Token found (${token.length} chars)');
      setState(() {
        _showTokenWarning = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Show dialog to choose camera or gallery
  Future<void> _showImagePickerDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Select Profile Picture",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            "Choose an option",
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
              child: Text(
                "Camera",
                style: GoogleFonts.poppins(color: const Color(0xFF29ABE2)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
              child: Text(
                "Gallery",
                style: GoogleFonts.poppins(color: const Color(0xFF29ABE2)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Pick image from camera
  Future<void> _pickImageFromCamera() async {
    try {
      setState(() => _isUploadingImage = true);
      
      final imageFile = await _imageService.pickImageFromCamera();
      if (imageFile != null) {
        await _uploadProfileImage(imageFile);
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, "Failed to capture image: ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  /// Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      setState(() => _isUploadingImage = true);
      
      final imageFile = await _imageService.pickImageFromGallery();
      if (imageFile != null) {
        await _uploadProfileImage(imageFile);
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, "Failed to select image: ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  /// Upload the selected image
  Future<void> _uploadProfileImage(File imageFile) async {
    try {
      // Call the Riverpod provider to upload
      await ref.read(profileUpdateProvider.notifier).uploadProfileImage(imageFile);
      
      if (mounted) {
        SnackBarHelper.showSuccess(context, "Profile picture updated successfully!");
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, "Upload failed: ${e.toString()}");
      }
    }
  }

  /// Get the appropriate image provider based on image type
  ImageProvider<Object>? _getBackgroundImage(dynamic image) {
    if (image is File) {
      return FileImage(image);
    } else if (image is String && image.isNotEmpty) {
      return NetworkImage(image);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF29ABE2);
    
    // Watch the current profile image from Riverpod
    // This will automatically update when the image is uploaded
    final currentImage = ref.watch(currentProfileImageProvider);
    print('🎨 EditProfilePage: currentImage = $currentImage');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit Profile",
          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Show warning if not authenticated
            if (_showTokenWarning)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[800]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please login first to upload profile pictures',
                        style: GoogleFonts.poppins(color: Colors.orange[800]),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            
            // --- Profile Image Edit ---
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryBlue, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[100],
                    backgroundImage: _getBackgroundImage(currentImage),
                    child: currentImage == null
                      ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                      : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _isUploadingImage ? null : _showImagePickerDialog,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: _isUploadingImage
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // --- Form Fields ---
            _buildTextField("Full Name", _nameController, Icons.person_outline),
            const SizedBox(height: 20),
            _buildReadOnlyField("Email Address", _email, Icons.email_outlined),
            const SizedBox(height: 20),
            _buildTextField("Phone Number", _phoneController, Icons.phone_outlined),
            
            const SizedBox(height: 50),

            // --- Save Button ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                ),
                onPressed: _isUploadingImage ? null : () {
                  // Text fields are not connected to backend yet in this snippet, 
                  // but we close the page as the image upload (if any) is done.
                  Navigator.pop(context);
                },
                child: Text(
                  "Done",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[400]),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF29ABE2)),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey[400]),
              const SizedBox(width: 12),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              const Icon(Icons.lock_outline, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }
}
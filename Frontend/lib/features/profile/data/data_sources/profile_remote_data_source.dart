import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSource(ref.read(apiClientProvider));
});

class ProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDataSource(this._apiClient);

  /// Upload profile image to backend
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      print('📤 Starting upload to backend');
      final response = await _apiClient.uploadFile(
        ApiEndpoints.uploadProfileImage,
        file: imageFile,
        fieldName: 'profilePicture',
      );

      print('📥 Response received: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Backend returns different response formats - try each
        print('📥 Full Response data: ${response.data}');
        
        final imageUrl = response.data['imageUrl'] ?? 
                        response.data['data']?['profilePicture'] ?? 
                        response.data['data']?['imageUrl'] ??
                        response.data['profilePicture'] ?? 
                        response.data['url'] ??
                        '';
        
        print('🔍 Parsed image URL: $imageUrl');
        print('🔍 Image URL is empty: ${imageUrl.isEmpty}');
        print('🔍 Image URL type: ${imageUrl.runtimeType}');
        
        if (imageUrl.isEmpty) {
          print('⚠️ No image URL found in response!');
          // Try to construct it manually from filename
          if (response.data['data'] is Map && response.data['data']['user'] is Map) {
            final user = response.data['data']['user'];
            if (user['profilePicture'] != null) {
              print('✅ Found profilePicture in user data: ${user['profilePicture']}');
            }
          }
          throw Exception('No image URL returned from server. Response: ${response.data}');
        }
        return imageUrl;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to upload image. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException during upload: ${e.message}');
      print('❌ Response data: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Upload failed');
    } catch (e) {
      print('❌ Exception during upload: $e');
      throw Exception('Upload failed: $e');
    }
  }

  /// Update user profile information
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.updateProfile,
        data: profileData,
      );

      if (response.statusCode == 200) {
        return response.data['data'] ?? response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update profile');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Update failed');
    }
  }
}

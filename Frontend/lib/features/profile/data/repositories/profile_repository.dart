import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data_sources/profile_remote_data_source.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.read(profileRemoteDataSourceProvider));
});

class ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepository(this._remoteDataSource);

  /// Upload profile image and return the image URL
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      print('📋 Repository: calling datasource uploadProfileImage');
      final imageUrl = await _remoteDataSource.uploadProfileImage(imageFile);
      print('📋 Repository: got image URL: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('📋 Repository: ERROR - ${e.toString()}');
      throw Exception('Profile image upload error: ${e.toString()}');
    }
  }

  /// Update profile with new information
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      return await _remoteDataSource.updateProfile(profileData);
    } catch (e) {
      throw Exception('Profile update error: ${e.toString()}');
    }
  }
}

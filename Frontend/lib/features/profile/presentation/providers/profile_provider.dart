import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/profile_repository.dart';

// ========== PROFILE IMAGE PROVIDER ==========
// Stores the current profile image (local or from backend)
final selectedProfileImageProvider = StateProvider<File?>((ref) => null);

// Current profile image URL from backend
final profileImageUrlProvider = StateProvider<String?>((ref) => null);

// ========== PROFILE UPDATE NOTIFIER ==========
class ProfileUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  final ProfileRepository _repository;
  final Ref _ref;

  ProfileUpdateNotifier(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  /// Upload and update profile image
  Future<void> uploadProfileImage(File imageFile) async {
    print('🟣 Notifier: uploadProfileImage called');
    state = const AsyncValue.loading();
    try {
      // Upload image to backend
      print('🟣 Notifier: calling repository uploadProfileImage');
      final imageUrl = await _repository.uploadProfileImage(imageFile);
      
      print('🟣 Notifier: got URL from repo: $imageUrl');
      // Update the profile image URL provider
      _ref.read(profileImageUrlProvider.notifier).state = imageUrl;
      print('🟣 Notifier: updated profileImageUrlProvider to: $imageUrl');
      
      // Keep the local file for immediate display
      _ref.read(selectedProfileImageProvider.notifier).state = imageFile;
      print('🟣 Notifier: updated selectedProfileImageProvider');
      
      state = const AsyncValue.data(null);
      print('🟣 Notifier: upload completed successfully');
    } catch (e, st) {
      print('🟣 Notifier: ERROR - $e');
      print('🟣 Notifier: Stack trace - $st');
      state = AsyncValue.error(e, st);
      // Reset on error
      Future.delayed(const Duration(seconds: 2), () {
        state = const AsyncValue.data(null);
      });
    }
  }

  /// Update full profile
  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateProfile(profileData);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      // Reset on error
      Future.delayed(const Duration(seconds: 2), () {
        state = const AsyncValue.data(null);
      });
    }
  }

  /// Clear error by resetting state
  void clearError() {
    state = const AsyncValue.data(null);
  }
}

final profileUpdateProvider = StateNotifierProvider<ProfileUpdateNotifier, AsyncValue<void>>((ref) {
  return ProfileUpdateNotifier(
    ref.read(profileRepositoryProvider),
    ref,
  );
});

// ========== GET CURRENT PROFILE IMAGE ==========
// Returns either the selected local image or the URL from backend
// This provider watches both sources and always returns the latest image
final currentProfileImageProvider = Provider<dynamic>((ref) {
  final localImage = ref.watch(selectedProfileImageProvider);
  final imageUrl = ref.watch(profileImageUrlProvider);
  
  print('🔍 currentProfileImageProvider: localImage=$localImage, imageUrl=$imageUrl');
  
  // Prefer local selected image (immediate display), then URL (from backend), then null
  if (localImage != null) {
    print('🔍 Returning localImage');
    return localImage;
  }
  if (imageUrl != null && imageUrl.isNotEmpty) {
    print('🔍 Returning imageUrl');
    return imageUrl;
  }
  print('🔍 Returning null');
  return null;
});

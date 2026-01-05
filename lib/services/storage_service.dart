// lib/services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload une image de recette
  Future<String?> uploadRecipeImage({
    required File imageFile,
    required String recipeId,
  }) async {
    try {
      final ref = _storage.ref().child('recipes/$recipeId/${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;

      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Erreur upload image: $e');
      return null;
    }
  }

  // Supprimer une image
  Future<bool> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Erreur suppression image: $e');
      return false;
    }
  }

  // Upload une photo de profil
  Future<String?> uploadProfilePhoto({
    required File imageFile,
    required String userId,
  }) async {
    try {
      final ref = _storage.ref().child('profiles/$userId.jpg');

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;

      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Erreur upload photo profil: $e');
      return null;
    }
  }
}
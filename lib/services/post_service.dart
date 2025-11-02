// lib/services/post_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avivamiento_app/models/post_model.dart';
import 'package:image_picker/image_picker.dart';

class PostService {
  final FirebaseFirestore _firestore;

  late final CollectionReference<Map<String, dynamic>> _postsCollection;

  PostService(this._firestore) {
    _postsCollection = _firestore.collection('posts');
  }

  Stream<List<PostModel>> getPostsStream() {
    return _postsCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PostModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<String> _uploadImageToImgbb(XFile imageFile) async {
    final apiKey = dotenv.env['IMGBB_API_KEY'];
    if (apiKey == null) throw Exception('IMGBB_API_KEY no encontrada');
    final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');
    final request = http.MultipartRequest('POST', uri);
    final bytes = await imageFile.readAsBytes();
    request.fields['image'] = base64Encode(bytes);
    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);
      return jsonResponse['data']['url'];
    } else {
      throw Exception('Fallo al subir la imagen a ImgBB');
    }
  }

  /// Extrae la primera URL de video válida del texto.
  Map<String, String>? _extractVideoInfo(String text) {
    final RegExp exp = RegExp(
        r'https?:\/\/(?:www\.)?(?:youtube\.com|youtu\.be|facebook\.com|fb\.watch|tiktok\.com)\S+');
    final Match? match = exp.firstMatch(text);

    if (match != null) {
      final String url = match.group(0)!;
      String provider = 'Link';
      if (url.contains('youtube') || url.contains('youtu.be')) {
        provider = 'YouTube';
      } else if (url.contains('facebook') || url.contains('fb.watch')) {
        provider = 'Facebook';
      } else if (url.contains('tiktok')) {
        provider = 'TikTok';
      }
      return {'url': url, 'provider': provider};
    }
    return null;
  }

  Future<void> createPost({
    required String content,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String authorRole,
    XFile? imageFile,
  }) async {
    String? imageUrl;
    Map<String, String>? videoInfo;

    if (imageFile != null) {
      imageUrl = await _uploadImageToImgbb(imageFile);
    }

    videoInfo = _extractVideoInfo(content);

    await _postsCollection.add({
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'authorRole': authorRole,
      'imageUrl': imageUrl,
      'videoUrl': videoInfo?['url'],
      'videoProvider': videoInfo?['provider'],
      'timestamp': FieldValue.serverTimestamp(),
      'likes': 0,
      'likedBy': [],
    });
  }

  Future<void> deletePost(String postId) {
    return _postsCollection.doc(postId).delete();
  }

  Future<void> toggleLike(String postId, String userId, bool isLiked) {
    return _firestore.runTransaction((transaction) async {
      final postRef = _postsCollection.doc(postId);
      if (isLiked) {
        transaction.update(postRef, {
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([userId])
        });
      } else {
        transaction.update(postRef, {
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([userId])
        });
      }
    });
  }
}

// lib/models/comment_model.dart

/// Modelo para comentarios en publicaciones
/// Soporta comentarios anidados (respuestas) mediante parentCommentId
class CommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String authorRole;
  final String content;
  final DateTime timestamp;
  final int likes;
  final List<String> likedBy;
  final String? parentCommentId; // null = comentario raíz, non-null = respuesta
  final int replyCount;

  CommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.authorRole,
    required this.content,
    required this.timestamp,
    this.likes = 0,
    this.likedBy = const [],
    this.parentCommentId,
    this.replyCount = 0,
  });

  factory CommentModel.fromJson(Map<String, dynamic> data) {
    DateTime parseDate(dynamic dateVal) {
      if (dateVal is String) {
        return DateTime.parse(dateVal);
      }
      return DateTime.now();
    }

    // El ID puede venir como 'commentId' o 'PK' de DynamoDB
    String docId = data['commentId'] ?? data['PK'] ?? '';
    if (docId.startsWith('COMMENT#')) {
      docId = docId.replaceAll('COMMENT#', '');
    }

    return CommentModel(
      id: docId,
      postId: data['postId'] ?? '',
      authorId: data['userId'] ?? data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Usuario',
      authorPhotoUrl: data['authorPhotoUrl'],
      authorRole: data['authorRole'] ?? 'Miembro',
      content: data['content'] ?? '',
      timestamp: parseDate(data['createdAt'] ?? data['timestamp']),
      likes: (data['likes'] is int) ? data['likes'] : 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      parentCommentId: data['parentCommentId'],
      replyCount: (data['replyCount'] is int) ? data['replyCount'] : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commentId': id,
      'postId': postId,
      'userId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'authorRole': authorRole,
      'content': content,
      'createdAt': timestamp.toIso8601String(),
      'likes': likes,
      'likedBy': likedBy,
      'parentCommentId': parentCommentId,
      'replyCount': replyCount,
    };
  }

  /// Copia del comentario con campos actualizados
  CommentModel copyWith({
    int? likes,
    List<String>? likedBy,
    int? replyCount,
  }) {
    return CommentModel(
      id: id,
      postId: postId,
      authorId: authorId,
      authorName: authorName,
      authorPhotoUrl: authorPhotoUrl,
      authorRole: authorRole,
      content: content,
      timestamp: timestamp,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      parentCommentId: parentCommentId,
      replyCount: replyCount ?? this.replyCount,
    );
  }
}

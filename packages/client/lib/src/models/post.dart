import 'package:client/client.dart';
import 'package:equatable/equatable.dart';

/// Post object from the API.
class Post extends Equatable {
  /// Class constructor.
  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  /// This constructor parses [JSON] and converts it to a [Post].
  factory Post.fromMap(JSON json) {
    return Post(
      id: (json['id'] as num? ?? 0).toInt(),
      userId: (json['userId'] as num? ?? 0).toInt(),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  /// This method converts the [Post] into a [Map].
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
    };
  }

  /// Id of the post.
  final int id;

  /// The id of the user who made the post.
  final int userId;

  /// The title of the post.
  final String title;

  /// The body text of the post.
  final String body;

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        body,
      ];
}

import 'dart:async';

import 'package:client/models/models.dart';
import 'package:data_persistence/src/data_persistence_exceptions.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

/// This repository handles all the methods regarding to the persistence of data
/// in the app.
class DataPersistenceRepository {
  /// The method that initializes the [Hive] instance.
  Future<void> init() async {
    final directory = await getApplicationSupportDirectory();
    if (!directory.existsSync()) {
      directory.createSync();
    }

    Hive
      ..init(directory.path)
      ..registerAdapter(PostAdapter());

    final completers = <Completer<void>>[];
    for (final key in boxKeys) {
      final completer = Completer<void>();

      if (!Hive.isBoxOpen(key)) {
        completers.add(completer);
        await Hive.openBox<dynamic>(key).catchError((dynamic e) {
          throw DataPersistenceInitException(e as Error);
        });
      }
    }
  }

  /// Get the App Settings box.
  Box<dynamic> get userSessionBox => Hive.box<dynamic>(userSessionKey);

  /// Get the Posts box.
  Box<dynamic> get postsBox => Hive.box<dynamic>(postsKey);

  /// Whether the user is logged in or not.
  bool get isLoggedIn =>
      userSessionBox.get(BoxKeys.isLoggedIn) as bool? ?? false;

  /// Updates the status of the login.
  Future<void> setLoggedIn({
    bool status = false,
  }) async =>
      userSessionBox.put(BoxKeys.isLoggedIn, status);

  /// Return the list of posts saved.
  List<Post>? get posts =>
      (postsBox.get(BoxKeys.offlinePosts) as List?)?.cast<Post>();

  /// Updates the posts.
  Future<void> setPosts(List<Post> posts) async =>
      postsBox.put(BoxKeys.offlinePosts, posts);

  static const userSessionKey = 'user_session';
  static const postsKey = 'posts';

  static const boxKeys = {
    userSessionKey,
    postsKey,
  };
}

/// This class holds all the box keys to access the info inside hive.
class BoxKeys {
  /// The key to access to the user session information.
  static const isLoggedIn = 'is_logged_in';

  /// The key to access to the blog posts saved.
  static const offlinePosts = 'offline_posts';
}

import 'dart:async';

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

    Hive.init(directory.path);

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
  Box<dynamic> get userSession => Hive.box<dynamic>(userSessionKey);

  /// Whether the user is logged in or not.
  bool get isLoggedIn => userSession.get(BoxKeys.isLoggedIn) as bool? ?? false;

  /// Updates the status of the login.
  Future<void> setLoggedIn({
    bool status = false,
  }) async =>
      userSession.put(BoxKeys.isLoggedIn, status);

  static const userSessionKey = 'user_session';

  static const boxKeys = {
    userSessionKey,
  };
}

/// This class holds all the box keys to access the info inside hive.
class BoxKeys {
  /// The key to access to the user session information.
  static const isLoggedIn = 'is_logged_in';
}

import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:client/client.dart' as client_repository;
import 'package:data_persistence/data_persistence.dart';
import 'package:equatable/equatable.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.dataPersistenceRepository,
    required this.client,
  }) : super(const HomeState());

  final DataPersistenceRepository dataPersistenceRepository;
  final client_repository.Client client;

  static const pagination = 15;
  static const searchUsername = 'Leanne Graham';

  Future<void> logout() async {
    await dataPersistenceRepository.setLoggedIn();
  }

  Future<void> init() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final result = await InternetConnectionChecker().hasConnection;
      if (result) {
        emit(state.copyWith(status: HomeStatus.success));
        return;
      }

      final posts = dataPersistenceRepository.posts;

      emit(
        state.copyWith(
          status: HomeStatus.offline,
          posts: posts,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.error));
    }
  }

  Future<void> refresh() async {
    emit(const HomeState());
    await init();
  }

  Future<void> loadPosts() async {
    if (state.isOffline) return;
    emit(state.copyWith(status: HomeStatus.loadingMore));
    try {
      final newPosts = await client
          .getPosts(
        limit: pagination,
        start: state.posts.length,
      )
          .timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          emit(state.copyWith(status: HomeStatus.offline));
          return [];
        },
      );

      if (state.isOffline) return;

      final posts = [...state.posts, ...newPosts];
      await dataPersistenceRepository.setPosts(posts);

      emit(
        state.copyWith(
          status: HomeStatus.success,
          posts: posts,
          hasReachedMax: newPosts.length < pagination,
        ),
      );
    } on HttpException {
      emit(state.copyWith(status: HomeStatus.offline));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.error));
    }
  }

  Future<void> search(String username) async {
    emit(state.copyWith(status: HomeStatus.searching));

    if (username != searchUsername) {
      // We put a delay to simulate searching the user.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      emit(state.copyWith(status: HomeStatus.success, searchResults: []));
      return;
    }

    try {
      final newPosts = await client
          .getPosts(
        limit: pagination,
        start: state.searchResults.length,
        userId: 1,
      )
          .timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          emit(state.copyWith(status: HomeStatus.offline));
          return [];
        },
      );

      final posts = [...state.searchResults, ...newPosts];

      emit(
        state.copyWith(
          status: HomeStatus.success,
          searchResults: posts,
          hasReachedMaxSearches: newPosts.length < pagination,
        ),
      );
    } on HttpException {
      emit(state.copyWith(status: HomeStatus.offline));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.error));
    }
  }
}

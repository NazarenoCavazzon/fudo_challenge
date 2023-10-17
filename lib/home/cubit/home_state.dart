part of 'home_cubit.dart';

enum HomeStatus {
  initial,
  loading,
  success,
  offline,
  loadingMore,
  searching,
  error,
}

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.posts = const <client_repository.Post>[],
    this.searchResults = const <client_repository.Post>[],
    this.hasReachedMax = false,
    this.hasReachedMaxSearches = false,
  });

  bool get isInitial => status == HomeStatus.initial;
  bool get isLoading => status == HomeStatus.loading;
  bool get isSuccess => status == HomeStatus.success;
  bool get isOffline => status == HomeStatus.offline;
  bool get isLoadingMore => status == HomeStatus.loadingMore;
  bool get isSearching => status == HomeStatus.searching;
  bool get isError => status == HomeStatus.error;

  final HomeStatus status;
  final List<client_repository.Post> posts;
  final List<client_repository.Post> searchResults;
  final bool hasReachedMax;
  final bool hasReachedMaxSearches;

  HomeState copyWith({
    HomeStatus? status,
    List<client_repository.Post>? posts,
    List<client_repository.Post>? searchResults,
    bool? hasReachedMax,
    bool? hasReachedMaxSearches,
  }) {
    return HomeState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      searchResults: searchResults ?? this.searchResults,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      hasReachedMaxSearches:
          hasReachedMaxSearches ?? this.hasReachedMaxSearches,
    );
  }

  @override
  String toString() => status.toString();

  @override
  List<Object> get props => [
        status,
        posts,
        searchResults,
        hasReachedMax,
        hasReachedMaxSearches,
      ];
}

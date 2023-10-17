import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fudo_challenge/home/cubit/home_cubit.dart';
import 'package:fudo_challenge/l10n/l10n.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class CustomSearchDelegate extends SearchDelegate<void> {
  CustomSearchDelegate({
    required this.hint,
    required this.cubit,
  });

  final String hint;
  final HomeCubit cubit;
  Timer? _debounce;

  @override
  String get searchFieldLabel => hint;

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);

    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        iconTheme: theme.primaryIconTheme.copyWith(color: Colors.white),
        titleTextStyle: theme.textTheme.titleLarge,
        toolbarTextStyle: theme.textTheme.bodyMedium,
      ),
      hintColor: Colors.grey,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.white,
      ),
      textTheme: const TextTheme(
        titleMedium: TextStyle(color: Colors.white, fontSize: 16),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      cubit.search(query);
    });
    return BlocConsumer<HomeCubit, HomeState>(
      bloc: cubit,
      listener: (context, state) {
        if (state.isOffline || state.isError) {
          close(context, null);
        }
      },
      builder: (context, state) {
        if (state.isSearching) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.black,
            ),
          );
        } else if (state.searchResults.isEmpty) {
          return Center(
            child: Text(
              context.l10n.noSearchResults,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                color: Colors.black,
              ),
            ),
          );
        }

        return InfiniteList(
          itemCount: state.searchResults.length,
          isLoading: state.isSearching,
          separatorBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              height: 1,
              color: Colors.black45,
            );
          },
          loadingBuilder: (context) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              ),
            );
          },
          debounceDuration: const Duration(milliseconds: 300),
          hasReachedMax: state.hasReachedMaxSearches,
          onFetchData: () => cubit.search(query),
          itemBuilder: (context, index) {
            final post = state.posts[index];

            return ListTile(
              dense: true,
              title: Text(
                post.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(post.body),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}

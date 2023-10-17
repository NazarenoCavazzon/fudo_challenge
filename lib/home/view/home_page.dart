import 'package:data_persistence/data_persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fudo_challenge/create_post/create_post.dart';
import 'package:fudo_challenge/home/cubit/home_cubit.dart';
import 'package:fudo_challenge/home/widgets/widgets.dart';
import 'package:fudo_challenge/l10n/l10n.dart';
import 'package:fudo_challenge/login/login.dart';
import 'package:go_router/go_router.dart';
import 'package:json_placeholder_client/json_placeholder_client.dart';
import 'package:ui/ui.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const route = '/home';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(
        dataPersistenceRepository: context.read<DataPersistenceRepository>(),
        jsonPlaceholderClient: context.read<JsonPlaceholderClient>(),
      )..init(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.edit,
          color: Colors.white,
          size: 30,
        ),
        onPressed: () => onFABPressed(context),
      ),
      appBar: CustomAppbar(
        title: context.l10n.homePage,
        preffixIcon: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () => onLogout(context),
          icon: const Icon(
            Icons.logout,
            color: Colors.white,
            size: 24,
          ),
        ),
        suffixIcon: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () => onSearchPressed(context),
          icon: const Icon(
            Icons.search,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      body: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state.isError) {
            CustomSnackbar.showToast(
              context: context,
              status: SnackbarStatus.error,
              title: context.l10n.unknownError,
            );
          } else if (state.isOffline) {
            CustomSnackbar.showToast(
              context: context,
              status: SnackbarStatus.warning,
              title: context.l10n.offlineMode,
            );
          }
        },
        builder: (context, state) {
          if ((state.isLoadingMore && state.posts.isEmpty) || state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            );
          } else if (state.isError) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    context.l10n.unknownError,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: context.read<HomeCubit>().refresh,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.refreshPosts.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const Icon(
                        Icons.refresh,
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return RefreshIndicator(
            color: Colors.black,
            onRefresh: context.read<HomeCubit>().refresh,
            child: InfiniteList(
              itemCount: state.posts.length,
              isLoading: state.isLoadingMore && !state.isOffline,
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
              hasReachedMax: state.hasReachedMax,
              onFetchData: context.read<HomeCubit>().loadPosts,
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
            ),
          );
        },
      ),
    );
  }

  Future<void> onFABPressed(BuildContext context) async {
    final result = await context.pushNamed<bool>(CreatePostPage.route);

    if ((result ?? false) && mounted) {
      CustomSnackbar.showToast(
        context: context,
        status: SnackbarStatus.success,
        title: context.l10n.postHasBeenCreated,
      );
    }
  }

  Future<void> onLogout(BuildContext context) async {
    await context.read<HomeCubit>().logout();
    if (!mounted) return;
    context.goNamed(LoginPage.route);
  }

  void onSearchPressed(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    if (cubit.state.isOffline) {
      CustomSnackbar.showToast(
        context: context,
        status: SnackbarStatus.warning,
        title: context.l10n.offlineMode,
      );
      return;
    }

    showSearch(
      context: context,
      delegate: CustomSearchDelegate(
        hint: context.l10n.username,
        cubit: cubit,
      ),
    );
  }
}

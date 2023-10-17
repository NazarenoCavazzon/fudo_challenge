import 'package:bloc/bloc.dart';
import 'package:client/client.dart';
import 'package:equatable/equatable.dart';

part 'create_post_state.dart';

class CreatePostCubit extends Cubit<CreatePostState> {
  CreatePostCubit({
    required this.client,
  }) : super(const CreatePostState());

  final Client client;

  Future<void> createPost({
    required String title,
    required String body,
  }) async {
    emit(state.copyWith(status: CreatePostStatus.loading));

    try {
      await client.createPost(title: title, body: body);
      emit(state.copyWith(status: CreatePostStatus.success));
    } catch (e) {
      emit(state.copyWith(status: CreatePostStatus.error));
    }
  }
}

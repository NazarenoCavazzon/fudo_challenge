part of 'create_post_cubit.dart';

enum CreatePostStatus {
  initial,
  loading,
  success,
  error,
}

class CreatePostState extends Equatable {
  const CreatePostState({
    this.status = CreatePostStatus.initial,
  });

  bool get isInitial => status == CreatePostStatus.initial;
  bool get isLoading => status == CreatePostStatus.loading;
  bool get isSuccess => status == CreatePostStatus.success;
  bool get isError => status == CreatePostStatus.error;

  final CreatePostStatus status;

  CreatePostState copyWith({
    CreatePostStatus? status,
  }) {
    return CreatePostState(
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [
        status,
      ];
}

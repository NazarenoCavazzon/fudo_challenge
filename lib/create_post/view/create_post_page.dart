import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fudo_challenge/create_post/cubit/create_post_cubit.dart';
import 'package:fudo_challenge/l10n/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:json_placeholder_client/json_placeholder_client.dart';
import 'package:ui/ui.dart';

class CreatePostPage extends StatelessWidget {
  const CreatePostPage({super.key});

  static const route = '/create-post';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreatePostCubit(
        client: context.read<JsonPlaceholderClient>(),
      ),
      child: const CreatePostView(),
    );
  }
}

class CreatePostView extends StatefulWidget {
  const CreatePostView({super.key});

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: BlocListener<CreatePostCubit, CreatePostState>(
          listener: _blocListeners,
          child: Scaffold(
            appBar: CustomAppbar(title: context.l10n.createPost),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const Spacer(),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      iconColor: Colors.black,
                      labelText: context.l10n.title,
                      prefixIcon: const Icon(Icons.title),
                    ),
                    validator: onValidateField,
                  ),
                  TextFormField(
                    controller: _bodyController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      iconColor: Colors.black,
                      labelText: context.l10n.body,
                      prefixIcon: const Icon(Icons.description),
                    ),
                    validator: onValidateField,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.l10n.postCreationWarning,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                    ),
                  ),
                  const Spacer(),
                  BlocBuilder<CreatePostCubit, CreatePostState>(
                    buildWhen: (previous, current) {
                      return previous.isLoading != current.isLoading;
                    },
                    builder: (context, state) {
                      return CustomButton(
                        text: context.l10n.createPost,
                        loading: state.isLoading,
                        onPressed: createPost,
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _blocListeners(BuildContext context, CreatePostState state) {
    if (state.isSuccess) {
      context.pop(true);
    } else if (state.isError) {
      CustomSnackbar.showToast(
        context: context,
        status: SnackbarStatus.error,
        title: context.l10n.anErrorOcurredCreatingThePost,
      );
    }
  }

  String? onValidateField(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.textFormFieldEmptyError;
    }
    return null;
  }

  void createPost() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    context.read<CreatePostCubit>().createPost(
          title: _titleController.text,
          body: _bodyController.text,
        );
  }
}

import 'package:data_persistence/data_persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fudo_challenge/home/home.dart';
import 'package:fudo_challenge/l10n/l10n.dart';
import 'package:fudo_challenge/login/cubit/login_cubit.dart';
import 'package:fudo_challenge/login/utils/text_form_validator.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const route = '/login';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(
        dataPersistenceRepository: context.read<DataPersistenceRepository>(),
      ),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: CustomAppbar(title: context.l10n.loginPage),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BlocListener<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state.isBadCredentials) {
                CustomSnackbar.showToast(
                  context: context,
                  status: SnackbarStatus.error,
                  title: context.l10n.badCredentials,
                );
              } else if (state.isError) {
                CustomSnackbar.showToast(
                  context: context,
                  status: SnackbarStatus.warning,
                  title: context.l10n.unknownError,
                );
              } else if (state.isSuccess) {
                CustomSnackbar.showToast(
                  context: context,
                  status: SnackbarStatus.success,
                  title: context.l10n.validCredentials,
                );

                context.goNamed(HomePage.route);
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: AutofillGroup(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          autofillHints: const [AutofillHints.username],
                          decoration: InputDecoration(
                            iconColor: Colors.black,
                            labelText: context.l10n.username,
                            prefixIcon: const Icon(Icons.person),
                          ),
                          validator: onValidateField,
                        ),
                        TextFormField(
                          controller: _passwordController,
                          autofillHints: const [AutofillHints.password],
                          decoration: InputDecoration(
                            iconColor: Colors.black,
                            labelText: context.l10n.password,
                            prefixIcon: const Icon(Icons.lock),
                          ),
                          obscureText: true,
                          validator: onValidateField,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                BlocBuilder<LoginCubit, LoginState>(
                  builder: (context, state) {
                    return CustomButton(
                      text: context.l10n.login,
                      loading: state.isLoading,
                      onPressed: login,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? onValidateField(String? value) => textFormValidator(value, context);

  void login() {
    if (_formKey.currentState!.validate()) {
      context.read<LoginCubit>().login(
            username: _usernameController.text,
            password: _passwordController.text,
          );
    }
  }
}

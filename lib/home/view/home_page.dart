import 'package:flutter/material.dart';
import 'package:fudo_challenge/home/widgets/widgets.dart';
import 'package:fudo_challenge/l10n/l10n.dart';
import 'package:ui/ui.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const route = '/home';

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
        onPressed: () {},
      ),
      appBar: CustomAppbar(
        title: context.l10n.homePage,
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
      body: Column(),
    );
  }

  void onSearchPressed(BuildContext context) {
    showSearch(
      context: context,
      delegate: CustomSearchDelegate(),
    );
  }
}

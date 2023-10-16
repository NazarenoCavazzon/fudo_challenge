import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.text,
    required this.onPressed,
    this.loading = false,
    super.key,
  });

  final String text;
  final bool loading;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith(
            (states) => Colors.black,
          ),
          overlayColor: MaterialStateProperty.resolveWith(
            (states) {
              return states.contains(MaterialState.pressed)
                  ? Colors.white.withOpacity(0.2)
                  : null;
            },
          ),
        ),
        onPressed: onPressed,
        child: loading
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

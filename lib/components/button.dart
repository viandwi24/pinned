import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinned/constant.dart';
import 'package:pinned/screens/create_screen.dart';

class PinnedButton extends StatelessWidget {
  const PinnedButton({
    super.key,
    required this.title,
    required this.icon,
    this.margin,
    this.onPressed,
    this.enabled = true,
  });

  final String title;
  final IconData icon;
  final EdgeInsets? margin;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: TextButton(
        autofocus: enabled,
        style: ElevatedButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: kPrimaryColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Icon(
                    icon,
                    color: Colors.white,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: kDarkTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        onPressed: () {
          if (!enabled) {
            return;
          }
          onPressed!();
        },
      ),
    );
  }
}

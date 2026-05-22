import 'package:flutter/material.dart';

void showSidePanel(BuildContext context, Widget child) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "SidePanel",
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: child,
        ),
      );
    },
    transitionBuilder: (_, anim, __, child) {
      final offsetAnim = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
      ));

      return SlideTransition(
        position: offsetAnim,
        child: child,
      );
    },
  );
}
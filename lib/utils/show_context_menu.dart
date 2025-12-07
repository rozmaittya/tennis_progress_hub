import 'package:flutter/material.dart';

//universal popup menu
Future<String?> showContextMenu({
  required BuildContext context,
  required Offset tapPosition,
  required List<PopupMenuEntry<String>> items
}) {
  return showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          tapPosition.dx,
          tapPosition.dy,
          tapPosition.dx+1,
          tapPosition.dy+1
      ),
      items: items
  );
}
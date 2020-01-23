
import 'package:flutter/material.dart';

mixin ScreenWithSnackbar {
  @protected
  void showSnackBar(BuildContext context, String message) {
      final snackBar = SnackBar(
        content: Text(message),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    }
}
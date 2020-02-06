
import 'package:flutter/material.dart';

mixin ScreenWithSnackbar {
  /// context needs to come from a Scafold widget */
  @protected
  void showSnackBar(BuildContext context, String message) {
      final snackBar = SnackBar(
        content: Text(message),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    }
}

import 'package:flutter/material.dart';
import 'dart:io';

class Utils {
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());
  }
}

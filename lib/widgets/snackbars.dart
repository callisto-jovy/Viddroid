import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

SnackBar _defaultBar(Widget content) => SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: content);

SnackBar successSnackbar(String message) => _defaultBar(
      AwesomeSnackbarContent(
        title: 'Success!',
        message: message,
        contentType: ContentType.success,
      ),
    );

SnackBar errorSnackbar(String message) => _defaultBar(
      AwesomeSnackbarContent(
        title: 'Oh Snap!',
        message: message,

        /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
        contentType: ContentType.failure,
      ),
    );

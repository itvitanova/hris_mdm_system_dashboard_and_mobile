import 'package:flutter/material.dart';

/// Form controllers container for request form text and search inputs
class RequestFormControllers {
  final formKey = GlobalKey<FormState>();
  final title = TextEditingController();
  final description = TextEditingController();
  final amount = TextEditingController();
  final hours = TextEditingController();
  final location = TextEditingController();
  late final kindSearch = TextEditingController();

  RequestFormControllers({String initialKind = 'Cuti'}) {
    kindSearch.text = initialKind;
  }

  void dispose() {
    title.dispose();
    description.dispose();
    amount.dispose();
    hours.dispose();
    location.dispose();
    kindSearch.dispose();
  }
}

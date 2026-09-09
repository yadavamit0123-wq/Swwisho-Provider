import 'dart:math';
import 'package:demandium_provider/utils/core_export.dart';
import 'package:get/get.dart';


class FieldItemView extends StatelessWidget {
  final MethodField? methodField;
  final Map<String, TextEditingController>? textControllers;
  final Map<String, FocusNode>? focusNodes;
  const FieldItemView({super.key, this.methodField, this.textControllers, this.focusNodes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        CustomTextField(
          controller: textControllers![methodField!.inputName],
          focusNode: focusNodes![methodField!.inputName],
          hintText:  methodField!.placeholder??'',
          inputType:  _getType(methodField!.inputType??""),
          isPassword: methodField!.inputType == 'password',
          title: methodField!.inputName!.replaceAll('_', ' ').formattedUpperCase(),
          onValidate: (value){
            return FormValidationHelper().validateDynamicTextFiled(value!, methodField!.placeholder?.replaceAll("_", " ").capitalizeFirst ?? "");
          },
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge,),
      ],
    );
  }

  TextInputType _getType(String type) {
    switch(type) {
      case 'number': return TextInputType.number;
      case 'date': return TextInputType.datetime;
      case 'password': return TextInputType.visiblePassword;
      case 'email': return  TextInputType.emailAddress;
      case 'phone': return TextInputType.phone;
      default: return TextInputType.text;
    }

  }
}

extension StringExtension on String {
  String formattedUpperCase() => replaceAllMapped(
      RegExp(r'(?<= |-|^).'), (match) => match[0]!.toUpperCase());
}

const indexNotFound = -1;


class DateInputFormatter extends TextInputFormatter {
  final String _placeholder = '--/----';
  TextEditingValue? _lastNewValue;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (oldValue.text.isEmpty) {
      oldValue = oldValue.copyWith(
        text: _placeholder,
      );
      newValue = newValue.copyWith(
        text: _fillInputToPlaceholder(newValue.text),
      );
      return newValue;
    }

    if (newValue == _lastNewValue) {
      return oldValue;
    }
    _lastNewValue = newValue;

    int offset = newValue.selection.baseOffset;

    if (offset > 7) {
      return oldValue;
    }

    if (oldValue.text == newValue.text && oldValue.text.isNotEmpty) {
      return newValue;
    }

    final String oldText = oldValue.text;
    final String newText = newValue.text;
    String? resultText;

    int index = _indexOfDifference(newText, oldText);
    if (oldText.length < newText.length) {

      String newChar = newText[index];
      if (index == 2 ) {
        index++;
        offset++;
      }
      resultText = oldText.replaceRange(index, index + 1, newChar);
      if (offset == 2) {
        offset++;
      }
    } else if (oldText.length > newText.length) {
      if (oldText[index] != '/') {
        resultText = oldText.replaceRange(index, index + 1, '-');
        if (offset == 2) {
          offset--;
        }
      } else {
        resultText = oldText;
      }
    }

    return oldValue.copyWith(
      text: resultText,
      selection: TextSelection.collapsed(offset: offset),
      composing: defaultTargetPlatform == TargetPlatform.iOS
          ? const TextRange(start: 0, end: 0)
          : TextRange.empty,
    );
  }

  int _indexOfDifference(String? cs1, String? cs2) {
    if (cs1 == cs2) {
      return indexNotFound;
    }
    if (cs1 == null || cs2 == null) {
      return 0;
    }
    int i;
    for (i = 0; i < cs1.length && i < cs2.length; ++i) {
      if (cs1[i] != cs2[i]) {
        break;
      }
    }
    if (i < cs2.length || i < cs1.length) {
      return i;
    }
    return indexNotFound;
  }

  String _fillInputToPlaceholder(String? input) {
    if (input == null || input.isEmpty) {
      return _placeholder;
    }
    String result = _placeholder;
    final index = [0, 1, 3, 4, 6, 7, 8, 9];
    final length = min(index.length, input.length);
    for (int i = 0; i < length; i++) {
      result = result.replaceRange(index[i], index[i] + 1, input[i]);
    }
    return result;
  }
}
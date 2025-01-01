import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_effeciency/provider/radio_provider.dart';

class RadioWidget extends ConsumerWidget {
  const RadioWidget({
    super.key,
    required this.titleRadio,
    required this.categoryColor,
    required this.valueInput,
    required this.onChangedValue,
  });

  final String titleRadio;
  final Color categoryColor;
  final int valueInput;
  final ValueChanged<int?> onChangedValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radio = ref.watch(radioProvider);
    return RadioListTile(
      activeColor: categoryColor,
      dense: true,
      fillColor: WidgetStateProperty.all(categoryColor),
      contentPadding: EdgeInsets.zero,
      value: valueInput,
      groupValue: radio,
      onChanged: (value) {
        onChangedValue(value);
      },
      title: Transform.translate(
        offset: const Offset(-20, 0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            titleRadio,
            style: TextStyle(
              fontSize: 11,
              color: categoryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

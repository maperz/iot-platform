import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LastUpdateText extends StatelessWidget {
  final DateTime updateTime;
  const LastUpdateText(this.updateTime, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      DateFormat("HH:mm:ss dd.MM.y").format(updateTime.toLocal()),
      style: TextStyle(fontSize: 12),
    );
  }
}

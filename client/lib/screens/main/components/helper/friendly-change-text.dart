import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FriendlyChangeText extends StatefulWidget {
  final DateTime updateTime;
  const FriendlyChangeText(this.updateTime, {Key? key}) : super(key: key);

  @override
  _FriendlyChangeTextState createState() => _FriendlyChangeTextState();
}

class _FriendlyChangeTextState extends State<FriendlyChangeText> {
  late String _timeInfo;
  late String _timeDetail;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _refreshTime();
    _timer = Timer.periodic(Duration(seconds: 30), (timer) => _refreshTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Tooltip(
        message: _timeDetail,
        child: SizedBox(
          child: Text(
            _timeInfo,
            style: TextStyle(fontSize: 12),
          ),
        ),
      ),
    ]);
  }

  void _refreshTime() {
    setState(() {
      final updatedTime = widget.updateTime.toLocal();
      _timeDetail = DateFormat("HH:mm:ss, dd.MM.y").format(updatedTime);
      _timeInfo = _getFriendlyTimeInfo();
    });
  }

  String _getFriendlyTimeInfo() {
    final updatedTime = widget.updateTime.toLocal();
    final now = DateTime.now();
    final diff = now.difference(updatedTime);

    if (diff.isNegative || diff < Duration(minutes: 1)) {
      return "Few seconds ago";
    }

    final pluralization = (int n) => n > 1 ? "s" : "";

    if (diff < Duration(hours: 1)) {
      return "${diff.inMinutes} minute${pluralization(diff.inMinutes)} ago";
    }

    if (diff < Duration(hours: 3)) {
      return "${diff.inHours} hour${pluralization(diff.inHours)} ago";
    }

    if (updatedTime.day == now.day &&
        updatedTime.month == now.month &&
        updatedTime.year == now.year) {
      return "Today, " + DateFormat("HH:mm").format(updatedTime);
    }

    final yesterday = now.subtract(Duration(days: 1));
    if (updatedTime.day == yesterday.day &&
        updatedTime.month == yesterday.month &&
        updatedTime.year == yesterday.year) {
      return "Yesterday, " + DateFormat("HH:mm").format(updatedTime);
    }

    return DateFormat("HH:mm, dd.MM.y").format(widget.updateTime);
  }
}

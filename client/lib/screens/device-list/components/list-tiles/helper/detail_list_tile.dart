import 'package:flutter/material.dart';

class DetailListTile extends StatelessWidget {
  final bool active;
  final EdgeInsets? tilePadding;
  final Widget leading;
  final Widget title;
  final Widget subtitle;
  final Widget child;

  const DetailListTile(
      {required this.leading,
      required this.title,
      required this.subtitle,
      required this.active,
      required this.child,
      this.tilePadding,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        key: key,
        tilePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        leading: leading,
        title: Opacity(opacity: active ? 1.0 : 0.38, child: title),
        subtitle: Opacity(opacity: active ? 1.0 : 0.38, child: subtitle),
        children: [child]);
  }
}

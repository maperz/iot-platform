import 'package:flutter/material.dart';

class SkeletonTile extends StatelessWidget {
  const SkeletonTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      leading: Skeleton(
        width: 36,
        height: 36,
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Skeleton(
          height: 20,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Skeleton(
          height: 12,
        ),
      ),
      trailing: Skeleton(
        width: 24,
        height: 24,
      ),
    ));
  }
}

class Skeleton extends StatefulWidget {
  final double height;
  final double width;

  Skeleton({Key? key, this.height = 20, this.width = 200}) : super(key: key);

  createState() => SkeletonState();
}

class SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _gradientPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: Duration(milliseconds: 1500), vsync: this);

    _gradientPosition = Tween<double>(
      begin: -3,
      end: 10,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    )..addListener(() {
        setState(() {});
      });

    _controller.repeat();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment(_gradientPosition.value, 0),
              end: Alignment(-1, 0),
              colors: [Colors.black12, Colors.black26, Colors.black12])),
    );
  }
}

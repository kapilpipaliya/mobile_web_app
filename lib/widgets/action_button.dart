import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final Function() onTap;
  final Widget icon;
  final double? radius;

  const ActionButton(
      {Key? key, required this.onTap, required this.icon, this.radius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius ?? 25),
      child: Container(
        width: radius != null ? (radius! * 2) : 50,
        height: radius != null ? (radius! * 2) : 50,
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
        child: icon,
      ),
    );
  }
}

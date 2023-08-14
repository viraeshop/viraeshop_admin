import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

class CylindricalButton extends StatelessWidget {
  const CylindricalButton({
    Key? key,
    required this.deleteColor,
    required this.quantity,
    required this.onDelete,
    required this.onAdd,
    required this.onReduce,
  }) : super(key: key);
  final String quantity;
  final Color deleteColor;
  final void Function()? onAdd;
  final void Function()? onReduce;
  final void Function()? onDelete;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 125.0,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.white24.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10.0),
          ),
          //padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: onAdd,
                icon: const Icon(FontAwesomeIcons.plus),
                color: kBlackColor,
                iconSize: 20.0,
              ),
              Text(
                quantity,
                style: kSansTextStyleBigBlack,
              ),
              IconButton(
                onPressed: onReduce,
                icon: const Icon(FontAwesomeIcons.minus),
                color: kBlackColor,
                iconSize: 20.0,
              ),
            ],
          ),
        ),
        OpaqueButton(
          onTap: onDelete,
          color: deleteColor,
          icon: Icons.delete,
        )
      ],
    );
  }
}

class OpaqueButton extends StatelessWidget {
  const OpaqueButton({
    Key? key,
    required this.onTap,
    required this.color,
    required this.icon,
  }) : super(key: key);

  final void Function()? onTap;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40.0,
        width: 40.0,
        decoration: BoxDecoration(
          color: Colors.white24.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.all(10.0),
        child: Align(
          child: Icon(
            icon,
            color: color,
            size: 20.0,
          ),
        ),
      ),
    );
  }
}

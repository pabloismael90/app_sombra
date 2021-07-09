import 'package:flutter/material.dart';

class ButtonMainStyle extends StatelessWidget {
    final String? title;
    final IconData? icon;
    final Function? press;
    const ButtonMainStyle({
        Key? key,
        this.title,
        this.icon,
        this.press,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return ElevatedButton.icon(
            icon:Icon(icon, size: 20,),
            label: Text(title!),
            onPressed:press as void Function()?,
        );
    }
}



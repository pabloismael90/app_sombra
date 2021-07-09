import 'package:flutter/material.dart';

class TitulosPages  extends StatelessWidget {
    final String? titulo;
    const TitulosPages({
        Key? key,
        this.titulo,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Container(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: Text(
                    titulo!,
                    style: Theme.of(context).textTheme
                        .headline5!
                        .copyWith(fontWeight: FontWeight.w900)
                ),
            )
        );
    }
}







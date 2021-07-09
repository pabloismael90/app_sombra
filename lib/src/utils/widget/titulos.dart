import 'package:flutter/material.dart';

import '../constants.dart';

class TitulosPages  extends StatelessWidget {
    final String? titulo;
    const TitulosPages({
        Key? key,
        this.titulo,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Container(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                            titulo!,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                        ),
                    ),
                    Row(
                        children: List.generate(
                            150~/2, (index) => Expanded(
                                child: Container(
                                    color: index%2==0?Colors.transparent
                                    :kShadowColor2,
                                    height: 2,
                                ),
                            )
                        ),
                    ),
                ],
            ),
        );
        
        
        
    }
}







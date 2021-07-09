import 'package:app_sombra/src/models/finca_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:app_sombra/src/models/selectValue.dart' as selectMap;
import '../constants.dart';


class CardList extends StatelessWidget {
    final Size? size;  
    final Finca? finca;
    final String? icon;
    
    const CardList({
        Key? key,
        this.size,
        this.finca,
        this.icon

    }) : super(key: key);

    @override
    Widget build(BuildContext context) {

        
        String? labelMedida;
        final item = selectMap.dimenciones().firstWhere((e) => e['value'] == '${finca!.tipoMedida}');
        labelMedida  = item['label'];


        return Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                        BoxShadow(
                                color: Color(0xFF3A5160)
                                    .withOpacity(0.05),
                                offset: const Offset(1.1, 1.1),
                                blurRadius: 17.0),
                        ],
                ),
                child: Column(
                    children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                                Padding(
                                    padding: EdgeInsets.only(right: 20),
                                    child: SvgPicture.asset('assets/icons/finca.svg', height:60,),
                                ),
                                Flexible(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                        
                                            Padding(
                                                padding: EdgeInsets.only(top: 10, bottom: 10.0),
                                                child: Text(
                                                    "${finca!.nombreFinca}",
                                                    style: Theme.of(context).textTheme.headline6,
                                                ),
                                            ),
                                            Text(
                                                "${finca!.nombreProductor}",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(color: kLightBlackColor),
                                            ),
                                            Padding(
                                                padding: EdgeInsets.only(top: 10, bottom: 10.0),
                                                child: Text(
                                                    "${finca!.areaFinca} $labelMedida",
                                                    style: TextStyle(color: kLightBlackColor),
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                                
                                
                            ],
                        ),
                        Divider(),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                                Icon(Icons.touch_app, color: kRedColor,),
                                Text(' Tocar para agregar parcelas', style: TextStyle(color: kRedColor),)
                            ],
                        )
                    ],
                ),
        );
    }
}


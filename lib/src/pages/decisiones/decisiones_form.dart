import 'package:app_sombra/src/models/finca_model.dart';
import 'package:app_sombra/src/models/parcela_model.dart';
import 'package:app_sombra/src/models/testsombra_model.dart';
import 'package:app_sombra/src/models/selectValue.dart' as selectMap;
import 'package:app_sombra/src/providers/db_provider.dart';
import 'package:app_sombra/src/utils/constants.dart';
import 'package:app_sombra/src/utils/widget/titulos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';




class DesicionesPage extends StatefulWidget {
    DesicionesPage({Key key}) : super(key: key);

    @override
    _DesicionesPageState createState() => _DesicionesPageState();
}

class _DesicionesPageState extends State<DesicionesPage> {
    @override
    Widget build(BuildContext context) {

        TestSombra sombra = ModalRoute.of(context).settings.arguments;

        Future _getdataFinca() async{
            Finca finca = await DBProvider.db.getFincaId(sombra.idFinca);
            Parcela parcela = await DBProvider.db.getParcelaId(sombra.idLote);
            //List<Paso> pasos = await DBProvider.db.getTodasPasoIdTest(plagaTest.id);
            return [finca, parcela];
        }

        
        return Scaffold(
            appBar: AppBar(),
            body:FutureBuilder(
            future:  _getdataFinca(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                    }

                    List<Widget> pageItem = List<Widget>();
                    Finca finca = snapshot.data[0];
                    Parcela parcela = snapshot.data[1];

                    pageItem.add(_principalData(finca, parcela));

                    return Column(
                        children: [
                            Container(
                                child: Column(
                                    children: [
                                        TitulosPages(titulo: 'Toma de Decisiones'),
                                        Divider(),
                                        Padding(
                                            padding: EdgeInsets.symmetric(vertical: 10),
                                            child: Text(
                                                "Deslice hacia la derecha para continuar con el formulario",
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context).textTheme
                                                    .headline5
                                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 16)
                                            ),
                                        ),
                                    ],
                                )
                            ),
                            Expanded(
                                
                                child: Swiper(
                                    itemBuilder: (BuildContext context, int index) {
                                        return pageItem[index];
                                    },
                                    itemCount: pageItem.length,
                                    viewportFraction: 1,
                                    loop: false,
                                    scale: 1,
                                ),
                            ),
                        ],
                    );
                },
            ),
            
        );
    }


    Widget _principalData(Finca finca, Parcela parcela){
    
                return Container(
                    decoration: BoxDecoration(
                        
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                        children: [
                            _dataFincas( context, finca, parcela),

                            Expanded(
                                child: SingleChildScrollView(
                                    child: Container(
                                        color: Colors.white,
                                        child: Column(
                                            children: [
                                                Padding(
                                                    padding: EdgeInsets.symmetric(vertical: 10),
                                                    child: InkWell(
                                                        child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                                Container(                                                                    
                                                                    child: Text(
                                                                        "Porcentaje de cobertura",
                                                                        textAlign: TextAlign.center,
                                                                        style: Theme.of(context).textTheme
                                                                            .headline5
                                                                            .copyWith(fontWeight: FontWeight.w600, fontSize: 18)
                                                                    ),
                                                                ),
                                                                Padding(
                                                                    padding: EdgeInsets.only(left: 10),
                                                                    child: Icon(
                                                                        Icons.info_outline_rounded,
                                                                        color: Colors.green,
                                                                        size: 22.0,
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                        onTap: () => _dialogText(context),
                                                    ),
                                                ),
                                                
                                                Container(
                                                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                                    width: double.infinity,
                                                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(10),
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
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                children: [
                                                                    Expanded(
                                                                        child: Container(
                                                                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                                                                            child: Text('Tipos', textAlign: TextAlign.start, style: Theme.of(context).textTheme.headline6
                                                                                                    .copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
                                                                        ),
                                                                    ),
                                                                    
                                                                    Container(
                                                                        width: 100,
                                                                        child: Text('Cobertura', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline6
                                                                                .copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
                                                                    ),
                                                                ],
                                                            ),
                                                            Divider(),
                                                            //_countPlagas(plagaid, 1),
                                                        ],
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                ),
                            )
                            
                        ],
                    ),
                );
                

            
    }

    Widget _dataFincas( BuildContext context, Finca finca, Parcela parcela ){
        String labelMedidaFinca;
        String labelvariedad;

        final item = selectMap.dimenciones().firstWhere((e) => e['value'] == '${finca.tipoMedida}');
        labelMedidaFinca  = item['label'];

        

        final itemvariedad = selectMap.variedadCacao().firstWhere((e) => e['value'] == '${parcela.variedadCacao}');
        labelvariedad  = itemvariedad['label'];

        return Container(
                    
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                    BoxShadow(
                            color: Color(0xFF3A5160)
                                .withOpacity(0.05),
                            offset: const Offset(1.1, 1.1),
                            blurRadius: 17.0),
                    ],
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                    
                    Flexible(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                            
                                Padding(
                                    padding: EdgeInsets.only(top: 10, bottom: 10.0),
                                    child: Text(
                                        "${finca.nombreFinca}",
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: Theme.of(context).textTheme.headline6,
                                    ),
                                ),
                                Padding(
                                    padding: EdgeInsets.only( bottom: 10.0),
                                    child: Text(
                                        "${parcela.nombreLote}",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: kTextColor, fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                ),
                                Padding(
                                    padding: EdgeInsets.only( bottom: 10.0),
                                    child: Text(
                                        "Productor ${finca.nombreProductor}",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: kTextColor, fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                ),

                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                        Flexible(
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                    Padding(
                                                        padding: EdgeInsets.only( bottom: 10.0),
                                                        child: Text(
                                                            "Área Finca: ${finca.areaFinca} ($labelMedidaFinca)",
                                                            style: TextStyle(color: kTextColor, fontSize: 14, fontWeight: FontWeight.bold),
                                                        ),
                                                    ),
                                                    Padding(
                                                        padding: EdgeInsets.only( bottom: 10.0),
                                                        child: Text(
                                                            "N de Plantas: ${parcela.numeroPlanta}",
                                                            style: TextStyle(color: kTextColor, fontSize: 14, fontWeight: FontWeight.bold),
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                        Flexible(
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                    Padding(
                                                        padding: EdgeInsets.only( bottom: 10.0, left: 20),
                                                        child: Text(
                                                            "Área Parcela: ${parcela.areaLote} ($labelMedidaFinca)",
                                                            style: TextStyle(color: kTextColor, fontSize: 14, fontWeight: FontWeight.bold),
                                                        ),
                                                    ),
                                                    Padding(
                                                        padding: EdgeInsets.only( bottom: 10.0, left: 20),
                                                        child: Text(
                                                            "Variedad: $labelvariedad ",
                                                            style: TextStyle(color: kTextColor, fontSize: 14, fontWeight: FontWeight.bold),
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        )
                                    ],
                                )

                                
                            ],  
                        ),
                    ),
                ],
            ),
        );

    } 








}


Future<void> _dialogText(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
            return AlertDialog(
                title: Text('Titulo'),
                content: SingleChildScrollView(
                    child: ListBody(
                        children: <Widget>[
                        Text('Texto para breve explicacion'),
                        ],
                    ),
                ),
                actions: <Widget>[
                    TextButton(
                        child: Text('Cerrar'),
                        onPressed: () {
                        Navigator.of(context).pop();
                        },
                    ),
                ],
            );
        },
    );
}

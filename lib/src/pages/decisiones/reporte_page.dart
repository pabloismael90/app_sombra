import 'package:app_sombra/src/models/decisiones_model.dart';
import 'package:app_sombra/src/models/testsombra_model.dart';
//import 'package:app_sombra/src/pages/decisiones/pdf_view.dart';
import 'package:app_sombra/src/providers/db_provider.dart';
import 'package:app_sombra/src/models/selectValue.dart' as selectMap;
import 'package:app_sombra/src/utils/constants.dart';
import 'package:app_sombra/src/utils/widget/titulos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class ReportePage extends StatefulWidget {


  @override
  _ReportePageState createState() => _ReportePageState();
}

class _ReportePageState extends State<ReportePage> {
    final List<Map<String, dynamic>>  itemEspecie = selectMap.especies();
    final List<Map<String, dynamic>>  itemDensidad  = selectMap.densidadSombra();
    final List<Map<String, dynamic>>  itemForma  = selectMap.formaArboles();
    final List<Map<String, dynamic>>  itemCompetencia  = selectMap.competenciaCacao();
    final List<Map<String, dynamic>>  itemArreglo = selectMap.arregloArboles();
    final List<Map<String, dynamic>>  itemCantidad = selectMap.cantidadHoja();
    final List<Map<String, dynamic>>  itemCalidad = selectMap.calidadHoja();
    final List<Map<String, dynamic>>  itemMejora = selectMap.accionesMejora();
    final List<Map<String, dynamic>>  itemDominio = selectMap.dominioSombra();
    final List<Map<String, dynamic>>  itemReduccion = selectMap.accionesReduccion();
    final List<Map<String, dynamic>>  itemAumento = selectMap.accionesAumento();
    final List<Map<String, dynamic>>  itemMeses = selectMap.listMeses();
    
    Widget textFalse = Text('0.00%', textAlign: TextAlign.center);
    Widget textmt= Text('0', textAlign: TextAlign.center);
    final Map checksPrincipales = {};
    double areaEstacion;

    
    

    Future getdata(String idTest) async{

        List<Decisiones> listDecisiones = await DBProvider.db.getDecisionesIdTest(idTest);
        TestSombra testSombra = await DBProvider.db.getTestId(idTest);

        Finca finca = await DBProvider.db.getFincaId(testSombra.idFinca);
        Parcela parcela = await DBProvider.db.getParcelaId(testSombra.idLote);

        return [listDecisiones, finca, parcela, testSombra];
    }

     Future<double> _coberturaByEstacion(String idSombra, int estacion) async{
        double coberturaEstacion = await DBProvider.db.getCoberturaByEstacion(idSombra, estacion);
        return coberturaEstacion;
    }

    Future<double> _coberturaPromedio(String idSombra) async{
        double coberturaPromedio = await DBProvider.db.getCoberturaPromedio(idSombra);
        return coberturaPromedio;
    }

    Future<int> _riquezaByEstacion(String idSombra, int estacion) async{
        int countEspecies = await DBProvider.db.getConteoByEstacion(idSombra, estacion);
        return countEspecies;
    }

    Future<int> _riquezaTotal(String idSombra) async{
        int countEspecies = await DBProvider.db.getConteoEspecies(idSombra);
        return countEspecies;
    }

    Future<int> _arbolesByEstacion(String idSombra, int estacion) async{
        int countArboles = await DBProvider.db.getArbolesByEstacion(idSombra, estacion);
        return countArboles;
    }

    Future<double> _arbolesPromedio(String idSombra) async{
        double countArboles = await DBProvider.db.getArbolesPromedio(idSombra);
        return countArboles;
    }

    Future<List<Map<String, dynamic>>> _countByEspecie(String idSombra) async{
        List<Map<String, dynamic>> listEspecies = await DBProvider.db.dominanciaEspecie(idSombra);
        return listEspecies;
    }

    

    @override
    Widget build(BuildContext context) {
        String idTest = ModalRoute.of(context).settings.arguments;

        return Scaffold(
            appBar: AppBar(),
            body: FutureBuilder(
                future: getdata(idTest),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                    }
                    List<Widget> pageItem = List<Widget>();
                    Finca finca = snapshot.data[1];
                    Parcela parcela = snapshot.data[2];
                    TestSombra sombra = snapshot.data[3];
                    print(snapshot.data[3]);
                    pageItem.add(_principalData(finca, parcela, sombra));
                    
                    
                    
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

    Widget _principalData(Finca finca, Parcela parcela, TestSombra sombra){
    
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
                                                    _areByEstacion(),
                                                    _areTotalEstacion(),
                                                    Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                            Expanded(child: Container(
                                                                padding: EdgeInsets.symmetric(horizontal: 20.0),
                                                                child: Text('Estaciones', textAlign: TextAlign.start, style: Theme.of(context).textTheme.headline6
                                                                                        .copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
                                                            ),),
                                                            Container(
                                                                width: 45,
                                                                child: Text('1', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline6
                                                                        .copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
                                                            ),
                                                            Container(
                                                                width: 45,
                                                                child: Text('2', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline6
                                                                        .copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
                                                            ),
                                                            Container(
                                                                width: 45,
                                                                child: Text('3', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline6
                                                                        .copyWith(fontSize: 16, fontWeight: FontWeight.w600))
                                                            ),
                                                            Container(
                                                                width: 45,
                                                                child: Text('Total', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline6
                                                                        .copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
                                                            ),
                                                        ],
                                                    ),
                                                    Divider(),
                                                    _cobertura(sombra.id),
                                                    _riqueza(sombra.id),
                                                    _arboles(sombra.id),
                                                    _densidad(sombra.id),
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

    Widget _areByEstacion(){
        List<Widget> lisItem = List<Widget>();


            lisItem.add(
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                        
                        Container(
                            width: 225,
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text('Area de cada estación mt2', textAlign: TextAlign.left, style:TextStyle(fontWeight: FontWeight.bold) ,),
                        ),

                        Expanded(
                            child: Text('$areaEstacion', textAlign: TextAlign.center),
                                
                        ),
                       
                        
                    ],
                )
            );
            lisItem.add(Divider());
        
        return Column(children:lisItem,);
    }

    Widget _areTotalEstacion(){
        List<Widget> lisItem = List<Widget>();


            lisItem.add(
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                        
                        Container(
                            width: 225,
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text('Area de tres estaciones mt2', textAlign: TextAlign.left, style:TextStyle(fontWeight: FontWeight.bold) ,),
                        ),

                        Expanded(
                            child: Text('${areaEstacion*3}', textAlign: TextAlign.center),
                                
                        ),
                       
                        
                    ],
                )
            );
            lisItem.add(Divider());
        
        return Column(children:lisItem,);
    }

    Widget _cobertura(String idSombra){
        List<Widget> lisItem = List<Widget>();


            lisItem.add(
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                        Expanded(child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text('Cobertura de sombra % Est', textAlign: TextAlign.left, style:TextStyle(fontWeight: FontWeight.bold) ,),
                        ),),
                        Container(
                            width: 45,
                            child: FutureBuilder(
                                future: _coberturaByEstacion(idSombra, 1),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (!snapshot.hasData) {
                                        return textmt;
                                    }

                                    return Text('${snapshot.data.toStringAsFixed(0)}%', textAlign: TextAlign.center);
                                },
                            ),
                        ),
                        Container(
                            width: 45,
                            child: FutureBuilder(
                                future: _coberturaByEstacion(idSombra, 2),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (!snapshot.hasData) {
                                        return textmt;
                                    }

                                    return Text('${snapshot.data.toStringAsFixed(0)}%', textAlign: TextAlign.center);
                                },
                            ),
                        ),
                        Container(
                            width: 45,
                            child: FutureBuilder(
                                future: _coberturaByEstacion(idSombra, 3),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (!snapshot.hasData) {
                                        return textmt;
                                    }

                                    return Text('${snapshot.data.toStringAsFixed(0)}%', textAlign: TextAlign.center);
                                },
                            ),
                        ),
                        Container(
                            width: 45,
                            child: FutureBuilder(
                                future: _coberturaPromedio(idSombra),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (!snapshot.hasData) {
                                        return textmt;
                                    }

                                    return Text('${snapshot.data.toStringAsFixed(0)}%', textAlign: TextAlign.center);
                                },
                            ),
                        ),
                        
                    ],
                )
            );
            lisItem.add(Divider());
        
        return Column(children:lisItem,);
    }

    Widget _riqueza(String idSombra){
        List<Widget> lisItem = List<Widget>();


            lisItem.add(
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                        Expanded(child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text('Riqueza (# de especies)', textAlign: TextAlign.left, style:TextStyle(fontWeight: FontWeight.bold) ,),
                        ),),
                        Container(
                            width: 45,
                            child: FutureBuilder(
                                future: _riquezaByEstacion(idSombra, 1),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (!snapshot.hasData) {
                                        return textmt;
                                    }

                                    return Text('${snapshot.data}', textAlign: TextAlign.center);
                                },
                            ),
                        ),
                        Container(
                            width: 45,
                            child: FutureBuilder(
                                future: _riquezaByEstacion(idSombra, 2),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (!snapshot.hasData) {
                                        return textmt;
                                    }

                                    return Text('${snapshot.data}', textAlign: TextAlign.center);
                                },
                            ),
                        ),
                        Container(
                            width: 45,
                            child: FutureBuilder(
                                future: _riquezaByEstacion(idSombra, 3),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (!snapshot.hasData) {
                                        return textmt;
                                    }

                                    return Text('${snapshot.data}', textAlign: TextAlign.center);
                                },
                            ),
                        ),
                        Container(
                            width: 45,
                            child: FutureBuilder(
                                future: _riquezaTotal(idSombra),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (!snapshot.hasData) {
                                        return textmt;
                                    }

                                    return Text('${snapshot.data}', textAlign: TextAlign.center);
                                },
                            ),
                        ),
                        
                    ],
                )
            );
            lisItem.add(Divider());
        
        return Column(children:lisItem,);
    }

    Widget _arboles(String idSombra){
        List<Widget> lisItem = List<Widget>();


            lisItem.add(
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                        Expanded(child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text('Suma de arboles (todas)', textAlign: TextAlign.left, style:TextStyle(fontWeight: FontWeight.bold) ,),
                        ),),
                        Container(
                            width: 45,
                            child: FutureBuilder(
                                future: _arbolesByEstacion(idSombra, 1),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (!snapshot.hasData) {
                                        return textmt;
                                    }

                                    return Text('${snapshot.data}', textAlign: TextAlign.center);
                                },
                            ),
                        ),
                        Container(
                            width: 45,
                            child: FutureBuilder(
                                future: _arbolesByEstacion(idSombra, 2),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (!snapshot.hasData) {
                                        return textmt;
                                    }

                                    return Text('${snapshot.data}', textAlign: TextAlign.center);
                                },
                            ),
                        ),
                        Container(
                            width: 45,
                            child: FutureBuilder(
                                future: _arbolesByEstacion(idSombra, 3),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (!snapshot.hasData) {
                                        return textmt;
                                    }

                                    return Text('${snapshot.data}', textAlign: TextAlign.center);
                                },
                            ),
                        ),
                        Container(
                            width: 45,
                            child: FutureBuilder(
                                future: _arbolesPromedio(idSombra),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (!snapshot.hasData) {
                                        return textmt;
                                    }

                                    return Text('${snapshot.data.toStringAsFixed(1)}', textAlign: TextAlign.center);
                                },
                            ),
                        ),
                        
                    ],
                )
            );
            lisItem.add(Divider());
        
        return Column(children:lisItem,);
    }

    Widget _densidad(String idSombra){
        List<Widget> lisItem = List<Widget>();


            lisItem.add(
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                        Expanded(child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text('Densidad de árboles (#/ha)', textAlign: TextAlign.left, style:TextStyle(fontWeight: FontWeight.bold) ,),
                        ),),
                        Container(
                            width: 45,
                            child: FutureBuilder(
                                future: _arbolesByEstacion(idSombra, 1),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (!snapshot.hasData) {
                                        return textmt;
                                    }

                                    return Text('${((snapshot.data/areaEstacion)* 10000).toStringAsFixed(1)}', textAlign: TextAlign.center);
                                },
                            ),
                        ),
                        Container(
                            width: 45,
                            child: FutureBuilder(
                                future: _arbolesByEstacion(idSombra, 2),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (!snapshot.hasData) {
                                        return textmt;
                                    }

                                    return Text('${((snapshot.data/areaEstacion)* 10000).toStringAsFixed(1)}', textAlign: TextAlign.center);
                                },
                            ),
                        ),
                        Container(
                            width: 45,
                            child: FutureBuilder(
                                future: _arbolesByEstacion(idSombra, 3),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (!snapshot.hasData) {
                                        return textmt;
                                    }

                                    return Text('${((snapshot.data/areaEstacion)* 10000).toStringAsFixed(1)}', textAlign: TextAlign.center);
                                },
                            ),
                        ),
                        Container(
                            width: 45,
                            child: FutureBuilder(
                                future: _arbolesPromedio(idSombra),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (!snapshot.hasData) {
                                        return textmt;
                                    }

                                    return Text('${((snapshot.data/areaEstacion)* 10000).toStringAsFixed(1)}', textAlign: TextAlign.center);
                                },
                            ),
                        ),
                        
                    ],
                )
            );
            lisItem.add(Divider());
        
        return Column(children:lisItem,);
    }

    // Widget _dominanciaEspecie(String idSombra){
        
    //     return FutureBuilder(
    //         future:Future.wait([
    //             _countByEspecie(idSombra),
    //             _arbolesPromedio(idSombra)
    //         ]),
    //         builder: (BuildContext context, AsyncSnapshot snapshot) {
    //             if (!snapshot.hasData) {
    //                 return textmt;
    //             }
                
    //             List<Map<String, dynamic>> especiesConteo = snapshot.data[0];
    //             double totalArboles = snapshot.data[1]*3;
    //             List<Widget> listPrincipales = List<Widget>();

    //             listPrincipales.add(
    //                 Column(
    //                     children: [
    //                         Container(
    //                             child: Padding(
    //                                 padding: EdgeInsets.only(top: 20, bottom: 10),
    //                                 child: Text(
    //                                     "Dominancia de especies",
    //                                     textAlign: TextAlign.center,
    //                                     style: Theme.of(context).textTheme
    //                                         .headline5
    //                                         .copyWith(fontWeight: FontWeight.w600, fontSize: 18)
    //                                 ),
    //                             )
    //                         ),
    //                         Divider(),
    //                     ],
    //                 )
                    
    //             );

                
    //             for (var especie in especiesConteo) {

    //                 String labelEspecie = itemEspecie.firstWhere((e) => e['value'] == '${especie['idPlanta']}', orElse: () => {"value": "1","label": "No data"})['label'];
    //                 double densidad = (especie['total']/totalArboles)*100;
                                        
    //                 listPrincipales.add(
    //                     Column(
    //                         children: [
    //                             Row(
    //                                 mainAxisAlignment: MainAxisAlignment.end,
    //                                 children: [
    //                                     Expanded(
    //                                         child: Container(
    //                                             padding: EdgeInsets.symmetric(horizontal: 20.0),
    //                                             child: Text(labelEspecie, textAlign: TextAlign.left, style:TextStyle(fontWeight: FontWeight.bold) ,),
    //                                         ),
    //                                     ),
    //                                     Container(
    //                                         width: 45,
    //                                         child: FutureBuilder(
    //                                             future: _arbolesPromedio(idSombra),
    //                                             builder: (BuildContext context, AsyncSnapshot snapshot) {
    //                                                 if (!snapshot.hasData) {
    //                                                     return textmt;
    //                                                 }

    //                                                 return Text('${densidad.toStringAsFixed(1)}%', textAlign: TextAlign.center);
    //                                             },
    //                                         ),
    //                                     ),
                                        
    //                                 ],
    //                             ),
    //                             Divider(),
    //                         ],
    //                     )
                        
    //                 );
    //             }

    //             return SingleChildScrollView(
    //                 child: Container(
    //                     margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    //                     width: double.infinity,
    //                     padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    //                     decoration: BoxDecoration(
    //                         color: Colors.white,
    //                         borderRadius: BorderRadius.circular(10),
    //                         boxShadow: [
    //                             BoxShadow(
    //                                     color: Color(0xFF3A5160)
    //                                         .withOpacity(0.05),
    //                                     offset: const Offset(1.1, 1.1),
    //                                     blurRadius: 17.0),
    //                             ],
    //                     ),
    //                     child: Column(children:listPrincipales)
    //                 ),
    //             );
    //         },
    //     );
    
        
        
    // }

   

    


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
import 'package:app_sombra/src/bloc/fincas_bloc.dart';
import 'package:app_sombra/src/models/decisiones_model.dart';
import 'package:app_sombra/src/models/finca_model.dart';
import 'package:app_sombra/src/models/parcela_model.dart';
import 'package:app_sombra/src/models/testsombra_model.dart';
import 'package:app_sombra/src/models/selectValue.dart' as selectMap;
import 'package:app_sombra/src/providers/db_provider.dart';
import 'package:app_sombra/src/utils/constants.dart';
import 'package:app_sombra/src/utils/widget/titulos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:math' as math;
import 'package:uuid/uuid.dart';




class DesicionesPage extends StatefulWidget {
    DesicionesPage({Key key}) : super(key: key);

    @override
    _DesicionesPageState createState() => _DesicionesPageState();
}

class _DesicionesPageState extends State<DesicionesPage> {

    Decisiones decisiones = Decisiones();
    List<Decisiones> listaDecisiones = [];
    String idSombraMain = "";
    bool _guardando = false;
    var uuid = Uuid();
    
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

    Widget textmt= Text('0', textAlign: TextAlign.center);
    double areaEstacion;

    final Map checksDensidad= {};
    final Map checksForma= {};
    final Map checksCompetencia= {};
    final Map checksArreglo= {};
    final Map checksCantidad= {};
    final Map checksCalidad= {};
    final Map checksMejora= {};
    final Map checksDominio= {};
    final Map checksReduccion= {};
    final Map checksAumento= {};
    final Map checksMesSombra = {};

    void checkKeys(){
        for(int i = 0 ; i < itemDensidad.length ; i ++){
            checksDensidad[itemDensidad[i]['value']] = false;
        }
        for(int i = 0 ; i < itemForma.length ; i ++){
            checksForma[itemForma[i]['value']] = false;
        }
        for(int i = 0 ; i < itemCompetencia.length ; i ++){
            checksCompetencia[itemCompetencia[i]['value']] = false;
        }
        for(int i = 0 ; i < itemArreglo.length ; i ++){
            checksArreglo[itemArreglo[i]['value']] = false;
        }
        for(int i = 0 ; i < itemCantidad.length ; i ++){
            checksCantidad[itemCantidad[i]['value']] = false;
        }
        for(int i = 0 ; i < itemCalidad.length ; i ++){
            checksCalidad[itemCalidad[i]['value']] = false;
        }
        for(int i = 0 ; i < itemMejora.length ; i ++){
            checksMejora[itemMejora[i]['value']] = false;
        }
        for(int i = 0 ; i < itemDominio.length ; i ++){
            checksDominio[itemDominio[i]['value']] = false;
        }
        for(int i = 0 ; i < itemReduccion.length ; i ++){
            checksReduccion[itemReduccion[i]['value']] = false;
        }
        for(int i = 0 ; i < itemAumento.length ; i ++){
            checksAumento[itemAumento[i]['value']] = false;
        }
        for(int i = 0 ; i < itemMeses.length ; i ++){
           checksMesSombra[itemMeses[i]['value']] = false;
        }
        
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

    Future<int> _noMusaceaeByEstacion(String idSombra, int estacion) async{
        int countArboles = await DBProvider.db.noMusaceaeByEstacion(idSombra, estacion);
        return countArboles;
    }

    Future<double> _noMusaceaePromedio(String idSombra) async{
        double countArboles = await DBProvider.db.noMusaceaePromedio(idSombra);
        return countArboles;
    }

    Future<List<Map<String, dynamic>>> _countByEspecie(String idSombra) async{
        List<Map<String, dynamic>> listEspecies = await DBProvider.db.dominanciaEspecie(idSombra);
        return listEspecies;
    }

    final fincasBloc = new FincasBloc();

    @override
    void initState() {
        super.initState();
        checkKeys();
    }

    @override
    Widget build(BuildContext context) {
        
        TestSombra sombra = ModalRoute.of(context).settings.arguments;
        areaEstacion = (sombra.surcoDistancia * 10)*(sombra.plantaDistancia * 10);

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

                    pageItem.add(_principalData(finca, parcela, sombra));
                    pageItem.add(_dominanciaEspecie(sombra.id));
                    pageItem.add(_densidadForma());
                    pageItem.add(_competenciaArreglo());
                    pageItem.add(_cantidadCalidad());
                    pageItem.add(_mejoraDominio());
                    pageItem.add(_reduccionAumento());
                    pageItem.add(_accionesMeses());
                    pageItem.add(_botonsubmit(sombra.id));

                    return Column(
                        children: [
                            Container(
                                child: Column(
                                    children: [
                                        TitulosPages(titulo: 'Toma de Decisiones'),
                                        Divider(),
                                        Padding(
                                            padding: EdgeInsets.symmetric(vertical: 10),
                                            child: Row(
                                          
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                    Container(
                                                        width: 200,
                                                        child: Text(
                                                                "Deslice hacia la derecha para continuar con el formulario",
                                                                textAlign: TextAlign.center,
                                                                style: Theme.of(context).textTheme
                                                                    .headline5
                                                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 14)
                                                            )
                                                    
                                                    ),
                                                    
                                                    
                                                    Transform.rotate(
                                                        angle: 90 * math.pi / 180,
                                                        child: Icon(
                                                            Icons.arrow_circle_up_rounded,
                                                            size: 25,
                                                        ),
                                                        
                                                    ),
                                                ],
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
                                                            _noMusaceaeDensidad(sombra.id),
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

                                    return Text('${snapshot.data.toStringAsFixed(0)}', textAlign: TextAlign.center);
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

                                    return Text('${((snapshot.data/areaEstacion)* 10000).toStringAsFixed(0)}', textAlign: TextAlign.center);
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

                                    return Text('${((snapshot.data/areaEstacion)* 10000).toStringAsFixed(0)}', textAlign: TextAlign.center);
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

                                    return Text('${((snapshot.data/areaEstacion)* 10000).toStringAsFixed(0)}', textAlign: TextAlign.center);
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

                                    return Text('${((snapshot.data/areaEstacion)* 10000).toStringAsFixed(0)}', textAlign: TextAlign.center);
                                },
                            ),
                        ),
                        
                    ],
                )
            );
            lisItem.add(Divider());
        
        return Column(children:lisItem,);
    }

    Widget _noMusaceaeDensidad(String idSombra){
        List<Widget> lisItem = List<Widget>();


            lisItem.add(
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                        Expanded(child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text('Densidad de árboles (#/ha) sin Musaceae', textAlign: TextAlign.left, style:TextStyle(fontWeight: FontWeight.bold) ,),
                        ),),
                        Container(
                            width: 45,
                            child: FutureBuilder(
                                future: _noMusaceaeByEstacion(idSombra, 1),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (!snapshot.hasData) {
                                        return textmt;
                                    }

                                    return Text('${((snapshot.data/areaEstacion)* 10000).toStringAsFixed(0)}', textAlign: TextAlign.center);
                                },
                            ),
                        ),
                        Container(
                            width: 45,
                            child: FutureBuilder(
                                future: _noMusaceaeByEstacion(idSombra, 2),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (!snapshot.hasData) {
                                        return textmt;
                                    }

                                    return Text('${((snapshot.data/areaEstacion)* 10000).toStringAsFixed(0)}', textAlign: TextAlign.center);
                                },
                            ),
                        ),
                        Container(
                            width: 45,
                            child: FutureBuilder(
                                future: _noMusaceaeByEstacion(idSombra, 3),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (!snapshot.hasData) {
                                        return textmt;
                                    }

                                    return Text('${((snapshot.data/areaEstacion)* 10000).toStringAsFixed(0)}', textAlign: TextAlign.center);
                                },
                            ),
                        ),
                        Container(
                            width: 45,
                            child: FutureBuilder(
                                future: _noMusaceaePromedio(idSombra),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (!snapshot.hasData) {
                                        return textmt;
                                    }

                                    return Text('${((snapshot.data/areaEstacion)* 10000).toStringAsFixed(0)}', textAlign: TextAlign.center);
                                },
                            ),
                        ),
                        
                    ],
                )
            );
            lisItem.add(Divider());
        
        return Column(children:lisItem,);
    }


    Widget _dominanciaEspecie(String idSombra){
        
        return FutureBuilder(
            future:Future.wait([
                _countByEspecie(idSombra),
                _arbolesPromedio(idSombra)
            ]),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                    return textmt;
                }
                
                List<Map<String, dynamic>> especiesConteo = snapshot.data[0];
                double totalArboles = snapshot.data[1]*3;
                List<Widget> listPrincipales = List<Widget>();

                listPrincipales.add(
                    Column(
                        children: [
                            Container(
                                child: Padding(
                                    padding: EdgeInsets.only(top: 20, bottom: 10),
                                    child: Text(
                                        "Dominancia de especies",
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme
                                            .headline5
                                            .copyWith(fontWeight: FontWeight.w600, fontSize: 18)
                                    ),
                                )
                            ),
                            Divider(),
                        ],
                    )
                    
                );

                
                for (var especie in especiesConteo) {

                    String labelEspecie = itemEspecie.firstWhere((e) => e['value'] == '${especie['idPlanta']}', orElse: () => {"value": "1","label": "No data"})['label'];
                    double densidad = (especie['total']/totalArboles)*100;
                                        
                    listPrincipales.add(
                        Column(
                            children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                        Expanded(
                                            child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 20.0),
                                                child: Text(labelEspecie, textAlign: TextAlign.left, style:TextStyle(fontWeight: FontWeight.bold) ,),
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

                                                    return Text('${densidad.toStringAsFixed(0)}%', textAlign: TextAlign.center);
                                                },
                                            ),
                                        ),
                                        
                                    ],
                                ),
                                Divider(),
                            ],
                        )
                        
                    );
                }

                return SingleChildScrollView(
                    child: Container(
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
                        child: Column(children:listPrincipales)
                    ),
                );
            },
        );
    
        
        
    }


    Widget _densidadForma(){
        List<Widget> listPrincipales = List<Widget>();

        listPrincipales.add(
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "Densidad de árboles de sombra",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme
                                    .headline5
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 18)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        for (var i = 0; i < itemDensidad.length; i++) {
            String label = itemDensidad.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            listPrincipales.add(

                CheckboxListTile(
                    title: Text('$label',
                        style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 16),
                    ),
                    value: checksDensidad[itemDensidad[i]['value']], 
                    onChanged: (value) {
                        setState(() {
                            for(int i = 0 ; i < itemDensidad.length ; i ++){
                                checksDensidad[itemDensidad[i]['value']] = false;
                            }
                            checksDensidad[itemDensidad[i]['value']] = value;
                        });
                    },
                )                    
            );
        }

        listPrincipales.add(
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "Forma de copa de árboles",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme
                                    .headline5
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 18)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        for (var i = 0; i < itemForma.length; i++) {
            String label = itemForma.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            listPrincipales.add(

                CheckboxListTile(
                    title: Text('$label',
                        style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 16),
                    ),
                    value: checksForma[itemForma[i]['value']], 
                    onChanged: (value) {
                        setState(() {
                            for(int i = 0 ; i < itemForma.length ; i ++){
                                checksForma[itemForma[i]['value']] = false;
                            }
                            checksForma[itemForma[i]['value']] = value;
                        });
                    },
                )                    
            );
        }
        
        return SingleChildScrollView(
            child: Container(
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
                child: Column(children:listPrincipales,)
            ),
        );
    }

    Widget _competenciaArreglo(){
        List<Widget> listPrincipales = List<Widget>();

        listPrincipales.add(
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "Competencia de árboles con cacao",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme
                                    .headline5
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 18)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        for (var i = 0; i < itemCompetencia.length; i++) {
            String label = itemCompetencia.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            listPrincipales.add(

                CheckboxListTile(
                    title: Text('$label',
                        style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 16),
                    ),
                    value: checksCompetencia[itemCompetencia[i]['value']], 
                    onChanged: (value) {
                        setState(() {
                            for(int i = 0 ; i < itemCompetencia.length ; i ++){
                                checksCompetencia[itemCompetencia[i]['value']] = false;
                            }
                            checksCompetencia[itemCompetencia[i]['value']] = value;
                        });
                    },
                )                    
            );
        }

        listPrincipales.add(
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "Arreglo de árboles",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme
                                    .headline5
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 18)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        for (var i = 0; i < itemArreglo.length; i++) {
            String label = itemArreglo.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            listPrincipales.add(

                CheckboxListTile(
                    title: Text('$label',
                        style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 16),
                    ),
                    value: checksArreglo[itemArreglo[i]['value']], 
                    onChanged: (value) {
                        setState(() {
                            for(int i = 0 ; i < itemArreglo.length ; i ++){
                                checksArreglo[itemArreglo[i]['value']] = false;
                            }
                            checksArreglo[itemArreglo[i]['value']] = value;
                        });
                    },
                )                    
            );
        }
        
        return SingleChildScrollView(
            child: Container(
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
                child: Column(children:listPrincipales,)
            ),
        );
    }

    Widget _cantidadCalidad(){
        List<Widget> listPrincipales = List<Widget>();

        listPrincipales.add(
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "Catidad de hoja rasca",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme
                                    .headline5
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 18)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        for (var i = 0; i < itemCantidad.length; i++) {
            String label = itemCantidad.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            listPrincipales.add(

                CheckboxListTile(
                    title: Text('$label',
                        style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 16),
                    ),
                    value: checksCantidad[itemCantidad[i]['value']], 
                    onChanged: (value) {
                        setState(() {
                            for(int i = 0 ; i < itemCantidad.length ; i ++){
                                checksCantidad[itemCantidad[i]['value']] = false;
                            }
                            checksCantidad[itemCantidad[i]['value']] = value;
                        });
                    },
                )                    
            );
        }

        listPrincipales.add(
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "Calidad de hora rasca",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme
                                    .headline5
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 18)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        for (var i = 0; i < itemCalidad.length; i++) {
            String label = itemCalidad.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            listPrincipales.add(

                CheckboxListTile(
                    title: Text('$label',
                        style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 16),
                    ),
                    value: checksCalidad[itemCalidad[i]['value']], 
                    onChanged: (value) {
                        setState(() {
                            for(int i = 0 ; i < itemCalidad.length ; i ++){
                                checksCalidad[itemCalidad[i]['value']] = false;
                            }
                            checksCalidad[itemCalidad[i]['value']] = value;
                        });
                    },
                )                    
            );
        }
        
        return SingleChildScrollView(
            child: Container(
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
                child: Column(children:listPrincipales,)
            ),
        );
    }

    Widget _mejoraDominio(){
        List<Widget> listPrincipales = List<Widget>();

        listPrincipales.add(
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "Acciones para mejorar la sombra",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme
                                    .headline5
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 18)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        for (var i = 0; i < itemMejora.length; i++) {
            String label = itemMejora.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            listPrincipales.add(

                CheckboxListTile(
                    title: Text('$label',
                        style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 16),
                    ),
                    value: checksMejora[itemMejora[i]['value']], 
                    onChanged: (value) {
                        setState(() {
                            for(int i = 0 ; i < itemMejora.length ; i ++){
                                checksMejora[itemMejora[i]['value']] = false;
                            }
                            checksMejora[itemMejora[i]['value']] = value;
                        });
                    },
                )                    
            );
        }

        listPrincipales.add(
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "Dominio de la acción",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme
                                    .headline5
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 18)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        for (var i = 0; i < itemDominio.length; i++) {
            String label = itemDominio.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            listPrincipales.add(

                CheckboxListTile(
                    title: Text('$label',
                        style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 16),
                    ),
                    value: checksDominio[itemDominio[i]['value']], 
                    onChanged: (value) {
                        setState(() {
                            for(int i = 0 ; i < itemDominio.length ; i ++){
                                checksDominio[itemDominio[i]['value']] = false;
                            }
                            checksDominio[itemDominio[i]['value']] = value;
                        });
                    },
                )                    
            );
        }
        
        return SingleChildScrollView(
            child: Container(
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
                child: Column(children:listPrincipales,)
            ),
        );
    }

    Widget _reduccionAumento(){
        List<Widget> listPrincipales = List<Widget>();

        listPrincipales.add(
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "Acciones para reducción de sombra",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme
                                    .headline5
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 18)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        for (var i = 0; i < itemReduccion.length; i++) {
            String label = itemReduccion.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            listPrincipales.add(

                CheckboxListTile(
                    title: Text('$label',
                        style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 16),
                    ),
                    value: checksReduccion[itemReduccion[i]['value']], 
                    onChanged: (value) {
                        setState(() {
                            for(int i = 0 ; i < itemReduccion.length ; i ++){
                                checksReduccion[itemReduccion[i]['value']] = false;
                            }
                            checksReduccion[itemReduccion[i]['value']] = value;
                        });
                    },
                )                    
            );
        }

        listPrincipales.add(
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "Acciones para aumento de sombra",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme
                                    .headline5
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 18)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        for (var i = 0; i < itemAumento.length; i++) {
            String label = itemAumento.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            listPrincipales.add(

                CheckboxListTile(
                    title: Text('$label',
                        style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 16),
                    ),
                    value: checksAumento[itemAumento[i]['value']], 
                    onChanged: (value) {
                        setState(() {
                            for(int i = 0 ; i < itemAumento.length ; i ++){
                                checksAumento[itemAumento[i]['value']] = false;
                            }
                            checksAumento[itemAumento[i]['value']] = value;
                        });
                    },
                )                    
            );
        }
        
        return SingleChildScrollView(
            child: Container(
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
                child: Column(children:listPrincipales,)
            ),
        );
    }

    Widget _accionesMeses(){

        List<Widget> listaAcciones = List<Widget>();
        listaAcciones.add(
            
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "¿Cúando vamos a realizar el manejo de sombra?",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme
                                    .headline5
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 18)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        for (var i = 0; i < itemMeses.length; i++) {
            String labelmeses = itemMeses.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            
            listaAcciones.add(
                Container(
                    child: CheckboxListTile(
                        title: Text('$labelmeses'),
                        value: checksMesSombra[itemMeses[i]['value']], 
                        onChanged: (value) {
                            setState(() {
                                checksMesSombra[itemMeses[i]['value']] = value;
                            });
                        },
                    ),
                )
            );
        }

        return SingleChildScrollView(
            child: Container(
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
                child: Column(children:listaAcciones,)
            ),
        );
    }

    Widget  _botonsubmit(String idSombra){
        idSombraMain = idSombra;
        return SingleChildScrollView(
            child: Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
                        Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 30),
                            child: Text(
                                "¿Ha Terminado todos los formularios de toma de desición?",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme
                                    .headline5
                                    .copyWith(fontWeight: FontWeight.w600)
                            ),
                        ),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 60),
                            child: RaisedButton.icon(
                                icon:Icon(Icons.save),
                                label: Text('Guardar',
                                    style: Theme.of(context).textTheme
                                        .headline6
                                        .copyWith(fontWeight: FontWeight.w600, color: Colors.white)
                                ),
                                padding:EdgeInsets.all(13),
                                onPressed:(_guardando) ? null : _submit,
                                
                            ),
                        ),
                    ],
                ),
            ),
        );
    }

    _listaDecisiones(Map checksPreguntas, int pregunta){
       
        checksPreguntas.forEach((key, value) {
            final Decisiones itemDesisiones = Decisiones();
            itemDesisiones.id = uuid.v1();
            itemDesisiones.idPregunta = pregunta;
            itemDesisiones.idItem = int.parse(key);
            itemDesisiones.repuesta = value ? 1 : 0;
            itemDesisiones.idTest = idSombraMain;

            listaDecisiones.add(itemDesisiones);
        });
    }



    void _submit(){
        setState(() {_guardando = true;});
        _listaDecisiones(checksDensidad, 1);
        _listaDecisiones(checksForma, 2);
        _listaDecisiones(checksCompetencia, 3);
        _listaDecisiones(checksArreglo, 4);
        _listaDecisiones(checksCantidad, 5);
        _listaDecisiones(checksCalidad, 6);
        _listaDecisiones(checksMejora, 7);
        _listaDecisiones(checksDominio, 8);
        _listaDecisiones(checksReduccion, 9);
        _listaDecisiones(checksAumento, 10);
        _listaDecisiones(checksMesSombra, 11);



        listaDecisiones.forEach((decision) {
            // print("Id Pregunta: ${decision.idPregunta}");
            // print("Id item: ${decision.idItem}");
            // print("Id Respues: ${decision.repuesta}");
            // print("Id prueba: ${decision.idTest}");
            DBProvider.db.nuevaDecision(decision);
        });

        
        fincasBloc.obtenerDecisiones(idSombraMain);
        setState(() {_guardando = false;});

        Navigator.pop(context, 'estaciones');
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

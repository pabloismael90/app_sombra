import 'package:app_sombra/src/bloc/fincas_bloc.dart';
import 'package:app_sombra/src/models/decisiones_model.dart';
import 'package:app_sombra/src/models/finca_model.dart';
import 'package:app_sombra/src/models/parcela_model.dart';
import 'package:app_sombra/src/models/testsombra_model.dart';
import 'package:app_sombra/src/models/selectValue.dart' as selectMap;
import 'package:app_sombra/src/providers/db_provider.dart';
import 'package:app_sombra/src/utils/widget/button.dart';
import 'package:app_sombra/src/utils/widget/varios_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:uuid/uuid.dart';




class DesicionesPage extends StatefulWidget {
    DesicionesPage({Key? key}) : super(key: key);

    @override
    _DesicionesPageState createState() => _DesicionesPageState();
}

class _DesicionesPageState extends State<DesicionesPage> {

    Decisiones decisiones = Decisiones();
    List<Decisiones> listaDecisiones = [];
    String? idSombraMain = "";
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
    double? areaEstacion;

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



    Future<double?> _arbolesPromedio(String? idSombra) async{
        double? countArboles = await DBProvider.db.getArbolesPromedio(idSombra);
        return countArboles;
    }

    Future<List<Map<String, dynamic>>> _countByEspecie(String? idSombra) async{
        List<Map<String, dynamic>> listEspecies = await DBProvider.db.dominanciaEspecie(idSombra);
        return listEspecies;
    }

    Future _dataTableSombra( String idSombra, double? areaEstacion ) async{
        

        List<String>? coberturaData = [];
        
        coberturaData.add('Cobertura de sombra % Est');

        for (var i = 1; i < 4; i++) {
            double? cobertura = await DBProvider.db.getCoberturaByEstacion(idSombra, i);
            coberturaData.add('${cobertura!.toStringAsFixed(0)}%');
        }
        double? coberturaPromedio = await DBProvider.db.getCoberturaPromedio(idSombra);
        coberturaData.add('${coberturaPromedio!.toStringAsFixed(0)}%');


        
        List<String>? riquezaData = [];
        riquezaData.add('Riqueza (# de especies)');
        for (var i = 1; i < 4; i++) {
            int? riqueza = await DBProvider.db.getConteoByEstacion(idSombra, i);
            riquezaData.add('$riqueza');
        }
        int? riquezaTotal = await DBProvider.db.getConteoEspecies(idSombra);
        riquezaData.add('$riquezaTotal');



        List<String>? arbolesData = [];
        arbolesData.add('Suma de arboles (todas)');
        for (var i = 1; i < 4; i++) {
            int? arboles = await DBProvider.db.getArbolesByEstacion(idSombra, i);
            arbolesData.add('$arboles');
        }
        double? arbolesTotal = await DBProvider.db.getArbolesPromedio(idSombra);
        arbolesData.add('${arbolesTotal!.toStringAsFixed(0)}');




        List<String>? densidadData = [];
        densidadData.add('Densidad de árboles (#/ha)');
        for (var i = 1; i < 4; i++) {
            int? densidad = await DBProvider.db.getArbolesByEstacion(idSombra, i);
            densidadData.add('${((densidad!/areaEstacion!)* 10000).toStringAsFixed(0)}');
        }
        double? densidadTotal = await DBProvider.db.getArbolesPromedio(idSombra);
        densidadData.add('${((densidadTotal!/areaEstacion!)* 10000).toStringAsFixed(0)}');
        
        
        
        List<String>? sinMusaceaeData = [];
        sinMusaceaeData.add('Densidad de árboles (#/ha) sin Musaceae');
        for (var i = 1; i < 4; i++) {
            int? sinMusaceae = await DBProvider.db.noMusaceaeByEstacion(idSombra, i);
            sinMusaceaeData.add('${((sinMusaceae!/areaEstacion)* 10000).toStringAsFixed(0)}');
        }
        double? sinMusaceaeTotal = await DBProvider.db.noMusaceaePromedio(idSombra);
        sinMusaceaeData.add('${((sinMusaceaeTotal!/areaEstacion)* 10000).toStringAsFixed(0)}');
    
        return [coberturaData,riquezaData,arbolesData,densidadData,sinMusaceaeData];
    }

    final fincasBloc = new FincasBloc();

    @override
    void initState() {
        super.initState();
        checkKeys();
    }

    @override
    Widget build(BuildContext context) {
        
        TestSombra sombra = ModalRoute.of(context)!.settings.arguments as TestSombra;
        areaEstacion = (sombra.surcoDistancia! * 10)*(sombra.plantaDistancia! * 10);

        Future _getdataFinca() async{
            Finca? finca = await DBProvider.db.getFincaId(sombra.idFinca);
            Parcela? parcela = await DBProvider.db.getParcelaId(sombra.idLote);
            return [finca, parcela];
        }

        
        return Scaffold(
            appBar: AppBar(title: Text('Toma de Decisiones'),),
            body:FutureBuilder(
            future:  _getdataFinca(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                    }

                    List<Widget> pageItem = [];
                    Finca finca = snapshot.data[0];
                    Parcela parcela = snapshot.data[1];

                    pageItem.add(_principalData(finca, parcela, sombra, areaEstacion));
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
                            mensajeSwipe('Deslice hacia la izquierda para continuar con el formulario'),
                            Expanded(
                                child: Container(
                                    color: Colors.white,
                                    padding: EdgeInsets.all(15),
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
                            ),
                        ],
                    );
                },
            ),
            
        );
    }

    Widget _dataFincas( BuildContext context, Finca finca, Parcela parcela ){
        String? labelMedidaFinca;
        String? labelvariedad;

        labelMedidaFinca = selectMap.dimenciones().firstWhere((e) => e['value'] == '${finca.tipoMedida}')['label'];
        labelvariedad = selectMap.variedadCacao().firstWhere((e) => e['value'] == '${parcela.variedadCacao}')['label'];

        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                encabezadoCard('${finca.nombreFinca}','Parcela: ${parcela.nombreLote}', ''),
                textoCardBody('Productor: ${finca.nombreProductor}'),
                tecnico('${finca.nombreTecnico}'),
                textoCardBody('Variedad: $labelvariedad'),
                Wrap(
                    spacing: 20,
                    children: [
                        textoCardBody('Área Finca: ${finca.areaFinca} ($labelMedidaFinca)'),
                        textoCardBody('Área Parcela: ${parcela.areaLote} ($labelMedidaFinca)'),
                        textoCardBody('N de plantas: ${parcela.numeroPlanta}'),
                    ],
                ),
            ],  
        );

    }
    
    Widget _principalData(Finca finca, Parcela parcela, TestSombra sombra, double? areaEstacion){
    
        return Column(
            children: [
                _dataFincas( context, finca, parcela),
                Divider(),
                Expanded(
                    child: SingleChildScrollView(
                        child: Column(
                            children: [
                                Container(
                                    padding: EdgeInsets.symmetric(vertical: 3),
                                    child: InkWell(
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                                Container(                                                                    
                                                    child: Text(
                                                        "Datos consolidados",
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)
                                                    ),
                                                ),
                                                Container(
                                                    padding: EdgeInsets.only(left: 10),
                                                    child: Icon(
                                                        Icons.info_outline_rounded,
                                                        color: Colors.green,
                                                        size: 20,
                                                    ),
                                                ),
                                            ],
                                        ),
                                        onTap: () => _explicacion(context),
                                    ),
                                ),
                                Divider(),
                                Column(
                                    children: [
                                        _tableDataSombra(sombra.id, areaEstacion),
                                    ],
                                ),
                            ],
                        ),
                    ),
                )
                
            ],
        );
            
    }

    Widget _rowAreaEstacion( String titulo, double? value ){
        return Column(
            children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                        Container(
                            width: 225,
                            child: textList(titulo),
                        ),
                        Expanded(
                            child: Text('$value', textAlign: TextAlign.center),
                        ),
                    ],
                ),
                Divider()
            ],
        );
    }

    Widget _rowTable( List data){
        List<Widget> celdas = [];

        celdas.add(
            Expanded(
                child: Container(
                    padding: EdgeInsets.only(right: 10),
                    child: textList(data[0])
                )
            ),
        );

        for (var i = 1; i < data.length; i++) {
            celdas.add(
                Container(
                    width: 45,
                    child: Text(data[i], textAlign: TextAlign.center,)
                ),
                
            );
        }
        return Column(
            children: [
                Row(children: celdas,),
                Divider()
            ],
        );
    }

    Widget _tableDataSombra(String? idSombra, double? areaEstacion){

        return FutureBuilder(
            future: _dataTableSombra(idSombra!, areaEstacion),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                    return textmt;
                }

                List<Widget> filas = [];
                filas.add(_rowAreaEstacion( 'Area de cada sitio mt2', areaEstacion ));
                filas.add( _rowAreaEstacion( 'Area de tres sitios mt2', areaEstacion!*3 ));
                filas.add(_rowTable(['Sito', '1', '2', '3', 'Total']),);
                for (var item in snapshot.data) {
                    filas.add(_rowTable(item));
                }

                return Column(
                    children: filas
                );
            },
        );
    }






    Widget _dominanciaEspecie(String? idSombra){
        
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
                double? totalArboles = snapshot.data[1]*3;
                List<Widget> listPrincipales = [];

                listPrincipales.add(
                    Column(
                        children: [
                            Container(
                                padding: EdgeInsets.only(top: 20, bottom: 10),
                                child: Text(
                                    "Dominancia de especies",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)
                                ),
                            ),
                            Divider(),
                        ],
                    )
                    
                );

                
                for (var especie in especiesConteo) {

                    String labelEspecie = itemEspecie.firstWhere((e) => e['value'] == '${especie['idPlanta']}', orElse: () => {"value": "1","label": "No data"})['label'];
                    double? densidad = (especie['total']/totalArboles)*100;
                                        
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

                                                    return Text('${densidad!.toStringAsFixed(0)}%', textAlign: TextAlign.center);
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
                    child: Column(children:listPrincipales),
                );
            },
        );
    
        
        
    }

    Widget _densidadForma(){
        List<Widget> listPrincipales = [];

        listPrincipales.add(
            Column(
                children: [
                    Container(
                        padding: EdgeInsets.only(top: 20, bottom: 10),
                        child: Text(
                            "Densidad de árboles de sombra",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)
                        ),
                    ),
                    Divider(),
                ],
            )
            
        );
        for (var i = 0; i < itemDensidad.length; i++) {
            String? label = itemDensidad.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            listPrincipales.add(

                CheckboxListTile(
                    title: textoCardBody('$label'),
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
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        for (var i = 0; i < itemForma.length; i++) {
            String? label = itemForma.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            listPrincipales.add(

                CheckboxListTile(
                    title: textoCardBody('$label'),
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
            child: Column(children:listPrincipales,),
        );
    }

    Widget _competenciaArreglo(){
        List<Widget> listPrincipales = [];

        listPrincipales.add(
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "Competencia de árboles con cacao",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        for (var i = 0; i < itemCompetencia.length; i++) {
            String? label = itemCompetencia.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            listPrincipales.add(

                CheckboxListTile(
                    title: textoCardBody('$label'),
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
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        for (var i = 0; i < itemArreglo.length; i++) {
            String? label = itemArreglo.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            listPrincipales.add(

                CheckboxListTile(
                    title: textoCardBody('$label'),
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
            child: Column(children:listPrincipales,),
        );
    }

    Widget _cantidadCalidad(){
        List<Widget> listPrincipales = [];

        listPrincipales.add(
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "Catidad de hoja rasca",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        for (var i = 0; i < itemCantidad.length; i++) {
            String? label = itemCantidad.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            listPrincipales.add(

                CheckboxListTile(
                    title: textoCardBody('$label'),
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
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        for (var i = 0; i < itemCalidad.length; i++) {
            String? label = itemCalidad.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            listPrincipales.add(

                CheckboxListTile(
                    title: textoCardBody('$label'),
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
            child: Column(children:listPrincipales,),
        );
    }

    Widget _mejoraDominio(){
        List<Widget> listPrincipales = [];

        listPrincipales.add(
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "Acciones para mejorar la sombra",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        for (var i = 0; i < itemMejora.length; i++) {
            String? label = itemMejora.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            listPrincipales.add(

                CheckboxListTile(
                    title: textoCardBody('$label'),
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
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        for (var i = 0; i < itemDominio.length; i++) {
            String? label = itemDominio.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            listPrincipales.add(

                CheckboxListTile(
                    title: textoCardBody('$label'),
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
            child: Column(children:listPrincipales,),
        );
    }

    Widget _reduccionAumento(){
        List<Widget> listPrincipales = [];

        listPrincipales.add(
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "Acciones para reducción de sombra",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        for (var i = 0; i < itemReduccion.length; i++) {
            String? label = itemReduccion.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            listPrincipales.add(

                CheckboxListTile(
                    title: textoCardBody('$label'),
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
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        for (var i = 0; i < itemAumento.length; i++) {
            String? label = itemAumento.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            listPrincipales.add(

                CheckboxListTile(
                    title: textoCardBody('$label'),
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
            child: Column(children:listPrincipales,),
        );
    }

    Widget _accionesMeses(){

        List<Widget> listaAcciones = [];
        listaAcciones.add(
            
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "¿Cúando vamos a realizar el manejo de sombra?",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        for (var i = 0; i < itemMeses.length; i++) {
            String? labelmeses = itemMeses.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            
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
            child: Column(children:listaAcciones,),
        );
    }

    Widget  _botonsubmit(String? idSombra){
        idSombraMain = idSombra;
        return SingleChildScrollView(
            child: Column(
                children: [
                    Container(
                        padding: EdgeInsets.only(top: 20, bottom: 30),
                        child: Text(
                            "¿Ha Terminado todos los formularios de toma de desición?",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)
                        ),
                    ),
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 60),
                        child: ButtonMainStyle(
                            title: 'Guardar',
                            icon: Icons.save,
                            press: (_guardando) ? null : _submit,
                        )
                    ),
                ],
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
            DBProvider.db.nuevaDecision(decision);
        });

        
        fincasBloc.obtenerDecisiones(idSombraMain);
        setState(() {_guardando = false;});

        Navigator.pop(context, 'estaciones');
    }

    Future<void> _explicacion(BuildContext context){

        return dialogText(
            context,
            Column(
                children: [
                    textoCardBody('•	Las observaciones sobre la sombra de cacaotal se presentan en dos pantallas.'),

                    textoCardBody('•	En la primera pantalla se indican el :'),
                    textoCardBody(' 	o	% de cobertura de la sombra de cada uno de los sitios y el promedio de los tres sitios.'),
                    textoCardBody(' 	o	La riqueza de árboles expresado en número de especies de árboles presentes en el área de observación, para cada uno de los sitios y para el área total de los 3 sitios.'),
                    textoCardBody(' 	o	La cantidad de árboles presentes en los tres sitios de observación y promedio de los tres sitios.'),
                    textoCardBody(' 	o	La densidad de árboles expresado en número por ha, para los tres sitios y la parcela.'),
                    textoCardBody('•	En la segunda pantalla se presenta la dominancia de las diferentes especies, expresado en % de representación de cada una de las especies de árbol en base de las observaciones realizadas en los tres sitios'),
                ],
            ),
            'Observación sobre sombra de cacaotal'
        );
    }


}


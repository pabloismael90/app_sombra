import 'package:app_sombra/src/models/decisiones_model.dart';
import 'package:app_sombra/src/models/testsombra_model.dart';
import 'package:app_sombra/src/pages/pdf/pdf_api.dart';
import 'package:app_sombra/src/providers/db_provider.dart';
import 'package:app_sombra/src/models/selectValue.dart' as selectMap;
import 'package:app_sombra/src/utils/constants.dart';
import 'package:app_sombra/src/utils/widget/varios_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

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
    late double areaEstacion;

    
    

    Future getdata( TestSombra sombra) async{

        List<Decisiones> listDecisiones = await DBProvider.db.getDecisionesIdTest(sombra.id);

        Finca? finca = await DBProvider.db.getFincaId(sombra.idFinca);
        Parcela? parcela = await DBProvider.db.getParcelaId(sombra.idLote);

        return [listDecisiones, finca, parcela];
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


    

    @override
    Widget build(BuildContext context) {
        TestSombra? sombra = ModalRoute.of(context)!.settings.arguments as TestSombra?;
        areaEstacion = (sombra!.surcoDistancia! * 10)*(sombra.plantaDistancia! * 10);

        return Scaffold(
            appBar: AppBar(
                title: Text('Reporte de Decisiones'),
                actions: [
                    TextButton(
                        onPressed: () => _crearPdf(sombra, areaEstacion), 
                        child: Row(
                            children: [
                                Icon(Icons.download, color: kwhite, size: 16,),
                                SizedBox(width: 5,),
                                Text('PDF', style: TextStyle(color: Colors.white),)
                            ],
                        )
                        
                    )
                ],
            ),
            body: FutureBuilder(
                future: getdata(sombra),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                    }
                    List<Widget> pageItem = [];
                    Finca finca = snapshot.data[1];
                    Parcela parcela = snapshot.data[2];
                    

                    pageItem.add(_principalData(finca, parcela, sombra, areaEstacion));
                    pageItem.add(_dominanciaEspecie(sombra.id));
                    
                    pageItem.add(
                        SingleChildScrollView(
                            child: Column(
                                children:[
                                    Column(
                                        children:_generatePregunta(snapshot.data[0],'Densidad de árboles de sombra', 1, itemDensidad ),
                                    ),
                                    Column(
                                        children:_generatePregunta(snapshot.data[0],'Forma de copa de árboles', 2, itemForma ),
                                    )
                                ]
                            )
                        ) 
                    );

                    pageItem.add(
                        SingleChildScrollView(
                            child: Column(
                                children:[
                                    Column(
                                        children:_generatePregunta(snapshot.data[0],'Competencia de árboles con cacao', 3, itemCompetencia ),
                                    ),
                                    Column(
                                        children:_generatePregunta(snapshot.data[0],'Arreglo de árboles', 4, itemArreglo ),
                                    )
                                ]
                            )
                        ) 
                    );
                    
                    pageItem.add(
                        SingleChildScrollView(
                            child: Column(
                                children:[
                                    Column(
                                        children:_generatePregunta(snapshot.data[0],'Catidad de hoja rasca', 5, itemCantidad ),
                                    ),
                                    Column(
                                        children:_generatePregunta(snapshot.data[0],'Calidad de hora rasca', 6, itemCalidad ),
                                    )
                                ]
                            )
                        ) 
                    );
                    
                    pageItem.add(
                        SingleChildScrollView(
                            child: Column(
                                children:[
                                    Column(
                                        children:_generatePregunta(snapshot.data[0],'Acciones para mejorar la sombra', 7, itemMejora ),
                                    ),
                                    Column(
                                        children:_generatePregunta(snapshot.data[0],'Dominio de la acción', 8, itemDominio ),
                                    )
                                ]
                            )
                        ) 
                    );
                    
                    pageItem.add(
                        SingleChildScrollView(
                            child: Column(
                                children:[
                                    Column(
                                        children:_generatePregunta(snapshot.data[0],'Acciones para reducción de sombra', 9, itemReduccion ),
                                    ),
                                    Column(
                                        children:_generatePregunta(snapshot.data[0],'Acciones para aumento de sombra', 10, itemAumento ),
                                    )
                                ]
                            )
                        ) 
                    );

                    pageItem.add(
                        SingleChildScrollView(
                            child: Column(
                                children:_generatePregunta(snapshot.data[0],'¿Cúando vamos a realizar el manejo de sombra?', 11, itemMeses ),
                            )
                        ) 
                    );
                    
                    return Column(
                        children: [
                            mensajeSwipe('Deslice hacia la izquierda para continuar con el reporte'),                            
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
                                                child: textList(labelEspecie),
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

    List<Widget> _generatePregunta(List<Decisiones> decisionesList, String? titulo, int idPregunta, List<Map<String, dynamic>>  listaItem){
        List<Widget> listWidget = [];
        List<Decisiones> listDecisiones = decisionesList.where((i) => i.idPregunta == idPregunta).toList();

        listWidget.add(
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                titulo as String,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        
        
        for (var item in listDecisiones) {
                String? label= listaItem.firstWhere((e) => e['value'] == '${item.idItem}', orElse: () => {"value": "1","label": "No data"})['label'];

                listWidget.add(

                    Container(
                        child: CheckboxListTile(
                        title: textoCardBody('$label'),
                            value: item.repuesta == 1 ? true : false ,
                            activeColor: Colors.teal[900], 
                            onChanged: (value) {
                                
                            },
                        ),
                    )                  
                    
                );
        }
        return listWidget;
    }

    Future _crearPdf( TestSombra? sombra, double? areaEstacion) async{
        List dataBySombra = await _dataTableSombra(sombra!.id as String, areaEstacion);
        List<Map<String, dynamic>> conteoEspecies = await _countByEspecie(sombra.id);
        double? totalArboles = (await _arbolesPromedio(sombra.id))!*3;
        
        
        final pdfFile = await PdfApi.generateCenteredText(sombra, dataBySombra, conteoEspecies, totalArboles);
        
        PdfApi.openFile(pdfFile);
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
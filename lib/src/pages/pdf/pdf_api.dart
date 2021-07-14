
import 'dart:io';

import 'package:app_sombra/src/models/decisiones_model.dart';
import 'package:app_sombra/src/models/testsombra_model.dart';
import 'package:app_sombra/src/providers/db_provider.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:app_sombra/src/models/selectValue.dart' as selectMap;
import 'package:pdf/widgets.dart' as pw;

import 'package:pdf/widgets.dart';

class PdfApi {
    

    static Future<File> generateCenteredText(
        TestSombra? sombra,
        List? dataSombra,
        List<Map<String, dynamic>>  conteoEspecies,
        double? totalArboles
    
    ) async {
        final pdf = pw.Document();
        final font = pw.Font.ttf(await rootBundle.load('assets/fonts/Museo/Museo300.ttf'));
        Finca? finca = await DBProvider.db.getFincaId(sombra!.idFinca);
        Parcela? parcela = await DBProvider.db.getParcelaId(sombra.idLote);
        List<Decisiones> listDecisiones = await DBProvider.db.getDecisionesIdTest(sombra.id);
        double? areaEstacion = (sombra.surcoDistancia! * 10)*(sombra.plantaDistancia! * 10);

        String? labelMedidaFinca = selectMap.dimenciones().firstWhere((e) => e['value'] == '${finca!.tipoMedida}')['label'];
        String? labelvariedad = selectMap.variedadCacao().firstWhere((e) => e['value'] == '${parcela!.variedadCacao}')['label'];

        
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

        pdf.addPage(
            
            pw.MultiPage(
                pageFormat: PdfPageFormat.a4,
                build: (context) => <pw.Widget>[
                    _encabezado('Datos de finca', font),
                    pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                            pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                    _textoBody('Finca: ${finca!.nombreFinca}', font),
                                    _textoBody('Parcela: ${parcela!.nombreLote}', font),
                                    _textoBody('Productor: ${finca.nombreProductor}', font),
                                    finca.nombreTecnico != '' ?
                                    _textoBody('Técnico: ${finca.nombreTecnico}', font)
                                    : pw.Container(),

                                    _textoBody('Variedad: $labelvariedad', font),


                                ]
                            ),
                            pw.Container(
                                padding: pw.EdgeInsets.only(left: 40),
                                child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                        _textoBody('Área Finca: ${finca.areaFinca} ($labelMedidaFinca)', font),
                                        _textoBody('Área Parcela: ${parcela.areaLote} ($labelMedidaFinca)', font),
                                        _textoBody('N de plantas: ${parcela.numeroPlanta}', font),                    
                                        _textoBody('Fecha: ${sombra.fechaTest}', font),                    
                                    ]
                                ),
                            )
                        ]
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                        'Datos consolidados',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, font: font)
                    ),
                    pw.SizedBox(height: 10),
                    _tablaPoda(dataSombra, areaEstacion, font),
                    pw.SizedBox(height: 30),
                    _dominanciaEspecie('Dominancia de especies', font, conteoEspecies, totalArboles, itemEspecie),
                    _pregunta('Densidad de árboles de sombra', font, listDecisiones, 1, itemDensidad),
                    _pregunta('Forma de copa de árboles', font, listDecisiones, 2, itemForma),
                    _pregunta('Competencia de árboles con cacao', font, listDecisiones, 3, itemCompetencia),
                    _pregunta('Arreglo de árboles', font, listDecisiones, 4, itemArreglo),
                    _pregunta('Catidad de hoja rasca', font, listDecisiones, 5, itemCantidad),
                    _pregunta('Calidad de hora rasca', font, listDecisiones, 6, itemCalidad),
                    _pregunta('Acciones para mejorar la sombra', font, listDecisiones, 7, itemMejora),
                    _pregunta('Dominio de la acción', font, listDecisiones, 8, itemDominio),
                    _pregunta('Acciones para reducción de sombra', font, listDecisiones, 9, itemReduccion),
                    _pregunta('Acciones para aumento de sombra', font, listDecisiones, 10, itemAumento),
                    _pregunta('¿Cúando vamos a realizar el manejo de sombra?', font, listDecisiones, 11, itemMeses),                
                    
                ],
                footer: (context) {
                    final text = 'Page ${context.pageNumber} of ${context.pagesCount}';

                    return Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(top: 1 * PdfPageFormat.cm),
                        child: Text(
                            text,
                            style: TextStyle(color: PdfColors.black, font: font),
                        ),
                    );
                },
            )
        
        );

        return saveDocument(name: 'Reporte ${finca!.nombreFinca} ${sombra.fechaTest}.pdf', pdf: pdf);
    }

    static Future<File> saveDocument({
        required String name,
        required pw.Document pdf,
    }) async {
        final bytes = await pdf.save();

        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$name');

        await file.writeAsBytes(bytes);

        return file;
    }

    static Future openFile(File file) async {
        final url = file.path;

        await OpenFile.open(url);
    }

    static pw.Widget _encabezado(String? titulo, pw.Font fuente){
        return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
                pw.Text(
                    titulo as String,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, font: fuente)
                ),
                pw.Divider(color: PdfColors.black),
            
            ]
        );

    }

    static pw.Widget _textoBody(String? contenido, pw.Font fuente){
        return pw.Container(
            padding: pw.EdgeInsets.symmetric(vertical: 3),
            child: pw.Text(contenido as String,style: pw.TextStyle(fontSize: 12, font: fuente))
        );

    }

    static pw.Widget _dominanciaEspecie(String? titulo, pw.Font fuente, List<Map<String, dynamic>>? conteoEspecies, double? totalArboles, List<Map<String, dynamic>> itemEspecie ){
        List<pw.Widget> listWidget = [];

        listWidget.add(
            _encabezado(titulo, fuente)
        );

        for (var especie in conteoEspecies!) {
            String? labelEspecie = itemEspecie.firstWhere((e) => e['value'] == '${especie['idPlanta']}', orElse: () => {"value": "1","label": "No data"})['label'];
            double? densidad = (especie['total']/totalArboles)*100;
            listWidget.add(
                pw.Column(
                    children: [
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                                _textoBody(labelEspecie, fuente),
                                _textoBody('${densidad!.toStringAsFixed(0)}%' , fuente),
                                
                            ]
                        ),
                        pw.SizedBox(height: 10)
                    ]
                ),                    
            );
        }
            
        return pw.Container(
            padding: pw.EdgeInsets.symmetric(vertical: 10),
            child: pw.Column(children:listWidget)
        );
    }

    static pw.Widget _pregunta(String? titulo, pw.Font fuente, List<Decisiones> listDecisiones, int idPregunta, List<Map<String, dynamic>>? listaItem){

        List<pw.Widget> listWidget = [];

        listWidget.add(
            _encabezado(titulo, fuente)
        );

        for (var item in listDecisiones) {

            if (item.idPregunta == idPregunta) {
                String? label= listaItem!.firstWhere((e) => e['value'] == '${item.idItem}', orElse: () => {"value": "1","label": "No data"})['label'];

                listWidget.add(
                    pw.Column(
                        children: [
                            pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                    _textoBody(label, fuente),
                                    pw.Container(
                                        decoration: pw.BoxDecoration(
                                            border: pw.Border.all(color: PdfColors.green900),
                                            borderRadius: pw.BorderRadius.all(
                                                pw.Radius.circular(5.0)
                                            ),
                                            color: item.repuesta == 1 ? PdfColors.green900 : PdfColors.white,
                                        ),
                                        width: 10,
                                        height: 10,
                                        padding: pw.EdgeInsets.all(2),
                                        
                                    )
                                ]
                            ),
                            pw.SizedBox(height: 10)
                        ]
                    ),

                    
                    
                );
            }
        }


        return pw.Container(
            padding: pw.EdgeInsets.symmetric(vertical: 10),
            child: pw.Column(children:listWidget)
        );

    }

    static pw.Widget _tablaPoda( List? dataSombra, double? areaEstacion, Font font){
        return pw.Column(
            children: [
                pw.Table(
                    columnWidths: const <int, TableColumnWidth>{
                        0: FlexColumnWidth(),
                        1:FixedColumnWidth(200),
                    },
                    border: TableBorder.all(),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                        _crearFila( ['Area de cada sitio mt2', '$areaEstacion'], font, false),
                        _crearFila( ['Area de tres sitios mt2', '${areaEstacion!*3}'], font, false),
                    ]
                ),
                pw.Table(
                    columnWidths: const <int, TableColumnWidth>{
                        0: FlexColumnWidth(),
                        1:FixedColumnWidth(50),
                        2:FixedColumnWidth(50),
                        3:FixedColumnWidth(50),
                        4:FixedColumnWidth(50),
                    },
                    border: TableBorder.all(),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: _filasPoda(dataSombra, font)
                ),

                
            ]
        );

    }

    static pw.TableRow _crearFila(List data, Font font, bool fondo){
        List<Widget> celdas = [];

        for (var item in data) {
            celdas.add(_cellText('$item', font));
        }
        
        return pw.TableRow(children: celdas,decoration: pw.BoxDecoration(color: fondo ? PdfColors.grey300 : PdfColors.white));

    }

    static List<pw.TableRow> _filasPoda(List? dataSombra, Font font){
        List<pw.TableRow> filas = [];

        filas.add(_crearFila(['Sito', '1', '2', '3', 'Total'], font, true),);
        dataSombra!.forEach((element) {
            filas.add(_crearFila(element, font, false));
        });
        return filas;

    }

    static pw.Widget _cellText( String texto, pw.Font font){
        return pw.Container(
            padding: pw.EdgeInsets.all(5),
            child: pw.Text(texto,
                style: pw.TextStyle(font: font,)
            )
        );
    }




}



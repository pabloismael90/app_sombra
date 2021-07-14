
import 'package:app_sombra/src/models/decisiones_model.dart';
import 'package:app_sombra/src/models/testsombra_model.dart';
import 'package:app_sombra/src/providers/db_provider.dart';
import 'package:app_sombra/src/utils/widget/varios_widget.dart';
import 'package:flutter/material.dart';

class DesicionesList extends StatelessWidget {
    const DesicionesList({Key? key}) : super(key: key);

    
    Future getRegistros() async{
        
        List<Decisiones> listAcciones= await DBProvider.db.getTodasDesiciones();

        return listAcciones;
    }

    Future getDatos(String? id) async{
        
        TestSombra? testSombra= await (DBProvider.db.getTestId(id));

        Finca? finca = await DBProvider.db.getFincaId(testSombra!.idFinca);
        Parcela? parcela = await DBProvider.db.getParcelaId(testSombra.idLote);

        return [testSombra, finca, parcela];
    }

    @override
    Widget build(BuildContext context) {
        
        return Scaffold(
            appBar: AppBar(title: Text('Reportes'),),
            body: FutureBuilder(
                future: getRegistros(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                    }
                    return Column(
                        children: [
                            Expanded(
                                child:
                                snapshot.data.length == 0
                                ?
                                textoListaVacio('Complete toma de Decisiones')
                                :
                                SingleChildScrollView(child: _reporteSombra(snapshot.data, context))
                            ),
                        ],
                    );

                },
            ),
        );
    }

    Widget  _reporteSombra(List acciones, BuildContext context){
        return ListView.builder(
            itemBuilder: (context, index) {
                return FutureBuilder(
                    future: getDatos(acciones[index].idTest),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                            return CircularProgressIndicator();
                        }
                        TestSombra testSombradata = snapshot.data[0];
                        Finca fincadata = snapshot.data[1];
                        Parcela parceladata = snapshot.data[2];

                        return GestureDetector(
                            child: _cardDesiciones(testSombradata,fincadata,parceladata, context),
                            onTap: () => Navigator.pushNamed(context, 'reporte', arguments: testSombradata),
                        );
                    },
                );
               
            },
            shrinkWrap: true,
            itemCount: acciones.length,
            padding: EdgeInsets.only(bottom: 30.0),
            controller: ScrollController(keepScrollOffset: false),
        );

    }

    Widget _cardDesiciones(TestSombra sombra, Finca finca, Parcela parcela, BuildContext context){
        return cardDefault(
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    encabezadoCard('${finca.nombreFinca}','${parcela.nombreLote}', 'assets/icons/report.svg'),
                    textoCardBody('Fecha: ${sombra.fechaTest}'),
                    iconTap(' Toca para ver reporte')
                ],
            )
        );
    }
   
}
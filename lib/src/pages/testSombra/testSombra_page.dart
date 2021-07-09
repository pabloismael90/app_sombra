import 'package:app_sombra/src/bloc/fincas_bloc.dart';
import 'package:app_sombra/src/models/testsombra_model.dart';
import 'package:app_sombra/src/providers/db_provider.dart';
import 'package:app_sombra/src/utils/widget/button.dart';
import 'package:app_sombra/src/utils/widget/dialogDelete.dart';
import 'package:app_sombra/src/utils/widget/varios_widget.dart';
import 'package:flutter/material.dart';


final fincasBloc = new FincasBloc();

class TestPage extends StatefulWidget {

    

  @override
  _TestPageState createState() => _TestPageState();
}


class _TestPageState extends State<TestPage> {

    
    Future _getdataFinca(TestSombra textSombra) async{
        Finca? finca = await DBProvider.db.getFincaId(textSombra.idFinca);
        Parcela? parcela = await DBProvider.db.getParcelaId(textSombra.idLote);
        return [finca, parcela];
    }

    @override
    Widget build(BuildContext context) {
        var size = MediaQuery.of(context).size;
        fincasBloc.obtenerSombra();

        return Scaffold(
                appBar: AppBar(),
                body: StreamBuilder<List<TestSombra>>(
                    stream: fincasBloc.podaStream,

                    
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());

                        }

                        List<TestSombra> textSombras= snapshot.data;

                        return Column(
                            children: [
                                Expanded(
                                    child:
                                    snapshot.data.length == 0
                                    ?
                                    textoListaVacio('Complete toma de Decisiones')
                                    :
                                    SingleChildScrollView(child: _listaSombra(textSombras, size, context))
                                ),
                            ],
                        );
                        
                        
                    },
                ),
                bottomNavigationBar: botonesBottom(_addtest(context)),
        );
        
    }

    Widget _addtest(BuildContext context){
        return Row(
            children: [
                Spacer(),
                ButtonMainStyle(
                    title: 'Escoger parcelas',
                    icon: Icons.post_add,
                    press: () => Navigator.pushNamed(context, 'addTest'),
                ),
                Spacer()
            ],
        );
    }

    Widget  _listaSombra(List textSombra, Size size, BuildContext context){
        return ListView.builder(
            itemBuilder: (context, index) {
                return Dismissible(
                    key: UniqueKey(),
                    child: GestureDetector(
                        child: FutureBuilder(
                            future: _getdataFinca(textSombra[index]),
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                                if (!snapshot.hasData) {
                                    return Center(child: CircularProgressIndicator());
                                }
                                Finca finca = snapshot.data[0];
                                Parcela parcela = snapshot.data[1];

                                return _cardDesing(textSombra[index], finca, parcela);
                            },
                        ),
                        onTap: () => Navigator.pushNamed(context, 'estaciones', arguments: textSombra[index]),
                    ),
                    confirmDismiss: (direction) => confirmacionUser(direction, context),
                    direction: DismissDirection.endToStart,
                    background: backgroundTrash(context),
                    movementDuration: Duration(milliseconds: 500),
                    onDismissed: (direction) => fincasBloc.borrarTestSombra(textSombra[index].id),
                );
               
            },
            shrinkWrap: true,
            itemCount: textSombra.length,
            padding: EdgeInsets.only(bottom: 30.0),
            controller: ScrollController(keepScrollOffset: false),
        );

    }

    Widget _cardDesing(TestSombra textSombra, Finca finca, Parcela parcela){
        
        return cardDefault(
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    encabezadoCard('${finca.nombreFinca}','${parcela.nombreLote}', 'assets/icons/test.svg'),
                    textoCardBody('Fecha: ${textSombra.fechaTest}'),
                    iconTap(' Tocar para completar datos')
                ],
            )
        );
    }


}
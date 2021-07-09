import 'package:app_sombra/src/bloc/fincas_bloc.dart';
import 'package:app_sombra/src/models/decisiones_model.dart';
import 'package:app_sombra/src/models/estacion_model.dart';
import 'package:app_sombra/src/models/finca_model.dart';
import 'package:app_sombra/src/models/parcela_model.dart';
import 'package:app_sombra/src/models/testsombra_model.dart';
import 'package:app_sombra/src/providers/db_provider.dart';
import 'package:app_sombra/src/utils/constants.dart';
import 'package:app_sombra/src/utils/widget/button.dart';
import 'package:app_sombra/src/utils/widget/titulos.dart';
import 'package:app_sombra/src/utils/widget/varios_widget.dart';
import 'package:flutter/material.dart';

class EstacionesPage extends StatefulWidget {
    const EstacionesPage({Key? key}) : super(key: key);

  @override
  _EstacionesPageState createState() => _EstacionesPageState();
}

class _EstacionesPageState extends State<EstacionesPage> {

    final fincasBloc = new FincasBloc();
    List<int>? countEspecie;

    Future _getdataFinca(TestSombra textPlaga) async{
        Finca? finca = await DBProvider.db.getFincaId(textPlaga.idFinca);
        Parcela? parcela = await DBProvider.db.getParcelaId(textPlaga.idLote);
        
        return [finca, parcela];
    }

    @override
    Widget build(BuildContext context) {
        
        TestSombra sombra = ModalRoute.of(context)!.settings.arguments as TestSombra;
        fincasBloc.allEstacionsByTest(sombra.id);
        

        return StreamBuilder(
            stream: fincasBloc.allestacionesStream,
            builder: (BuildContext context, AsyncSnapshot snapshot){
                if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                }

                List<Estacion>? estaciones = snapshot.data;
                fincasBloc.comprobarInventario(sombra.id);
                

                return Scaffold(
                    appBar: AppBar(),
                    body: Column(
                        children: [
                            escabezadoEstacion( context, sombra ),
                            TitulosPages(titulo: 'Lista de sitios'),
                            Expanded(
                                child: StreamBuilder(
                                    stream: fincasBloc.comprobarStream,
                                    builder: (BuildContext context, AsyncSnapshot snapshot){

                                        if (!snapshot.hasData) {
                                            return CircularProgressIndicator();
                                        }

                                        List<int>? countEspecie = snapshot.data;

                                        return SingleChildScrollView(
                                            child: _listaDeEstaciones( context, sombra, countEspecie),
                                        );
                                    },
                                )
                                
                            ),
                        ],
                    ),
                    
                    bottomNavigationBar: botonesBottom(_tomarDecisiones(estaciones, sombra)),
                );
            },
        );
    
    }



    Widget escabezadoEstacion( BuildContext context, TestSombra testSombra ){


        return FutureBuilder(
            future: _getdataFinca(testSombra),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                }
                Finca finca = snapshot.data[0];
                Parcela parcela = snapshot.data[1];

                return Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.only(bottom: 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            encabezadoCard('Área finca: ${finca.nombreFinca}','Productor: ${finca.nombreProductor}', 'assets/icons/finca.svg'),
                            Wrap(
                                spacing: 20,
                                children: [
                                    textoCardBody('Área finca: ${finca.areaFinca}'),
                                    textoCardBody('Área parcela: ${parcela.areaLote} ${finca.tipoMedida == 1 ? 'Mz': 'Ha'}'), 
                                ],
                            )
                        ],
                    ),
                );
            },
        );        
    }

    Widget  _listaDeEstaciones( BuildContext context, TestSombra sombra, List<int>? countEspecie){
        
        return ListView.builder(
            itemBuilder: (context, index) {
                
                return GestureDetector(
                    child: _cardTest(index+1, countEspecie![index]),
                    onTap: () => Navigator.pushNamed(context, 'inventario', arguments: [sombra, index]),
                );
            },
            shrinkWrap: true,
            itemCount:  sombra.estaciones,
            padding: EdgeInsets.only(bottom: 30.0),
            controller: ScrollController(keepScrollOffset: false),
        );
         

    }

    Widget _cardTest(int estacion, int countEstacion){
        return cardDefault(
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Flexible(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                                tituloCard('Sitio $estacion'),
                                subtituloCardBody('Número de especies:: $countEstacion')
                            ],  
                        ),
                    ),
                    Container(
                        child: Icon(Icons.check_circle, 
                            color: countEstacion == 0 ? Colors.black38 : Colors.green[900],
                            size: 25,
                        ),
                        
                    ) 
                    
                    
                ],
            )
        );
    }
   

    Widget  _tomarDecisiones(List<Estacion>? estaciones, TestSombra sombra){

        
        return StreamBuilder(
            stream: fincasBloc.comprobarStream ,
            builder: (BuildContext context, AsyncSnapshot snapshot){

                if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                }

                countEspecie = snapshot.data;

                if (estaciones!.length >= 3 && !countEspecie!.contains(0)) {
                    fincasBloc.obtenerDecisiones(sombra.id);

                     return StreamBuilder(
                        stream: fincasBloc.decisionesStream ,
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (!snapshot.hasData) {
                                return Center(child: CircularProgressIndicator());
                            }
                            List<Decisiones> desiciones = snapshot.data;

                            if (desiciones.length == 0){

                                return Row(
                                    children: [
                                        Spacer(),
                                        ButtonMainStyle(
                                            title: 'Toma de decisiones',
                                            icon: Icons.post_add,
                                            press:() => Navigator.pushNamed(context, 'decisiones', arguments: sombra),
                                        ),
                                        Spacer(),
                                    ],
                                );
                                
                            }

                            return Row(
                                children: [
                                    Spacer(),
                                        ButtonMainStyle(
                                        title: 'Consultar decisiones',
                                        icon: Icons.receipt_rounded,
                                        press: () => Navigator.pushNamed(context, 'reporte', arguments: sombra),
                                    ),
                                    Spacer(),
                                ],
                            );

                
                                            
                        },  
                    );
                    
                }
                return Container(
                    child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Text(
                            "Complete las estaciones",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w900, color: kRedColor, fontSize: 18)
                        ),
                    ),
                );
                
                
            },
        );
    }


}
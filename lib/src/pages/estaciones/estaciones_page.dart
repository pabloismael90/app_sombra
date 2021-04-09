import 'package:app_sombra/src/bloc/fincas_bloc.dart';
import 'package:app_sombra/src/models/estacion_model.dart';
import 'package:app_sombra/src/models/finca_model.dart';
import 'package:app_sombra/src/models/parcela_model.dart';
import 'package:app_sombra/src/models/testsombra_model.dart';
import 'package:app_sombra/src/providers/db_provider.dart';
import 'package:app_sombra/src/utils/constants.dart';
import 'package:app_sombra/src/utils/widget/titulos.dart';
import 'package:flutter/material.dart';

class EstacionesPage extends StatefulWidget {
    const EstacionesPage({Key key}) : super(key: key);

  @override
  _EstacionesPageState createState() => _EstacionesPageState();
}

class _EstacionesPageState extends State<EstacionesPage> {

    final fincasBloc = new FincasBloc();
    List<int> countEspecie;

    Future _getdataFinca(TestSombra textPlaga) async{
        Finca finca = await DBProvider.db.getFincaId(textPlaga.idFinca);
        Parcela parcela = await DBProvider.db.getParcelaId(textPlaga.idLote);
        
        return [finca, parcela];
    }

    @override
    Widget build(BuildContext context) {
        
        TestSombra sombra = ModalRoute.of(context).settings.arguments;
        fincasBloc.allEstacionsByTest(sombra.id);
        
        

        return StreamBuilder(
            stream: fincasBloc.allestacionesStream,
            builder: (BuildContext context, AsyncSnapshot snapshot){
                if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                }

                List<Estacion> estaciones = snapshot.data;
                fincasBloc.comprobarInventario(sombra.id);

                return Scaffold(
                    appBar: AppBar(),
                    body: Column(
                        children: [
                            escabezadoEstacion( context, sombra ),
                            TitulosPages(titulo: 'Estaciones'),
                            Divider(),
                            Expanded(
                                child: StreamBuilder(
                                    stream: fincasBloc.comprobarStream ,
                                    builder: (BuildContext context, AsyncSnapshot snapshot){

                                        if (!snapshot.hasData) {
                                            return CircularProgressIndicator();
                                        }

                                        List<int> countEspecie = snapshot.data;

                                        return SingleChildScrollView(
                                            child: _listaDeEstaciones( context, sombra, countEspecie),
                                        );
                                    },
                                )
                                
                            ),
                        ],
                    ),
                    bottomNavigationBar: BottomAppBar(
                        child: _tomarDecisiones(estaciones, sombra)
                    ),
                );
            },
        );
    
    }



    Widget escabezadoEstacion( BuildContext context, TestSombra sombra ){


        return FutureBuilder(
            future: _getdataFinca(sombra),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                }
                Finca finca = snapshot.data[0];
                Parcela parcela = snapshot.data[1];

                return Container(
                    
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
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
                                                style: TextStyle(color: kLightBlackColor),
                                            ),
                                        ),
                                        
                                    ],  
                                ),
                            ),
                        ],
                    ),
                );
            },
        );        
    }

    Widget  _listaDeEstaciones( BuildContext context, TestSombra sombra, List<int> countEspecie){
        
        return ListView.builder(
            itemBuilder: (context, index) {
                
                return GestureDetector(
                    child: _cardTest(index+1, countEspecie[index]),
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


        return Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
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
                                            "Estación $estacion",
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: Theme.of(context).textTheme.headline6,
                                        ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 10.0),
                                        child: Text(
                                                'Número de especies:: $countEstacion',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(color: kLightBlackColor),
                                            ),
                                    ),
                                    
                                ],  
                            ),
                        ),    
                        
                    ],
                ),
        );
    }
   

    Widget  _tomarDecisiones(List<Estacion> estaciones, TestSombra sombrae){


        return StreamBuilder(
            stream: fincasBloc.comprobarStream ,
            builder: (BuildContext context, AsyncSnapshot snapshot){

                if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                }

                countEspecie = snapshot.data;

                if (estaciones.length >= 3 && !countEspecie.contains(0)) {
                    return Container(
                        color: kBackgroundColor,
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                            child: RaisedButton.icon(
                                icon:Icon(Icons.add_circle_outline_outlined),
                                
                                label: Text('Toma de decisiones',
                                    style: Theme.of(context).textTheme
                                        .headline6
                                        .copyWith(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)
                                ),
                                padding:EdgeInsets.all(13),
                                //onPressed: () => Navigator.pushNamed(context, 'decisiones', arguments: sombra),
                                onPressed: (){},
                            )
                        ),
                    );
                }
                return Container(
                    color: kBackgroundColor,
                    child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Text(
                            "Complete las estaciones",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme
                                .headline5
                                .copyWith(fontWeight: FontWeight.w900, color: kRedColor, fontSize: 22)
                        ),
                    ),
                );
                
                
            },
        );
    }
}
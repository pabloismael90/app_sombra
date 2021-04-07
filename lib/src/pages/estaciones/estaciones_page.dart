import 'package:app_sombra/src/bloc/fincas_bloc.dart';
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

    Future _getdataFinca(TestSombra textPlaga) async{
        Finca finca = await DBProvider.db.getFincaId(textPlaga.idFinca);
        Parcela parcela = await DBProvider.db.getParcelaId(textPlaga.idLote);
        
        return [finca, parcela];
    }

    @override
    Widget build(BuildContext context) {
        
        TestSombra sombra = ModalRoute.of(context).settings.arguments;
        //fincasBloc.obtenerPlantas(poda.id);
        int estacion1 = 0;
        int estacion2 = 0;
        int estacion3 = 0;
        List countEstaciones = [estacion1,estacion2,estacion3];
        return Scaffold(
            appBar: AppBar(),
            body: Column(
                children: [
                    escabezadoEstacion( context, sombra ),
                    TitulosPages(titulo: 'Estaciones'),
                    Divider(),
                    Expanded(
                        child: SingleChildScrollView(
                            child: _listaDeEstaciones( context, sombra),
                        ),
                    ),
                ],
            ),
            bottomNavigationBar: BottomAppBar(
                child: _tomarDecisiones(countEstaciones, sombra)
            ),
        );

    //    return StreamBuilder<List<Planta>>(
    //         stream: fincasBloc.countPlanta,
    //         builder: (BuildContext context, AsyncSnapshot snapshot){
    //             if (!snapshot.hasData) {
    //                 return CircularProgressIndicator();
    //             }
    //             List<Planta> plantas= snapshot.data;
    //             //print(plantas.length);
    //             fincasBloc.obtenerDecisiones(poda.id);
    //             int estacion1 = 0;
    //             int estacion2 = 0;
    //             int estacion3 = 0;
    //             List countEstaciones = [];

    //             for (var item in plantas) {
    //                 if (item.estacion == 1) {
    //                     estacion1 ++;
    //                 } else if (item.estacion == 2){
    //                     estacion2 ++;
    //                 }else{
    //                     estacion3 ++;
    //                 }
    //             }
    //             countEstaciones = [estacion1,estacion2,estacion3];
                
    //             return Scaffold(
    //                 appBar: AppBar(),
    //                 body: Column(
    //                     children: [
    //                         escabezadoEstacion( context, poda ),
    //                         TitulosPages(titulo: 'Estaciones'),
    //                         Divider(),
    //                         Expanded(
    //                             child: SingleChildScrollView(
    //                                 child: _listaDeEstaciones( context, poda, countEstaciones ),
    //                             ),
    //                         ),
    //                     ],
    //                 ),
    //                 bottomNavigationBar: BottomAppBar(
    //                     child: _tomarDecisiones(countEstaciones, poda)
    //                 ),
    //             );
    //         },
    //     );
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

    Widget  _listaDeEstaciones( BuildContext context, TestSombra sombra){
        return ListView.builder(
            itemBuilder: (context, index) {
                
                return GestureDetector(
                    child: _cardTest(index+1),
                    onTap: () => Navigator.pushNamed(context, 'inventario', arguments: [sombra, index]),
                );
                
               
            },
            shrinkWrap: true,
            itemCount:  sombra.estaciones,
            padding: EdgeInsets.only(bottom: 30.0),
            controller: ScrollController(keepScrollOffset: false),
        );

    }

    Widget _cardTest(int estacion){
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                    
                                ],  
                            ),
                        ),    
                        
                    ],
                ),
        );
    }
   

    Widget  _tomarDecisiones(List countEstaciones, TestSombra poda){
        
        // if(countEstaciones[0] >= 10 && countEstaciones[1] >= 10 && countEstaciones[2] >= 10){
            
        //     return StreamBuilder(
        //     stream: fincasBloc.decisionesStream ,
        //         builder: (BuildContext context, AsyncSnapshot snapshot) {
        //             if (!snapshot.hasData) {
        //                 return Center(child: CircularProgressIndicator());
        //             }
        //             List desiciones = snapshot.data;

        //             //print(desiciones);

        //             if (desiciones.length == 0){

        //                 return Container(
        //                     color: kBackgroundColor,
        //                     child: Padding(
        //                         padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
        //                         child: RaisedButton.icon(
        //                             icon:Icon(Icons.add_circle_outline_outlined),
                                    
        //                             label: Text('Toma de decisiones',
        //                                 style: Theme.of(context).textTheme
        //                                     .headline6
        //                                     .copyWith(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)
        //                             ),
        //                             padding:EdgeInsets.all(13),
        //                             onPressed: () => Navigator.pushNamed(context, 'decisiones', arguments: poda),
        //                         )
        //                     ),
        //                 );
                        
        //             }


        //             return Container(
        //                 color: kBackgroundColor,
        //                 child: Padding(
        //                     padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
        //                     child: RaisedButton.icon(
        //                         icon:Icon(Icons.receipt_rounded),
                            
        //                         label: Text('Consultar decisiones',
        //                             style: Theme.of(context).textTheme
        //                                 .headline6
        //                                 .copyWith(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)
        //                         ),
        //                         padding:EdgeInsets.all(13),
        //                         onPressed: () => Navigator.pushNamed(context, 'reporte', arguments: poda.id),
        //                     )
        //                 ),
        //             );
                                       
        //         },  
        //     );
        // }
        

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
    }
}
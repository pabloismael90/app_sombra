import 'package:app_sombra/src/bloc/fincas_bloc.dart';
import 'package:app_sombra/src/models/decisiones_model.dart';
import 'package:app_sombra/src/models/estacion_model.dart';
import 'package:app_sombra/src/models/finca_model.dart';
import 'package:app_sombra/src/models/parcela_model.dart';
import 'package:app_sombra/src/models/testsombra_model.dart';
import 'package:app_sombra/src/providers/db_provider.dart';
import 'package:app_sombra/src/utils/constants.dart';
import 'package:app_sombra/src/utils/widget/button.dart';
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
                    appBar: AppBar(title: Text('Completar datos'),),
                    body: Column(
                        children: [
                            escabezadoEstacion( context, sombra ),
                            _textoExplicacion('Lista de sitios'),
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
                            encabezadoCard('${finca.nombreFinca}','Parcela: ${parcela.nombreLote}', 'assets/icons/finca.svg'),
                            Wrap(
                                spacing: 20,
                                children: [
                                    textoCardBody('Productor: ${finca.nombreProductor}'),
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

    Widget _textoExplicacion(String? titulo){
        return Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: InkWell(
                child: Column(
                    children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                                Container(                                                                    
                                    child: Text(
                                        titulo!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)
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
                        SizedBox(height: 5,),
                        Row(
                            children: List.generate(
                                150~/2, (index) => Expanded(
                                    child: Container(
                                        color: index%2==0?Colors.transparent
                                        :kShadowColor2,
                                        height: 2,
                                    ),
                                )
                            ),
                        ),
                    ],
                ),
                onTap: () => _explicacion(context),
            ),
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

    Future<void> _explicacion(BuildContext context){

        return dialogText(
            context,
            Column(
                children: [
                    textoCardBody('•	Realizar un recorrido de la parcela SAF cacao para identificar los 3 sitios para las observaciones. '),
                    textoCardBody('•	En cada uno de los tres puntos, identificar un cuadro de 10 surcos con 10 plantas de cacao en cada surco, para un total de 100 plantas. Si el distanciamiento de las plantas es 3 x 3 mt, este cuadro debe representar 900 mt2. Se realiza observaciones en el cuadro para completar el inventario de los árboles acompañantes incluyendo musáceas. '),
                    textoCardBody('•	Seguir los pasos de la aplicación para la toma de datos en los tres puntos. Una vez completado este paso, la aplicación le dirigirá a la pantalla de toma de decisiones. Seguir los pasos revelados por la aplicación, grabando los datos e información como solicita la aplicación.'),
                ],
            ),
            'Metodología aplicación sombra'
        );
    }

}
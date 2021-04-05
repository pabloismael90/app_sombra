import 'package:app_sombra/src/bloc/fincas_bloc.dart';
import 'package:app_sombra/src/models/estacion_model.dart';
import 'package:app_sombra/src/models/testsombra_model.dart';
import 'package:app_sombra/src/utils/constants.dart';
import 'package:uuid/uuid.dart';
import 'package:app_sombra/src/utils/validaciones.dart' as utils;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';




class InventarioPage extends StatefulWidget {
    InventarioPage({Key key}) : super(key: key);
    final scaffoldKey = GlobalKey<ScaffoldState>();

    @override
    _InventarioPageState createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {

    final fincasBloc = new FincasBloc();
    final formKey = GlobalKey<FormState>();
    bool _guardando = false;
    var uuid = Uuid();
    TestSombra testSombra;
    int numeroEstacion;

    Estacion estacion = Estacion();

    @override
    Widget build(BuildContext context) {
        List dataSombra = ModalRoute.of(context).settings.arguments;
        testSombra = dataSombra[0];
        numeroEstacion = dataSombra[1]+1;

        return _body(context, testSombra, numeroEstacion);
    }

    Widget _body( BuildContext context, TestSombra sombra, int nEstacion){

        fincasBloc.obtenerEstacion(sombra.id, nEstacion);

        return StreamBuilder(
            stream: fincasBloc.estacionStream,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                }

                estacion = snapshot.data;
                if (snapshot.data.id == null) {

                    return Scaffold(
                        appBar: AppBar(),
                        body: _coberturaForm(),
                    );
                }

                return Scaffold(
                    appBar: AppBar(),
                    body: Column(
                        children: [
                            _dataEstacion(sombra),
                        ],
                    ),
                    bottomNavigationBar: _addPlanta(estacion),
                );
            },
        );        
    }

    Widget _dataEstacion(TestSombra sombra){
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
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                
                    
                    Text(
                        "Estación ${estacion.nestacion}",
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.headline6,
                    ),
                    SizedBox(height: 10,),
                
                    Text(
                        "Cobertura: ${estacion.cobertura}%",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: kLightBlackColor),
                    ),
                    SizedBox(height: 10,),
                    Text(
                        "Area de estación mt2: ${sombra.surcoDistancia * 10} x ${sombra.plantaDistancia * 10}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: kLightBlackColor),
                    ),
                    
                ],  
            ),
        );
    }

    Widget _coberturaForm(){
        return Padding(
            padding: EdgeInsets.all(15),
            child: Column(
                children: [
                    Form(
                        key: formKey,
                        child: TextFormField(
                            initialValue: estacion.cobertura.toString(),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                            ], 
                            decoration: InputDecoration(
                                labelText: 'Ingresar Porcentaje de Cobertura'
                            ),
                            validator: (value) {

                                if (utils.isNumeric(value)){
                                    if (double.parse(value) > 0 && double.parse(value) <= 100) {
                                        return null;
                                    } else {
                                        return 'Porcentar entre 1 y 100';
                                    }
                                }else{
                                    return 'Solo números';
                                }
                            },
                            onSaved: (value) => estacion.cobertura = double.parse(value),
                        ),
                    ),
                    SizedBox(height: 20,),
                    RaisedButton.icon(
            
                        icon:Icon(Icons.save, color: Colors.white,),
                        
                        label: Text('Guardar',
                            style: Theme.of(context).textTheme
                                .headline6
                                .copyWith(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)
                        ),
                        padding:EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                        onPressed:(_guardando) ? null : _submit,
                    ),
                ],
            )
        );
    }

    Widget _addPlanta(Estacion estacion){
        return BottomAppBar(
            child: Container(
                color: kBackgroundColor,
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    child: RaisedButton.icon(
                        icon:Icon(Icons.add_circle_outline_outlined),
                        
                        label: Text('Agregar Planta',
                            style: Theme.of(context).textTheme
                                .headline6
                                .copyWith(fontWeight: FontWeight.w600, color: Colors.white)
                        ),
                        padding:EdgeInsets.all(13),
                        onPressed:() => Navigator.pushNamed(context, 'addPlanta', arguments: estacion),
                    ),
                ),
            ),
        );
}

    void _submit( ){

        if  ( !formKey.currentState.validate() ){
            return null;
        }
        
        formKey.currentState.save();

        setState(() {_guardando = true;});

        estacion.id = uuid.v1();
        estacion.idTestSombra = testSombra.id;
        estacion.nestacion = numeroEstacion;
        
        print(estacion.id);
        print(estacion.idTestSombra);
        print(estacion.cobertura);
        print(estacion.nestacion);
       
       fincasBloc.addEstacion(estacion, estacion.idTestSombra, estacion.nestacion);
        


        setState(() {_guardando = false;});
        


        //Navigator.pop(context, 'fincas');
       
        
    }
}



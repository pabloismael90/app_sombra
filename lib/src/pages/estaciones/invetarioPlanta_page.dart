import 'package:app_sombra/src/bloc/fincas_bloc.dart';
import 'package:app_sombra/src/models/estacion_model.dart';
import 'package:app_sombra/src/models/inventarioPlanta_model.dart';
import 'package:app_sombra/src/models/testsombra_model.dart';
import 'package:app_sombra/src/pages/testSombra/testSombra_page.dart';
import 'package:app_sombra/src/utils/constants.dart';
import 'package:app_sombra/src/utils/widget/button.dart';
import 'package:app_sombra/src/utils/widget/dialogDelete.dart';
import 'package:app_sombra/src/utils/widget/varios_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:app_sombra/src/utils/validaciones.dart' as utils;
import 'package:app_sombra/src/models/selectValue.dart' as selectMap;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';




class InventarioPage extends StatefulWidget {
    InventarioPage({Key? key}) : super(key: key);
    final scaffoldKey = GlobalKey<ScaffoldState>();

    @override
    _InventarioPageState createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {

    final fincasBloc = new FincasBloc();
    final formKey = GlobalKey<FormState>();
    bool _guardando = false;
    var uuid = Uuid();
    late TestSombra testSombra;
    int? numeroEstacion;

    Estacion? estacion = Estacion();
    List<InventacioPlanta>? plantas;

    @override
    Widget build(BuildContext context) {
        List dataSombra = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
        testSombra = dataSombra[0];
        numeroEstacion = dataSombra[1]+1;
        
        return _body(context, testSombra, numeroEstacion);
    }

    Widget _body( BuildContext context, TestSombra sombra, int? nEstacion){

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
                            _listaPlanta(estacion!.id, sombra.id)
                        ],
                    ),
                    bottomNavigationBar: BottomAppBar(
                        child: Container(
                            color: kBackgroundColor,
                            child: Padding(
                                padding: EdgeInsets.symmetric( vertical: 10),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                        Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                            child: _addPlanta(estacion),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                            child: _netEstacion(sombra, estacion!),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                    ),
                );
            },
        );        
    }

    Widget _dataEstacion(TestSombra sombra){
        return Container(
            color: Colors.white,
            padding: EdgeInsets.all(15),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Flexible(
                                child: Container(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            tituloCard('Sitio ${estacion!.nestacion}'),
                                            subtituloCardBody('Cobertura: ${estacion!.cobertura}%')
                                        ],
                                    ),
                                ),
                            ),
                            
                            TextButton(
                                // onPressed: () => Navigator.pushNamed(context, 'addFinca', arguments: finca),
                                onPressed: () => _dialogText(estacion!, context),
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(kmorado),
                                ),
                                child: Row(
                                    children: [
                                        Icon(Icons.mode_edit_outlined, color: kwhite, size: 16,),
                                        SizedBox(width: 5,),
                                        Text('Editar', style: TextStyle(color: kwhite, fontWeight: FontWeight.bold),)
                                    ],
                                ),
                            )
                        ],
                    ),
                    textoCardBody('Área del sitio mt2: ${sombra.surcoDistancia! * 10} x ${sombra.plantaDistancia! * 10}'),         

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
                            initialValue: estacion!.cobertura == null ? '' : estacion!.cobertura.toString(),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                            ], 
                            decoration: InputDecoration(
                                labelText: 'Ingresar Porcentaje de Cobertura',
                                hintText: 'ejem: 20',
                            ),
                            validator: (value) => utils.validateEntero(value),
                            onSaved: (value) => estacion!.cobertura = double.parse(value!),
                        ),
                    ),
                    SizedBox(height: 20,),
                    ButtonMainStyle(
                        title: 'Guardar',
                        icon: Icons.post_add,
                        press: (_guardando) ? null : _submit,
                    )
                    
                ],
            )
        );
    }

    Widget _listaPlanta(String? idEstacion, String? idTestSombra){

        fincasBloc.obtenerInventario(idEstacion);

        return StreamBuilder(
            stream: fincasBloc.inventarioStream,
            builder: (BuildContext context, AsyncSnapshot snapshot){
                if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                }
                plantas = snapshot.data;

                if (plantas!.length == 0) {
                    return Expanded(child: textoListaVacio('Ingrese datos de especies'));
                }

                return Expanded(
                    child: SingleChildScrollView(
                        child: ListView.builder(
                            itemBuilder: (context, index) {
                                
                                return Dismissible(
                                    key: UniqueKey(),
                                    child: GestureDetector(
                                        child: _cardEspecie(plantas![index]),
                                    ),
                                    confirmDismiss: (direction) => confirmacionUser(direction, context),
                                    direction: DismissDirection.endToStart,
                                    background: backgroundTrash(context),
                                    movementDuration: Duration(milliseconds: 500),
                                    onDismissed: (direction) => fincasBloc.borrarEspecie(plantas![index].idPlanta, plantas![index].idEstacion, idTestSombra),
                                );
                            
                            },
                            shrinkWrap: true,
                            itemCount: plantas!.length,
                            padding: EdgeInsets.only(bottom: 30.0),
                            controller: ScrollController(keepScrollOffset: false),
                        )
                    )
                );
            },
        );
    }

    Widget _cardEspecie(InventacioPlanta planta){
        final nombrePlanta = selectMap.especies().firstWhere((e) => e['value'] == '${planta.idPlanta}')['label'];
        final labelUso = selectMap.listaUso().firstWhere((e) => e['value'] == '${planta.uso}')['label'];
        return cardDefault(
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                
                    tituloCard('$nombrePlanta'),
                    Wrap(
                        spacing: 15,
                        children: [
                            textoCardBody('Pequeño: ${planta.pequeno}'),
                            textoCardBody('Mediano: ${planta.mediano}'),
                            textoCardBody('Grande: ${planta.grande}'),
                            textoCardBody('Uso: $labelUso'),
                        ],
                    ),                    
                ],  
            )

        );
    }
   



    Widget _addPlanta(Estacion? estacion){


        return ButtonMainStyle(
            title: 'Agregar planta',
            icon: Icons.post_add,
            press: () => Navigator.pushNamed(context, 'addPlanta', arguments:[estacion, plantas]),
        );

        
        
    }
    
    
    Widget _netEstacion(TestSombra sombra, Estacion estacion){
        fincasBloc.obtenerInventario(estacion.id);
        return StreamBuilder(
            stream: fincasBloc.inventarioStream,
            builder: (BuildContext context, AsyncSnapshot snapshot){
                if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                }
                plantas = snapshot.data;

                if (plantas!.length == 0) {
                    return ButtonMainStyle(
                        title: 'Siguiente Sitio',
                        icon: Icons.navigate_next_rounded,
                        press: null,
                    );
                } else {
                    if (estacion.nestacion! <= 2){
                        return ButtonMainStyle(
                            title: 'Siguiente Sitio',
                            icon: Icons.navigate_next_rounded,
                            press: () => Navigator.popAndPushNamed(context, 'inventario', arguments: [sombra, estacion.nestacion]),
                        );
                    } else {
                        return ButtonMainStyle(
                            title: 'Lista de sitios',
                            icon: Icons.chevron_left,
                            press: () =>  Navigator.pop(context),
                        );
                    }
                }
            },
        );

       
          
       
        
        
    } 
    

    void _submit( ){

        if  ( !formKey.currentState!.validate() ){
            return null;
        }
        
        formKey.currentState!.save();

        setState(() {_guardando = true;});

        estacion!.id = uuid.v1();
        estacion!.idTestSombra = testSombra.id;
        estacion!.nestacion = numeroEstacion;
       
        fincasBloc.addEstacion(estacion!, estacion!.idTestSombra, estacion!.nestacion);
        
        


        setState(() {_guardando = false;});
       
        
    }
}

Future<void> _dialogText(Estacion estacion, BuildContext context) async {
    final formUpdate = GlobalKey<FormState>();
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
            return AlertDialog(
                title: Text('Titulo'),
                content: SingleChildScrollView(
                    child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                            children: [
                                Form(
                                    key: formUpdate,
                                    child: TextFormField(
                                        initialValue: estacion.cobertura == null ? '' : estacion.cobertura.toString(),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.digitsOnly
                                        ], 
                                        decoration: InputDecoration(
                                            labelText: 'Ingresar Porcentaje de Cobertura',
                                            hintText: 'ejem: 20',
                                        ),
                                        validator: (value) => utils.floatSiCero(value!),
                                        onSaved: (value) => estacion.cobertura = double.parse(value!),
                                    ),
                                ),
                                SizedBox(height: 20,),
                                ButtonMainStyle(
                                    title: 'Guardar',
                                    icon: Icons.post_add,
                                    press: () {
                                        if  ( !formUpdate.currentState!.validate() ){
                                            return null;
                                        }
                                        formUpdate.currentState!.save();
                                        fincasBloc.actualizarEstacion(estacion);
                                        Navigator.of(context).pop();
                                    }
                                    
                                )
                                
                            ],
                        )
                    ),
                ),
                actions: <Widget>[
                    TextButton(
                        child: Text('Cerrar'),
                        onPressed: () {
                        Navigator.of(context).pop();
                        },
                    ),
                ],
            );
        },
    );
}


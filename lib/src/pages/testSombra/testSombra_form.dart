//import 'dart:html';

import 'package:app_sombra/src/models/testsombra_model.dart';
import 'package:app_sombra/src/utils/widget/titulos.dart';
import 'package:flutter/material.dart';

import 'package:app_sombra/src/bloc/fincas_bloc.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:app_sombra/src/utils/validaciones.dart' as utils;

class AgregarTest extends StatefulWidget {

  @override
  _AgregarTestState createState() => _AgregarTestState();
}

class _AgregarTestState extends State<AgregarTest> {

    final formKey = GlobalKey<FormState>();
    final scaffoldKey = GlobalKey<ScaffoldState>();



    TestSombra sombra = new TestSombra();
    final fincasBloc = new FincasBloc();

    bool _guardando = false;
    var uuid = Uuid();
    String idFinca ='';

    //Configuracion de FEcha
    DateTime _dateNow = new DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    String _fecha = '';
    TextEditingController _inputfecha = new TextEditingController();

    List<TestSombra>? mainlistsombras ;

    List? mainparcela;
    TextEditingController? _control;

    @mustCallSuper
    // ignore: must_call_super
    void initState(){
        _fecha = formatter.format(_dateNow);
        _inputfecha.text = _fecha;


    }




    @override
    Widget build(BuildContext context) {

        fincasBloc.selectFinca();



        return StreamBuilder(
            stream: fincasBloc.fincaSelect,
            //future: DBProvider.db.getSelectFinca(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
                //print(snapshot.data);
                if (!snapshot.hasData) {
                    return Scaffold(body: CircularProgressIndicator(),);
                } else {

                    List<Map<String, dynamic>> _listitem = snapshot.data;
                    return Scaffold(
                        key: scaffoldKey,
                        appBar: AppBar(),
                        body: SingleChildScrollView(
                            child: Column(
                                children: [
                                    TitulosPages(titulo: 'Toma de datos'),
                                    Divider(),
                                    Container(
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                                    child:Text(
                                                        'Plantas por estaciones: 100 plantas 10x 10',
                                                        style: Theme.of(context).textTheme
                                                            .headline6!
                                                            .copyWith(fontSize: 16)
                                                    ),
                                                ),
                                                Divider(),
                                                Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                                    child:Text(
                                                        '3 Estaciones',
                                                        style: Theme.of(context).textTheme
                                                            .headline6!
                                                            .copyWith(fontSize: 16)
                                                    ),
                                                ),
                                            ],
                                        )
                                    ),
                                    Divider(),
                                    Container(
                                        padding: EdgeInsets.all(15.0),
                                        child: Form(
                                            key: formKey,
                                            child: Column(
                                                children: <Widget>[

                                                    _selectfinca(_listitem),
                                                    SizedBox(height: 30.0),
                                                    _selectParcela(),
                                                    SizedBox(height: 30.0),
                                                    _distanciaSurco(),
                                                    SizedBox(height: 30.0),
                                                    _distanciaPlanta(),
                                                    SizedBox(height: 30.0),
                                                    _date(context),
                                                    SizedBox(height: 60.0),

                                                    _botonsubmit()
                                                ],
                                            ),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                    );
                }
            },
        );
    }

    Widget _selectfinca(List<Map<String, dynamic>> _listitem){

        bool _enableFinca = _listitem.isNotEmpty ? true : false;

        return SelectFormField(
            labelText: 'Seleccione la finca',
            items: _listitem,
            enabled: _enableFinca,
            validator: (value){
                if(value!.length < 1){
                    return 'No se selecciono una finca';
                }else{
                    return null;
                }
            },

            onChanged: (val){
                fincasBloc.selectParcela(val);
            },
            onSaved: (value) => sombra.idFinca = value,
        );
    }

    Widget _selectParcela(){

        return StreamBuilder(
            stream: fincasBloc.parcelaSelect,
            builder: (BuildContext context, AsyncSnapshot snapshot){
                if (!snapshot.hasData) {
                    return SelectFormField(
                        controller: _control,
                        initialValue: '',
                        enabled: false,
                        labelText: 'Seleccione la parcela',
                        items: [],
                    );
                }

                mainparcela = snapshot.data;
                return SelectFormField(
                    controller: _control,
                    initialValue: '',
                    labelText: 'Seleccione la parcela',
                    items: mainparcela as List<Map<String, dynamic>>,
                    validator: (value){
                        if(value!.length < 1){
                            return 'Selecione un elemento';
                        }else{
                            return null;
                        }
                    },

                    //onChanged: (val) => print(val),
                    onSaved: (value) => sombra.idLote = value,
                );
            },
        );

    }

    Widget _distanciaSurco(){

        return TextFormField(
            initialValue: sombra.surcoDistancia == null ? '' : sombra.surcoDistancia.toString(),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
                labelText: 'Distancia entre surco mt',
                hintText: 'ejem: 3',
                
            ),
            validator: (value) {
                
                if (utils.isNumeric(value!)){
                    if (double.parse(value) > 0) {
                        return null;
                    } else {
                        return 'Área mayor a cero';
                    }
                }else{
                    return 'Solo números';
                }
            },
            onSaved: (value) => sombra.surcoDistancia = double.parse(value!),
        );

    }

    Widget _distanciaPlanta(){

        return TextFormField(
            initialValue: sombra.plantaDistancia == null ? '' : sombra.plantaDistancia.toString(),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
                labelText: 'Distancia entre planta mt',
                hintText: 'ejem: 3',
                
            ),
            validator: (value) {
                
                if (utils.isNumeric(value!)){
                    if (double.parse(value) > 0) {
                        return null;
                    } else {
                        return 'Área mayor a cero';
                    }
                }else{
                    return 'Solo números';
                }
            },
            onSaved: (value) => sombra.plantaDistancia = double.parse(value!),
        );

    }

    Widget _date(BuildContext context){
        return TextFormField(

            //autofocus: true,
            controller: _inputfecha,
            enableInteractiveSelection: false,
            decoration: InputDecoration(
                labelText: 'Fecha'
            ),
            onTap: (){
                FocusScope.of(context).requestFocus(new FocusNode());
                _selectDate(context);
            },
            //onChanged: (value) => print('hola: $value'),
            //validator: (value){},
            onSaved: (value){
                sombra.fechaTest = value;
            }
        );
    }

    _selectDate(BuildContext context) async{
        DateTime? picked = await showDatePicker(
            context: context,

            initialDate: new DateTime.now(),
            firstDate: new DateTime.now().subtract(Duration(days: 0)),
            lastDate:  new DateTime(2025),
            locale: Locale('es', 'ES')
        );
        if (picked != null){
            setState(() {
                //_fecha = picked.toString();
                _fecha = formatter.format(picked);
                _inputfecha.text = _fecha;
            });
        }

    }

  


    Widget  _botonsubmit(){
        fincasBloc.obtenerSombra();
        return StreamBuilder(
            stream: fincasBloc.podaStream ,
            builder: (BuildContext context, AsyncSnapshot snapshot){
                if (!snapshot.hasData) {
                    return Container();
                }
                mainlistsombras = snapshot.data;

                return RaisedButton.icon(
                    icon:Icon(Icons.save, color: Colors.white,),

                    label: Text('Guardar',
                        style: Theme.of(context).textTheme
                            .headline6!
                            .copyWith(fontWeight: FontWeight.w600, color: Colors.white)
                    ),
                    padding:EdgeInsets.symmetric(vertical: 13, horizontal: 50),
                    onPressed:(_guardando) ? null : _submit,
                    //onPressed: clearTextInput,
                );
            },
        );


    }





    void _submit(){
        bool checkRepetido = false;

        sombra.estaciones = 3;

        if  ( !formKey.currentState!.validate() ){
            //Cuendo el form no es valido
            return null;
        }
        formKey.currentState!.save();

        mainlistsombras!.forEach((e) {
            //print(sombra.fechaTest);
            //print(e.fechaTest);
            if (sombra.idFinca == e.idFinca && sombra.idLote == e.idLote && sombra.fechaTest == e.fechaTest) {
                checkRepetido = true;
            }
        });



        if (checkRepetido == true) {
            mostrarSnackbar('Ya existe un registros con los mismos valores');
            return null;
        }

        String? checkParcela = mainparcela!.firstWhere((e) => e['value'] == '${sombra.idLote}', orElse: () => {"value": "1","label": "No data"})['value'];



        if (checkParcela == '1') {
            mostrarSnackbar('La parcela selecionada no pertenece a esa finca');
            return null;
        }



        setState(() {_guardando = true;});

        // print(sombra.id);
        // print(sombra.idFinca);
        // print(sombra.idLote);
        // print(sombra.estaciones);
        // print(sombra.fechaTest);
        if(sombra.id == null){
            sombra.id =  uuid.v1();
            fincasBloc.addTestSombra(sombra);
        }

        setState(() {_guardando = false;});
        mostrarSnackbar('Registro Guardado');


        Navigator.pop(context, 'fincas');


    }


    void mostrarSnackbar(String mensaje){
        final snackbar = SnackBar(
            content: Text(mensaje),
            duration: Duration(seconds: 2),
        );

        scaffoldKey.currentState!.showSnackBar(snackbar);
    }
}
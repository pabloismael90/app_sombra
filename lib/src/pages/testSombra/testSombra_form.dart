import 'package:app_sombra/src/models/testsombra_model.dart';
import 'package:app_sombra/src/utils/widget/button.dart';
import 'package:app_sombra/src/utils/widget/varios_widget.dart';
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
            builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                    return Scaffold(body: CircularProgressIndicator(),);
                } else {

                    List<Map<String, dynamic>> _listitem = snapshot.data;
                    return Scaffold(
                        key: scaffoldKey,
                        appBar: AppBar(title: Text('Toma de datos'),),
                        body: SingleChildScrollView(
                            child: Column(
                                children: [
                                    Container(
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                                                    child:textoCardBody('Plantas por sitio: 100 plantas 10 x 10'),
                                                ),
                                                Divider(),
                                                Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                                                    child:textoCardBody('3 Sitios'),
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
                                                ],
                                            ),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                        bottomNavigationBar: botonesBottom(_botonsubmit()),
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
            validator: (value) => utils.floatPositivo(value),
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
            validator: (value) => utils.floatPositivo(value),
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
                _fecha = formatter.format(picked);
                _inputfecha.text = _fecha;
            });
        }

    }

  


    Widget  _botonsubmit(){
        fincasBloc.obtenerSombra();
        return Row(
            children: [
                Spacer(),
                StreamBuilder(
                    stream: fincasBloc.podaStream ,
                    builder: (BuildContext context, AsyncSnapshot snapshot){
                        if (!snapshot.hasData) {
                            return Container();
                        }
                        mainlistsombras= snapshot.data;

                    
                        return ButtonMainStyle(
                            title: 'Guardar',
                            icon: Icons.save,
                            press: (_guardando) ? null : _submit,
                        );

                        
                    },
                ),
                Spacer()
            ],
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
            if (sombra.idFinca == e.idFinca && sombra.idLote == e.idLote && sombra.fechaTest == e.fechaTest) {
                checkRepetido = true;
            }
        });



        if (checkRepetido == true) {
            mostrarSnackbar('Ya existe un registros con los mismos valores', context);
            return null;
        }

        String? checkParcela = mainparcela!.firstWhere((e) => e['value'] == '${sombra.idLote}', orElse: () => {"value": "1","label": "No data"})['value'];



        if (checkParcela == '1') {
            mostrarSnackbar('La parcela selecionada no pertenece a esa finca', context);
            return null;
        }



        setState(() {_guardando = true;});

        if(sombra.id == null){
            sombra.id =  uuid.v1();
            fincasBloc.addTestSombra(sombra);
            mostrarSnackbar('Registro Guardado', context);
        }

        setState(() {_guardando = false;});


        Navigator.pop(context, 'fincas');


    }



}
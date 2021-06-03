
import 'package:app_sombra/src/utils/widget/titulos.dart';
import 'package:flutter/material.dart';

import 'package:app_sombra/src/bloc/fincas_bloc.dart';
import 'package:app_sombra/src/providers/db_provider.dart';
import 'package:app_sombra/src/utils/validaciones.dart' as utils;
import 'package:select_form_field/select_form_field.dart';
import 'package:app_sombra/src/models/selectValue.dart' as selectMap;
import 'package:uuid/uuid.dart';

class AgregarFinca extends StatefulWidget {
    
  @override
  _AgregarFincaState createState() => _AgregarFincaState();
}

class _AgregarFincaState extends State<AgregarFinca> {
    
    
    final formKey = GlobalKey<FormState>();
    final scaffoldKey = GlobalKey<ScaffoldState>();
 

    Finca finca = new Finca();
    final fincasBloc = new FincasBloc();

    bool _guardando = false;
    var uuid = Uuid();
        

    

    @override
    Widget build(BuildContext context) {

        final fincaData = ModalRoute.of(context).settings.arguments;    
        String tituloForm;
        String tituloBtn;
        
        tituloForm = 'Agregar nueva finca';
        tituloBtn = 'Guardar';

        if (fincaData != null){
            finca = fincaData;
            tituloForm = 'Editar Finca';
            tituloBtn = 'Actualizar';
        }

        return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(),
            body: SingleChildScrollView(
                child: Column(
                    children: [
                        TitulosPages(titulo: tituloForm),
                        Divider(),
                        Container(
                            padding: EdgeInsets.all(15.0),
                            child: Form(
                                key: formKey,
                                child: Column(
                                    children: <Widget>[
                                        _nombreFinca(),
                                        SizedBox(height: 40.0,),
                                        Row(
                                            children: <Widget>[
                                                Flexible(
                                                    child: _areaFinca(),
                                                ),
                                                SizedBox(width: 20.0,),
                                                Flexible(
                                                    child: _medicionFinca(),
                                                ),
                                            ],
                                        ),
                                        SizedBox(height: 40.0,),
                                        _nombreProductor(),
                                        SizedBox(height: 40.0,),
                                        _nombreTecnico(),
                                        SizedBox(height: 60.0,),
                                        _botonsubmit(tituloBtn)
                                    ],
                                ),
                            ),
                        ),
                    ],
                )
            ),
        );
    }

    Widget _nombreFinca(){
        return TextFormField(
            initialValue: finca.nombreFinca,
            autofocus: true,
            decoration: InputDecoration(
                labelText: 'Nombre de la finca',
            ),
            validator: (value){
                if(value.length < 3){
                    return 'Ingrese el nombre de la finca';
                }else{
                    return null;
                }
            },
            onSaved: (value) => finca.nombreFinca = value,
        );
        
    }

    Widget _nombreProductor(){
        return TextFormField(
            initialValue: finca.nombreProductor,
            autofocus: true,
            decoration: InputDecoration(
                labelText: 'Nombre de productor',
                
            ),
            validator: (value){
                if(value.length < 3){
                    return 'Ingrese el nombre del Productor';
                }else{
                    return null;
                }
            },
            onSaved: (value) => finca.nombreProductor = value,
        );
        
    }

    Widget _areaFinca(){

        return TextFormField(
            initialValue: finca.areaFinca == null ? '' : finca.areaFinca.toString(),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
                labelText: 'Área de la finca',
                hintText: 'ejem: 2',
                
            ),
            validator: (value) {
                
                if (utils.isNumeric(value)){
                    return null;
                }else{
                    return 'Solo números';
                }
            },
            onSaved: (value) => finca.areaFinca = double.parse(value),
        );

    }

    Widget _medicionFinca(){
        return SelectFormField(
            initialValue: finca.tipoMedida.toString(),            
            labelText: 'Unidad',
            items: selectMap.dimenciones(),
            validator: (value){
                if(value.length < 1){
                    return 'Selecione un elemento';
                }else{
                    return null;
                } 
            },

            //onChanged: (val) => print(val),
            onSaved: (value) => finca.tipoMedida = int.parse(value),
        );
    }


    Widget _nombreTecnico(){
        return TextFormField(
            initialValue: finca.nombreTecnico,
            autofocus: true,
            decoration: InputDecoration(
                labelText: 'Nombre del Técnico'
            ),
            validator: (value){
                return null;  
            },
            onSaved: (value){
                if(value.length < 1){
                    finca.nombreTecnico = 'Sin Nombre';
                }else{
                    finca.nombreTecnico = value;
                }
            } 
        );
        
    }

    Widget  _botonsubmit(tituloBtn){
        return RaisedButton.icon(
            
            icon:Icon(Icons.save, color: Colors.white,),
            
            label: Text(tituloBtn,
                style: Theme.of(context).textTheme
                    .headline6
                    .copyWith(fontWeight: FontWeight.w600, color: Colors.white)
            ),
            padding:EdgeInsets.symmetric(vertical: 13, horizontal: 50),
            onPressed:(_guardando) ? null : _submit,
        );
    }


    


    void _submit(){

        if  ( !formKey.currentState.validate() ){
            //Cuendo el form no es valido
            return null;
        }

        formKey.currentState.save();

        setState(() {_guardando = true;});
        if(finca.id == null){
            finca.id = uuid.v1();
            fincasBloc.addFinca(finca);
        }else{
            fincasBloc.actualizarFinca(finca);
        }

        setState(() {_guardando = false;});
        mostrarSnackbar('Registro Guardado');


        Navigator.pop(context, 'fincas');
       
        
    }

    
    void mostrarSnackbar(String mensaje){
        final snackbar = SnackBar(
            content: Text(mensaje),
            duration: Duration(microseconds: 1500),
        );

        scaffoldKey.currentState.showSnackBar(snackbar);
    }
}
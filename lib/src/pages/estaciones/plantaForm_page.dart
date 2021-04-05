import 'package:app_sombra/src/bloc/fincas_bloc.dart';
import 'package:app_sombra/src/models/estacion_model.dart';
import 'package:app_sombra/src/models/inventarioPlanta_model.dart';
import 'package:app_sombra/src/utils/widget/titulos.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:uuid/uuid.dart';
import 'package:app_sombra/src/models/selectValue.dart' as selectMap;
import 'package:app_sombra/src/utils/validaciones.dart' as utils;
import 'package:flutter/material.dart';



class PlantaForm extends StatefulWidget {
    PlantaForm({Key key}) : super(key: key);

    @override
    _PlantaFormState createState() => _PlantaFormState();
}

class _PlantaFormState extends State<PlantaForm> {

    Estacion estacion;
    InventacioPlanta planta = InventacioPlanta();
    final formKey = GlobalKey<FormState>();
    final fincasBloc = new FincasBloc();

    List<Map<String, dynamic>>  _especies = selectMap.especies();
    bool _guardando = false;
    var uuid = Uuid();

    @override
    void initState() {
        super.initState();

    }

    /// This implementation is just to simulate a load data behavior
    /// from a data base sqlite or from a API

    @override
    Widget build(BuildContext context) {
        estacion = ModalRoute.of(context).settings.arguments;
        
        return Scaffold(
            appBar: AppBar(),
            body: SingleChildScrollView(
                child: Column(
                    children: [
                        TitulosPages(titulo: 'Nueva Especie'),
                        Divider(),
                        Container(
                            padding: EdgeInsets.all(15.0),
                            child: Form(
                                key: formKey,
                                child: Column(
                                    children: <Widget>[
                                        _selectEspecie(),
                                        SizedBox(height: 40.0,),
                                        Row(
                                            children: <Widget>[
                                                Flexible(
                                                    child: _plantaPequeno(),
                                                ),
                                                SizedBox(width: 20.0,),
                                                Flexible(
                                                    child: _plantaMediano(),
                                                ),
                                            ],
                                        ),
                                        SizedBox(height: 40.0,),
                                        Row(
                                            children: <Widget>[
                                                Flexible(
                                                    child: _plantaGrande(),
                                                ),
                                                SizedBox(width: 20.0,),
                                                Flexible(
                                                    child: Container(),
                                                ),
                                            ],
                                        ),
                                        // _botonsubmit(tituloBtn)
                                    ],
                                ),
                            ),
                        ),
                    ],
                )
            ),
        );
    }

    Widget _selectEspecie(){

        return SelectFormField(
            type: SelectFormFieldType.dialog,
            labelText: 'Seleccione la especie',
            dialogTitle: '',
            dialogCancelBtn: 'CANCELAR',
            enableSearch: true,
            dialogSearchHint: 'Buscar',
            items: _especies,
            validator: (value) {
                if(value.length < 1){
                    return 'No se selecciono especie';
                }else{
                    return null;
                }
            },          
            onSaved: (value) => planta.idPlanta = int.parse(value),
        );
    }

    Widget _plantaPequeno(){

        return TextFormField(
            initialValue: planta.pequeno.toString(),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
                labelText: 'Pequeño',
                hintText: 'ejem: 1',
                
            ),
            validator: (value) {
                
                if (utils.isNumeric(value)){
                    if (int.parse(value) > 0) {
                        return null;
                    } else {
                        return 'Área mayor a cero';
                    }
                }else{
                    return 'Solo números';
                }
            },
            onSaved: (value) => planta.pequeno = int.parse(value),
        );

    }

    Widget _plantaMediano(){
        
        return TextFormField(
            initialValue: planta.mediano.toString(),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
                labelText: 'Mediano',
                hintText: 'ejem: 1',
                
            ),
            validator: (value) {
                
                if (utils.isNumeric(value)){
                    if (int.parse(value) > 0) {
                        return null;
                    } else {
                        return 'Área mayor a cero';
                    }
                }else{
                    return 'Solo números';
                }
            },
            onSaved: (value) => planta.mediano = int.parse(value),
        );

    }

    Widget _plantaGrande(){
        
        return TextFormField(
            initialValue: planta.grande.toString(),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
                labelText: 'Grande',
                hintText: 'ejem: 1',
                
            ),
            validator: (value) {
                
                if (utils.isNumeric(value)){
                    if (int.parse(value) > 0) {
                        return null;
                    } else {
                        return 'Área mayor a cero';
                    }
                }else{
                    return 'Solo números';
                }
            },
            onSaved: (value) => planta.grande = int.parse(value),
        );

    }





}
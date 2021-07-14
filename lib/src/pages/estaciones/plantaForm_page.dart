import 'package:app_sombra/src/bloc/fincas_bloc.dart';
import 'package:app_sombra/src/models/estacion_model.dart';
import 'package:app_sombra/src/models/inventarioPlanta_model.dart';
import 'package:app_sombra/src/utils/widget/button.dart';
import 'package:app_sombra/src/utils/widget/varios_widget.dart';
import 'package:flutter/services.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:uuid/uuid.dart';
import 'package:app_sombra/src/utils/validaciones.dart' as utils;
import 'package:app_sombra/src/models/selectValue.dart' as selectMap;
import 'package:flutter/material.dart';



class PlantaForm extends StatefulWidget {
    PlantaForm({Key? key}) : super(key: key);

    @override
    _PlantaFormState createState() => _PlantaFormState();
}

class _PlantaFormState extends State<PlantaForm> {

    late Estacion estacion;
    InventacioPlanta inventarioPlanta = InventacioPlanta();
    late List<InventacioPlanta> plantas;
    final formKey = GlobalKey<FormState>();
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final fincasBloc = new FincasBloc();

    List<Map<String, dynamic>>  _especies = selectMap.especies();
    List<Map<String, dynamic>>  _uso = selectMap.listaUso();
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
        final List dataRoute = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
        estacion = dataRoute[0];
        plantas = dataRoute[1];
        inventarioPlanta.idEstacion = estacion.id;
        
        return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(title: Text('Nueva Especie')),
            body: SingleChildScrollView(
                child: Column(
                    children: [
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
                                                    child: _selectUso(),
                                                ),
                                            ],
                                        ),
                                        SizedBox(height: 60.0),
                                        _botonsubmit(),
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
                if(value!.length < 1){
                    return 'No se selecciono especie';
                }else{
                    return null;
                }
            },          
            onSaved: (value) => inventarioPlanta.idPlanta = int.parse(value!),
        );
    }

    Widget _plantaPequeno(){

        return TextFormField(
            initialValue: inventarioPlanta.pequeno == null ? '' : inventarioPlanta.pequeno.toString(),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
                labelText: 'Pequeño',
                hintText: 'ejem: 1',
                
            ),
            validator: (value) => utils.validatePositive(value),
            onSaved: (value) => inventarioPlanta.pequeno = int.parse(value!),
        );

    }

    Widget _plantaMediano(){
        
        return TextFormField(
            initialValue: inventarioPlanta.mediano == null ? '' : inventarioPlanta.mediano.toString(),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
                labelText: 'Mediano',
                hintText: 'ejem: 1',
                
            ),
            validator: (value) => utils.validatePositive(value),
            onSaved: (value) => inventarioPlanta.mediano = int.parse(value!),
        );

    }

    Widget _plantaGrande(){
        
        return TextFormField(
            initialValue: inventarioPlanta.grande == null ? '' : inventarioPlanta.grande.toString(),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
                labelText: 'Grande',
                hintText: 'ejem: 1',
                
            ),
            validator: (value) => utils.validatePositive(value),
            onSaved: (value) => inventarioPlanta.grande = int.parse(value!),
        );

    }

    Widget _selectUso(){

        return SelectFormField(
            type: SelectFormFieldType.dropdown,
            labelText: 'Uso',
            dialogTitle: '',
            items: _uso,
            validator: (value) {
                if(value!.length < 1){
                    return 'No se selecciono uso';
                }else{
                    return null;
                }
            },          
            onSaved: (value) => inventarioPlanta.uso = int.parse(value!),
        );
    }

    Widget  _botonsubmit(){
        return ButtonMainStyle(
            title: 'Guardar',
            icon: Icons.save,
            press: (_guardando) ? null : _submit,
        );

    }

    void _submit(){

        
        if  ( !formKey.currentState!.validate() ){
            return null;
        }

        formKey.currentState!.save();

        for (var item in plantas) {
            if (item.idPlanta == inventarioPlanta.idPlanta) {
                mostrarSnackbar('Especie ya registrada', context);
                return null;
            }
        }

        if (inventarioPlanta.pequeno == 0 && inventarioPlanta.mediano == 0 && inventarioPlanta.grande == 0) {
            mostrarSnackbar('Especie vacia', context);
            return null;
        }

        setState(() {_guardando = true;});
        

        inventarioPlanta.id =  uuid.v1();
        fincasBloc.addInventario(inventarioPlanta, estacion.id, estacion.idTestSombra, estacion.nestacion);
        mostrarSnackbar('Especie guardada', context);

        setState(() {_guardando = false;});


        Navigator.pop(context, 'inventario');


    }

    

}
import 'package:app_sombra/src/bloc/fincas_bloc.dart';
import 'package:app_sombra/src/models/estacion_model.dart';
import 'package:app_sombra/src/models/inventarioPlanta_model.dart';
import 'package:app_sombra/src/utils/widget/titulos.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:uuid/uuid.dart';
import 'package:app_sombra/src/models/selectValue.dart' as selectMap;
import 'package:flutter/material.dart';



class PlantaForm extends StatefulWidget {
    PlantaForm({Key key}) : super(key: key);

    @override
    _PlantaFormState createState() => _PlantaFormState();
}

class _PlantaFormState extends State<PlantaForm> {

    Estacion estacion;
    InventacioPlanta inventarioPlanta = InventacioPlanta();
    List<InventacioPlanta> plantas;
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
        final List dataRoute = ModalRoute.of(context).settings.arguments;
        estacion = dataRoute[0];
        plantas = dataRoute[1];
        inventarioPlanta.idEstacion = estacion.id;

        
    
        
        return Scaffold(
            key: scaffoldKey,
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
                if(value.length < 1){
                    return 'No se selecciono especie';
                }else{
                    return null;
                }
            },          
            onSaved: (value) => inventarioPlanta.idPlanta = int.parse(value),
        );
    }

    Widget _plantaPequeno(){

        return TextFormField(
            initialValue: inventarioPlanta.pequeno == null ? '' : inventarioPlanta.pequeno.toString(),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
                labelText: 'Pequeño',
                hintText: 'ejem: 1',
                
            ),
            validator: (value) {
                
                final isDigitsOnly = int.tryParse(value);
                if (isDigitsOnly == null) {
                    return 'Solo números enteros';
                }
                if (isDigitsOnly <= 0) {
                    return 'Valor invalido';
                }else{
                    return null;
                }
            },
            onSaved: (value) => inventarioPlanta.pequeno = int.parse(value),
        );

    }

    Widget _plantaMediano(){
        
        return TextFormField(
            initialValue: inventarioPlanta.mediano == null ? '' : inventarioPlanta.mediano.toString(),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
                labelText: 'Mediano',
                hintText: 'ejem: 1',
                
            ),
            validator: (value) {
                
                final isDigitsOnly = int.tryParse(value);
                if (isDigitsOnly == null) {
                    return 'Solo números enteros';
                }
                if (isDigitsOnly <= 0) {
                    return 'Valor invalido';
                }else{
                    return null;
                }
            },
            onSaved: (value) => inventarioPlanta.mediano = int.parse(value),
        );

    }

    Widget _plantaGrande(){
        
        return TextFormField(
            initialValue: inventarioPlanta.grande == null ? '' : inventarioPlanta.grande.toString(),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
                labelText: 'Grande',
                hintText: 'ejem: 1',
                
            ),
            validator: (value) {
                
                final isDigitsOnly = int.tryParse(value);
                if (isDigitsOnly == null) {
                    return 'Solo números enteros';
                }
                if (isDigitsOnly <= 0) {
                    return 'Valor invalido';
                }else{
                    return null;
                }
            },
            onSaved: (value) => inventarioPlanta.grande = int.parse(value),
        );

    }

    Widget _selectUso(){

        return SelectFormField(
            type: SelectFormFieldType.dropdown,
            labelText: 'Uso',
            dialogTitle: '',
            items: _uso,
            validator: (value) {
                if(value.length < 1){
                    return 'No se selecciono uso';
                }else{
                    return null;
                }
            },          
            onSaved: (value) => inventarioPlanta.uso = int.parse(value),
        );
    }

    Widget  _botonsubmit(){
        return RaisedButton.icon(
            icon:Icon(Icons.save, color: Colors.white,),

            label: Text('Guardar',
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
            return null;
        }

        formKey.currentState.save();

        for (var item in plantas) {
            if (item.idPlanta == inventarioPlanta.idPlanta) {
                mostrarSnackbar('Especie ya registrada');
                return null;
            }
        }

        if (inventarioPlanta.pequeno == 0 && inventarioPlanta.mediano == 0 && inventarioPlanta.grande == 0) {
            mostrarSnackbar('Especie vacia');
            return null;
        }

        setState(() {_guardando = true;});
        

        inventarioPlanta.id =  uuid.v1();
        fincasBloc.addInventario(inventarioPlanta, estacion.id, estacion.idTestSombra, estacion.nestacion);

        setState(() {_guardando = false;});


        Navigator.pop(context, 'inventario');


    }

    void mostrarSnackbar(String mensaje){
        final snackbar = SnackBar(
            content: Text(mensaje),
            duration: Duration(seconds: 2),
        );

        scaffoldKey.currentState.showSnackBar(snackbar);
    }

}
import 'package:app_sombra/src/bloc/fincas_bloc.dart';
import 'package:app_sombra/src/models/parcela_model.dart';
import 'package:app_sombra/src/providers/db_provider.dart';
import 'package:app_sombra/src/utils/widget/titulos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



import 'package:app_sombra/src/utils/validaciones.dart' as utils;
import 'package:select_form_field/select_form_field.dart';
import 'package:app_sombra/src/models/selectValue.dart' as selectMap;
import 'package:uuid/uuid.dart';


class AgregarParcela extends StatefulWidget {
  AgregarParcela({Key key}) : super(key: key);

  @override
  _AgregarParcelaState createState() => _AgregarParcelaState();
}



class _AgregarParcelaState extends State<AgregarParcela> {

    final formKey = GlobalKey<FormState>();

    Parcela parcela = new Parcela();
    final fincasBloc = new FincasBloc();

    bool _guardando = false;
    var uuid = Uuid();
    


    Future getparcelas(String idFinca) async{
        List<Parcela> parcelas = await DBProvider.db.getTodasParcelasIdFinca(idFinca);

        Finca finca = await DBProvider.db.getFincaId(idFinca);

        return [finca, parcelas];
    }
    

    @override
    Widget build(BuildContext context) {


        String fincaid ;
        Finca finca = Finca();
        var dataRoute = ModalRoute.of(context).settings.arguments;

        String tituloForm;
        String tituloBtn;
        
        
        tituloBtn = 'Guardar';

        if (dataRoute.runtimeType == Finca) {
            finca = dataRoute;
            fincaid = finca.id;
            tituloForm = 'Agregar nueva parcela';
            tituloBtn = 'Guardar';
        } else {
            if (dataRoute != null){
                parcela = dataRoute;
                fincaid = parcela.idFinca;
                tituloForm = 'Actualizar parcela';
                tituloBtn = 'Actualizar';
            }
            
        }
        
        String labelMedida;
        
        
        return Scaffold(
            appBar: AppBar(),
            body: FutureBuilder(
                    future: getparcelas(fincaid),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                            return CircularProgressIndicator();
                        }

                        finca = snapshot.data[0];
                        List<Parcela> listParcela = snapshot.data[1];
                        labelMedida = selectMap.dimenciones().firstWhere((e) => e['value'] == '${finca.tipoMedida}')['label'];
                        return SingleChildScrollView(                
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
                                                    _nombreParcela(fincaid),
                                                    SizedBox(height: 40.0,),
                                                    _areaParcela(finca, labelMedida, listParcela),
                                                    SizedBox(height: 40.0,),
                                                    Row(
                                                        children: <Widget>[
                                                            Flexible(
                                                                child: _variedadCacao(),
                                                            ),
                                                            SizedBox(width: 20.0,),
                                                            Flexible(
                                                                child: _numeroPlanta(labelMedida),
                                                            ),
                                                        ],
                                                    ),
                                                    SizedBox(height: 60.0,),
                                                    _botonsubmit(tituloBtn)
                                                ],
                                            ),
                                        ),
                                    ),
                                ],
                            ),
                        );
                    },
                ),
        );
    
    }
    Widget _nombreParcela( String fincaid ){
        //print('id de finca: $fincaid');
        return TextFormField(
            initialValue: parcela.nombreLote,
            //autofocus: true,
            decoration: InputDecoration(
                labelText: 'Nombre de la parcela'
            ),
            validator: (value){
                if(value.length < 3){
                    return 'Ingrese el nombre de la Parcela';
                }else{
                    return null;
                }
            },
            onSaved: (value){
                parcela.idFinca = fincaid;
                parcela.nombreLote = value;
            } 
        );
        
    }
    
    Widget _areaParcela(Finca finca, String labelMedida, List<Parcela> listParcela){

                double sumaParcelas = 0.0;
                double valorsuma = 0.0;
                double areaParcela = parcela.areaLote == null ? 0 : parcela.areaLote;         

                for (var item in listParcela) {
                    sumaParcelas = sumaParcelas+item.areaLote;
                }
                
                sumaParcelas = sumaParcelas - areaParcela;

                return TextFormField(
                    initialValue: parcela.areaLote == null ? '' : parcela.areaLote.toString(),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        labelText: 'Área de la parcela ($labelMedida)'
                    ),
                    validator: (value) {
                        
                        if (utils.isNumeric(value)){

                            valorsuma = double.parse(value) + sumaParcelas;
                            //print(valorsuma);
                            //print(finca.areaFinca);
                            if (valorsuma <= finca.areaFinca) {
                                if (double.parse(value) > 0) {
                                    return null;
                                } else {
                                    return 'Área mayor a cero';
                                }
                            } else {
                                return 'Área parcelas mayor a Finca';
                            }
                        }else{
                            return 'Solo números';
                        }
                    },
                    onSaved: (value) => parcela.areaLote = double.parse(value),
                );
            

    }


    Widget _variedadCacao(){
        return SelectFormField(
            initialValue: parcela.variedadCacao.toString(),
            labelText: 'Variedad',
            items: selectMap.variedadCacao(),
            validator: (value){
                if(value.length < 1){
                    return 'Selecione variedad';
                }else{
                    return null;
                } 
            },

            //onChanged: (val) => print(val),
            onSaved: (value) => parcela.variedadCacao = int.parse(value),
        );
    }

    Widget _numeroPlanta(String labelMedida){

        return TextFormField(
            initialValue: parcela.numeroPlanta == null ? '' : parcela.numeroPlanta.toString(),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
            ], 
            decoration: InputDecoration(
                labelText: 'No de plantas x $labelMedida'
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
            onSaved: (value) => parcela.numeroPlanta = int.parse(value),
        );

    }

    Widget  _botonsubmit(String tituloBtn){
        return RaisedButton.icon(
            
            icon:Icon(Icons.save, color: Colors.white,),
            
            label: Text(tituloBtn,
                style: Theme.of(context).textTheme
                    .headline6
                    .copyWith(fontWeight: FontWeight.w600, color: Colors.white)
            ),
            padding:EdgeInsets.symmetric(vertical: 13, horizontal: 50),
            onPressed:(_guardando) ? null : _submit,
           // onPressed: _submit,
        );
    }
    

    void _submit( ){

        

        if  ( !formKey.currentState.validate() ){
            
            //Cuendo el form no es valido
            return null;
        }
        

        formKey.currentState.save();

        setState(() {_guardando = true;});

        if(parcela.id == null){
            parcela.id = uuid.v1();
            fincasBloc.addParcela(parcela, parcela.idFinca);
        }else{
            fincasBloc.actualizarParcela(parcela, parcela.idFinca);
        }

        setState(() {_guardando = false;});
        


        Navigator.pop(context, 'fincas');
       
        
    }
}
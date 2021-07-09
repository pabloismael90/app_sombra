import 'package:app_sombra/src/bloc/fincas_bloc.dart';
import 'package:app_sombra/src/models/parcela_model.dart';
import 'package:app_sombra/src/providers/db_provider.dart';
import 'package:app_sombra/src/utils/widget/button.dart';
import 'package:app_sombra/src/utils/widget/varios_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



import 'package:app_sombra/src/utils/validaciones.dart' as utils;
import 'package:select_form_field/select_form_field.dart';
import 'package:app_sombra/src/models/selectValue.dart' as selectMap;
import 'package:uuid/uuid.dart';


class AgregarParcela extends StatefulWidget {
  AgregarParcela({Key? key}) : super(key: key);

  @override
  _AgregarParcelaState createState() => _AgregarParcelaState();
}



class _AgregarParcelaState extends State<AgregarParcela> {

    final formKey = GlobalKey<FormState>();

    Parcela parcela = new Parcela();
    final fincasBloc = new FincasBloc();

    bool _guardando = false;
    var uuid = Uuid();
    


    Future getparcelas(String? idFinca) async{
        List<Parcela> parcelas = await DBProvider.db.getTodasParcelasIdFinca(idFinca);

        Finca? finca = await DBProvider.db.getFincaId(idFinca);

        return [finca, parcelas];
    }
    

    @override
    Widget build(BuildContext context) {


        String? fincaid ;
        Finca? finca = Finca();
        var dataRoute = ModalRoute.of(context)!.settings.arguments;

        String? tituloForm;
        String tituloBtn;
        
        
        tituloBtn = 'Guardar';

        if (dataRoute.runtimeType == Finca) {
            finca = dataRoute as Finca?;
            fincaid = finca!.id;
            tituloForm = 'Agregar nueva parcela';
            tituloBtn = 'Guardar';
        } else {
            if (dataRoute != null){
                parcela = dataRoute as Parcela;
                fincaid = parcela.idFinca;
                tituloForm = 'Actualizar parcela';
                tituloBtn = 'Actualizar';
            }
            
        }
        
        String? labelMedida;
        
        
        return Scaffold(
            appBar: AppBar(title: Text(tituloForm as String),),
            body: FutureBuilder(
                    future: getparcelas(fincaid),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                            return CircularProgressIndicator();
                        }

                        finca = snapshot.data[0];
                        List<Parcela> listParcela = snapshot.data[1];
                        labelMedida = selectMap.dimenciones().firstWhere((e) => e['value'] == '${finca!.tipoMedida}')['label'];
                        return SingleChildScrollView(                
                            child: Column(
                                children: [
                                    Container(
                                    padding: EdgeInsets.all(15.0),
                                        child: Form(
                                            key: formKey,
                                            child: Column(
                                                children: <Widget>[
                                                    _nombreParcela(fincaid),
                                                    SizedBox(height: 30.0,),
                                                    _areaParcela(finca, labelMedida, listParcela),
                                                    SizedBox(height: 30.0,),
                                                    _variedadCacao(),
                                                    SizedBox(height: 30.0,),
                                                    _numeroPlanta(labelMedida),
                                                ],
                                            ),
                                        ),
                                    ),
                                ],
                            ),
                        );
                    },
            ),
            bottomNavigationBar: botonesBottom(_botonsubmit(tituloBtn)),
        );
    
    }
    Widget _nombreParcela( String? fincaid ){
        return TextFormField(
            initialValue: parcela.nombreLote,
            maxLength: 30,
            decoration: InputDecoration(
                labelText: 'Nombre de la parcela'
            ),
            validator: (value){
                if(value!.length < 3){
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
    
    Widget _areaParcela(Finca? finca, String? labelMedida, List<Parcela> listParcela){

                double sumaParcelas = 0.0;
                double valorsuma = 0.0;             
                double areaParcela = parcela.areaLote == null ? 0 : parcela.areaLote!;         

                for (var item in listParcela) {
                    sumaParcelas = sumaParcelas+item.areaLote!;
                }
                
                sumaParcelas = sumaParcelas - areaParcela;

                return TextFormField(
                    initialValue: parcela.areaLote == null ? '' : parcela.areaLote.toString(),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    maxLength: 5,
                    decoration: InputDecoration(
                        labelText: 'Área de la parcela ($labelMedida)'
                    ),
                    validator: (value) {
                        
                        if (utils.isNumeric(value!)){
                            valorsuma = double.parse(value) + sumaParcelas;
                            if (valorsuma <= finca!.areaFinca!) {
                                if (double.parse(value) > 0) {
                                    return null;
                                } else {
                                    return 'Valor $value inválido';
                                }
                            } else {
                                return 'Área parcelas mayor a Finca';
                            }
                        }else{
                            return 'Valor $value inválido';
                        }
                    },
                    onSaved: (value) => parcela.areaLote = double.parse(value!),
                );
            

    }


    Widget _variedadCacao(){
        return SelectFormField(
            initialValue: parcela.variedadCacao.toString(),
            labelText: 'Variedad',
            maxLength: 24,
            items: selectMap.variedadCacao(),
            validator: (value){
                if(value!.length < 1){
                    return 'Selecione variedad';
                }else{
                    return null;
                } 
            },
            onSaved: (value) => parcela.variedadCacao = int.parse(value!),
        );
    }

    Widget _numeroPlanta(String? labelMedida){

        return TextFormField(
            initialValue: parcela.numeroPlanta == null ? '' : parcela.numeroPlanta.toString(),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
            ],
            maxLength: 5,
            decoration: InputDecoration(
                labelText: 'No de plantas por $labelMedida'
            ),
            validator: (value) => utils.validateEntero(value),
            onSaved: (value) => parcela.numeroPlanta = int.parse(value!),
        );

    }

    Widget  _botonsubmit(tituloBtn){
        return Row(
            children: [
                Spacer(),
                ButtonMainStyle(
                    title: tituloBtn,
                    icon: Icons.save,
                    press: (_guardando) ? null : _submit,
                ),
                Spacer()
            ],
        );
    }
    

    void _submit( ){

        

        if  ( !formKey.currentState!.validate() ){
            return null;
        }
        

        formKey.currentState!.save();

        setState(() {_guardando = true;});
        if(parcela.id == null){
            parcela.id = uuid.v1();
            fincasBloc.addParcela(parcela, parcela.idFinca);
            mostrarSnackbar('Registro parcela guardado', context);
        }else{
            fincasBloc.actualizarParcela(parcela, parcela.idFinca);
            mostrarSnackbar('Registro parcela actualizada', context);
        }

        setState(() {_guardando = false;});
        


        Navigator.pop(context, 'fincas');
       
        
    }
}
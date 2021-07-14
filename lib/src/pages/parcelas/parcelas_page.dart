import 'package:app_sombra/src/bloc/fincas_bloc.dart';
import 'package:app_sombra/src/models/finca_model.dart';
import 'package:app_sombra/src/providers/db_provider.dart';
import 'package:app_sombra/src/utils/constants.dart';
import 'package:app_sombra/src/models/selectValue.dart' as selectMap;
import 'package:app_sombra/src/utils/widget/button.dart';
import 'package:app_sombra/src/utils/widget/dialogDelete.dart';
import 'package:app_sombra/src/utils/widget/varios_widget.dart';
import 'package:flutter/material.dart';


class ParcelaPage extends StatefulWidget {
    ParcelaPage({Key? key}) : super(key: key);

    @override
    _ParcelaPageState createState() => _ParcelaPageState();
}


final fincasBloc = new FincasBloc();
class _ParcelaPageState extends State<ParcelaPage> {

    @override
    Widget build(BuildContext context) {

        final Finca fincaData = ModalRoute.of(context)!.settings.arguments as Finca;
        var size = MediaQuery.of(context).size;
        fincasBloc.obtenerParcelasIdFinca(fincaData.id);

        return Scaffold(
            appBar: AppBar(title: Text('Mis Parcelas'),),
            body: StreamBuilder(
                stream: fincasBloc.parcelaStream,
                builder: (BuildContext context, AsyncSnapshot snapshot) {

                    if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                    }

                    final parcela = snapshot.data;


                        return Column(
                            children: [
                                _dataFinca(fincaData),
                                parcela.length == 0 ? 
                                Expanded(
                                    child: Center(
                                        child: Text('No hay datos: \nIngrese datos de parcela en la finca', 
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context).textTheme.headline6,
                                        )
                                    )
                                )
                                :
                                Container(
                                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Container(
                                                padding: EdgeInsets.only(bottom: 10),
                                                child: Text(
                                                    'Lista de parcelas',
                                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                                                ),
                                            ),
                                            Row(
                                                children: List.generate(
                                                    150~/2, (index) => Expanded(
                                                        child: Container(
                                                            color: index%2==0?Colors.transparent
                                                            :kShadowColor2,
                                                            height: 2,
                                                        ),
                                                    )
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                                Expanded(
                                    child: SingleChildScrollView(child: _listaDeParcelas(parcela, fincaData, size, context))
                                ),
                            ],
                        );
            
                    
                },
            ),
            bottomNavigationBar: botonesBottom(
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                        _addParcela(fincaData),
                    ],
                ),
            ),
        );
                

        
    }

    Widget  _addParcela( Finca finca ){
        return ButtonMainStyle(
            title: 'Nueva Parcela',
            icon: Icons.post_add,
            press: () => Navigator.pushNamed(context, 'addParcela', arguments: finca),
        );
    }

    Widget _dataFinca(Finca finca){
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
                                            tituloCard('${finca.nombreFinca}'),
                                            subtituloCardBody('Productor: ${finca.nombreProductor}')
                                        ],
                                    ),
                                ),
                            ),
                            
                            TextButton(
                                onPressed: () => Navigator.pushNamed(context, 'addFinca', arguments: finca),
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
                    textoCardBody('Área de la finca: ${finca.areaFinca} ${finca.tipoMedida == 1 ? 'Mz': 'Ha'}'),
                    textoCardBody('${finca.nombreTecnico}'),           

                ],
            ),
        );
    }


    Widget  _listaDeParcelas(List parcelas, Finca finca, Size size, BuildContext context){
        String? labelMedida;
        String? labelVariedad;

        return ListView.builder(
            itemBuilder: (context, index) {
                final item = selectMap.dimenciones().firstWhere((e) => e['value'] == '${finca.tipoMedida}');
                labelMedida  = item['label'];
                final item2 = selectMap.variedadCacao().firstWhere((e) => e['value'] == '${parcelas[index].variedadCacao}');
                labelVariedad  = item2['label'];

                return Dismissible(
                    key: UniqueKey(),
                    child: GestureDetector(
                        child: _cardDesing(parcelas[index], labelMedida, labelVariedad),
                        onTap: () => Navigator.pushNamed(context, 'addParcela', arguments: parcelas[index]),
                    ),
                    confirmDismiss: (direction) => confirmacionUser(direction, context),
                    direction: DismissDirection.endToStart,
                    background: backgroundTrash(context),
                    movementDuration: Duration(milliseconds: 500),
                    onDismissed: (direction) => fincasBloc.borrarParcela(parcelas[index].id),
                );
               
            },
            shrinkWrap: true,
            itemCount: parcelas.length,
            padding: EdgeInsets.only(bottom: 30.0),
            controller: ScrollController(keepScrollOffset: false),
        );

    }


    Widget _cardDesing(Parcela parcela, String? labelMedida, String? labelVariedad){
        
        return cardDefault(
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    encabezadoCard('${parcela.nombreLote}','$labelVariedad', 'assets/icons/parcela.svg'),
                    Wrap(
                        spacing: 20,
                        children: [
                            textoCardBody('N Plantas: ${parcela.numeroPlanta}'),
                            textoCardBody('Área: ${parcela.areaLote} $labelMedida'),
                        ],
                    ),
                    iconTap(' Tocar para editar')
                ],
            )
        );
    }




}
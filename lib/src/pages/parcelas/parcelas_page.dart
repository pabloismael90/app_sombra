import 'package:app_sombra/src/bloc/fincas_bloc.dart';
import 'package:app_sombra/src/models/finca_model.dart';
import 'package:app_sombra/src/providers/db_provider.dart';
import 'package:app_sombra/src/utils/constants.dart';
import 'package:app_sombra/src/models/selectValue.dart' as selectMap;
import 'package:app_sombra/src/utils/widget/dialogDelete.dart';
import 'package:app_sombra/src/utils/widget/titulos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


class ParcelaPage extends StatefulWidget {
    ParcelaPage({Key key}) : super(key: key);

    @override
    _ParcelaPageState createState() => _ParcelaPageState();
}


final fincasBloc = new FincasBloc();
class _ParcelaPageState extends State<ParcelaPage> {

    @override
    Widget build(BuildContext context) {

        final Finca fincaData = ModalRoute.of(context).settings.arguments;
        var size = MediaQuery.of(context).size;
        fincasBloc.obtenerParcelasIdFinca(fincaData.id);

        return Scaffold(
            appBar: AppBar(),
            body: StreamBuilder(
                stream: fincasBloc.parcelaStream,
                builder: (BuildContext context, AsyncSnapshot snapshot) {

                    if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                    }

                    final parcela = snapshot.data;

                    if (parcela.length == 0) {
                        return Column(
                            children: [
                                TitulosPages(titulo: 'Parcelas de ${fincaData.nombreFinca}'),
                                Divider(),
                                Expanded(child: Center(
                                    child: Text('No hay datos: \nIngrese datos de parcela en la finca', 
                                    textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.headline6,
                                        )
                                    )
                                )
                            ],
                        );
                    }

                    return Column(
                        children: [
                            TitulosPages(titulo: 'Parcelas Finca ${fincaData.nombreFinca}'),
                            Expanded(
                                child: SingleChildScrollView(child: _listaDeParcelas(parcela, fincaData, size, context))
                            )
                        ],
                    );
                    
                },
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
                                    child: _editarFinca(fincaData),
                                ),
                                Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 5),
                                    child: _addParcela(fincaData),
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        );
                

        
    }

    Widget  _editarFinca(Finca finca){
        return RaisedButton.icon(
            
            icon:Icon(Icons.edit_rounded),
            
            label: Text('Editar Finca',
                style: Theme.of(context).textTheme
                    .headline6
                    .copyWith(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)
            ),
            padding:EdgeInsets.all(13),
            onPressed: () => Navigator.pushNamed(context, 'addFinca', arguments: finca),
        );
    }

    Widget  _addParcela( Finca finca ){
        return RaisedButton.icon(
            
            icon:Icon(Icons.add_circle_outline_outlined),
            textColor: Colors.white,
            label: Text('Nueva Parcela',
                style: Theme.of(context).textTheme
                    .headline6
                    .copyWith(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)
            ),
            padding:EdgeInsets.all(13),
            
            onPressed:() => Navigator.pushNamed(context, 'addParcela', arguments: finca),
        );
    }


    Widget  _listaDeParcelas(List parcelas, Finca finca, Size size, BuildContext context){
        String labelMedida;
        String labelVariedad;

        return ListView.builder(
            itemBuilder: (context, index) {
                final item = selectMap.dimenciones().firstWhere((e) => e['value'] == '${finca.tipoMedida}');
                labelMedida  = item['label'];
                final item2 = selectMap.variedadCacao().firstWhere((e) => e['value'] == '${parcelas[index].variedadCacao}');
                labelVariedad  = item2['label'];

                return Dismissible(
                    key: UniqueKey(),
                    child: GestureDetector(
                        child: _cardParcela(size, parcelas[index], labelMedida, labelVariedad),
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

    Widget _cardParcela(Size size, Parcela parcela, String labelMedida, String labelVariedad){
        return Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                        BoxShadow(
                                color: Color(0xFF3A5160)
                                    .withOpacity(0.05),
                                offset: const Offset(1.1, 1.1),
                                blurRadius: 17.0),
                        ],
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                        Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: SvgPicture.asset('assets/icons/parcela.svg', height:80,),
                        ),
                        Flexible(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                
                                    Padding(
                                        padding: EdgeInsets.only(top: 10, bottom: 10.0),
                                        child: Text(
                                            "${parcela.nombreLote}",
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: Theme.of(context).textTheme.headline6,
                                        ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only( bottom: 10.0),
                                        child: Text(
                                            "Variedad: $labelVariedad",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: kLightBlackColor),
                                        ),
                                    ),
                                    Text(
                                        'N Plantas: ${parcela.numeroPlanta}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: kLightBlackColor),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(top: 10, bottom: 10.0),
                                        child: Text(
                                            "${parcela.areaLote} $labelMedida",
                                            style: TextStyle(color: kLightBlackColor),
                                        ),
                                    ),
                                ],  
                            ),
                        ),
                        
                        
                        
                    ],
                ),
        );
    }
   
}
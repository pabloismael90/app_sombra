import 'package:app_sombra/src/bloc/fincas_bloc.dart';
import 'package:app_sombra/src/models/finca_model.dart';
import 'package:app_sombra/src/providers/db_provider.dart';
import 'package:app_sombra/src/utils/constants.dart';
import 'package:app_sombra/src/utils/widget/card_list.dart';
import 'package:app_sombra/src/utils/widget/dialogDelete.dart';
import 'package:app_sombra/src/utils/widget/titulos.dart';
import 'package:flutter/material.dart';



class FincasPage extends StatefulWidget {
    @override
    _FincasPageState createState() => _FincasPageState();
}

final fincasBloc = new FincasBloc();


class _FincasPageState extends State<FincasPage> {


    @override
    Widget build(BuildContext context) {

        var size = MediaQuery.of(context).size;
        fincasBloc.obtenerFincas();
        return Scaffold(
            appBar: AppBar(
                
            ),
            body: StreamBuilder<List<Finca>>(
                stream: fincasBloc.fincaStream,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());

                    }

                    final fincas = snapshot.data;
                    if (fincas.length == 0) {
                        return Column(
                            children: [
                                TitulosPages(titulo: 'Mis Fincas'),
                                Divider(),
                                Expanded(child: Center(
                                    child: Text('No hay datos: \nIngrese datos de parcela', 
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
                            TitulosPages(titulo: 'Mis Fincas'),
                            Expanded(child: SingleChildScrollView(
                                child: _listaDeFincas(snapshot.data, context, size),
                            ))
                            

                        ],
                    );
                },
            ),

            bottomNavigationBar: BottomAppBar(
                child: Container(
                    color: kBackgroundColor,
                    child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 70, vertical: 10),
                        child: _addFinca(context)
                    ),
                ),
            ),
            
        );
        
       
    }

    Widget _addFinca(BuildContext context){
    
        return RaisedButton.icon(
            
            icon:Icon(Icons.add_circle_outline_outlined),
            
            label: Text('Agregar finca',
                style: Theme.of(context).textTheme
                    .headline6
                    .copyWith(fontWeight: FontWeight.w600, color: Colors.white)
            ),
            padding:EdgeInsets.all(13),
            onPressed:() => Navigator.pushNamed(context, 'addFinca'),
        );
    }

    Widget  _listaDeFincas(List fincas, BuildContext context, Size size){
        return ListView.builder(
            itemBuilder: (context, index) {
                return Dismissible(
                    key: UniqueKey(),
                    child: GestureDetector(
                        child: CardList(
                            size: size, 
                            finca: fincas[index],
                            icon:'assets/icons/finca.svg'
                            
                        ),
                        
                        onTap: () => Navigator.pushNamed(context, 'parcelas', arguments: fincas[index]),
                    ),
                    confirmDismiss: (direction) => confirmacionUser(direction, context),
                    direction: DismissDirection.endToStart,
                    background: backgroundTrash(context),
                    movementDuration: Duration(milliseconds: 500),
                    onDismissed: (direction) => fincasBloc.borrarFinca(fincas[index].id),
                );
                
               
            },
            shrinkWrap: true,
            itemCount: fincas.length,
            padding: EdgeInsets.only(bottom: 30.0),
            controller: ScrollController(keepScrollOffset: false),
        );

    }
}


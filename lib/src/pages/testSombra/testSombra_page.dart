import 'package:app_sombra/src/bloc/fincas_bloc.dart';
import 'package:app_sombra/src/models/testsombra_model.dart';
import 'package:app_sombra/src/providers/db_provider.dart';
import 'package:app_sombra/src/utils/constants.dart';
import 'package:app_sombra/src/utils/widget/dialogDelete.dart';
import 'package:app_sombra/src/utils/widget/titulos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


final fincasBloc = new FincasBloc();

class TestPage extends StatefulWidget {

    

  @override
  _TestPageState createState() => _TestPageState();
}


class _TestPageState extends State<TestPage> {

    
    Future _getdataFinca(TestSombra textSombra) async{
        Finca? finca = await DBProvider.db.getFincaId(textSombra.idFinca);
        Parcela? parcela = await DBProvider.db.getParcelaId(textSombra.idLote);
        return [finca, parcela];
    }

    @override
    Widget build(BuildContext context) {
        var size = MediaQuery.of(context).size;
        fincasBloc.obtenerSombra();

        return Scaffold(
                appBar: AppBar(),
                body: StreamBuilder<List<TestSombra>>(
                    stream: fincasBloc.podaStream,

                    
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());

                        }

                        List<TestSombra> textSombras= snapshot.data;
                        if (textSombras.length == 0) {
                            return Column(
                                children: [
                                    TitulosPages(titulo: 'Parcelas'),
                                    Divider(),
                                    Expanded(child: Center(
                                        child: Text('No hay datos: \nIngrese una toma de datos', 
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

                                TitulosPages(titulo: 'Parcelas'),
                                Divider(),
                                Expanded(child: SingleChildScrollView(child: _listaDePlagas(textSombras, size, context)))
                            ],
                        );
                        
                        
                    },
                ),
                bottomNavigationBar: BottomAppBar(
                    child: Container(
                        color: kBackgroundColor,
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                            child: _addtest(context)
                        ),
                    ),
                ),
        );
        
    }

    Widget _addtest(BuildContext context){
        return RaisedButton.icon(
            icon:Icon(Icons.add_circle_outline_outlined),
            
            label: Text('Escoger parcelas',
                style: Theme.of(context).textTheme
                    .headline6!
                    .copyWith(fontWeight: FontWeight.w600, color: Colors.white)
            ),
            padding:EdgeInsets.all(13),
            onPressed:() => Navigator.pushNamed(context, 'addTest'),
        );
    }

    Widget  _listaDePlagas(List textSombra, Size size, BuildContext context){
        return ListView.builder(
            itemBuilder: (context, index) {
                return Dismissible(
                    key: UniqueKey(),
                    child: GestureDetector(
                        child: FutureBuilder(
                            future: _getdataFinca(textSombra[index]),
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                                if (!snapshot.hasData) {
                                    return Center(child: CircularProgressIndicator());
                                }
                                Finca finca = snapshot.data[0];
                                Parcela parcela = snapshot.data[1];

                                return _cardTest(size, textSombra[index], finca, parcela);
                            },
                        ),
                        onTap: () => Navigator.pushNamed(context, 'estaciones', arguments: textSombra[index]),
                    ),
                    confirmDismiss: (direction) => confirmacionUser(direction, context),
                    direction: DismissDirection.endToStart,
                    background: backgroundTrash(context),
                    movementDuration: Duration(milliseconds: 500),
                    onDismissed: (direction) => fincasBloc.borrarTestSombra(textSombra[index].id),
                );
               
            },
            shrinkWrap: true,
            itemCount: textSombra.length,
            padding: EdgeInsets.only(bottom: 30.0),
            controller: ScrollController(keepScrollOffset: false),
        );

    }

    Widget _cardTest(Size size, TestSombra textSombra, Finca finca, Parcela parcela){
        
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
                child: Column(
                    children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                                Padding(
                                    padding: EdgeInsets.only(right: 20),
                                    child: SvgPicture.asset('assets/icons/test.svg', height:80,),
                                ),
                                Flexible(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                        
                                            Padding(
                                                padding: EdgeInsets.only(top: 10, bottom: 5.0),
                                                child: Text(
                                                    "${finca.nombreFinca}",
                                                    softWrap: true,
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    style: Theme.of(context).textTheme.headline6,
                                                ),
                                            ),
                                            Padding(
                                                padding: EdgeInsets.only( bottom: 4.0),
                                                child: Text(
                                                    "${parcela.nombreLote}",
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(color: kLightBlackColor),
                                                ),
                                            ),
                                            
                                            Padding(
                                                padding: EdgeInsets.only( bottom: 10.0),
                                                child: Text(
                                                    'Fecha: ${textSombra.fechaTest}',
                                                    style: TextStyle(color: kLightBlackColor),
                                                ),
                                            ),
                                        ],  
                                    ),
                                ),
                            ],
                        ),
                        Divider(),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                                Icon(Icons.touch_app, color: kRedColor,),
                                Text(' Tocar para completar datos', style: TextStyle(color: kRedColor),)
                            ],
                        )
                    ],
                ),
        );
    }




}
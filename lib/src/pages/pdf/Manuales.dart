import 'package:app_sombra/src/utils/widget/varios_widget.dart';
import 'package:flutter/material.dart';


class Manuales extends StatelessWidget {
  const Manuales({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: Text('Lista de instructivos'),),
            body: ListView(
                children: [
                    _card( context, 'Instructivo sombra cacao', 'assets/documentos/Instructivo Sombra.pdf'),
                    _card( context, 'Manual de usuario Cacao Sombra', 'assets/documentos/Manual de usuario Cacao Sombra.pdf')
                ],
            )
        );
    }

    Widget _card( BuildContext context, String titulo, String url){
        return GestureDetector(
            child: cardDefault(
                tituloCard('$titulo'),
            ),
            onTap: () => Navigator.pushNamed(context, 'PDFview', arguments: ['Instructivo sombra cacao', url]),
        );
    }


}
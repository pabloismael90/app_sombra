import 'package:flutter/material.dart';



class PlantaForm extends StatefulWidget {
    PlantaForm({Key key}) : super(key: key);

    @override
    _PlantaFormState createState() => _PlantaFormState();
}

class _PlantaFormState extends State<PlantaForm> {
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Center(
                child: Text('Planta Formulario'),
            ),
        );
    }
}
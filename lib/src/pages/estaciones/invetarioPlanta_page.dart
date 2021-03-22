import 'package:flutter/material.dart';



class InventarioPage extends StatefulWidget {
    InventarioPage({Key key}) : super(key: key);

    @override
    _InventarioPageState createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(),
            body: Center(
                child: Text('inventario'),
            ),
        );
    }
}
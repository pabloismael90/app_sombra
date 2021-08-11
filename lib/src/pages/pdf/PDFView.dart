import 'package:flutter/material.dart';
import 'package:pdf_flutter/pdf_flutter.dart';

class PDFView extends StatelessWidget {
    const PDFView({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {

        List dataPDF = ModalRoute.of(context)!.settings.arguments as List;
        String? titulo = dataPDF[0];
        String? url = dataPDF[1];

        return Scaffold(
            appBar: AppBar(title: Text(titulo!),),
            body: PDF.asset(
                url!,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                
            ),
        );
    }
}
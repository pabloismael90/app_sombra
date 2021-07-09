import 'package:flutter/material.dart';

import 'package:pdf_flutter/pdf_flutter.dart';

class PDFView extends StatelessWidget {
    const PDFView({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(),
            body: PDF.asset(
            "assets/documentos/Instructivo Sombra.pdf",
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            placeHolder: Image.asset("assets/icons/icon.png",
                height: 200, width: 100),
            ),
        );
    }
}
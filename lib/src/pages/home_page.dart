import 'package:app_sombra/src/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:app_sombra/src/utils/widget/category_cart.dart';


class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        
        Size size = MediaQuery.of(context).size;
       
        return Scaffold(
            body: Column(
                children: [
                    Expanded(
                        child: Stack(
                            children:<Widget> [
                                Container(
                                    height: size.height * 0.25,
                                    decoration: BoxDecoration(
                                        color: kBackgroundColor,
                                        image: DecorationImage(
                                            image: AssetImage("assets/images/cacao_bg.png"),
                                            fit: BoxFit.fitWidth
                                        )
                                    ),
                                        
                                ),
                                Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                                    child: Text(
                                        "Cacao Sombra",
                                        style: Theme.of(context).textTheme
                                            .headline4
                                            .copyWith(fontWeight: FontWeight.w900, fontSize: 30)
                                    ),
                                ),
                                Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    child: Column(
                                        children: [
                                            SizedBox(height: size.height * 0.18),
                                            Expanded(
                                                child:GridView.count(
                                                        crossAxisCount: 2,
                                                        crossAxisSpacing: 30,
                                                        mainAxisSpacing:15,
                                                        children: <Widget>[
                                                            CategoryCard(
                                                                title: "Mis Fincas y mis parcelas",
                                                                svgSrc: "assets/icons/finca.svg",
                                                                press:() => Navigator.pushNamed(context, 'fincas' ),
                                                            ),
                                                            CategoryCard(
                                                                title: "Tomar datos y decisiones",
                                                                svgSrc: "assets/icons/test.svg",
                                                                press: () => Navigator.pushNamed(context, 'tests' ),
                                                            ),
                                                            CategoryCard(
                                                                title: "Consultar registro",
                                                                svgSrc: "assets/icons/report.svg",
                                                                press: () => Navigator.pushNamed(context, 'registros' ),
                                                            ),
                                                            CategoryCard(
                                                                title: "Imágenes",
                                                                svgSrc: "assets/icons/galeria.svg",
                                                                press: () => Navigator.pushNamed(context, 'galeria' ),
                                                            ),
                                                            CategoryCard(
                                                                title: "Instructivo",
                                                                svgSrc: "assets/icons/manual.svg",
                                                                press: () => Navigator.pushNamed(context, 'PDFview' ),
                                                            ),
                                                            
                                                            
                                                        ],
                                                ),
                                                
                                            
                                            ),
                                        
                                        ],
                                    ),
                                ),
                                
                                            
                            ],
                        ),
                    ),
                    Container(
                        color: Colors.white,
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                            child: Container(
                                height: size.height * 0.1,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    image: DecorationImage(
                                        image: AssetImage("assets/images/logos.png"),
                                        fit: BoxFit.fitWidth
                                    )
                                ),
                                    
                            ),
                        ),
                    ),
                ],
            ),

        );
    }
   
}










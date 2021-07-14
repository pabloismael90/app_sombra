import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class GaleriaImagenes extends StatefulWidget {
    GaleriaImagenes({Key? key}) : super(key: key);

    @override
    _GaleriaImagenesState createState() => _GaleriaImagenesState();
}


List? someImages;
List? nameImages;
Future _initImages(BuildContext context) async {
    // >> To get paths you need these 2 lines
    final manifestContent = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');

    final Map<String?, dynamic> manifestMap = json.decode(manifestContent);
    // >> To get paths you need these 2 lines
    
    List imagePaths = manifestMap.keys
        .where((String? key) => key!.contains('assets/galeria/'))
        .where((String? key) => key!.contains('.jpeg'))
        .toList();

    for (var i = 0; i < imagePaths.length; i++) {
       imagePaths[i] = imagePaths[i].replaceAll("%20", " ");
    }
    
    return imagePaths;
}

class _GaleriaImagenesState extends State<GaleriaImagenes> {
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: Text('Galería de Imágenes'),),
            body: FutureBuilder(
                future: _initImages(context),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                    }
                    String name;
                    List<String> nameList = [];

                    someImages = snapshot.data;
                    for (var item in someImages!) {
                        File file = new File(item);
                        name = file.path.split('/').last.split(".")[0];
                        if (name == 'Jinocuabo') {
                            name = 'Jiñocuabo';
                          
                        }
                        nameList.add(name);
                    }
                    

                    return Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                            children: [
                                Expanded(
                                    child: GridView.builder(
                                        itemCount: someImages!.length,
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 5,
                                            mainAxisSpacing:5,
                                        ),
                                        itemBuilder: (BuildContext context, int index) {
                                            return GestureDetector(
                                                child: Hero(
                                                    tag: index,
                                                    child: Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(5),
                                                            image: DecorationImage(
                                                                image: AssetImage(someImages![index]),
                                                                fit: BoxFit.cover
                                                            )
                                                        ),
                                                    ),
                                                ),
                                                onTap: (){
                                                    
                                                    Navigator.pushNamed(context, 'viewImg', arguments: [someImages, index, nameList] );
                                                },
                                            );
                                        },
                                    )
                                
                                ),
                                
                            ],
                        ),
                    );
                    
                },
            )
        );
    }


    
}
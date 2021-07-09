import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:photo_view/photo_view.dart';

class ViewImage extends StatefulWidget {
  const ViewImage({Key? key}) : super(key: key);

  @override
  _ViewImageState createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
    int? currentIndex;

    @override
    void initState() {
        currentIndex = 0;
        super.initState();
    }

    void onPageChanged(int index) {
        setState(() {
            currentIndex = index;
            print(currentIndex);
        });
    }

    @override
    Widget build(BuildContext context) {
        
        List dataRoute = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
        List listimg = dataRoute[0];
        int index = dataRoute[1];
        List<String> listname = dataRoute[2];
        Size size = MediaQuery.of(context).size;
        
        //print(index);
        return Scaffold(
            appBar: AppBar(),
            
            body:Swiper(
                itemBuilder: (BuildContext context,int index){
                    return Column(
                        children: [
                            Expanded(
                                child: Hero(
                                    tag: index,
                                    child: PhotoView(
                                        imageProvider: AssetImage(listimg[index]),
                                        
                                        minScale: PhotoViewComputedScale.contained * 0.8,
                                        maxScale: PhotoViewComputedScale.covered * 1.8,
                                        initialScale: PhotoViewComputedScale.contained,
                                    ),
                                )
                            ),
                            Container(
                                color: Colors.white,
                                child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                    child: Container(
                                        height: size.height * 0.08,
                                        color: Colors.white,
                                        child: Center(child: Text(listname[index]),),
                                            
                                    ),
                                ),
                            ),
                        ],
                    );
                },
                itemCount: listimg.length,
                pagination: null,
                control: SwiperControl(),
                index: index,
                
                
            ),
        );
    }
}
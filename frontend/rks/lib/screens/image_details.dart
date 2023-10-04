import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../globals.dart';

class DetailsPage extends StatefulWidget {
  final Image image;
  final int index;
  Map<int, Image> images;
  List<int> ids;

  DetailsPage(
      {required this.image,
        required this.index,
        required this.images,
        required this.ids});

  @override
  State<DetailsPage> createState() => DetailsPageState(image: image, index: index, images: images, ids: ids);
}

class DetailsPageState extends State<DetailsPage> {
  final Image image;
  final int index;
  Map<int, Image> images;
  List<int> ids;
  late PageController _pageController;

  DetailsPageState(
      {required this.image,
      required this.index,
      required this.images,
      required this.ids});

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Hero(
              tag: 'logo$index',
              child: PhotoViewGallery.builder(
                itemCount: images.length,
                pageController: _pageController,
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.contained * 4,
                      imageProvider: images[ids[index]]?.image);
                },
              ),
            ),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: MaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        color: primaryColor,
                        child: Text(
                          'Back',
                          style: TextStyle(
                            color: primaryTextColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

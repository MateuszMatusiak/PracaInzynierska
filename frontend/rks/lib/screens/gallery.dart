import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rks/model/image.dart';
import 'package:rks/model/user_details.dart';

import '../globals.dart';
import 'image_details.dart';

class GalleryPanel extends StatefulWidget {
  int? eventId;

  GalleryPanel(this.eventId, {super.key});

  @override
  State<GalleryPanel> createState() => _GalleryPanelState();
}

class _GalleryPanelState extends State<GalleryPanel> {
  final UserDetails _user = UserDetails.getInstance();
  late List<String> filePaths;
  final ImagePicker _imagePicker = ImagePicker();
  late Future<List<int>> _imagesIds;
  DefaultCacheManager cacheManager = DefaultCacheManager();
  late ScrollController _controller;

  final int _limit = 18;
  int _page = 0;

  bool _isFirstLoadRunning = false;
  bool _hasNextPage = true;
  bool _isLoadMoreRunning = false;

  final Map<int, Image> _images = {};

  @override
  void initState() {
    super.initState();
    _imagesIds = widget.eventId == null
        ? getImagesIds()
        : getEventImagesIds(widget.eventId!);
    _firstLoad();
    _controller = ScrollController()..addListener(_loadMore);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            pickImageFromGallery();
          },
        ),
        body: getGallery());
  }

  void pickImageFromGallery() async {
    var selectedImages = await _imagePicker.pickMultiImage();

    setState(() {
      filePaths = [];
      for (int i = 0; i < selectedImages.length; ++i) {
        filePaths.add(selectedImages[i].path);
      }
      uploadImages();
    });
  }

  void uploadImages() async {
    String eventUrl = widget.eventId != null ? '/${widget.eventId}' : '';
    String url = '${apiUrl}/images$eventUrl';
    var formData = FormData();
    for (var file in filePaths) {
      formData.files.addAll([
        MapEntry("images", await MultipartFile.fromFile(file)),
      ]);
    }
    try {
      var response = await dio.post(url,
          data: formData,
          options: Options(
              contentType: "multipart/form-data",
              headers: {
                'Authorization':  _user.token,
                'App-Version': appVersion
              }));
      if (response.statusCode == 200) {
        setState(() {
          _imagesIds = widget.eventId == null
              ? getImagesIds()
              : getEventImagesIds(widget.eventId!);
          _images.clear();
          _firstLoad();
        });
      }
    } catch (e) {
    }
  }

  Future<List<int>> getImagesIds() async {
    String url = '${apiUrl}/imagesIds';
    try {
      var response = await dio.get(url,
          options: Options(
              contentType: "application/json",
              responseType: ResponseType.json,
              headers: {
                'Authorization':  _user.token,
                'App-Version': appVersion
              }));
      if (response.statusCode == 200) {
        return List<int>.from(response.data);
      }
    } catch (e) {
    }
    return List.empty();
  }

  Future<List<int>> getEventImagesIds(int eventId) async {
    String url = '${apiUrl}/imagesIds/${eventId}';
    try {
      var response = await dio.get(url,
          options: Options(
              contentType: "application/json",
              responseType: ResponseType.json,
              headers: {
                'Authorization':  _user.token,
                'App-Version': appVersion
              }));
      if (response.statusCode == 200) {
        return List<int>.from(response.data);
      }
    } catch (e) {
    }
    return List.empty();
  }

  Future<Image> getImage(int id) async {
    String url = '${apiUrl}/images/$id';

    var file = await cacheManager.getFileFromCache('$id');
    if (file == null) {
      try {
        var response = await dio.get(url,
            options: Options(
                contentType: "application/json",
                responseType: ResponseType.bytes,
                headers: {
                'Authorization':  _user.token,
                'App-Version': appVersion
              }));
        if (response.statusCode == 200) {
          await cacheManager.putFile('$id', response.data);
          return Image.memory(
            response.data,
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          );
        }
      } catch (e) {
        return Image.network(
          'https://upload.wikimedia.org/wikipedia/commons/7/74/Pu%C5%82tusk%2C_Zesp%C3%B3%C5%82_zamku_biskupiego%2C_XIV-XIX%2C_XX_w..JPG',
          fit: BoxFit.fitWidth,
        );
      }
    }
    return Image.file(
      file!.file,
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
    );
  }

  Future<Map<int, Image>> getImages(List<int> ids) async {
    if (ids.isEmpty) return {};
    String url = '${apiUrl}/images?ids=${ids[0]}';

    Map<int, Image> res = {};
    for (int id in ids) {
      var file = await cacheManager.getFileFromCache('$id');
      if (file != null) {
        res.addEntries([
          MapEntry(
              id,
              Image.file(
                file.file,
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
              ))
        ]);
      } else {
        break;
      }
    }
    if (res.length == ids.length) {
      return res;
    }

    for (int i = 1; i < ids.length; ++i) {
      url += '&ids=${ids[i]}';
    }

    try {
      var response = await dio.get(url,
          options: Options(
              contentType: "application/json",
              responseType: ResponseType.json,
              headers: {
                'Authorization':  _user.token,
                'App-Version': appVersion
              }));
      if (response.statusCode == 200) {
        List<ImageData> tempImages = List.empty(growable: true);
        for (var i in response.data) {
          tempImages.add(ImageData.fromJson(i));
        }
        for (var i in tempImages) {
          await cacheManager.removeFile('${i.id}');
          await cacheManager.putFile('${i.id}', i.bytes);
          res.addEntries([
            MapEntry(
                i.id,
                Image.memory(
                  i.bytes,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  alignment: Alignment.center,
                ))
          ]);
        }
        return res;
      }
    } catch (e) {
      return {};
    }
    return res;
  }

  void _firstLoad() async {
    List<int> ids = await _imagesIds;
    setState(() {
      _isFirstLoadRunning = true;
    });
    List<int> tempIds = List.empty(growable: true);
    for (int i = 0; i < _limit && i < ids.length; ++i) {
      tempIds.add(ids[i]);
    }

    Map<int, Image> imgs = await getImages(tempIds);
    _images.addAll(imgs);

    setState(() {
      if (_images.isEmpty) {
        _hasNextPage = false;
      }
      _isFirstLoadRunning = false;
    });
  }

  void _loadMore() async {
    if (_hasNextPage == true &&
        _isFirstLoadRunning == false &&
        _isLoadMoreRunning == false &&
        _controller.position.extentAfter < 300) {

      setState(() {
        _isLoadMoreRunning = true;
      });

      List<int> ids = await _imagesIds;
      _page += 1;

      List<int> tempIds = List.empty(growable: true);
      for (int i = _limit * _page;
          i < _limit * (_page + 1) && i < ids.length;
          ++i) {
        tempIds.add(ids[i]);
      }
      Map<int, Image> tempImages = await getImages(tempIds);


      setState(() {
        if (tempImages.isEmpty) {
          _hasNextPage = false;
        } else {
          _images.addAll(tempImages);
        }
        _isLoadMoreRunning = false;
      });
    }
  }

  Widget? getGallery() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          FutureBuilder<List<int>>(
              future: _imagesIds,
              builder: (BuildContext context, AsyncSnapshot<List<int>> data) {
                if (data.hasData) {
                  return data.data!.isNotEmpty
                      ? Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 1,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: primaryBackgroundColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                            child: GridView.builder(
                                controller: _controller,
                                physics: PageScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 1,
                                  mainAxisSpacing: 1,
                                ),
                                itemBuilder: (context, index) {
                                  if (data.hasData) {
                                    int id = data.data![index];
                                    return RawMaterialButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetailsPage(
                                              image: _images[id]!,
                                              index: index,
                                              images: _images,
                                              ids: data.data!,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Hero(
                                        tag: 'logo$id',
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(0),
                                            image: DecorationImage(
                                              image: _images[id]!.image,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                },
                                itemCount: _images.length),
                          ),
                        )
                      : Center(
                          child: Text("Brak zdjęć",
                              style: TextStyle(color: primaryTextColor, fontSize: 16)),
                        );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              })
        ],
      ),
    );
  }
}

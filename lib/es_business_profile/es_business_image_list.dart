import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_business_profile.dart';
import 'package:foore/data/model/es_business.dart';

class EsBusinessProfileImageList extends StatefulWidget {
  final EsBusinessProfileBloc esBusinessProfileBloc;

  EsBusinessProfileImageList(
    this.esBusinessProfileBloc, {
    Key key,
  }) : super(key: key);

  @override
  _EsBusinessProfileImageListState createState() =>
      _EsBusinessProfileImageListState();
}

class _EsBusinessProfileImageListState
    extends State<EsBusinessProfileImageList> {
  File imageFile;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EsBusinessProfileState>(
        stream: widget.esBusinessProfileBloc.createBusinessObservable,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }

          var uploadedList = snapshot.data.selectedBusinessInfo.dImages
              .map(
                (EsImages dImage) => Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Material(
                    elevation: 1.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Stack(
                        children: <Widget>[
                          Image.network(dImage.photoUrl,
                              height: 120, width: 120),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.cancel),
                              color: Colors.black54,
                              onPressed: () {
                                widget.esBusinessProfileBloc
                                    .removeImage(dImage);
                              },
                              iconSize: 20,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList();
          var uploadingList =
              List.generate(snapshot.data.uploadingImages.length + 1, (index) {
            if (index == snapshot.data.uploadingImages.length) {
              return GestureDetector(
                onTap: widget.esBusinessProfileBloc.selectAndUploadImage,
                child: Container(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: Container(
                      height: 120,
                      width: 120,
                      color: Colors.grey[100],
                      child: Center(
                        child: Icon(
                          Icons.add_a_photo,
                          // size: 40,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Material(
                elevation: 1.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Stack(
                    children: <Widget>[
                      Image.file(snapshot.data.uploadingImages[index].file,
                          height: 120, width: 120),
                      Container(
                        child:
                            !snapshot.data.uploadingImages[index].isUploadFailed
                                ? Positioned(
                                    top: 0,
                                    left: 0,
                                    child: Container(
                                      height: 120,
                                      width: 120,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  )
                                : null,
                      ),
                      Container(
                        child:
                            snapshot.data.uploadingImages[index].isUploadFailed
                                ? Positioned(
                                    top: 0,
                                    left: 0,
                                    child: Container(
                                      height: 120,
                                      width: 120,
                                      color: Colors.white60,
                                      child: Center(
                                        child: Text(
                                          'Upload failed',
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .copyWith(
                                                color: Colors.black,
                                              ),
                                        ),
                                      ),
                                    ),
                                  )
                                : null,
                      ),
                      Container(
                        child:
                            snapshot.data.uploadingImages[index].isUploadFailed
                                ? Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: Icon(Icons.cancel),
                                      color: Colors.black54,
                                      onPressed: () {
                                        widget.esBusinessProfileBloc
                                            .removeUploadableImage(snapshot
                                                .data.uploadingImages[index]);
                                      },
                                      iconSize: 20,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  )
                                : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          });

          var listViewChildren = List<Widget>();
          listViewChildren.addAll(uploadedList);
          listViewChildren.addAll(uploadingList);

          return Container(
            height: 120,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: listViewChildren,
            ),
          );
        });
  }
}

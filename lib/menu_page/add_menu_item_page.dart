import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/es_edit_product.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:foore/menu_page/add_menu_image_list.dart';
import 'package:provider/provider.dart';

class AddMenuItemPage extends StatefulWidget {
  static const routeName = '/add-menu-item';
  final EsProduct currentProduct;

  AddMenuItemPage(this.currentProduct);

  @override
  AddMenuItemPageState createState() => AddMenuItemPageState();
}

class AddMenuItemPageState extends State<AddMenuItemPage>
    with AfterLayoutMixin<AddMenuItemPage> {
  final _formKey = GlobalKey<FormState>();

  Future<bool> _onWillPop() async {
    Navigator.pop(context);
    return false;
  }

  _showFailedAlertDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: true, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Submit failed'),
          content: const Text('Please try again.'),
          actions: <Widget>[
            FlatButton(
              child: const Text('Dismiss'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final esEditProductBloc = Provider.of<EsEditProductBloc>(context);
    esEditProductBloc.setCurrentProduct(widget.currentProduct);
    esEditProductBloc.esEditProductStateObservable.listen((event) {
      if (event.isSubmitFailed) {
        this._showFailedAlertDialog();
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final esEditProductBloc = Provider.of<EsEditProductBloc>(context);
    submit() {
      if (this._formKey.currentState.validate()) {
        esEditProductBloc.addProduct((EsProduct product) {
          Navigator.of(context).pop(product);
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.currentProduct != null ? 'Edit Product' : 'Add Product',
        ),
      ),
      body: StreamBuilder<EsEditProductState>(
          stream: esEditProductBloc.esEditProductStateObservable,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            return Form(
              key: _formKey,
              onWillPop: _onWillPop,
              child: Scrollbar(
                child: ListView(
                  children: <Widget>[
                    const SizedBox(height: 20),
                    EsAddMenuItemImageList(esEditProductBloc),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 20,
                        right: 20,
                      ),
                      child: TextFormField(
                        controller: esEditProductBloc.nameEditController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Product name',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 20,
                        right: 20,
                      ),
                      child: TextFormField(
                        controller:
                            esEditProductBloc.shortDescriptionEditController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Short description',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 20,
                        right: 20,
                      ),
                      child: TextFormField(
                        controller:
                            esEditProductBloc.longDescriptionEditController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Long description',
                        ),
                      ),
                    ),
                    // Container(
                    //   padding: const EdgeInsets.only(
                    //     top: 24.0,
                    //     left: 20,
                    //     right: 20,
                    //     bottom: 8,
                    //     // bottom: 8.0,
                    //   ),
                    //   alignment: Alignment.bottomLeft,
                    //   child: Text(
                    //     'Categories',
                    //     style: Theme.of(context).textTheme.subtitle2,
                    //   ),
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 20),
                    //   child: Row(
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     children: <Widget>[
                    //       Expanded(
                    //         child: Wrap(
                    //           children: <Widget>[
                    //             Padding(
                    //               padding: const EdgeInsets.only(right: 8.0),
                    //               child: Chip(
                    //                 label: Text(
                    //                   "It is a long establis",
                    //                   overflow: TextOverflow.ellipsis,
                    //                 ),
                    //               ),
                    //             ),
                    //             Padding(
                    //               padding: const EdgeInsets.only(right: 8.0),
                    //               child: Chip(
                    //                 label: Text(
                    //                   "It is a long establis",
                    //                   overflow: TextOverflow.ellipsis,
                    //                 ),
                    //               ),
                    //             ),
                    //             Chip(
                    //               backgroundColor:
                    //                   Theme.of(context).primaryColor,
                    //               avatar: Icon(
                    //                 Icons.add,
                    //                 color: Colors.white,
                    //               ),
                    //               label: Text(
                    //                 "Add category",
                    //                 overflow: TextOverflow.ellipsis,
                    //                 style: Theme.of(context)
                    //                     .textTheme
                    //                     .caption
                    //                     .copyWith(color: Colors.white),
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       )
                    //     ],
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 20,
                        right: 20,
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Price',
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(
                    //     top: 8.0,
                    //     left: 8,
                    //     right: 0,
                    //   ),
                    //   child: CheckboxListTile(
                    //     title: Text('Availability'),
                    //     value: false,
                    //     onChanged: (value) {},
                    //   ),
                    // ),
                  ],
                ),
              ),
            );
          }),
      floatingActionButton: StreamBuilder<EsEditProductState>(
          stream: esEditProductBloc.esEditProductStateObservable,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            return FoSubmitButton(
              text: 'Save',
              onPressed: submit,
              isLoading: snapshot.data.isSubmitting,
            );
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

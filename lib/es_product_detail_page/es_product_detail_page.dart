import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/es_edit_product.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:foore/es_category_page/es_category_page.dart';
import 'package:foore/menu_page/add_menu_image_list.dart';
import 'package:foore/utils/utils.dart';
import 'package:provider/provider.dart';

class EsProductDetailPageParam {
  final EsProduct currentProduct;
  //if this is true, we push directly to add sku item
  final bool openSkuAddUpfront;
  EsProductDetailPageParam({this.currentProduct, this.openSkuAddUpfront});
}

class EsProductDetailPage extends StatefulWidget {
  static const routeName = '/view-menu-item';
  final EsProduct currentProduct;
  //if this is true, we push directly to add sku item
  final bool openSkuAddUpfront;

  EsProductDetailPage(this.currentProduct, {this.openSkuAddUpfront = false});

  @override
  EsProductDetailPageState createState() => EsProductDetailPageState();
}

class EsProductDetailPageState extends State<EsProductDetailPage>
    with AfterLayoutMixin<EsProductDetailPage> {
  final _formKey = GlobalKey<FormState>();

  Future<bool> _onWillPop() async {
    Navigator.pop(context);
    return false;
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final esEditProductBloc = Provider.of<EsEditProductBloc>(context);
    esEditProductBloc.setCurrentProduct(widget.currentProduct);
    esEditProductBloc.getCategories();
    esEditProductBloc.esEditProductStateObservable.listen((event) {
      if (event.isSubmitFailed) {
        showFailedAlertDialog(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final esEditProductBloc = Provider.of<EsEditProductBloc>(context);

    addPreSelectedCategory(List<int> existedCategoryIds) async {
      final selectedCategories = await Navigator.of(context)
          .pushNamed(EsCategoryPage.routeName, arguments: existedCategoryIds);
      if (selectedCategories != null) {
        esEditProductBloc.addPreSelectedCategories(selectedCategories);
      }
    }

    removePreSelectedCategory(int categoryId) async {
      esEditProductBloc.removePreSelectedCategory(categoryId);
    }

    submit() {
      if (this._formKey.currentState.validate()) {
        esEditProductBloc.updateProductFull((EsProduct product) {
          Navigator.of(context).pop(product);
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.currentProduct.dProductName,
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
              child: ListView(
                children: <Widget>[
                  SizedBox(height: 16),

                  /// Categories Section
                  ///
                  Padding(
                    padding: const EdgeInsets.only(left: 14, right: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (snapshot.data.preSelectedCategories.length > 0) ...[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                  snapshot.data.preSelectedCategories.length,
                                  (index) {
                                final category =
                                    snapshot.data.preSelectedCategories[index];
                                final parentCategory = snapshot.data
                                    .getCategoryById(category.parentCategoryId);
                                return Chip(
                                  backgroundColor:
                                      Colors.black.withOpacity(0.05),
                                  onDeleted: () {
                                    removePreSelectedCategory(
                                        category.categoryId);
                                  },
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        flex: 1,
                                        child: Container(
                                          child: parentCategory.dCategoryName !=
                                                  null
                                              ? Text(
                                                  parentCategory
                                                          .dCategoryName ??
                                                      '',
                                                  overflow: TextOverflow.fade,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle1
                                                      .copyWith(
                                                        color: ListTileTheme.of(
                                                                context)
                                                            .textColor,
                                                      ),
                                                )
                                              : null,
                                        ),
                                      ),
                                      Icon(Icons.chevron_right),
                                      Flexible(
                                        flex: 1,
                                        child: Container(
                                          child: Text(
                                            category.dCategoryName ?? '',
                                            overflow: TextOverflow.fade,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .copyWith(
                                                  color:
                                                      ListTileTheme.of(context)
                                                          .textColor,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                          // IconButton(
                          //   onPressed: () {
                          //     addPreSelectedCategory(snapshot
                          //         .data.preSelectedCategories
                          //         .map((e) => e.categoryId)
                          //         .toList());
                          //   },
                          //   icon: Icon(
                          //     Icons.add,
                          //     color: Theme.of(context).primaryColor,
                          //   ),
                          // ),
                        ],
                        if (snapshot.data.preSelectedCategories.length == 0)
                          InkWell(
                            onTap: () {
                              addPreSelectedCategory(snapshot
                                  .data.preSelectedCategories
                                  .map((e) => e.categoryId)
                                  .toList());
                            },
                            child: Chip(
                              backgroundColor: Theme.of(context).primaryColor,
                              avatar: Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                              label: Text(
                                AppTranslations.of(context)
                                    .text('products_page_add_category'),
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    .copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  /// Name Section
                  ///
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
                        labelText: AppTranslations.of(context)
                            .text('products_page_name'),
                      ),
                    ),
                  ),

                  /// Variations Section
                  ///
                  Container(
                    padding: const EdgeInsets.only(
                      top: 4.0,
                      left: 20,
                      bottom: 8,
                    ),
                    child: Column(
                      children: List.generate(
                          snapshot.data.preSelectedActiveSKUs.length + 1,
                          (index) {
                        if (snapshot.data.preSelectedActiveSKUs.length ==
                            index) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              FlatButton(
                                onPressed: () {
                                  esEditProductBloc.addPreSelectedSKU();
                                },
                                child: Text(
                                  '+ ' +
                                      AppTranslations.of(context)
                                          .text('products_page_add_variation'),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        }
                        return VariationCard(
                            snapshot.data.preSelectedActiveSKUs[index],
                            esEditProductBloc,
                            snapshot.data.preSelectedActiveSKUs.length);
                      }),
                    ),
                  ),

                  /// Images Section
                  ///
                  Container(
                    padding: const EdgeInsets.only(
                      top: 16.0,
                      left: 20,
                      right: 20,
                      bottom: 8,
                      // bottom: 8.0,
                    ),
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Product images',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ),
                  SizedBox(height: 8),
                  EsAddMenuItemImageList(esEditProductBloc),
                  SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: TextFormField(
                      controller:
                          esEditProductBloc.shortDescriptionEditController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText:
                              AppTranslations.of(context).text('Description'),
                          helperText: 'Optional'),
                    ),
                  ),
                  SizedBox(height: 100),
                ],
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
              text: AppTranslations.of(context).text('products_page_save'),
              onPressed: submit,
              isLoading: snapshot.data.isSubmitting,
            );
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class VariationCard extends StatelessWidget {
  final EsProductSKUTamplate skuTemplate;
  final numberOfPreSelectetSkuTemplate;
  final EsEditProductBloc esEditProductBloc;
  const VariationCard(
    this.skuTemplate,
    this.esEditProductBloc,
    this.numberOfPreSelectetSkuTemplate, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              skuTemplate.skuCode != null
                  ? Text(
                      'SKU: ' + skuTemplate.skuCode,
                      style: Theme.of(context).textTheme.caption,
                    )
                  : Text(
                      'New',
                      style: Theme.of(context).textTheme.caption.copyWith(
                          // color: Theme.of(context).primaryColor,
                          fontStyle: FontStyle.italic),
                    ),
              SizedBox(
                width: 4.0,
              ),
              if (!skuTemplate.isActive)
                Text(
                  '(Inactive)',
                  style: Theme.of(context).textTheme.caption.copyWith(
                      color:
                          Theme.of(context).colorScheme.error.withOpacity(0.8)),
                ),
            ],
          ),
          SizedBox(
            height: 4.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Colors.black26,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: skuTemplate.quantityController,
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                          ),
                          validator: (text) {
                            return text.length == 0
                                ? AppTranslations.of(context)
                                    .text('error_messages_required')
                                : null;
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: DropdownButton(
                            underline: SizedBox.shrink(),
                            isExpanded: true,
                            value: skuTemplate.unit,
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                .copyWith(color: Colors.black),
                            items: esEditProductBloc
                                .getUnitsList(skuTemplate.unit)
                                .map((unit) => DropdownMenuItem(
                                    value: unit, child: Text(unit)))
                                .toList(),
                            onChanged: (String value) {
                              esEditProductBloc.updatePreSelectedSKUUnit(
                                  skuTemplate.key, value);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 12.0,
              ),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Colors.black26,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 6,
                        ),
                        color: Colors.black12,
                        child: Text(
                          '₹',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextFormField(
                            controller: skuTemplate.priceController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.end,
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                            ),
                            validator: (text) {
                              if (double.tryParse(text) == null) {
                                return AppTranslations.of(context)
                                    .text('orders_page_invalid_price');
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 8.0,
              ),
              Container(
                height: 60.0,
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'In Stock',
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                        SizedBox(
                          height: 36.0,
                          child: Switch(
                            value: skuTemplate.inStock,
                            onChanged: (updatedVal) {
                              esEditProductBloc.updatePreSelectedSKUStock(
                                  skuTemplate.key, updatedVal);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 4.0,
              ),
              PopupMenuButton<int>(
                onSelected: (result) {
                  if (result == 1) {
                    esEditProductBloc.removePreSelectedSKU(skuTemplate.key);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                  PopupMenuItem(
                    enabled: numberOfPreSelectetSkuTemplate > 1,
                    value: 1,
                    child: Text('Remove'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

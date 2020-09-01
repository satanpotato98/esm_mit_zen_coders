import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_business_profile.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_business.dart';
import 'package:foore/es_business_profile/es_business_image_list.dart';
import 'package:foore/es_business_profile/es_edit_business_description.dart';
import 'package:foore/es_business_profile/es_edit_text_generic.dart';
import 'package:foore/widgets/es_select_business.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'es_edit_business_address.dart';
import 'es_edit_business_name.dart';
import 'es_edit_business_payment_upi_address.dart';
import 'es_edit_business_phone.dart';

class EsBusinessProfile extends StatefulWidget {
  static const routeName = '/es_business_profile';

  EsBusinessProfile({Key key}) : super(key: key);

  _EsBusinessProfileState createState() => _EsBusinessProfileState();
}

class _EsBusinessProfileState extends State<EsBusinessProfile> {
  EsBusinessProfileBloc esBusinessProfileBloc;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    this.esBusinessProfileBloc = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final httpService = Provider.of<HttpService>(context);
    final businessBloc = Provider.of<EsBusinessesBloc>(context);
    if (this.esBusinessProfileBloc == null) {
      this.esBusinessProfileBloc =
          EsBusinessProfileBloc(httpService, businessBloc);
    }

    editName() async {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => EsEditBaseTextPage(
                this.esBusinessProfileBloc,
                'Add phone number',
                'Phone number',
                this.esBusinessProfileBloc.phoneNumberEditingControllers,
                this.esBusinessProfileBloc.addPhone,
              )));
    }

    editUpiAddress() async {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              EsEditBusinessUpiPage(this.esBusinessProfileBloc)));
    }

    addPhone() async {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              EsEditBusinessPhonesPage(this.esBusinessProfileBloc)));
    }

    addAddress() async {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              EsEditBusinessAddressPage(this.esBusinessProfileBloc)));
    }

    addDescription() async {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              EsEditBusinessDescriptionPage(this.esBusinessProfileBloc)));
    }

    Widget getBaseHeaderWidget(String headerName) {
      return Container(
        padding: const EdgeInsets.only(
          top: 24.0,
          left: 20,
          right: 20,
          // bottom: 8.0,
        ),
        alignment: Alignment.bottomLeft,
        child: Text(
          headerName,
          style: Theme.of(context).textTheme.subtitle2,
        ),
      );
    }

    Widget getPhoneWidget(businessInfo) {
      return Container(
        child: businessInfo.dPhones.length == 0
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FlatButton(
                    onPressed: addPhone,
                    child: Text(
                      "+ Add phone",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Wrap(
                        children: businessInfo.dPhones
                            .map((phone) => Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Chip(
                                    label: Text(
                                      phone,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onDeleted: () {
                                      this
                                          .esBusinessProfileBloc
                                          .deletePhoneWithNumber(phone);
                                    },
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    IconButton(
                      onPressed: addPhone,
                      icon: Icon(
                        Icons.add,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  ],
                ),
              ),
      );
    }

    Widget getUpiHeaderWidget(businessInfo) {
      return Container(
          padding: const EdgeInsets.only(
            //top: 24.0,
            left: 20,
            right: 20,
            // bottom: 8.0,
          ),
          alignment: Alignment.bottomLeft,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'UPI Payment',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ),
              Switch(
                  value: businessInfo.dBusinessPaymentStatus,
                  onChanged: (value) {
                    this
                        .esBusinessProfileBloc
                        .updateUpiStatus(value, null, null);
                  }),
            ],
          ));
    }

    Widget getUpiWidget(businessInfo) {
      return Container(
        child: businessInfo.dBusinessPaymentUpiAddress == ''
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FlatButton(
                    onPressed: editUpiAddress,
                    child: Text(
                      "+ Add UPI ID",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        businessInfo.dBusinessPaymentUpiAddress,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                    IconButton(
                      onPressed: editUpiAddress,
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  ],
                ),
              ),
      );
    }

    Widget getBusinessNameWidget(businessInfo) {
      return Container(
        child: businessInfo.dBusinessName == ''
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FlatButton(
                    onPressed: editName,
                    child: Text(
                      "+ Add business name",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        businessInfo.dBusinessName,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                    IconButton(
                      onPressed: editName,
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  ],
                ),
              ),
      );
    }

    Widget getAddressWidget(businessInfo) {
      return Container(
        child: businessInfo.dBusinessPrettyAddress == ''
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FlatButton(
                    onPressed: addAddress,
                    child: Text(
                      "+ Add address",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        businessInfo.dBusinessPrettyAddress,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                    IconButton(
                      onPressed: addAddress,
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  ],
                ),
              ),
      );
    }

    Widget getDescriptionWidget(businessInfo) {
      return Container(
        child: businessInfo.dBusinessDescription == ''
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FlatButton(
                    onPressed: addDescription,
                    child: Text(
                      "+ Add description",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        businessInfo.dBusinessDescription,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                    IconButton(
                      onPressed: addDescription,
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  ],
                ),
              ),
      );
    }

    return Scaffold(
      appBar: EsSelectBusiness(() {}),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: SingleChildScrollView(
            child: StreamBuilder<EsBusinessProfileState>(
              stream: this.esBusinessProfileBloc.createBusinessObservable,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                EsBusinessInfo businessInfo =
                    snapshot.data.selectedBusinessInfo;
                return Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Wrap(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 0, top: 13, bottom: 13),
                                  child: Text(
                                    "Delivery",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Switch(
                                    value: snapshot.data.hasDelivery,
                                    onChanged: (value) {
                                      this
                                          .esBusinessProfileBloc
                                          .setDelivery(value);
                                    }),
                              ],
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Wrap(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 0, top: 13, bottom: 13),
                                  child: Text(
                                    "Store Open",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Switch(
                                    value: snapshot.data.isOpen,
                                    onChanged: (value) {
                                      this.esBusinessProfileBloc.setOpen(value);
                                    }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    getBaseHeaderWidget('Name'),
                    getBusinessNameWidget(businessInfo),
                    getBaseHeaderWidget('Phone'),
                    getPhoneWidget(businessInfo),
                    getUpiHeaderWidget(businessInfo),
                    getUpiWidget(businessInfo),
                    getBaseHeaderWidget('Address'),
                    getAddressWidget(businessInfo),
                    getBaseHeaderWidget('Description'),
                    getDescriptionWidget(businessInfo),
                    getBaseHeaderWidget('Photos'),
                    SizedBox(height: 20),
                    EsBusinessProfileImageList(esBusinessProfileBloc),
                    SizedBox(height: 120),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

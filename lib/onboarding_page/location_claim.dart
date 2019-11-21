import 'dart:async';
import 'dart:convert';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:foore/data/bloc/location_claim.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/search_gmb/model/google_locations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class LocationClaimPage extends StatefulWidget {
  // static const responseString =
  //     '{ "googleLocations": [ { "name": "googleLocations/ChIJ3a2l4X0RrjsRggWzPz6Q0xM", "location": { "locationName": "Mukesh Realtors", "primaryCategory": { "displayName": "Property management company", "categoryId": "gcid:property_management_company" }, "locationKey": { "placeId": "ChIJ3a2l4X0RrjsRggWzPz6Q0xM" }, "latlng": { "latitude": 12.969414, "longitude": 77.705732 }, "languageCode": "en", "address": { "regionCode": "IN", "languageCode": "en", "postalCode": "560037", "administrativeArea": "Karnataka", "locality": "Bengaluru", "addressLines": [ "# 51, Shanti Nivas 7th Cross chinapanahalli", "Doddanekundi, Ext" ] } }, "requestAdminRightsUrl": "https://business.google.com/arc/p/ChIJ3a2l4X0RrjsRggWzPz6Q0xM" } ] }';
  // static GoogleLocationsResponse googleLocationsResponse =
  //     GoogleLocationsResponse.fromJson(json.decode(responseString));

  // final GoogleLocation googleLocation =
  //     googleLocationsResponse.googleLocations[0];

  static const routeName = '/location-claim';
  LocationClaimPage({Key key}) : super(key: key);

  @override
  _LocationClaimPageState createState() => _LocationClaimPageState();

  static Route generateRoute(RouteSettings settings,
      {@required HttpService httpService, @required AuthBloc authBloc}) {
    var argumentsForLocationClaim = settings.arguments as Map<String, dynamic>;
    GoogleLocation googleLocation = argumentsForLocationClaim['googleLocation'];
    GmbLocationItem locationItem = argumentsForLocationClaim['locationItem'];
    return MaterialPageRoute(
      builder: (context) => Provider<LocationClaimBloc>(
        builder: (context) => LocationClaimBloc(
          httpService: httpService,
          authBloc: authBloc,
          googleLocation: googleLocation,
          locationItem: locationItem,
        ),
        dispose: (context, value) => value.dispose(),
        child: LocationClaimPage(),
      ),
    );
  }
}

class _LocationClaimPageState extends State<LocationClaimPage>
    with AfterLayoutMixin<LocationClaimPage> {
  Completer<GoogleMapController> _controller = Completer();
  StreamSubscription<LocationClaimState> _subscription;

  @override
  void afterFirstLayout(BuildContext context) {
    final LocationClaimBloc locationClaimBloc =
        Provider.of<LocationClaimBloc>(context);
    _subscription = locationClaimBloc.onboardingStateObservable
        .listen(_onLocationClaimChange);
  }

  _onLocationClaimChange(LocationClaimState state) {
    if (state.isShowVerificationPending) {
      // navigate away from this page.
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final LocationClaimBloc locationClaimBloc =
        Provider.of<LocationClaimBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Claim business"),
      ),
      body: SafeArea(
        child: StreamBuilder<LocationClaimState>(
            stream: locationClaimBloc.onboardingStateObservable,
            builder: (context, snapshot) {
              var child = Container();
              if (snapshot.hasData) {
                if (snapshot.data.isShowClaimed) {
                  child = claimedBusiness(snapshot.data.locationItem);
                } else if (snapshot.data.isShowLocation) {
                  child = claimBusiness(snapshot.data.locationItem);
                }
              }
              return child;
            }),
      ),
    );
  }

  Widget claimedBusiness(GmbLocationItem locationItem) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 32.0,
        ),
        locationDetail(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).errorColor.withOpacity(0.2),
          ),
          child: Text(
            "This business is managed by another Google account.If they are your friend or college please ask them to give permission to access to this location and come back here.",
            style: Theme.of(context)
                .textTheme
                .body1
                .copyWith(color: Theme.of(context).errorColor),
          ),
        ),
        FlatButton(
          child: Text(
            'Request Access to manage this business',
            style: Theme.of(context).textTheme.button.copyWith(
                  decoration: TextDecoration.underline,
                ),
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget claimBusiness(GmbLocationItem locationItem) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 32.0,
        ),
        locationDetail(),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          width: double.infinity,
          child: RaisedButton(
            onPressed: () {},
            child: Text('Manage this business'),
          ),
        )
      ],
    );
  }

  Container locationDetail(GmbLocationItem locationItem) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            child: ListTile(
              title: Text(locationItem.locationName ?? ''),
              subtitle: Text(
                  '# 51, Shanti Nivas 7th Cross chinapanahalli, "Doddanekundi, Ext, Bengaluru, Karnataka'),
            ),
          ),
          Container(
            height: 200.0,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  locationItem.latlng.latitude,
                  locationItem.latlng.longitude,
                ),
                zoom: 14.4746,
              ),
              markers: Set.from([
                Marker(
                  position: LatLng(
                    locationItem.latlng.latitude,
                    locationItem.latlng.longitude,
                  ),
                  markerId: MarkerId('fooreMarker'),
                )
              ]),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
        ],
      ),
    );
  }
}

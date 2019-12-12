import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foore/data/bloc/onboarding_guard.dart';
import 'package:foore/data/http_service.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:upi_india/upi_india.dart';

import 'analytics.dart';

import 'package:uuid/uuid.dart';

class CreatePromotionBloc {
  final CreatePromotionState _createPromotionState = CreatePromotionState();
  final HttpService httpService;
  final messageEditController = TextEditingController(
      text:
          'Grand offer - 5000Rs. ki shopping par paye 25% discount - Gupta Saree wale, Uttam Nagar Call kare - 765451234');

  static const button_one_base = 2908;
  final buttonOneCal = button_one_base + Random().nextInt(255);
  static const button_two_base = 1305;
  final buttonTwoCal = button_two_base + Random().nextInt(115);
  static const button_three_base = 360;
  final buttonThreeCal = button_three_base + Random().nextInt(31);

  BehaviorSubject<CreatePromotionState> _subjectCreatePromotionState;

  CreatePromotionBloc({@required this.httpService}) {
    this._subjectCreatePromotionState =
        new BehaviorSubject<CreatePromotionState>.seeded(_createPromotionState);
  }

  Observable<CreatePromotionState> get CreatePromotionStateObservable =>
      _subjectCreatePromotionState.stream;

  getNearbyPromotions() {
    this._createPromotionState.isLoading = true;
    this._createPromotionState.isLoadingFailed = false;
    this._updateState();
    httpService.foGet('nearby/promo/').then((httpResponse) {
      print(httpResponse.statusCode);
      if (httpResponse.statusCode == 200) {
        print(httpResponse.body);
        this._createPromotionState.response =
            NearbyPromotionResponse.fromJson(json.decode(httpResponse.body));
        this._createPromotionState.isLoadingFailed = false;
        this._createPromotionState.isLoading = false;
      } else {
        this._createPromotionState.isLoadingFailed = true;
        this._createPromotionState.isLoading = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._createPromotionState.isLoadingFailed = true;
      this._createPromotionState.isLoading = false;
      this._updateState();
    });
  }

  setPromoReach(String promoReach, int numberOfCustomers, int price) {
    this._createPromotionState.promoReach = promoReach;
    this._createPromotionState.numberOfCustomers = numberOfCustomers;
    this._createPromotionState.price = price;
    this._updateState();
  }

  setSelectedLocation(FoLocations location) {
    this._createPromotionState.selectedLocation = location;
    this._updateState();
  }

  Future<bool> pay(double price) async {
    var uuid = Uuid();
    UpiIndia upi = new UpiIndia(
      receiverUpiId: '7829862689@upi',
      receiverName: 'Ravinder Singh Mahori',
      transactionRefId: uuid.v1(),
      transactionNote: 'Charge',
      amount: price,
    );
    this
        .httpService
        .foAnalytics
        .trackUserEvent(name: FoAnalyticsEvents.payment_started);
    String response = await upi.startTransaction();
    this.httpService.foAnalytics.trackUserEvent(
        name: FoAnalyticsEvents.payment_response,
        parameters: <String, String>{'response': response});
    switch (response) {
      case UpiIndiaResponseError.APP_NOT_INSTALLED:
        return false;
        break;
      case UpiIndiaResponseError.INVALID_PARAMETERS:
        return false;
        break;
      case UpiIndiaResponseError.USER_CANCELLED:
        return false;
        break;
      case UpiIndiaResponseError.NULL_RESPONSE:
        return false;
        break;
      default:
        UpiIndiaResponse _upiResponse;
        _upiResponse = UpiIndiaResponse(response);
        String txnId = _upiResponse.transactionId;
        String resCode = _upiResponse.responseCode;
        String txnRef = _upiResponse.transactionRefId;
        String status = _upiResponse.status;
        String approvalRef = _upiResponse.approvalRefNo;
        if (status == UpiIndiaResponseStatus.SUCCESS) {
          return true;
        }
        return false;
    }
  }

  createPromotion(Function onDone) async {
    if (this._createPromotionState.isSubmitting) {
      return;
    }
    this._createPromotionState.isSubmitting = true;
    this._createPromotionState.isSubmitFailed = false;
    this._createPromotionState.isSubmitSuccess = false;
    this._updateState();
    ////
    bool isSuccess = await pay(_createPromotionState.price.toDouble());
    if (!isSuccess) {
      this._createPromotionState.isSubmitting = false;
      this._createPromotionState.isSubmitFailed = true;
      this._createPromotionState.isSubmitSuccess = false;
      this._updateState();
      return;
    }

    /////////////
    var payload = new PromotionCreatePayload(
        promoMessage: messageEditController.text,
        promoReach: _createPromotionState.promoReach,
        locationId: _createPromotionState.selectedLocation?.fbLocationId);
    var payloadString = json.encode(payload.toJson());
    print(payloadString);
    this
        .httpService
        .foPost('nearby/promo/create/', payloadString)
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 202) {
        this.httpService.foAnalytics.trackUserEvent(
            name: FoAnalyticsEvents.nearby_promo_created,
            parameters: <String, String>{
              'promoReach': _createPromotionState.promoReach
            });
        this._createPromotionState.promotionCreateResponse =
            PromotionItem.fromJson(json.decode(httpResponse.body));
        this._createPromotionState.isSubmitting = false;
        this._createPromotionState.isSubmitFailed = false;
        this._createPromotionState.isSubmitSuccess = true;
        if (onDone != null) {
          onDone();
        }
      } else {
        this._createPromotionState.isSubmitting = false;
        this._createPromotionState.isSubmitFailed = true;
        this._createPromotionState.isSubmitSuccess = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._createPromotionState.isSubmitting = false;
      this._createPromotionState.isSubmitFailed = true;
      this._createPromotionState.isSubmitSuccess = false;
      this._updateState();
    });
  }

  _updateState() {
    if (!this._subjectCreatePromotionState.isClosed) {
      this._subjectCreatePromotionState.sink.add(this._createPromotionState);
    }
  }

  dispose() {
    this._subjectCreatePromotionState.close();
  }
}

enum CreatePromotionScreens {
  loading,
  loadingFailed,
  sendPromotions,
  promotionSent
}

class CreatePromotionState {
  bool isLoading = false;
  bool isLoadingFailed = false;
  bool isSubmitting = false;
  bool isSubmitFailed = false;
  bool isSubmitSuccess = false;
  String promoReach = '';
  int numberOfCustomers = 0;
  int price = 0;
  FoLocations selectedLocation;
  NearbyPromotionResponse nearbyPromotionResponse;
  List<PromotionItem> promotionList = new List<PromotionItem>();

  CreatePromotionScreens get screenType {
    if (isLoading) {
      return CreatePromotionScreens.loading;
    } else if (isLoadingFailed) {
      return CreatePromotionScreens.loadingFailed;
    } else if (promotionList.length == 0) {
      return CreatePromotionScreens.sendPromotions;
    } else if (promotionList.length > 0) {
      return CreatePromotionScreens.promotionSent;
    }
    return CreatePromotionScreens.loading;
  }

  set response(NearbyPromotionResponse response) {
    nearbyPromotionResponse = response;
    promotionList = response.results;
  }

  set promotionCreateResponse(PromotionItem response) {
    promotionList.add(response);
  }
}

class NearbyPromotionResponse {
  int count;
  String next;
  String previous;
  List<PromotionItem> results;

  NearbyPromotionResponse({this.count, this.next, this.previous, this.results});

  NearbyPromotionResponse.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = new List<PromotionItem>();
      json['results'].forEach((v) {
        results.add(new PromotionItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['next'] = this.next;
    data['previous'] = this.previous;
    if (this.results != null) {
      data['results'] = this.results.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PromotionItem {
  int promoId;
  String companyId;
  String locationId;
  String promoMessage;
  String promoReach;
  int promoState;
  String created;

  PromotionItem(
      {this.promoId,
      this.companyId,
      this.locationId,
      this.promoMessage,
      this.promoReach,
      this.promoState,
      this.created});

  PromotionItem.fromJson(Map<String, dynamic> json) {
    promoId = json['promo_id'];
    companyId = json['company_id'];
    locationId = json['location_id'];
    promoMessage = json['promo_message'];
    promoReach = json['promo_reach'];
    promoState = json['promo_state'];
    created = json['created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['promo_id'] = this.promoId;
    data['company_id'] = this.companyId;
    data['location_id'] = this.locationId;
    data['promo_message'] = this.promoMessage;
    data['promo_reach'] = this.promoReach;
    data['promo_state'] = this.promoState;
    data['created'] = this.created;
    return data;
  }

  String getCreatedTimeText() {
    var lastInteractionDate = DateTime.parse(this.created);
    var formatter = new DateFormat('hh:mm a, dd MMM, yyyy');
    String timeText = formatter.format(lastInteractionDate);
    return timeText;
  }
}

class PromotionCreatePayload {
  String promoMessage;
  String promoReach;
  String locationId;

  PromotionCreatePayload({this.promoMessage, this.promoReach, this.locationId});

  PromotionCreatePayload.fromJson(Map<String, dynamic> json) {
    promoMessage = json['promo_message'];
    promoReach = json['promo_reach'];
    locationId = json['location_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['promo_message'] = this.promoMessage;
    data['promo_reach'] = this.promoReach;
    data['location_id'] = this.locationId;
    return data;
  }
}

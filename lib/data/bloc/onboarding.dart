import 'dart:convert';
import 'package:foore/data/http_service.dart';
import 'package:rxdart/rxdart.dart';

import 'gmb_location.dart';
import 'google_account.dart';

class OnboardingBloc {
  final OnboardingState _onboardingState = new OnboardingState();
  final HttpService _httpService;

  BehaviorSubject<OnboardingState> _subjectOnboardingState;

  OnboardingBloc(this._httpService) {
    this._subjectOnboardingState = new BehaviorSubject<OnboardingState>.seeded(
        _onboardingState); //initializes the subject with element already
  }

  Observable<OnboardingState> get onboardingStateObservable =>
      _subjectOnboardingState.stream;

  getData() {
    if (this._onboardingState.shouldFetch) {
      this._onboardingState.isLoading = true;
      this._onboardingState.isLoadingFailed = false;
      this._updateState();
      _httpService
          .foGet(
              'ui/helper/account/?verified&onboarding&google_account&gmb_locations&location_connections')
          .then((httpResponse) {
        if (httpResponse.statusCode == 200) {
          this._onboardingState.response =
              UiHelperResponse.fromJson(json.decode(httpResponse.body));
          this._onboardingState.isLoadingFailed = false;
          this._onboardingState.isLoading = false;
        } else {
          this._onboardingState.isLoadingFailed = true;
          this._onboardingState.isLoading = false;
        }
        this._updateState();
      }).catchError((onError) {
        this._onboardingState.isLoadingFailed = true;
        this._onboardingState.isLoading = false;
        this._updateState();
      });
    }
  }

  _updateState() {
    this._subjectOnboardingState.sink.add(this._onboardingState);
  }

  dispose() {
    this._subjectOnboardingState.close();
  }
}

class OnboardingState {
  bool isLoading;
  bool isLoadingFailed;
  UiHelperResponse response;

  get shouldFetch => isLoading == false && response == null;

  get isShowLocationList => true;

  get isShowInsufficientPermissions => false;

  get isShowNoGmbLocations => false;

  List<GmbLocation> get locations =>
      response != null ? response.gmbLocations : [];

  OnboardingState() {
    this.isLoading = false;
    this.isLoadingFailed = false;
  }
}

class UiHelperResponse {
  GoogleAccount googleAccount;
  List<GmbLocation> gmbLocations;

  UiHelperResponse({
    this.googleAccount,
    this.gmbLocations,
  });

  UiHelperResponse.fromJson(Map<String, dynamic> json) {
    googleAccount = json['google_account'] != null
        ? new GoogleAccount.fromJson(json['google_account'])
        : null;
    if (json['gmb_locations'] != null) {
      gmbLocations = new List<GmbLocation>();
      json['gmb_locations'].forEach((v) {
        gmbLocations.add(new GmbLocation.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.googleAccount != null) {
      data['google_account'] = this.googleAccount.toJson();
    }
    if (this.gmbLocations != null) {
      data['gmb_locations'] = this.gmbLocations.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
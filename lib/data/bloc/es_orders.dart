import 'dart:async';
import 'dart:convert';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_orders.dart';
import 'package:rxdart/rxdart.dart';

class EsOrdersBloc {
  final EsOrdersState _esOrdersState = new EsOrdersState();
  final HttpService httpService;
  final EsBusinessesBloc esBusinessesBloc;

  String orderStatus;

  String searchText = '';

  StreamSubscription<EsBusinessesState> _subscription;

  BehaviorSubject<EsOrdersState> _subjectEsOrdersState;

  EsOrdersBloc(this.orderStatus, this.httpService, this.esBusinessesBloc) {
    this._subjectEsOrdersState =
        new BehaviorSubject<EsOrdersState>.seeded(_esOrdersState);
    this._subscription =
        this.esBusinessesBloc.esBusinessesStateObservable.listen((event) {
      this.getOrders();
    });
  }

  Observable<EsOrdersState> get esProductStateObservable =>
      _subjectEsOrdersState.stream;

  getOrders() {
    getDeliveryAgents();
    this._esOrdersState.isLoading = true;
    this._esOrdersState.response = null;
    this._updateState();
    httpService
        .esGet(EsApiPaths.getOrders +
            '?order_status=${this.orderStatus}' +
            '&business_id=${this.esBusinessesBloc.getSelectedBusinessId()}')
        .then((httpResponse) {
      if (httpResponse.statusCode == 200) {
        this._esOrdersState.isLoadingFailed = false;
        this._esOrdersState.isLoading = false;
        this._esOrdersState.response =
            EsGetOrdersResponse.fromJson(json.decode(httpResponse.body));
        this._esOrdersState.items = this._esOrdersState.response.results;
      } else {
        this._esOrdersState.isLoadingFailed = true;
        this._esOrdersState.isLoading = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._esOrdersState.isLoadingFailed = true;
      this._esOrdersState.isLoading = false;
      this._updateState();
    });
  }

  loadMore() {
    if (this._esOrdersState.response == null ||
        this._esOrdersState.isLoadingMore) {
      return;
    }
    if (this._esOrdersState.response.next == null) {
      return;
    }
    this._esOrdersState.isLoadingMore = true;
    this._esOrdersState.isLoadingMoreFailed = false;
    this._updateState();
    httpService
        .esGetUrl(this._esOrdersState.response.next)
        .then((httpResponse) {
      if (httpResponse.statusCode == 200) {
        this._esOrdersState.response =
            EsGetOrdersResponse.fromJson(json.decode(httpResponse.body));
        this._esOrdersState.items.addAll(this._esOrdersState.response.results);
        this._esOrdersState.isLoadingMoreFailed = false;
        this._esOrdersState.isLoadingMore = false;
      } else {
        this._esOrdersState.isLoadingMoreFailed = true;
        this._esOrdersState.isLoadingMore = false;
      }
      this._updateState();
    }).catchError((err) {
      this._esOrdersState.isLoadingMoreFailed = true;
      this._esOrdersState.isLoadingMore = false;
      this._updateState();
    });
  }

  getOrderItems(String orderId) {
    print("getOrderItems");
    if (this._esOrdersState.orderItemsKV.containsKey(orderId)) {
      return;
    }
    //for (var order in this._esOrdersState.items) {
    //  if (order.orderId == orderId) {
    //    if (order.items != null) {
    //      return;
    //    }
    //  }
    //}

    this._esOrdersState.isSubmitting = true;
    this._esOrdersState.isSubmitFailed = false;
    this._esOrdersState.isSubmitSuccess = false;
    this._updateState();
    this
        .httpService
        .esGet(EsApiPaths.getOrderDetail(orderId))
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
        print("getOrderItems.response");
        this._esOrdersState.isSubmitting = false;
        this._esOrdersState.isSubmitFailed = false;
        this._esOrdersState.isSubmitSuccess = true;
        this._esOrdersState.orderItemsKV.putIfAbsent(
            orderId, () => EsOrder.getItems(json.decode(httpResponse.body)));
        //print(
        //    "..............................Adding items ..............................");
        //print(json.decode(httpResponse.body)['order_items']);

        //var orderItem;
        //for (var json_item in json.decode(httpResponse.body)['order_items']) {
        //  orderItem = EsOrderItem.fromJson(json_item);
        //  //print(orderItem);
        //}

        for (var order in this._esOrdersState.items) {
          if (order.orderId == orderId) {
            order.orderItems = this._esOrdersState.orderItemsKV[orderId];
            //print("founde.....");
            break;
          }
        }
        //print(EsOrder.getItems(json.decode(httpResponse.body)));
        //print("................Added items..............................");
      } else {
        //print("Errorr...");
        this._esOrdersState.isSubmitting = false;
        this._esOrdersState.isSubmitFailed = true;
        this._esOrdersState.isSubmitSuccess = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._esOrdersState.isSubmitting = false;
      this._esOrdersState.isSubmitFailed = true;
      this._esOrdersState.isSubmitSuccess = false;
      this._updateState();
    });
  }

  acceptOrder(String orderId, Function onSuccess, Function onFail) {
    this._esOrdersState.isSubmitting = true;
    this._esOrdersState.isSubmitFailed = false;
    this._esOrdersState.isSubmitSuccess = false;
    this._updateState();
    this
        .httpService
        .esPost(EsApiPaths.postAcceptOrder(orderId), '')
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
        this._esOrdersState.isSubmitting = false;
        this._esOrdersState.isSubmitFailed = false;
        this._esOrdersState.isSubmitSuccess = true;
        var createdBusinessInfo =
            EsOrder.fromJson(json.decode(httpResponse.body));
        if (onSuccess != null) {
          onSuccess(createdBusinessInfo);
        }
      } else {
        onFail();
        this._esOrdersState.isSubmitting = false;
        this._esOrdersState.isSubmitFailed = true;
        this._esOrdersState.isSubmitSuccess = false;
      }
      this._updateState();
    }).catchError((onError) {
      onFail();
      this._esOrdersState.isSubmitting = false;
      this._esOrdersState.isSubmitFailed = true;
      this._esOrdersState.isSubmitSuccess = false;
      this._updateState();
    });
  }

  cancelOrder(String orderId, String cancellationReason, Function onSuccess,
      Function onFail) {
    this._esOrdersState.isSubmitting = true;
    this._esOrdersState.isSubmitFailed = false;
    this._esOrdersState.isSubmitSuccess = false;
    this._updateState();
    var payload = new EsCancelOrderPayload(
      cancellationNote: cancellationReason,
    );
    var payloadString = json.encode(payload.toJson());
    this
        .httpService
        .esPost(EsApiPaths.postCancelOrder(orderId), payloadString)
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
        this._esOrdersState.isSubmitting = false;
        this._esOrdersState.isSubmitFailed = false;
        this._esOrdersState.isSubmitSuccess = true;
        var createdBusinessInfo =
            EsOrder.fromJson(json.decode(httpResponse.body));
        if (onSuccess != null) {
          onSuccess(createdBusinessInfo);
        }
      } else {
        onFail();
        this._esOrdersState.isSubmitting = false;
        this._esOrdersState.isSubmitFailed = true;
        this._esOrdersState.isSubmitSuccess = false;
      }
      this._updateState();
    }).catchError((onError) {
      onFail();
      this._esOrdersState.isSubmitting = false;
      this._esOrdersState.isSubmitFailed = true;
      this._esOrdersState.isSubmitSuccess = false;
      this._updateState();
    });
  }

  assignOrder(String orderId, Function onSuccess, Function onFail) {
    this._esOrdersState.isSubmitting = true;
    this._esOrdersState.isSubmitFailed = false;
    this._esOrdersState.isSubmitSuccess = false;
    this._updateState();
    var payload = new EsRequestDeliveryPayload(
        deliveryagentIds: this._esOrdersState.selectedDeliveryAgentIds);
    var payloadString = json.encode(payload.toJson());
    this
        .httpService
        .esPost(
            EsApiPaths.postOrderRequestDeliveryAgent(orderId), payloadString)
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
        this._esOrdersState.isSubmitting = false;
        this._esOrdersState.isSubmitFailed = false;
        this._esOrdersState.isSubmitSuccess = true;
        var createdBusinessInfo =
            EsOrder.fromJson(json.decode(httpResponse.body));
        if (onSuccess != null) {
          onSuccess(createdBusinessInfo);
        }
      } else {
        onFail();
        this._esOrdersState.isSubmitting = false;
        this._esOrdersState.isSubmitFailed = true;
        this._esOrdersState.isSubmitSuccess = false;
      }
      this._updateState();
    }).catchError((onError) {
      onFail();
      this._esOrdersState.isSubmitting = false;
      this._esOrdersState.isSubmitFailed = true;
      this._esOrdersState.isSubmitSuccess = false;
      this._updateState();
    });
  }

  markReady(String orderId, Function onSuccess, Function onFail) {
    this._esOrdersState.isSubmitting = true;
    this._esOrdersState.isSubmitFailed = false;
    this._esOrdersState.isSubmitSuccess = false;
    this._updateState();
    this
        .httpService
        .esPost(EsApiPaths.postReadyOrder(orderId), '')
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
        this._esOrdersState.isSubmitting = false;
        this._esOrdersState.isSubmitFailed = false;
        this._esOrdersState.isSubmitSuccess = true;
        var createdBusinessInfo =
            EsOrder.fromJson(json.decode(httpResponse.body));
        if (onSuccess != null) {
          onSuccess(createdBusinessInfo);
        }
      } else {
        onFail();
        this._esOrdersState.isSubmitting = false;
        this._esOrdersState.isSubmitFailed = true;
        this._esOrdersState.isSubmitSuccess = false;
      }
      this._updateState();
    }).catchError((onError) {
      onFail();
      this._esOrdersState.isSubmitting = false;
      this._esOrdersState.isSubmitFailed = true;
      this._esOrdersState.isSubmitSuccess = false;
      this._updateState();
    });
  }

  getDeliveryAgents() {
    if (this._esOrdersState.agents != null) {
      return;
    }
    this._esOrdersState.isLoadingAgents = true;
    this._esOrdersState.agents = [];
    this._updateState();
    httpService
        .esGet(
      EsApiPaths.getDeliveryAgents(
        this.esBusinessesBloc.getSelectedBusinessId(),
      ),
    )
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 ||
          httpResponse.statusCode == 201 ||
          httpResponse.statusCode == 202) {
        this._esOrdersState.isLoadingAgentsFailed = false;
        this._esOrdersState.isLoadingAgents = false;
        this._esOrdersState.agents = new List<EsDeliveryAgent>();
        json.decode(httpResponse.body).forEach((v) {
          this._esOrdersState.agents.add(new EsDeliveryAgent.fromJson(v));
        });

        print("aggentss...........start");
        for (var agnt in this._esOrdersState.agents) {
          print(agnt.deliveryagentId);
        }
        print("aggentss...........done");
      } else {
        this._esOrdersState.isLoadingAgentsFailed = true;
        this._esOrdersState.isLoadingAgents = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._esOrdersState.isLoadingAgentsFailed = true;
      this._esOrdersState.isLoadingAgents = false;
      this._updateState();
    });
  }

  selectDeliveryAgent(EsDeliveryAgent agent, bool isSelected) {
    this._esOrdersState.agents = this._esOrdersState.agents.map((ag) {
      if (ag.deliveryagentId == agent.deliveryagentId) {
        ag.selectAgent(isSelected);
      }
      return ag;
    }).toList();
    this._updateState();
  }

  _updateState() {
    if (!this._subjectEsOrdersState.isClosed) {
      this._subjectEsOrdersState.sink.add(this._esOrdersState);
    }
  }

  dispose() {
    this._subjectEsOrdersState.close();
    this._subscription.cancel();
  }
}

class EsOrdersState {
  bool isLoading = false;
  bool isLoadingAgents = false;
  EsGetOrdersResponse response;
  List<EsOrder> items = new List<EsOrder>();
  bool isLoadingFailed = false;
  bool isLoadingAgentsFailed = false;
  bool isLoadingMore;
  bool isLoadingMoreFailed;
  bool isSubmitting;
  bool isSubmitSuccess;
  bool isSubmitFailed;
  List<EsDeliveryAgent> agents;
  Map<String, List<EsOrderItem>> orderItemsKV =
      new Map<String, List<EsOrderItem>>();

  List<String> cancellationReasons = [
    'Kitchen full',
    'Item out of stock',
    'No delivery person',
    'Closing time',
    'Other'
  ];

  List<String> get selectedDeliveryAgentIds =>
      agents.map((e) => e.deliveryagentId).toList();

  EsOrdersState() {
    this.isLoading = false;
    this.isLoadingFailed = false;
    this.isLoadingMore = false;
    this.isLoadingMoreFailed = false;
    this.isSubmitting = false;
    this.isSubmitFailed = false;
    this.isSubmitSuccess = false;
  }
}
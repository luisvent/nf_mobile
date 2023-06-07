import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nf_mobile/database/payment_storage.dart';
import 'package:nf_mobile/interface/Activity.dart';
import 'package:nf_mobile/screens/activity_details_screen.dart';
import 'package:nf_mobile/screens/ticket_screen.dart';
import 'package:nf_mobile/utilities/slide_up_route.dart';

class WidgetFactory {
  static Widget _loadingTile() {
    Widget bar = Container(
      child: FadeShimmer(
        height: 18,
        width: 180,
        highlightColor: Colors.grey[200],
        baseColor: Colors.blueGrey[200],
      ),
      padding: EdgeInsets.all(5),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: FadeShimmer.round(
            size: 64,
            highlightColor: Colors.grey[200],
            baseColor: Colors.blueGrey[200],
          ),
          padding: EdgeInsets.all(5),
        ),
        Column(
          children: [bar, bar],
        ),
        Column(
          children: [
            Container(
              child: FadeShimmer(
                height: 18,
                width: 30,
                highlightColor: Colors.grey[200],
                baseColor: Colors.blueGrey[200],
              ),
              padding: EdgeInsets.all(5),
            ),
            Container(
              height: 23,
              padding: EdgeInsets.all(5),
            )
          ],
        )
      ],
    );
  }

  static Widget LoadingList(int items) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        itemBuilder: (_, index) => Padding(padding: EdgeInsets.all(5), child: _loadingTile()),
        itemCount: items,
      ),
    );
  }

  static Widget BuildActivitiesList(BuildContext context, List<Activity> activities, [bool compact = false]) {
    // date format varies
    // activities.sort((a, b) {
    //   return DateFormat('dd/MM/yyyy h:mm a')
    //       .parse(b.date)
    //       .compareTo(DateFormat('dd/MM/yyyy h:mm a').parse(a.date));
    // });

    openActivity(Activity activity) async {
      print(activity.type);
      if (activity.type == Activity.Payment) {
        PaymentStorage paymentStorage = PaymentStorage();
        final payment = await paymentStorage.GetPayment(activity.id);
        final result = await Navigator.push(context, SlideUpRoute(page: TicketScreen(payments: [payment])));
      } else {
        final result = await Navigator.push(context, SlideUpRoute(page: ActivityDetailsScreen(activity: activity)));
      }
    }

    if (activities.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            color: Colors.blueGrey[200],
            Icons.access_time,
            size: 24,
          ),
          Text(
            'Sin Actividad',
            style: TextStyle(color: Colors.blueGrey[200], fontSize: 16),
          )
        ],
      );
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: AnimationLimiter(
          child: ListView.separated(
            padding: EdgeInsets.all(0),
            separatorBuilder: (_, b) => Divider(
              height: compact ? 8 : 14,
              color: Colors.transparent,
            ),
            itemCount: activities.length,
            itemBuilder: (BuildContext context, int index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Container(
                      padding: EdgeInsets.all(compact ? 0 : 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(color: Color(0xff1546a0).withOpacity(0.1), blurRadius: 48, offset: Offset(2, 8), spreadRadius: -16),
                        ],
                        color: Colors.white,
                      ),
                      child: ListTile(
                        dense: compact ? true : false,
                        onTap: () {
                          openActivity(activities[index]);
                        },
                        contentPadding: compact ? EdgeInsets.all(0) : EdgeInsets.only(left: 4, top: 0, bottom: 0, right: 6.18),
                        leading: CircleAvatar(
                            radius: compact ? 18 : 28,
                            backgroundColor: Color(0xffF5F7FA),
                            child: Icon(
                              color: Colors.blue,
                              activities[index].icon,
                              size: 24,
                            )),
                        title: Text(
                          activities[index].title,
                          style: TextStyle(fontSize: 12, color: Color(0xff243656)),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.symmetric(vertical: compact ? 0 : 5),
                          child: Text(
                            activities[index].message,
                            style: TextStyle(fontSize: compact ? 10 : 12, color: Color(0xff929BAB)),
                          ),
                        ),
                        trailing: Text(
                          activities[index].trail,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff37d39b),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  static LatLngBounds getLatLngBounds(List<LatLng> list) {
    double? x0;
    late num x1;
    late num y0;
    late num y1;

    for (final latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1 as double, y1 as double), southwest: LatLng(x0 as double, y0 as double));
  }

  static LatLngBounds computeBounds(List<LatLng> list) {
    assert(list.isNotEmpty);
    var firstLatLng = list.first;
    var s = firstLatLng.latitude, n = firstLatLng.latitude, w = firstLatLng.longitude, e = firstLatLng.longitude;
    for (var i = 1; i < list.length; i++) {
      var latlng = list[i];
      s = min(s, latlng.latitude);
      n = max(n, latlng.latitude);
      w = min(w, latlng.longitude);
      e = max(e, latlng.longitude);
    }
    return LatLngBounds(southwest: LatLng(s, w), northeast: LatLng(n, e));
  }

  static Future<Widget> GMaps(List<dynamic> markers, [bool createPolyline = true, bool infoWindow = true]) async {
    String markerPath = 'marker_map.png';
    Set<Marker> mapMarkers = {};
    Set<Polyline> polylines = {};

    final iconTypes = {
      'payment': 'marker_payment.png',
      'loan_note': 'marker_loan_note.png',
      'loan_interaction': 'marker_loan_interaction.png',
      'activity': 'marker_map.png',
    };

    for (var i = 0; i < markers.length; i++) {
      final marker = markers[i];
      markerPath = iconTypes[marker['type']] as String;

      BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(), 'assets/images/${markerPath}');

      print(markerIcon);
      final newMarker = Marker(
        markerId: MarkerId('marker_$i'),
        position: LatLng(marker['latitude'] as double, marker['longitude'] as double),
        draggable: false,
        infoWindow: InfoWindow(
          title: marker['title'] == null ? '' : marker['title'],
          snippet: marker['description'] == null ? '' : marker['description'],
        ),
        icon: markerIcon,
      );

      if (createPolyline) {
        final newPolyline = Polyline(
            polylineId: PolylineId(i.toString()),
            points: markers.map((m) => LatLng(m['latitude'], m['longitude'])).toList(),
            color: Colors.blue,
            width: 4);
        polylines.add(newPolyline);
      }

      mapMarkers.add(newMarker);
    }

    final mapStyle = [
      {
        "featureType": "all",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#7c93a3"},
          {"lightness": "-10"}
        ]
      },
      {
        "featureType": "administrative.country",
        "elementType": "geometry",
        "stylers": [
          {"visibility": "on"}
        ]
      },
      {
        "featureType": "administrative.country",
        "elementType": "geometry.stroke",
        "stylers": [
          {"color": "#a0a4a5"}
        ]
      },
      {
        "featureType": "administrative.province",
        "elementType": "geometry.stroke",
        "stylers": [
          {"color": "#62838e"}
        ]
      },
      {
        "featureType": "landscape",
        "elementType": "geometry.fill",
        "stylers": [
          {"color": "#dde3e3"}
        ]
      },
      {
        "featureType": "landscape.man_made",
        "elementType": "geometry.stroke",
        "stylers": [
          {"color": "#3f4a51"},
          {"weight": "0.30"}
        ]
      },
      {
        "featureType": "poi",
        "elementType": "all",
        "stylers": [
          {"visibility": "simplified"}
        ]
      },
      {
        "featureType": "poi.attraction",
        "elementType": "all",
        "stylers": [
          {"visibility": "on"}
        ]
      },
      {
        "featureType": "poi.business",
        "elementType": "all",
        "stylers": [
          {"visibility": "off"}
        ]
      },
      {
        "featureType": "poi.government",
        "elementType": "all",
        "stylers": [
          {"visibility": "off"}
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "all",
        "stylers": [
          {"visibility": "on"}
        ]
      },
      {
        "featureType": "poi.place_of_worship",
        "elementType": "all",
        "stylers": [
          {"visibility": "off"}
        ]
      },
      {
        "featureType": "poi.school",
        "elementType": "all",
        "stylers": [
          {"visibility": "off"}
        ]
      },
      {
        "featureType": "poi.sports_complex",
        "elementType": "all",
        "stylers": [
          {"visibility": "off"}
        ]
      },
      {
        "featureType": "road",
        "elementType": "all",
        "stylers": [
          {"saturation": "-100"},
          {"visibility": "on"}
        ]
      },
      {
        "featureType": "road",
        "elementType": "geometry.stroke",
        "stylers": [
          {"visibility": "on"}
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry.fill",
        "stylers": [
          {"color": "#bbcacf"}
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry.stroke",
        "stylers": [
          {"lightness": "0"},
          {"color": "#bbcacf"},
          {"weight": "0.50"}
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "labels",
        "stylers": [
          {"visibility": "on"}
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "labels.text",
        "stylers": [
          {"visibility": "on"}
        ]
      },
      {
        "featureType": "road.highway.controlled_access",
        "elementType": "geometry.fill",
        "stylers": [
          {"color": "#ffffff"}
        ]
      },
      {
        "featureType": "road.highway.controlled_access",
        "elementType": "geometry.stroke",
        "stylers": [
          {"color": "#a9b4b8"}
        ]
      },
      {
        "featureType": "road.arterial",
        "elementType": "labels.icon",
        "stylers": [
          {"invert_lightness": true},
          {"saturation": "-7"},
          {"lightness": "3"},
          {"gamma": "1.80"},
          {"weight": "0.01"}
        ]
      },
      {
        "featureType": "transit",
        "elementType": "all",
        "stylers": [
          {"visibility": "off"}
        ]
      },
      {
        "featureType": "water",
        "elementType": "geometry.fill",
        "stylers": [
          {"color": "#a3c7df"}
        ]
      }
    ];

    final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
    CameraPosition initialPositionCamera = CameraPosition(
      target: LatLng(19.391900, -70.524397),
      zoom: 14,
    );

    final bounds = computeBounds(markers.map((m) => LatLng(m['latitude'], m['longitude'])).toList());
    final cameraBounds = new CameraTargetBounds(bounds);

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
          bottomRight: Radius.circular(15),
          bottomLeft: Radius.circular(15),
        ),
        child: Align(
            alignment: Alignment.bottomRight,
            child: GoogleMap(
              markers: mapMarkers,
              polylines: polylines,
              mapType: MapType.normal,
              cameraTargetBounds: cameraBounds,
              initialCameraPosition: initialPositionCamera,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                controller.setMapStyle(jsonEncode(mapStyle));
              },
            )),
      ),
    );
  }

  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
    GoogleMapController mapController,
  ) async {
    if (mapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude && source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: LatLng(source.latitude, destination.longitude), northeast: LatLng(destination.latitude, source.longitude));
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(southwest: LatLng(destination.latitude, source.longitude), northeast: LatLng(source.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 70);

    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }
}

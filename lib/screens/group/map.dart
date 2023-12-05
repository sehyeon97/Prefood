import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:prefoods/data/screen_size.dart';
import 'package:prefoods/models/group.dart';
import 'package:prefoods/providers/current_group_id_provider.dart';
import 'package:prefoods/providers/delivery_address_provider.dart';
import 'package:prefoods/providers/selected_event_day.dart';
import 'package:prefoods/styles/text.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({
    super.key,
    required this.address,
    required this.nearbyPlaces,
    required this.list,
    required this.selectedDay,
    required this.group,
  });

  final dynamic address;
  final List nearbyPlaces;
  final dynamic list;
  final DateTime selectedDay;
  final Group group;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MapScreenState();
  }
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> markers = <Marker>{};
  Map details = {
    'name': '',
    'rating': '',
    'price': '',
    'distance': '',
    'url': '',
  };

  // void _setMarkers(List nearbyPlaces) {
  //   Set<Marker> temp = <Marker>{};
  //   for (final place in nearbyPlaces) {
  //     final Marker marker = Marker(
  //       markerId: MarkerId(place['place_id']),
  //       infoWindow: InfoWindow(title: place['name']),
  //       icon: BitmapDescriptor.defaultMarker,
  //       position: LatLng(place['geometry']['location']['lat'],
  //           place['geometry']['location']['lng']),
  //     );
  //     temp.add(marker);
  //   }
  //   setState(() {
  //     markers = temp;
  //   });
  //   print('HELLO $nearbyPlaces');
  // }

  void _setMarkers(List list) {
    Set<Marker> temp = <Marker>{};
    for (final place in list) {
      final Marker marker = Marker(
        markerId: MarkerId(place['id']),
        infoWindow: InfoWindow(title: place['name']),
        icon: BitmapDescriptor.defaultMarker,
        position: LatLng(place['coordinates']['latitude'],
            place['coordinates']['longitude']),
        onTap: () {
          onMarkerTap(place);
        },
      );
      temp.add(marker);
    }
    setState(() {
      markers = temp;
    });
    // print('HELLO $list');
  }

  void onMarkerTap(place) {
    setState(() {
      details = {
        'name': place['name'],
        'rating': place['rating'],
        'price': place['price'],
        'distance': place['distance'],
        'url': place['url'],
      };
    });
  }

  // this should depend on user ID since a user can only vote once
  // when they vote something else, it should remove the previous vote
  void onCastVote() async {
    final String groupID = ref.watch(groupIDProvider);
    final String address = ref.watch(addressProvider);

    final DateTime current = widget.selectedDay;
    final DateTime other = ref.watch(selectedDayProvider);

    final groupDocument = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupID)
        .get();
    final groupData = groupDocument.data()!;
    final List events = groupData['events'];

    dynamic currentEvent;

    for (final event in events) {
      if (current.month == other.month &&
          current.day == other.day &&
          current.year == other.year) {
        currentEvent = event;
        events.remove(event);
        break;
      }
    }

    Map restaurantVotes = currentEvent['restaurantVotes'];
    if (restaurantVotes.containsKey(details['name'])) {
      final updatedVote = restaurantVotes[details['name']] + 1;
      restaurantVotes = {...restaurantVotes, details['name']: updatedVote};
    } else {
      restaurantVotes = {...restaurantVotes, details['name']: 1};
    }

    events.add({
      'deliveryAddress': address,
      'selectedDay': current.day,
      'selectedMonth': current.month,
      'selectedYear': current.year,
      'restaurantVotes': restaurantVotes,
    });

    for (final event in events) {
      if (event['day'] == current.day &&
          event['month'] == current.month &&
          event['year'] == current.year) {
        events.remove(event);
        break;
      }
    }

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupID)
        .set({'events': events}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final Marker marker = Marker(
      markerId: const MarkerId('value'),
      infoWindow: const InfoWindow(title: 'Place'),
      icon: BitmapDescriptor.defaultMarker,
      position: widget.address,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: Device.screenSize.width,
              height: Device.screenSize.height * 0.6,
              child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: widget.address,
                    zoom: 12,
                  ),
                  onMapCreated: (controller) {
                    _mapController.complete(controller);
                    setState(() {
                      _setMarkers(widget.list);
                    });
                  },
                  markers: {...markers, marker}),
            ),
            const SizedBox(height: 8),
            const Text(
              'Place Details',
              style: textStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Table(
              border: TableBorder.all(),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FixedColumnWidth(120),
                1: FixedColumnWidth(180)
              },
              children: [
                TableRow(
                  children: [
                    const Center(
                      child: Text(
                        'Name',
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: Center(
                          child: Text(
                        details['name'],
                        style: const TextStyle(
                          fontSize: 18.0,
                        ),
                      )),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const Center(
                      child: Text(
                        'Rating',
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: Center(
                          child: Text(
                        details['rating'],
                        style: const TextStyle(
                          fontSize: 18.0,
                        ),
                      )),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const Center(
                      child: Text(
                        'Price',
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: Center(
                          child: Text(
                        details['price'],
                        style: const TextStyle(
                          fontSize: 18.0,
                        ),
                      )),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const Center(
                      child: Text(
                        'Distance',
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: Center(
                          child: Text(
                        details['distance'],
                        style: const TextStyle(
                          fontSize: 18.0,
                        ),
                      )),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => launchUrl(Uri.parse(details['url'])),
              child: Text(
                details['name'],
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                onCastVote();
              },
              child: const Text('Cast Vote'),
            )
          ],
        ),
      ),
    );
  }
}

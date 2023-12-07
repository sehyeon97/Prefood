import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:prefoods/api/api_keys.dart';
import 'package:prefoods/data/screen_size.dart';
import 'package:prefoods/models/group.dart';
import 'package:prefoods/providers/delivery_address_provider.dart';
import 'package:prefoods/providers/selected_event_day.dart';
import 'package:prefoods/screens/group/group_screen.dart';
import 'package:prefoods/screens/group/map.dart';
import 'package:prefoods/screens/tabs.dart';
import 'package:prefoods/styles/text.dart';
import 'package:prefoods/widgets/event_details/chart.dart';
import 'package:http/http.dart' as http;
import 'package:prefoods/widgets/event_details/settings.dart';

class EventDetailsScreen extends ConsumerWidget {
  const EventDetailsScreen({
    super.key,
    required this.group,
  });

  final Group group;

  static String getModifiedAddress(String address) {
    return address.replaceAll(' ', '%20');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime selectedDay = ref.watch(selectedDayProvider);
    ref
        .read(addressProvider.notifier)
        .checkFirestoreModifyAddress(ref, selectedDay);
    String address = ref.watch(addressProvider);

    void nextPage(latitude, longitude, result, list) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (contxt) => MapScreen(
            address: LatLng(latitude, longitude),
            nearbyPlaces: result['results'],
            list: list,
            group: group,
          ),
        ),
      );
    }

    void displayNoAddressMessage() {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Delivery Address not set'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    void openMenu() {
      showModalBottomSheet(
        // works to auto adjust app with device feature
        useSafeArea: true,
        // modal overlay will take control of full available height
        isScrollControlled: true,
        context: context,
        builder: (cntxt) => const Settings(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (contxt) => GroupScreen(group: group)),
            );
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Text('Event Date: ${selectedDay.month}/${selectedDay.day}'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (contxt) => const TabsScreen()),
              );
            },
            icon: const Icon(Icons.home),
          ),
          IconButton(
            onPressed: () {
              openMenu();
            },
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Device.screenSize.width * 0.1,
          vertical: Device.screenSize.height * 0.1,
        ),
        child: Column(
          children: [
            const Text(
              'Most Voted Place',
              style: textStyle,
            ),
            const SizedBox(height: 40),
            const Chart(),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                if (address == '') {
                  displayNoAddressMessage();
                } else {
                  String modifiedAddress = getModifiedAddress(address);
                  final url = Uri.parse(
                      'https://maps.googleapis.com/maps/api/geocode/json?address=$modifiedAddress&key=${APIKeys.googleMaps}');
                  final response = await http.get(url);
                  final data = jsonDecode(response.body);
                  final cord = data['results'][0]['geometry']['location'];

                  final latitude = cord['lat'];
                  final longitude = cord['lng'];
                  const radius = '5000';
                  const keyword = 'food';

                  final uri = Uri.parse(
                      'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=$radius&keyword=$keyword&key=${APIKeys.googleMaps}');
                  final res = await http.get(uri);
                  final result = jsonDecode(res.body);

                  const String category1 = 'restaurants';
                  const String category2 = 'food';

                  const String price1 = '1';
                  const String price2 = '2';

                  const String locale = 'en_US';
                  const String sortBy = 'best_match';
                  const String limit = '50';
                  final headers = {
                    'Authorization': APIKeys.yelp,
                  };
                  final Uri yelpUrl = Uri.parse(
                      'https://api.yelp.com/v3/businesses/search?latitude=$latitude&longitude=$longitude&term=fast%20food&radius=$radius&categories=$category1&categories=$category2&locale=$locale&price=$price1&price=$price2&sort_by=$sortBy&limit=$limit');
                  final yelpResponse =
                      await http.get(yelpUrl, headers: headers);
                  final yelpResult = jsonDecode(yelpResponse.body);

                  final list = [];
                  final businesses = yelpResult['businesses'];
                  for (final business in businesses) {
                    final double metersToMiles =
                        (business['distance'] as double) / 1609.344;
                    list.add({
                      // distance is in meters
                      'id': business['id'],
                      'name': business['name'],
                      'rating': '${business['rating']} / 5.0',
                      'price': business['price'],
                      'coordinates': business['coordinates'],
                      'distance': '${metersToMiles.toStringAsFixed(2)} mi',
                      'url': business['url']
                    });
                  }

                  nextPage(latitude, longitude, result, list);
                }
              },
              child: const Text('View Map'),
            ),
          ],
        ),
      ),
    );
  }
}

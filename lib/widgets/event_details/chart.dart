import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prefoods/data/screen_size.dart';
import 'package:prefoods/providers/current_group_id_provider.dart';
import 'package:prefoods/providers/selected_event_day.dart';
import 'package:prefoods/styles/theme_colors.dart';

class Chart extends ConsumerStatefulWidget {
  const Chart({super.key});

  @override
  ConsumerState<Chart> createState() {
    return _ChartState();
  }
}

class _ChartState extends ConsumerState<Chart> {
  List<BarChartGroupData> barChartGroupData = [];
  SideTitles bottomTitles = SideTitles(showTitles: false);
  bool customInitState = false;
  int maxY = 0;

  void getBarData() async {
    List<BarChartGroupData> list = [];
    SideTitles xAxis = SideTitles(showTitles: false);

    final String groupID = ref.watch(groupIDProvider);
    final groupDocument = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupID)
        .get();
    final groupData = groupDocument.data()!;
    final events = groupData['events'];

    final DateTime selectedDay = ref.watch(selectedDayProvider);
    Map? restaurantVotes;
    for (final anEvent in events) {
      if (anEvent['selectedDay'] == selectedDay.day &&
          anEvent['selectedMonth'] == selectedDay.month &&
          anEvent['selectedYear'] == selectedDay.year) {
        restaurantVotes = anEvent['restaurantVotes'];
        break;
      }
    }

    if (restaurantVotes == null || restaurantVotes.isEmpty) {
      return;
    }

    int x = 1;
    int maxVotes = 0;
    for (String restaurant in restaurantVotes.keys) {
      final String name = restaurant;
      final int votes = restaurantVotes[name];
      print('restaurant name: $name');
      print('restaurant votes: $votes');

      BarChartGroupData data =
          BarChartGroupData(x: x, barRods: [BarChartRodData(toY: votes + 0.0)]);
      x++;

      list.add(data);
      maxVotes = max(maxVotes, votes);
    }

    setState(() {
      barChartGroupData = list;
      maxY = maxVotes;
      bottomTitles = xAxis;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double chartWidth = Device.screenSize.width * 0.9;
    if (!customInitState) {
      getBarData();
      setState(() {
        customInitState = true;
      });
    }

    return Container(
      width: chartWidth,
      height: Device.screenSize.height * 0.5,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          style: BorderStyle.solid,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            Center(
              child: Text(
                'Votes',
                style: TextStyle(
                  color: availableColors['blue'],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            AspectRatio(
              aspectRatio: 0.79,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                      ),
                    ),
                    rightTitles: AxisTitles(),
                    topTitles: AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: bottomTitles,
                    ),
                  ),
                  barTouchData: BarTouchData(enabled: true),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  barGroups: barChartGroupData,
                  maxY: maxY + 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:percent_indicator/circular_percent_indicator.dart';

/// A custom sensor card specifically for gas detection.
/// Displays gas level, percentage, and the last updated time.
class SensorCardGas extends StatelessWidget {
  final IconData icon; // Icon representing the sensor
  final String title; // Sensor title
  final Future<Map<String, dynamic>?> future; // Future fetching sensor data
  final String valueKey; // Key used to access sensor value
  final String timeKey; // Key used to access timestamp

  const SensorCardGas({
    super.key,
    required this.icon,
    required this.title,
    required this.future,
    required this.valueKey,
    required this.timeKey,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: FutureBuilder<Map<String, dynamic>?>(
        future: future,
        builder: (context, snapshot) {
          // Show loading spinner while waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Card(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          // Show error message if something went wrong
          if (snapshot.hasError) {
            return Card(child: Center(child: Text("Error: ${snapshot.error}")));
          }

          // Handle case when no data is returned
          if (!snapshot.hasData || snapshot.data == null) {
            return const Card(child: Center(child: Text("No data")));
          }

          // Get the fetched data
          final data = snapshot.data!;
          final dateTime = DateTime.tryParse(data[timeKey].toString());

          // Format timestamp into a "time ago" string
          final timeAgo = dateTime != null
              ? timeago.format(dateTime)
              : "Unknown time";

          // Clamp value between 0 and 100 to avoid UI issues
          final value = (data[valueKey] as num).clamp(0, 100);

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Sensor icon
                  Icon(icon, size: 40, color: Colors.black),
                  const SizedBox(height: 10),

                  // Sensor title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Circular percentage indicator for gas level
                  CircularPercentIndicator(
                    radius: 60,
                    lineWidth: 8,
                    percent: value / 100,
                    // Convert value to a fraction
                    center: Text(
                      "${value.toInt()}%",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Change color based on gas percentage
                    progressColor: value > 75
                        ? Colors.green
                        : value > 50
                        ? Colors.yellow
                        : Colors.red,
                  ),
                  const SizedBox(height: 8),

                  // Display the "last updated" time
                  Text(
                    timeAgo,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

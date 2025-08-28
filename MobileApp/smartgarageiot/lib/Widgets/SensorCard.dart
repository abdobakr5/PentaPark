import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

/// A reusable widget to display sensor data inside a styled card.
/// It shows the latest value, status, and how long ago the data was updated.
class SensorCard extends StatelessWidget {
  final IconData icon; // Icon representing the sensor
  final String title; // Sensor title
  final Future<Map<String, dynamic>?> future; // Future that fetches sensor data
  final String valueKey; // Key used to get sensor value
  final String timeKey; // Key used to get timestamp

  const SensorCard({
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
          // Show loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Card(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          // Show error message if something went wrong
          if (snapshot.hasError) {
            return Card(child: Center(child: Text("Error: ${snapshot.error}")));
          }

          // Handle case when no data is available
          if (!snapshot.hasData || snapshot.data == null) {
            return const Card(child: Center(child: Text("No data")));
          }

          // Extract sensor data
          final data = snapshot.data!;
          final dateTime = DateTime.tryParse(data[timeKey].toString());

          // Convert timestamp into a "time ago" format
          final timeAgo = dateTime != null
              ? timeago.format(dateTime)
              : "Unknown time";

          // Dynamic card color based on sensor value
          final cardColor = data[valueKey] == "No Detection"
              ? Colors.green
              : data[valueKey] == "Car Detected"
              ? Colors.red
              : const Color(0xFFFFFFFF); // Default Off-White

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            color: cardColor,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Sensor icon
                  Icon(
                    icon,
                    size: 40,
                    color: data[valueKey] == "No Detection"
                        ? Colors.white
                        : data[valueKey] == "Car Detected"
                        ? Colors.white
                        : Colors.black,
                  ),
                  const SizedBox(height: 10),

                  // Sensor title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Sensor value text
                  Text(
                    "${data[valueKey]}",
                    style: TextStyle(
                      fontSize: 22,
                      color: data[valueKey] == "No Detection"
                          ? Colors.white
                          : data[valueKey] == "Car Detected"
                          ? Colors.white
                          : const Color(0xFF000000),
                    ),
                  ),
                  const SizedBox(height: 5),

                  // "Last updated" time text
                  Text(
                    timeAgo,
                    style: TextStyle(
                      fontSize: 12,
                      color: data[valueKey] == "No Detection"
                          ? Colors.white
                          : data[valueKey] == "Car Detected"
                          ? Colors.white
                          : const Color(0xFF000000),
                    ),
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

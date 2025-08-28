import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

/// A sensor card used to display parking slot status.
/// Shows whether the slot is taken or free along with last updated time.
class SensorCardSlot extends StatelessWidget {
  final IconData icon; // Icon representing the slot
  final String title; // Title of the slot (e.g. Slot 1)
  final Future<Map<String, dynamic>?> future; // Future to fetch slot data
  final String valueKey; // Key for slot value ("Taken" or "Free")
  final String timeKey; // Key for timestamp

  const SensorCardSlot({
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
          // Show loading indicator while waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Card(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          // Show error message if something went wrong
          if (snapshot.hasError) {
            return Card(child: Center(child: Text("Error: ${snapshot.error}")));
          }

          // Handle case when there's no data available
          if (!snapshot.hasData || snapshot.data == null) {
            return const Card(child: Center(child: Text("No data")));
          }

          // Extract the fetched data
          final data = snapshot.data!;
          final dateTime = DateTime.tryParse(data[timeKey].toString());

          // Convert timestamp into a human-readable "time ago" format
          final timeAgo = dateTime != null
              ? timeago.format(dateTime)
              : "Unknown time";

          // Check if the slot is taken or free
          final bool isTaken = data[valueKey] == "Taken";

          // Change card color based on slot availability
          final cardColor = isTaken ? Colors.black : Colors.white;
          final textColor = isTaken ? Colors.white : Colors.black;

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
                  // Slot icon
                  Icon(icon, size: 40, color: textColor),
                  const SizedBox(height: 10),

                  // Display slot title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Show current slot status ("Taken" or "Free")
                  Text(
                    "${data[valueKey]}",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Show last updated time
                  Text(
                    timeAgo,
                    style: TextStyle(fontSize: 12, color: textColor),
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

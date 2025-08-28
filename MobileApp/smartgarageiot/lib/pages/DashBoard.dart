import 'package:flutter/material.dart';
import 'package:smartgarageiot/Widgets/SensorCardGas.dart';
import '../helpers/FetchLastSupa.dart';
import '../Widgets/SensorCard.dart';
import '../Widgets/SensorCardSlot.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sensors Dashboard"), // Dashboard title
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), // Refresh button
            onPressed: () {
              // Reload the page without animation
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, a1, a2) => const Dashboard(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: SensorCard(
                    icon: Icons.thermostat,
                    title: "Temperature",
                    // Show temperature reading
                    future: fetchLatestReading(
                      table: "heat_sensor",
                      valueColumn: "temperature",
                      timeColumn: "read_time",
                    ),
                    valueKey: "temperature",
                    timeKey: "read_time",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SensorCardGas(
                    icon: Icons.air_outlined,
                    title: "Air Quality",
                    // Show gas sensor reading
                    future: fetchLatestReading(
                      table: "gas_sensor",
                      valueColumn: "sensor_reading",
                      timeColumn: "time",
                    ),
                    valueKey: "sensor_reading",
                    timeKey: "time",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Divider for Doors Section
            Row(
              children: [
                Expanded(
                  child: Divider(
                    thickness: 2,
                    color: Colors.grey[200],
                    endIndent: 8,
                  ),
                ),
                const Text(
                  'Doors',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Expanded(
                  child: Divider(
                    thickness: 2,
                    color: Colors.grey[200],
                    indent: 8,
                  ),
                ),
              ],
            ),

            // Doors sensors row
            Row(
              children: [
                Expanded(
                  child: SensorCard(
                    icon: Icons.login_outlined,
                    title: "Entry Door",
                    // Entry door sensor
                    future: fetchLatestReading(
                      table: "doors_readings",
                      valueColumn: "entry_status",
                      timeColumn: "created_at",
                    ),
                    valueKey: "entry_status",
                    timeKey: "created_at",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SensorCard(
                    icon: Icons.logout_outlined,
                    title: "Exit Door",
                    // Exit door sensor
                    future: fetchLatestReading(
                      table: "doors_readings",
                      valueColumn: "exit_status",
                      timeColumn: "created_at",
                    ),
                    valueKey: "exit_status",
                    timeKey: "created_at",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Divider for Parking Slot Section
            Row(
              children: [
                Expanded(
                  child: Divider(
                    thickness: 2,
                    color: Colors.grey[200],
                    endIndent: 8,
                  ),
                ),
                const Text(
                  'PARKING SLOT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Expanded(
                  child: Divider(
                    thickness: 2,
                    color: Colors.grey[200],
                    indent: 8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Parking slots row
            Row(
              children: [
                Expanded(
                  child: SensorCardSlot(
                    icon: Icons.local_parking,
                    title: "Slot 1",
                    // Parking Slot 1 status
                    future: fetchLatestReading(
                      table: "doors_readings",
                      valueColumn: "slot1",
                      timeColumn: "created_at",
                    ),
                    valueKey: "slot1",
                    timeKey: "created_at",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SensorCardSlot(
                    icon: Icons.local_parking,
                    title: "Slot 2",
                    // Parking Slot 2 status
                    future: fetchLatestReading(
                      table: "doors_readings",
                      valueColumn: "slot2",
                      timeColumn: "created_at",
                    ),
                    valueKey: "slot2",
                    timeKey: "created_at",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

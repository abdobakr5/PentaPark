import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client; // Get the Supabase client instance

Future<Map<String, dynamic>?> fetchLatestReading({
  required String table, // Table name in Supabase
  required String valueColumn, // Column where the reading value is stored
  required String timeColumn, // Column where the timestamp is stored
}) async {
  final response = await supabase
      .from(table) // Select data from the given table
      .select('$valueColumn, $timeColumn') // Get value and time columns
      .order('id', ascending: false) // Order by id descending to get the latest
      .limit(1) // Limit result to the latest record only
      .maybeSingle(); // Return a single row or null if none

  return response; // Return the fetched data
}

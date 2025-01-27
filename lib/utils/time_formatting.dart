import 'package:intl/intl.dart';

String formatLocalTime(String localtime) {
  final DateTime now = DateTime.now();
  final DateTime parsedDate = DateFormat("yyyy-MM-dd HH:mm").parse(localtime);

  // Check if the parsed date is "Today" or "Tomorrow"
  String dayLabel;
  if (DateFormat('yyyy-MM-dd').format(parsedDate) ==
      DateFormat('yyyy-MM-dd').format(now)) {
    dayLabel = "Today";
  } else if (DateFormat('yyyy-MM-dd').format(parsedDate) ==
      DateFormat('yyyy-MM-dd').format(now.add(Duration(days: 1)))) {
    dayLabel = "Tomorrow";
  } else {
    dayLabel = DateFormat('EEEE').format(parsedDate); // Day of the week
  }

  // Format the time in 12-hour format
  final String time = DateFormat("hh:mm a").format(parsedDate);

  // Combine the day label and time
  return "$dayLabel: $time";
}

String convertDateFormat(String inputDate) {
  // Parse the input date string
  DateTime parsedDate = DateTime.parse(inputDate);
  // Format it to the desired output
  String formattedDate = DateFormat('d/M/yyyy').format(parsedDate);
  return formattedDate;
}

import 'dart:ui';

import 'package:flutter/material.dart';

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.isAllDay, this.background);
  DateTime? from;
  DateTime? to;
  String? eventName;
  bool isAllDay;
  Color background;
}

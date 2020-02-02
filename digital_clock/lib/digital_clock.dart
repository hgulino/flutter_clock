// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flare_flutter/flare_actor.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Color(0xFF81B3FE),
  _Element.text: Colors.white,
  _Element.shadow: Colors.black,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
  _Element.shadow: Color(0xFF174EA6),
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  var _temperature = '';
  var _condition = '';
  var _location = '';
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
      _temperature = widget.model.temperatureString;
      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final fontSize = MediaQuery.of(context).size.width / 34;
    final offset = fontSize / 4;
    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontSize: fontSize,
    );
    final weatherInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          hour + ":" + minute,
          style:
              TextStyle(fontSize: fontSize + 60, fontWeight: FontWeight.bold),
        ),
        Text(_temperature),
        Text("Weather conditions will be " + _condition + "."),
        RichText(
          text: TextSpan(
            style: defaultStyle,
            children: [
              TextSpan(
                  text: "StreamBuilder Geyser",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ", " + _location),
            ],
          ),
        )
      ],
    );

    return Container(
      color: colors[_Element.background],
      child: Center(
        child: DefaultTextStyle(
          style: defaultStyle,
          child: Stack(
            children: <Widget>[
              FlareActor(
                "assets/StreamBuilderGeyser.flr",
                // controller: _flareController,
                fit: BoxFit.contain,
                animation: "Animations",
                artboard: "full animation",
              ),
              Positioned(
                right: offset,
                bottom: offset,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: weatherInfo,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

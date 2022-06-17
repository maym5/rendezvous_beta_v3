import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/animations/bounce_animation.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'package:rendezvous_beta_v3/dialogues/date_time_dialogue.dart';
import 'package:rendezvous_beta_v3/services/google_places_service.dart';
import 'package:rendezvous_beta_v3/widgets/tile_card.dart';
import 'package:intl/intl.dart';

import '../models/users.dart';
import '../services/match_data_service.dart';

class MatchCard extends StatefulWidget {
  // TODO: figure out how to check if they have unread messages
  const MatchCard({Key? key, required this.data}) : super(key: key);
  final MatchCardData data;

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late bool _beenTapped;
  DateTime? _dateTime;

  Widget get _circleAvatar => Align(
        alignment: const Alignment(.75, 0.25),
        child: CircleAvatar(
          backgroundImage: widget.data.image == null
              ? null
              : NetworkImage(widget.data.image!),
          radius: 40,
        ),
      );

  Widget get ui {
    if (widget.data.dateTime == null) {
      // standard layout
      return Stack(
        children: <Widget>[
          NameAndButtons(
              name: widget.data.name,
              hasUnreadMessages: false,
              confirmedDate: widget.data.dateTime != null,
              dateType: widget.data.dateType),
          MatchDateType(dateTypes: widget.data.dateTypes!),
          _circleAvatar,
          MatchCardOverlay(activeDate: _beenTapped)
        ],
      );
    } else {
      // date layout
      return Stack(
        children: <Widget>[
          NameAndButtons(
              name: widget.data.name,
              hasUnreadMessages: false,
              confirmedDate: widget.data.dateTime != null,
              dateType: widget.data.dateType),
          _circleAvatar,
          DateInfo(venue: widget.data.venue!, dateTime: widget.data.dateTime!, dateType: widget.data.dateType!,),
        ],
      );
    }
  }

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _beenTapped = widget.data.dateTime != null;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setDateTime(DateTime date, TimeOfDay time) {
    setState(() {
      _dateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BounceAnimation(
      controller: _controller,
      child: GestureDetector(
        onTapDown: (details) {
          if (!_beenTapped) {
            _controller.forward();
          }
        },
        onTapUp: (details) async {
          if (!_beenTapped) {
            _controller.reverse();
            setState(() => _beenTapped = true);
            // maybe just use sets instead here, could be more efficient
            List? _commonDates = widget.data.dateTypes
                ?.where((element) => UserData.dates.contains(element))
                .toList();
            if (_commonDates != null) {
              print("have common dates");
              final _dateType =
                  _commonDates[Random().nextInt(_commonDates.length)];
              final Map _venue =
                  await GooglePlacesService(venueType: _dateType).venue;
              // deal with google places edge cases
              print(_venue["status"]);
              if (_venue["status"] == "OK") {
                print("venue status OK");
                // TODO: if they dismiss dialogue dont show calendar and clock
                await DateTimeDialogue(setDateTime: _setDateTime)
                    .buildCalendarDialogue(context,
                        venueName: _venue["name"], matchName: widget.data.name);
                final _isOpen = await GooglePlacesService.checkDateTime(
                    _dateTime!, _venue);
                if (_dateTime != null && _isOpen) {
                  print("date time is alright");
                  await MatchDataService.updateMatchData(
                      otherUserUID: widget.data.matchID,
                      dateType: _dateType,
                      dateTime: _dateTime!,
                      venue: _venue["name"]);
                  print("added data to firebase");
                } else {
                  setState(() => _beenTapped = false);
                }
              } else {
                setState(() {
                  _beenTapped = false;
                });
              }
            }
          }
        },
        child: SizedBox(
          height: 175,
          child: TileCard(
            padding: const EdgeInsets.all(0),
            child: ui,
          ),
        ),
      ),
    );
  }
}

class MatchName extends StatelessWidget {
  const MatchName({Key? key, required this.name, this.dateType, required this.confirmedDate})
      : super(key: key);
  final String name;
  final String? dateType;
  final bool confirmedDate;

  Widget get _name {
    String? displayedName = confirmedDate ? "Date with $name" : name;
    return Text(displayedName,
        style: kTextStyle, softWrap: true, textAlign: TextAlign.start);
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
        child: _name, fit: BoxFit.scaleDown, alignment: Alignment.centerLeft);
  }
}

class DateInfo extends StatelessWidget {
  DateInfo({Key? key, required this.venue, required this.dateTime, required this.dateType})
      : super(key: key);
  final String venue;
  final String dateType;
  final DateTime dateTime;
  final DateFormat formatter = DateFormat('EEEE, d MMMM, h:mm a');

  String? get displayDate =>
      formatter.format(DateTime.parse(dateTime.toString()));

  String get _dateType {
    String dateTypeString = "";
    int index = 0;
    for (String char in dateType.characters) {
      if (char == char.toUpperCase() || index == 0) {
        dateTypeString += (" " + char.toUpperCase());
      } else {
        char.toLowerCase();
        dateTypeString += char;
      } index++;
  } return dateTypeString + " date";
  }

  Widget get _dateDescription => Align(
        alignment: const Alignment(-0.85, -0.2),
        child: Padding(
          padding: const EdgeInsets.only(left: 10, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            textBaseline: TextBaseline.ideographic,
            children: <Widget>[
              Row(
                children: [
                  const Icon(Icons.where_to_vote, color: Colors.white, size: 18),
                  const SizedBox(width: 5,),
                  Text(_dateType)
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.add_business_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 5),
                  Text(venue),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.timer, color: Colors.white, size: 18),
                  const SizedBox(width: 5),
                  Text(displayDate!),
                ],
              )
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return _dateDescription;
  }
}

class DateOptionsBar extends StatelessWidget {
  const DateOptionsBar({Key? key, required this.hasUnreadMessages})
      : super(key: key);
  final bool hasUnreadMessages;

  void _onMessageTap() {
    // TODO: add messaging tap
  }

  void _onDetailsTap() {
    // TODO: add details tap
  }

  Widget get _messageButton => GestureDetector(
        onTap: _onMessageTap,
        child: Stack(
          children: [
            const Icon(Icons.message, color: Colors.white),
            Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasUnreadMessages ? Colors.red : Colors.transparent),
            )
          ],
        ),
      );

  Widget get _detailsButton => IconButton(
        onPressed: _onDetailsTap,
        icon: Icon(
          Platform.isIOS ? Icons.more_horiz : Icons.more_vert,
          color: Colors.white,
          size: 25,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[_messageButton, _detailsButton],
    );
  }
}

class MatchCardOverlay extends StatelessWidget {
  const MatchCardOverlay({Key? key, required this.activeDate})
      : super(key: key);
  final bool activeDate;

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: const Alignment(-0.85, 0.6),
        decoration: BoxDecoration(
            color: !activeDate
                ? kDarkTransparent.withOpacity(0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(25)),
        child: !activeDate
            ? Text(
                "Tap to ask out",
                style:
                    kTextStyle.copyWith(color: Colors.redAccent, fontSize: 20),
              )
            : null);
  }
}

class DateTypeIcon extends StatelessWidget {
  const DateTypeIcon({Key? key, required this.icon}) : super(key: key);
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration:
          const BoxDecoration(shape: BoxShape.circle, color: Colors.black45),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class MatchDateType extends StatelessWidget {
  MatchDateType({Key? key, required this.dateTypes}) : super(key: key);
  final List dateTypes;
  final Map<String, IconData> _icons = {
    "restaurant": Icons.restaurant,
    "cafe": Icons.local_cafe_sharp,
    "museum": Icons.museum_rounded,
    "bowlingAlley": Icons.album_rounded,
    "bar": Icons.local_bar,
    "bakery": Icons.bakery_dining,
    "nightClub": Icons.music_note_outlined,
    "artGallery": Icons.brush,
    "park": Icons.park
  };

  List<DateTypeIcon> get children {
    List<DateTypeIcon> result = [];
    int index = 0;
    for (var dateType in dateTypes) {
      if (index <= 6) {
        result.add(DateTypeIcon(icon: _icons[dateType]!));
      }
      index++;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(-0.85, -0.25),
      child: Wrap(
        runSpacing: 10.0,
        children: children,
      ),
    );
  }
}

class NameAndButtons extends StatelessWidget {
  const NameAndButtons(
      {Key? key,
      required this.name,
      required this.hasUnreadMessages,
        required this.confirmedDate,
      this.dateType})
      : super(key: key);
  final String name;
  final bool hasUnreadMessages;
  final String? dateType;
  final bool confirmedDate;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 10,
          ),
          Flexible(
              child: MatchName(name: name, dateType: dateType, confirmedDate: confirmedDate,),
              flex: 4,
              fit: FlexFit.tight),
          const SizedBox(
            width: 10,
          ),
          Flexible(
            child: DateOptionsBar(hasUnreadMessages: hasUnreadMessages),
            flex: 1,
          )
        ],
      ),
    );
  }
}

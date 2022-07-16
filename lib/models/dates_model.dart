import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/models/users.dart';
import 'package:rendezvous_beta_v3/services/discover_service.dart';
import 'package:rendezvous_beta_v3/services/google_places_service.dart';
import '../dialogues/date_time_dialogue.dart';
import '../services/match_data_service.dart';

// class DatesModel {
//   DatesModel({required this.otherDiscoverData});
//   final DiscoverData otherDiscoverData;
//   DateTime? _dateTime;
//
//   void setDateTime(DateTime date, TimeOfDay time) {
//     _dateTime =
//         DateTime(date.year, date.month, date.day, time.hour, time.minute);
//   }
//
//   Future<List<String>> get commonDates async {
//     List<String> commonDates = [];
//     for (String date in otherDiscoverData.dates) {
//       if (UserData.dates.contains(date)) {
//         commonDates.add(date);
//       }
//     }
//     return commonDates;
//   }
//
//   Future<String> get randomDateType async {
//     final List<String> _commonDates = await commonDates;
//     return _commonDates[Random().nextInt(_commonDates.length)];
//   }
//
//   Future<Map> get venueData async {
//     final String _venueType = await randomDateType;
//     return {
//       "venue": GooglePlacesService(venueType: _venueType).venue,
//       "venueType": _venueType
//     };
//   }
//
//   Future<Map> get matchData async {
//     final FirebaseFirestore _db = FirebaseFirestore.instance;
//     final DocumentSnapshot _matchSnapshot =
//         await _db.collection("userData").doc(otherDiscoverData.uid).get();
//     final Map _matchData = _matchSnapshot.data() as Map;
//     return _matchData;
//   }
//
//   Future<void> getDate(BuildContext context, {double? userRating}) async {
//     final Map _venueData = await venueData;
//     final Map _matchData = await matchData;
//     if (_venueData["venue"]["status"] == "OK") {
//       await DateTimeDialogue(setDateTime: setDateTime).buildCalendarDialogue(
//           context,
//           matchName: _matchData["name"],
//           venueName: _venueData["venue"]["name"]);
//       if (_dateTime != null &&
//           await GooglePlacesService.checkDateTime(
//               _dateTime!, _venueData["venue"])) {
//         await MatchDataService.updateMatchData(
//             otherUserUID: otherDiscoverData.uid,
//             dateType: _venueData['venueType'],
//             dateTime: _dateTime!,
//             venue: _venueData["venue"]["name"],
//             userRating: userRating);
//       }
//     } else {
//       if (!await GooglePlacesService.checkDateTime(_dateTime!, _venueData)) {
//         await DateTimeDialogue(setDateTime: setDateTime).buildCalendarDialogue(
//             context,
//             venueName: _venueData["venue"]["name"],
//             pickAnother: true,
//             matchName: _matchData["name"]);
//       } else {
//         print("there was an error");
//         // TODO: error dialogue
//       }
//     }
//   }
// }

class DatesModel {
  DatesModel({this.discoverData, this.dateData});
  final DiscoverData? discoverData;
  final DateData? dateData;
  DateTime? _dateTime;

  void setDateTime(DateTime date, TimeOfDay time) {
    _dateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<List<String>> get commonDates async {
    List<String> commonDates = [];
    if (discoverData != null) {
      for (String date in discoverData!.dates) {
        if (UserData.dates.contains(date)) {
          commonDates.add(date);
        }
      }
    } else if (dateData != null) {
      for (var date in dateData!.dateTypes!) {
        if (UserData.dates.contains(date)) {
          commonDates.add(date.toString());
        }
      }
    }
    return commonDates;
  }

  Future<String> get randomDateType async {
    final List<String> _commonDates = await commonDates;
    return _commonDates[Random().nextInt(_commonDates.length)];
  }

  Future<Map> get venueData async {
    final String _venueType = await randomDateType;
    return {
      "venue": await GooglePlacesService(venueType: _venueType).venue,
      "venueType": _venueType
    };
  }

  Future<Map> get matchData async {
    final FirebaseFirestore _db = FirebaseFirestore.instance;
    if (discoverData != null) {
      final DocumentSnapshot _matchSnapshot =
          await _db.collection("userData").doc(discoverData!.uid).get();
      final Map _matchData = _matchSnapshot.data() as Map;
      return _matchData;
    } else if (dateData != null) {
      final DocumentSnapshot _matchSnapshot =
          await _db.collection("userData").doc(dateData!.matchID).get();
      final Map _matchData = _matchSnapshot.data() as Map;
      return _matchData;
    } else {
      throw ('must have either discover or date data to preform this operation');
    }
  }

  Future<void> getDate(BuildContext context,
      {double? userRating, bool pickAnother = false}) async {
    final Map _venueData = await venueData;
    final Map _matchData = await matchData;
    if (_venueData["venue"]["status"] == "OK") {
      await DateTimeDialogue(setDateTime: setDateTime).buildCalendarDialogue(
          context,
          pickAnother: pickAnother,
          matchName: _matchData["name"],
          venueName: _venueData["venue"]["name"]);
      if (_dateTime != null &&
          await GooglePlacesService.checkDateTime(
              _dateTime!, _venueData["venue"])) {
        await MatchDataService.updateMatchData(
            otherUserUID: discoverData != null
                ? discoverData!.uid
                : dateData != null
                    ? dateData!.matchID
                    : throw ("must have either discover or date data to preform this operation"),
            dateType: _venueData['venueType'],
            dateTime: _dateTime!,
            venue: _venueData["venue"]["name"],
            userRating: userRating);
        // TODO: maybe a congrats dialogue
      } else if (_dateTime == null) {
        // TODO: cancel dialogue
      } else if (!await GooglePlacesService.checkDateTime(
          _dateTime!, _venueData["venue"])) {
        getDate(context, pickAnother: true);
      }
    } else {
      // TODO: error dialogue
    }
  }
}
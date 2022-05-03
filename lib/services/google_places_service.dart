import 'package:dio/dio.dart';
import '../models/users.dart';

class GooglePlacesService {
  final String PLACES_API_KEY = "AIzaSyCl-kVxhkNP1ySziCMs8kdkMMMbOMLlg6k";
  // final String basePath =
  //     "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?fields=formatted_address%2Cname%2Crating%2Copening_hours";
  final String basePath =
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json?";
  GooglePlacesService({required this.venueType});
  final String venueType;
  Dio dio = Dio();

  Future<List> get venues async {
    final double meters = UserData.maxDistance! * 1609.34;
    final String _path = basePath +
        "&location=${UserData.location?.latitude}%2C${UserData.location?.longitude}" +
        "&radius=$meters" +
        "&type=$venueType" +
        "&key=$PLACES_API_KEY";
    try {
      final Response _venues = await dio.get(_path);
      final _venueData = _venues.data;
      if (_venueData["results"] != null) {
        return _venueData["results"]!;
      }
      throw ("could not find suitable venues");
    } catch (e) {
      // TODO: error handing
      print(e);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> get venuesWithOpenHours async {
    // TODO: figure out how to get open hours
    List<Map<String, dynamic>> result = [];
    for (Map<String, dynamic> venue in await venues) {
      if (venue["opening_hours"]["periods"] != null) {
        result.add(venue);
      }
    }
    return result;
  }

  // maybe grab max rating after eliminating all requests without opening hours
  Future<Map<String, dynamic>> get venue async {
    double maxRating = 0;
    Map<String, dynamic> resultVenue = {};
    for (Map<String, dynamic> venue in await venuesWithOpenHours) {
      if (venue["rating"] > maxRating) {
        resultVenue = venue;
        maxRating = venue["rating"];
      }
    }
    return resultVenue;
  }

  Future<String> get address async {
    final _venue = await venue;
    return _venue["formatted_address"];
  }

  // String get name => venue["name"];

  Future<String> get name async {
    final _venue = await venue;
    return _venue["name"];
  }

  Future<List> get openHours async {
    final _venue = await venue;
    return _venue["opening_hours"]["periods"];
  }
}

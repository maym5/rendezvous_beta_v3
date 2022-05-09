
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rendezvous_beta_v3/models/user_images.dart';
import 'package:rendezvous_beta_v3/pages/discover_page.dart';

class UserData with ChangeNotifier {
  static String? name;
  static int? age;
  static String? gender;
  static String? bio;
  static Set<String> dates = {};
  static Set<String> prefGender = {};
  static int? minAge;
  static int? maxAge;
  static int? maxDistance;
  static int? minPrice;
  static int? maxPrice;
  static List<String> imageURLs = [];
  static Position? location;
  static String? userUID;

  UserData();

  static Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender.toString(),
      'bio': bio,
      'dates': dates.toList(),
      'prefGender': prefGender.toList(),
      'minAge': minAge,
      'maxAge': maxAge,
      'distance': maxDistance,
      'minPrice': minPrice,
      "maxPrice" : maxPrice,
      'imageURLs': imageURLs,
      "uid" : userUID
    };
  }

  static Set<String> toSetOfString(dynamic values) {
    Set<String> result = {};
    for (var item in values) {
      result.add(item.toString());
    } return result;
  }

  static void fromJson(Map<String, dynamic> incomingData) {
    name = incomingData["name"];
    age = incomingData["age"];
    gender = incomingData["gender"];
    prefGender = toSetOfString(incomingData["prefGender"]);
    bio = incomingData["bio"];
    dates = toSetOfString(incomingData["dates"]);
    maxPrice = incomingData["maxPrice"];
    minPrice = incomingData["minPrice"];
    maxDistance = incomingData["distance"];
    maxAge = incomingData["maxAge"];
    minAge = incomingData["minAge"];
    imageURLs = DiscoverData.listToListOfStrings(incomingData["imageURLs"]); // refactor this now that youre using it here
  }


  User? retrieveUser({FirebaseAuth? auth}) {
    auth ??= FirebaseAuth.instance;
    return auth.currentUser;
  }

  Future<void> uploadUserData() async {
    final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
    User? _user = retrieveUser();
    if (_user != null) {
      await UserImages.uploadImages(_user);
      Map<String, dynamic> _userData = UserData.toJson();
      _fireStore.collection("userData").doc(_user.uid).set(_userData);
    }
  }

  static bool get canCreateUser {
    for (var value in UserData.toJson().values) {
      if (value == null) {
        return false;
      }
    } return true;
  }

  // void updateUserData() async {
  //   // TODO: test this
  //   final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  //   User? _user = retrieveUser();
  //   final Map<String, dynamic> _newUserData = UserData.toJson();
  //   if (_user != null) {
  //     final DocumentSnapshot _oldUserData = await _fireStore.collection("userData").doc(_user.uid).get();
  //     final Map<String, dynamic> _data = _oldUserData.data() as Map<String, dynamic>;
  //     for (String key in _data.keys) {
  //       if (_newUserData[key] != _oldUserData[key]) {
  //         _fireStore.collection("userData").doc(_user.uid).update(_newUserData);
  //      }
  //    }
  //   }
  // }

  static Future<Position> get userLocation async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are not enabled");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permissions are denied");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error("Permissions are denied forever, there is nothing we can do");
    }
    return await Geolocator.getCurrentPosition();
  }

}

// class UserPhotos {
//   User user;
//   static List<XFile?> images = [];
//   static List<XFile?> indexedUserPhotos = List.filled(9, null);
//
//   // pre: initialize images[] with all user's images
//   // post: userdata photo urls are updated
//   // void uploadPhotos() async {
//   //   UserData.imageURLs = [];
//   //   for (int i = 0; i < images.length; i++) {
//   //     String path = 'images/${user.uid}/$i';
//   //     Reference ref = FirebaseStorage.instance.ref(path);
//   //     await ref.putFile(File(images[i]!.path));
//   //     UserData.imageURLs.add(await ref.getDownloadURL());
//   //   }
//   //   for (int i = images.length; i < 9; i++) {
//   //     String path = 'images/${user.uid}/$i';
//   //     await FirebaseStorage.instance.ref(path).delete();
//   //   }
//   // }
//
//
//   UserPhotos(this.user);
// }
//
// void setUser(User user) {}
//
// // User? retrieveUser({FirebaseAuth? auth}) {
// //   auth ??= FirebaseAuth.instance;
// //   return auth.currentUser;
// // }
//
// // Future addUser({User? user}) {
// //   user ??= retrieveUser();
// //   if (user == null) {
// //     return Future.error("User could not be authenticated");
// //   }
// //   FirebaseFirestore firestore = FirebaseFirestore.instance;
// //
// //   DocumentReference ref = firestore.collection('users').doc(user.uid);
// //   return ref.set(UserData.toJson());
// // }

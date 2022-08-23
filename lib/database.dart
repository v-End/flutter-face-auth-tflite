import 'package:hive/hive.dart';

class User {
  String? name;
  String? pass;
  List? key;

  static const String userName = "user_name";
  static const String userPass = "user_pass";
  static const String userKey = "user_key";

  User({required this.name, required this.pass, required this.key});

  factory User.fromJson(Map<dynamic, dynamic> json) =>
      User(name: json[userName], pass: json[userPass], key: json[userKey]);

  Map<String, dynamic> toJson() =>
      {userName: name, userPass: pass, userKey: key};
}

class HiveBoxes {
  static const userDetails = "user_details";

  static Box userDetailsBox() => Hive.box(userDetails);

  static initialize() async {
    await Hive.openBox(userDetails);
  }

  static clearAllBox() async {
    await HiveBoxes.userDetailsBox().clear();
  }
}

class LocalDB {
  static User getUser() => User.fromJson(HiveBoxes.userDetailsBox().toMap());

  static String getUserName() =>
      HiveBoxes.userDetailsBox().toMap()[User.userName];

  static String getUserPass() =>
      HiveBoxes.userDetailsBox().toMap()[User.userPass];

  static String getUserKey() =>
      HiveBoxes.userDetailsBox().toMap()[User.userKey];

  static setUserDetails(User user) =>
      HiveBoxes.userDetailsBox().putAll(user.toJson());
}

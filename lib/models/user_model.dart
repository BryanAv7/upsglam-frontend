class UserModel {
  final String uid;
  final String email;
  final String displayName;

  UserModel({required this.uid, required this.email, required this.displayName});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    uid: json['uid'],
    email: json['email'],
    displayName: json['displayName'],
  );
}

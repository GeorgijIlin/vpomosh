class User {
  String userId;
  String userName;
  String userImage;
  String userPhone;
  String pushToken;
  String createdOn;
  List searchIndex;
  int userType;
  String userCity;
  bool isAgree;


  User(
      this.userId,
      this.userName,
      this.userImage,
      this.userPhone,
      this.pushToken,
      this.createdOn,
      this.searchIndex,
      this.userType,
      this.userCity,
      this.isAgree
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'userImage': userImage,
    'userPhone': userPhone,
    'pushToken': pushToken,
    'createdOn': createdOn,
    'searchIndex': searchIndex,
    'userType': userType,
    'userCity': userCity,
    'isAgree': isAgree
  };
}
class User_Info {
  String? userName;
  String? phoneNumber;
  List<String>? favoriteFood;
  int? avatarNum;

  User_Info(
      {this.userName, this.phoneNumber, this.favoriteFood, this.avatarNum});

  User_Info.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    phoneNumber = json['phoneNumber'];
    favoriteFood = json['favoriteFood'].cast<String>();
    avatarNum = json['avatarNum'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userName'] = this.userName;
    data['phoneNumber'] = this.phoneNumber;
    data['favoriteFood'] = this.favoriteFood;
    data['avatarNum'] = this.avatarNum;
    return data;
  }
}

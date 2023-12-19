class Rate {
  String? sId;
  String? comment;
  int? rate;
  String? userId;
  String? foodId;
  String? date;
  int? iV;
  List<UserInfo>? userInfo;

  Rate(
      {this.sId,
      this.comment,
      this.rate,
      this.userId,
      this.foodId,
      this.date,
      this.iV,
      this.userInfo});

  Rate.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    comment = json['comment'];
    rate = json['rate'];
    userId = json['userId'];
    foodId = json['foodId'];
    date = json['date'];
    iV = json['__v'];
    if (json['userInfo'] != null) {
      userInfo = <UserInfo>[];
      json['userInfo'].forEach((v) {
        userInfo!.add(new UserInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['comment'] = this.comment;
    data['rate'] = this.rate;
    data['userId'] = this.userId;
    data['foodId'] = this.foodId;
    data['date'] = this.date;
    data['__v'] = this.iV;
    if (this.userInfo != null) {
      data['userInfo'] = this.userInfo!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserInfo {
  String? userName;
  int? avatarNum;

  UserInfo({this.userName, this.avatarNum});

  UserInfo.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    avatarNum = json['avatarNum'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userName'] = this.userName;
    data['avatarNum'] = this.avatarNum;
    return data;
  }
}

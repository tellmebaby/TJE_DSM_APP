class User {
  int? userNo;
  String? name;
  String? id;
  String? email;
  String? password;
  String? phone;
  String? address;
  DateTime? regDate;
  DateTime? updDate;
  String? gender;
  String? birth;
  String? socialCode;
  int? point;
  List<Auth>? authList;

  User({
    this.userNo,
    this.name,
    this.id,
    this.email,
    this.password,
    this.phone,
    this.address,
    this.regDate,
    this.updDate,
    this.gender,
    this.birth,
    this.socialCode,
    this.point,
    this.authList,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userNo: json['userNo'],
      name: json['name'],
      id: json['id'],
      email: json['email'],
      password: json['password'],
      phone: json['phone'],
      address: json['address'],
      regDate: json['regDate'] != null ? DateTime.parse(json['regDate']) : null,
      updDate: json['updDate'] != null ? DateTime.parse(json['updDate']) : null,
      gender: json['gender'],
      birth: json['birth'],
      socialCode: json['socialCode'],
      point: json['point'],
      authList: (json['authList'] as List<dynamic>?)
          ?.map((authJson) => Auth.fromJson(authJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userNo': userNo,
      'name': name,
      'id': id,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
      'regDate': regDate?.toIso8601String(),
      'updDate': updDate?.toIso8601String(),
      'gender': gender,
      'birth': birth,
      'socialCode': socialCode,
      'point': point,
      'authList': authList?.map((auth) => auth.toJson()).toList(),
    };
  }
}

class Auth {
  int? authNo;
  String? userId;
  String? auth;

  Auth({
    this.authNo,
    this.userId,
    this.auth,
  });

  factory Auth.fromJson(Map<String, dynamic> json) {
    return Auth(
      authNo: json['authNo'],
      userId: json['userId'],
      auth: json['auth'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authNo': authNo,
      'userId': userId,
      'auth': auth,
    };
  }
}
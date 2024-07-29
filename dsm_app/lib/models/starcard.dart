class StarCard {
  int? starNo;
  String? title;
  String? writer;
  String? content;
  DateTime? regDate;
  DateTime? updDate;
  int? views;
  int? userNo;
  int? payNo;
  int? likes;
  String? status;
  String? card;
  String? category1;
  String? category2;
  String? koreaCategory2;
  String? type;
  DateTime? startDate;
  DateTime? endDate;
  int? imgNo;
  int? commentCount;
  int? likesChk;
  int? userImgId;
  int? starPrice;
  dynamic action;
  dynamic icons;
  List<String>? comments;  // 수정된 부분

  StarCard({
    this.starNo,
    this.title,
    this.writer,
    this.content,
    this.regDate,
    this.updDate,
    this.views,
    this.userNo,
    this.payNo,
    this.likes,
    this.status,
    this.card,
    this.category1,
    this.category2,
    this.koreaCategory2,
    this.type,
    this.startDate,
    this.endDate,
    this.imgNo,
    this.commentCount,
    this.likesChk,
    this.userImgId,
    this.starPrice,
    this.action,
    this.icons,
    this.comments,  // 수정된 부분
  });

  factory StarCard.fromJson(Map<String, dynamic> json) {
    return StarCard(
      starNo: json['starNo'],
      title: json['title'],
      writer: json['writer'],
      content: json['content'],
      regDate: json['regDate'] != null ? DateTime.parse(json['regDate']) : null,
      updDate: json['updDate'] != null ? DateTime.parse(json['updDate']) : null,
      views: json['views'],
      userNo: json['userNo'],
      payNo: json['payNo'],
      likes: json['likes'],
      status: json['status'],
      card: json['card'],
      category1: json['category1'],
      category2: json['category2'],
      koreaCategory2: json['koreaCategory2'],
      type: json['type'],
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      imgNo: json['imgNo'],
      commentCount: json['commentCount'],
      likesChk: json['likes_chk'],
      userImgId: json['userImgId'],
      starPrice: json['starPrice'],
      action: json['action'],
      icons: json['icons'],
      comments: json['comments'] != null ? List<String>.from(json['comments']) : [],  // 수정된 부분
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'starNo': starNo,
      'title': title,
      'writer': writer,
      'content': content,
      'regDate': regDate?.toIso8601String(),
      'updDate': updDate?.toIso8601String(),
      'views': views,
      'userNo': userNo,
      'payNo': payNo,
      'likes': likes,
      'status': status,
      'card': card,
      'category1': category1,
      'category2': category2,
      'koreaCategory2': koreaCategory2,
      'type': type,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'imgNo': imgNo,
      'commentCount': commentCount,
      'likes_chk': likesChk,
      'userImgId': userImgId,
      'starPrice': starPrice,
      'action': action,
      'icons': icons,
      'comments': comments,  // 수정된 부분
    };
  }
}

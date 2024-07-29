class Reply {
  int? replyNo;
  int? starNo;
  String? writer;
  String? content;
  DateTime? regDate;
  DateTime? updDate;

  Reply({
    this.replyNo,
    this.starNo,
    this.writer,
    this.content,
    this.regDate,
    this.updDate,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      replyNo: json['replyNo'],
      starNo: json['starNo'],
      writer: json['writer'],
      content: json['content'],
      regDate: json['regDate'] != null ? DateTime.parse(json['regDate']) : null,
      updDate: json['updDate'] != null ? DateTime.parse(json['updDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'replyNo': replyNo,
      'starNo': starNo,
      'writer': writer,
      'content': content,
      'regDate': regDate?.toIso8601String(),
      'updDate': updDate?.toIso8601String(),
    };
  }
}
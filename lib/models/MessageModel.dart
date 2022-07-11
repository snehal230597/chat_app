class MessageModel {
  String? messageid;
  String? sender;
  String? text;
  bool? seen;
  String? type;
  DateTime? createdon;

  MessageModel({this.messageid,this.sender, this.text, this.seen,this.type,this.createdon});

  MessageModel.fromMap(Map<String, dynamic> map) {
    messageid = map["messageid"];
    sender = map["sender"];
    text = map["text"];
    type = map["type"];
    seen = map["seen"];
    createdon = map["createdon"].toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      "messageid" : messageid,
      "sender": sender,
      "text": text,
      "seen": seen,
      "type" : type,
      "createdon": createdon,
    };
  }
}

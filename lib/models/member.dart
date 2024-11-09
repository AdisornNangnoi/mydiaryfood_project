// ignore_for_file: unnecessary_new, unnecessary_this, prefer_collection_literals

class Member {
  String? message;
  String? memId;
  String? memFullName;
  String? memEmail;
  String? memUsername;
  String? memPassword;
  String? memAge;
  String? memImage;

  Member({
    this.message,
    this.memId,
    this.memFullName,
    this.memEmail,
    this.memUsername,
    this.memPassword,
    this.memAge,
    this.memImage,
  });

  //แปลงจาก JSON มาเป็นข้อมูลที่ใช้ใน App
  Member.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    memId = json['memId'];
    memFullName = json['memFullName'];
    memEmail = json['memEmail'];
    memUsername = json['memUsername'];
    memPassword = json['memPassword'];
    memAge = json['memAge'];
    memImage = json['memImage'];
  }

  //แปลงข้อมูลที่ใช้ใน App ไปเป็น JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['memId'] = this.memId;
    data['memFullName'] = this.memFullName;
    data['memEmail'] = this.memEmail;
    data['memUsername'] = this.memUsername;
    data['memPassword'] = this.memPassword;
    data['memAge'] = this.memAge;
    data['memImage'] = this.memImage;
    return data;
  }
}

class Contest {
  String website;
  String url;
  String name;
  String id;
  DateTime start;
  DateTime end;
  DateTime duration;
  Contest(
      {this.website,
      this.url,
      this.name,
      this.duration,
      this.end,
      this.id,
      this.start});

  Contest.fromJson(Map<String, dynamic> json) {
    // this.id = json['objects']['id'];
    this.url = json['objects']['href'];
    try {
      this.website = json['objects']['resource']['name'];
    } catch (e) {}
    // try {
    //   this.start = DateTime.tryParse(json['objects']["start"]+'Z').toLocal();
    //   this.end = DateTime.tryParse(json['objects']["end"]+'Z').toLocal();
    // } catch (e) {
    //   // print(e);
    // }
  }
}

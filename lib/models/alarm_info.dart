class AlarmInfo {
  int? id;
  String title;
  int minutesRepeat; // number of minutes
  int status; // 0=off, 1=on
  int gradientColorIndex;

  AlarmInfo(
      {this.id,
      required this.title,
      required this.minutesRepeat,
      required this.status,
      required this.gradientColorIndex});

  factory AlarmInfo.fromMap(Map<String, dynamic> json) => AlarmInfo(
        id: json["id"],
        title: json["title"],
        minutesRepeat: json["minutesRepeat"],
        status: json["status"],
        gradientColorIndex: json["gradientColorIndex"],
      );
  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "minutesRepeat": minutesRepeat,
        "status": status,
        "gradientColorIndex": gradientColorIndex,
      };
}

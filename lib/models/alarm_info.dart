class AlarmInfo {
  int id;
  int? idx;
  String title;
  DateTime timeAdded;
  int minutesRepeat; // number of minutes
  int status; // 0=off, 1=on
  int gradientColorIndex;

  AlarmInfo(
      {required this.id,
      this.idx,
      required this.title,
      required this.timeAdded,
      required this.minutesRepeat,
      required this.status,
      required this.gradientColorIndex});

  factory AlarmInfo.fromMap(Map<String, dynamic> json) => AlarmInfo(
        id: json["id"],
        idx: json["idx"],
        title: json["title"],
        timeAdded: DateTime.parse(json["timeAdded"]),
        minutesRepeat: json["minutesRepeat"],
        status: json["status"],
        gradientColorIndex: json["gradientColorIndex"],
      );
  Map<String, dynamic> toMap() => {
        "id": id,
        "idx": idx,
        "title": title,
        "timeAdded": timeAdded.toIso8601String(),
        "minutesRepeat": minutesRepeat,
        "status": status,
        "gradientColorIndex": gradientColorIndex,
      };
}

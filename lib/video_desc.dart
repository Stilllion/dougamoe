class VideoDescrtiption{
  String title = "";
  String uploader = "";
  String thumbnaillUrl = "";
  String duration = "";
  String downloadProgress = "";
  String errorText = "";

  VideoDescrtiption({
    this.title = "",
    this.uploader = "",
    this.duration = "",
    this.thumbnaillUrl = "",
  });

  static VideoDescrtiption fromJSON(Map<String, dynamic> json) => VideoDescrtiption(
    title: json['title'] ?? "",
    uploader: json['uploader'] ?? "",
    duration: json['duration_string'] ?? "",
    thumbnaillUrl: json['thumbnail'] ?? json['thumbnails'][0]["url"] ?? "",
  );
}
/// Model untuk video edukasi
class VideoModel {
  final String title;
  final String url;
  final String? duration; // Optional duration field
  final String? thumbnailUrl;

  VideoModel({
    required this.title,
    required this.url,
    this.duration,
    this.thumbnailUrl,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      title: json['title'] as String,
      url: json['url'] as String,
      duration: json['duration'] as String?, // Parse duration from API
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'duration': duration,
      'thumbnail_url': thumbnailUrl,
    };
  }
}

/// Model untuk kategori edukasi
class EducationCategoryModel {
  final int id;
  final String kategori;
  final List<VideoModel> videos;

  EducationCategoryModel({
    required this.id,
    required this.kategori,
    required this.videos,
  });

  factory EducationCategoryModel.fromJson(Map<String, dynamic> json) {
    return EducationCategoryModel(
      id: json['id'] as int,
      kategori: json['kategori'] as String,
      videos: (json['videos'] as List<dynamic>)
          .map((video) => VideoModel.fromJson(video as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kategori': kategori,
      'videos': videos.map((video) => video.toJson()).toList(),
    };
  }
}

/// Model untuk response API
class EducationResponseModel {
  final List<EducationCategoryModel> data;

  EducationResponseModel({
    required this.data,
  });

  factory EducationResponseModel.fromJson(Map<String, dynamic> json) {
    return EducationResponseModel(
      data: (json['data'] as List<dynamic>)
          .map((category) => EducationCategoryModel.fromJson(category as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((category) => category.toJson()).toList(),
    };
  }
}

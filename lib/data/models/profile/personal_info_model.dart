class PersonalInfoModel {
  final String? name;
  final String? birthDate;
  final String? phone;
  final String? address;
  final String? photoUrl;
  final double? weight;
  final double? height;
  final int? age;

  PersonalInfoModel({
    this.name,
    this.birthDate,
    this.phone,
    this.address,
    this.photoUrl,
    this.weight,
    this.height,
    this.age,
  });

  factory PersonalInfoModel.fromJson(Map<String, dynamic> json) {
    return PersonalInfoModel(
      name: json['name'] as String?,
      birthDate: json['birth_date'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      photoUrl: json['photo_url'] as String?,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      age: json['age'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'birth_date': birthDate,
      'phone': phone,
      'address': address,
      'photo_url': photoUrl,
      'weight': weight,
      'height': height,
      'age': age,
    };
  }

  /// toJson untuk create - memastikan name dan birth_date selalu ada (minimal string kosong)
  Map<String, dynamic> toJsonForCreate() {
    return {
      'name': name ?? '',
      'birth_date': birthDate ?? '',
      'phone': phone,
      'address': address,
      'photo_url': photoUrl,
      'weight': weight,
      'height': height,
      'age': age,
    };
  }
}

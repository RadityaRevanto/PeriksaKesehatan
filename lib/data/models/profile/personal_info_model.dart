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
    final Map<String, dynamic> data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (birthDate != null) data['birth_date'] = birthDate;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;
    if (photoUrl != null) data['photo_url'] = photoUrl;
    if (weight != null) data['weight'] = weight;
    if (height != null) data['height'] = height;
    if (age != null) data['age'] = age;
    return data;
  }

  /// toJson untuk create - memastikan name dan birth_date selalu ada (minimal string kosong)
  Map<String, dynamic> toJsonForCreate() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name ?? '';
    data['birth_date'] = birthDate ?? '';
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;
    if (photoUrl != null) data['photo_url'] = photoUrl;
    if (weight != null) data['weight'] = weight;
    if (height != null) data['height'] = height;
    if (age != null) data['age'] = age;
    return data;
  }
}

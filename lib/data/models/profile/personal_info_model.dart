class PersonalInfoModel {
  final String? name;
  final String? birthDate;
  final String? phone;
  final String? address;
  final String? photo;

  PersonalInfoModel({
    this.name,
    this.birthDate,
    this.phone,
    this.address,
    this.photo,
  });

  factory PersonalInfoModel.fromJson(Map<String, dynamic> json) {
    return PersonalInfoModel(
      name: json['name'] as String?,
      birthDate: json['birth_date'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      photo: json['photo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'birth_date': birthDate,
      'phone': phone,
      'address': address,
      'photo': photo,
    };
  }
}

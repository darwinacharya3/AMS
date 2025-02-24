class Country {
  final int id;
  final String name;

  Country({required this.id, required this.name});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class StateModel {
  final int id;
  final int countryId;
  final String stateName;

  StateModel({
    required this.id, 
    required this.countryId, 
    required this.stateName,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'] as int,
      countryId: json['country_id'] as int,
      stateName: json['state_name'] as String,
    );
  }
}

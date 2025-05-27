class Recommendation {
  final String crop;
  final DateTime date;
  final double ph;
  final String soilType;
  final double temp;
  final double rainfall;

  Recommendation({
    required this.crop,
    required this.date,
    required this.ph,
    required this.soilType,
    required this.temp,
    required this.rainfall,
  });
  String recommendCrop({
  required String weather,
  required String soil,
  required int month,
}) {
  if (weather == 'Sunny' && soil == 'Loamy' && (month >= 3 && month <= 5)) {
    return 'Maize';
  } else if (soil == 'Clay' && (month >= 6 && month <= 8)) {
    return 'Rice';
  } else {
    return 'Cassava';
  }
}

}

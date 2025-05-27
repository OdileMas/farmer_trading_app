String recommendCrop({
  required double soilPh,
  required String soilType,
  required double rainfall,
  required double temperature,
  required String season,
}) {
  if (soilType == 'loamy' && soilPh >= 6 && rainfall > 300 && temperature >= 18 && temperature <= 30) {
    return 'Maize';
  } else if (soilType == 'sandy' && soilPh >= 5.5 && temperature >= 20 && season == 'Summer') {
    return 'Groundnut';
  }
  return 'No strong recommendation based on current data';
}

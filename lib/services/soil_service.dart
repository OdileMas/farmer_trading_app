Future<Map<String, dynamic>> getSoil(double lat, double lon) async {
  final url = 'https://rest.isric.org/soilgrids/v2.0/properties/query?lon=$lon&lat=$lat&property=phh2o&depth=0-5cm&value=mean';

  final response = await http.get(Uri.parse(url));
  final data = jsonDecode(response.body);

  double ph = data['properties']['phh2o']['values'][0]['value'];
  
  return {
    'ph': ph,
    'soilType': ph >= 6 && ph <= 7.5 ? 'loamy' : 'sandy',
  };
}

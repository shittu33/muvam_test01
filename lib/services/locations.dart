
import 'package:muvam_test01/api/location_api.dart';
import 'package:muvam_test01/model/location.dart';

class LocationService {
  late ApiClient _client;

  LocationService() {
    _client = ApiClient();
  }

  Future<List<Location>> getLocations() => _client.getLocations();
}

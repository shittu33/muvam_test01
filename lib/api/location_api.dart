import 'dart:io';

import 'package:dio/dio.dart';
import 'package:muvam_test01/model/location.dart';

const BASE_URL = "https://enpuyr7bafpswlw.m.pipedream.net";

class ApiClient {
  late Dio dio;

  ApiClient() {
    BaseOptions options = BaseOptions();
    options.baseUrl = BASE_URL;
    dio = Dio(options);
  }

  Future<List<Location>> getLocations() {

    print("BEFORE FETCH");

    return dio.get("/").then((res) {
      if (res.statusCode == HttpStatus.ok) {

        List locations = res.data;

        if (locations == null) return [];

        print("API");

        print(res);

        print(locations);

        return locations
            .map(
              (location) => Location(
                name: location["name"],
                active: location["active"],
                lat: double.parse(location["lat"]),
                lng: double.parse(location["lng"]),
              ),
            )
            .toList();
      }
      return [];
    });
    // .catchError((Object obj) {
    //
    //   switch (obj.runtimeType) {
    //     case DioError:
    //       Response res = (obj as DioError).response!;
    //       print(res);
    //       break;
    //   }
    //
    // });
  }
}

import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ship_track_flutter/app/services/app_exception.dart';

import '../../exports.dart';
import '../constant/api_constants.dart';

enum REQUEST { get, post, put, patch, delete }

Uri getUrl(String methodName) {
  if (methodName.contains("http")) {
    return Uri.parse(methodName);
  } else {
    return Uri.parse(baseUrl + methodName);
  }
}

dynamic safeDecode(String body) {
  try {
    return jsonDecode(body);
  } catch (e) {
    debugPrint("Failed to decode JSON: $e");
    throw FetchDataException("Invalid JSON response from server.");
  }
}

Future<dynamic> httpRequest(
  REQUEST requestType,
  String url,
  dynamic data, {
  String token = "",
}) async {
  dynamic responseJson;
  data = jsonEncode(data);
  dynamic value;
  debugPrint(
    "$requestType Url:- ${getUrl(url)} ${data != "{}" ? "DataSend:- $data" : ""} Token:- ${token.isNotEmpty}",
  );
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      switch (requestType) {
        case REQUEST.get:
          value = await http.get(
            Uri.parse("$baseUrl$url"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": token.isNotEmpty ? "Bearer $token" : '',
              // HttpHeaders.contentTypeHeader: "application/json",
              // 'Content-Type': 'application/json; charset=UTF-8',
              // HttpHeaders.authorizationHeader: token,
              // 'token': token,
              // HttpHeaders.authorizationHeader: 'Bearer $token',
            },
          );
          break;
        case REQUEST.post:
          value = await http.post(
            Uri.parse("$baseUrl$url"),
            headers: token.isEmpty
                ? {"Content-Type": "application/json"}
                : {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer $token",
                  },
            // headers: (token.isEmpty)
            //     ? {HttpHeaders.contentTypeHeader: "application/json"}
            //     : {
            //         HttpHeaders.contentTypeHeader: "application/json",
            //         // HttpHeaders.authorizationHeader: token,
            //         // 'token': token,
            //         HttpHeaders.authorizationHeader: 'Bearer $token',
            //       },
            body: data,
          );
          break;
        case REQUEST.put:
          value = await http.put(
            Uri.parse("$baseUrl$url"),
            headers: {
              HttpHeaders.contentTypeHeader: "application/json",
              // HttpHeaders.authorizationHeader:  token,
              // 'token': token,
              HttpHeaders.authorizationHeader: 'Bearer $token',
            },
            body: data,
          );
          break;
        case REQUEST.patch:
          value = await http.patch(
            Uri.parse("$baseUrl$url"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: data,
          );
          break;
        case REQUEST.delete:
          value = await http.delete(
            Uri.parse("$baseUrl$url"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
              // HttpHeaders.contentTypeHeader: "application/json",
              // // HttpHeaders.authorizationHeader:  token,
              // // 'token': token,
              // HttpHeaders.authorizationHeader: 'Bearer $token',
            },
            body: data,
          );
          break;
      }
    }
    if (kDebugMode) {
      final decoded = safeDecode(value.body);
      final prettyString = const JsonEncoder.withIndent('  ').convert(decoded);
      log("Code ${value.statusCode}Url 👉 ${getUrl(url)} \n Response 👉 $prettyString");
    }
    if (value.statusCode == 401 &&
        jsonDecode(value.body)["message"].toString() == "Please authenticate") {
      // ShowMyDialogs.onSessionExpired(Get.context,
      //     title: "Login Expired", onBtnClick: (a) {});
      return {};
    } else {
      responseJson = returnResponse(value);
    }
  } on SocketException catch (_) {
    throw FetchDataException("No Internet Connection");
  }
  return responseJson;
}

@visibleForTesting
returnResponse(http.Response response) {
  switch (response.statusCode) {
    case 200:
      return jsonDecode(response.body);
    case 201:
      return jsonDecode(response.body);
    case 204:
      return {};
    case 400:
      throw BadRequestException(getMessage(response));
    case 401:
      throw BadRequestException(getMessage(response));
    case 403:
      throw UnauthorisedException(getMessage(response));
    case 500:
      throw UnauthorisedException(getMessage(response));
    case 404:
      throw BadRequestException(getMessage(response));
    case 406:
      throw BadRequestException(getMessage(response));

    default:
      throw FetchDataException(
        'Error occurred while communication with server with status code : ${response.statusCode}',
      );
  }
}

String getMessage(http.Response response) {
  dynamic responseJson = jsonDecode(response.body);
  String? msg = responseJson['message'];
  if (msg != null) {
    return msg.contains("HandshakeException") ? "no_internet".tr : msg;
  } else {
    // return "ERROR ${response.statusCode} - NO ERROR MESSAGE RECEIVED FROM BACKEND ";
    return "Please Refresh Page Network Problem";
  }
}

// Future<dynamic> uploadRequest(file, {type, ext}) async {
//   var fle = File(file);
//   // var img = Image(image: FileImage(File(file))); //file(new File(file);
//   var stream = http.ByteStream(DelegatingStream.typed(fle.openRead()));
//   var length = await fle.length();
//   var uri = Uri.parse('$baseUrl$postImageUrl');
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? token = prefs.getString('token');
//   var request = http.MultipartRequest("POST", uri);
//   var multipartFile = http.MultipartFile('image', stream, length,
//       filename: basename(fle.path),
//       contentType: MediaType(type ?? 'image', ext ?? 'jpg'));
//   request.files.add(multipartFile);
//   request.headers.addAll({
//     HttpHeaders.contentTypeHeader: "application/json",
//     HttpHeaders.authorizationHeader: 'Bearer $token',
//     // 'Bearer': token,
//   });
//   var response = await request.send();
//   var responseData = await response.stream.toBytes();
//   var responseString = String.fromCharCodes(responseData);
//   // print(response);
//   // print(responseData);
//   // print(responseString);
//   return jsonDecode(responseString)['image'];
// }

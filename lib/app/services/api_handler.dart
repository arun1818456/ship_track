import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ship_track_flutter/app/services/app_exception.dart';

import '../../exports.dart';

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
            body: data,
          );
          break;
        case REQUEST.put:
          value = await http.put(
            Uri.parse("$baseUrl$url"),
            headers: {
              HttpHeaders.contentTypeHeader: "application/json",
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
            },
            body: data,
          );
          break;
      }
    }
    if (kDebugMode) {
      final decoded = safeDecode(value.body);
      final prettyString = const JsonEncoder.withIndent('  ').convert(decoded);
      log(
        "Code ${value.statusCode}Url 👉 ${getUrl(url)} \n Response 👉 $prettyString",
      );
    }
    if (value.statusCode == 401 &&
        jsonDecode(value.body)["message"].toString() == "Please authenticate") {
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
    return "Please Refresh Page Network Problem";
  }
}

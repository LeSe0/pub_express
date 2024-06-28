import 'package:dio/dio.dart';
import 'package:push_express_lib/src/domain/common/icommon_repo.dart';
import 'package:push_express_lib/enums/common.dart';
import 'package:push_express_lib/src/models/api/response_model.dart';
import 'package:push_express_lib/src/utils/user_locales.dart';

class CommonRepo implements ICommonRepo {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://core.push.express/api/r/v2',
    contentType: "application/json",
  ));

  @override
  Future<ResponseModel> createAppInstance({
    required String appId,
    required TransportType transportType,
    required String icId,
  }) async {
    final response = await dio.post(
      "https://core.push.express/api/r/v2/apps/$appId/instances",
      options: Options(contentType: Headers.jsonContentType),
      data: {
        'ic_token': icId,
      },
    );

    return ResponseModel.fromJson(
      response,
      response.data,
    );
  }

  @override
  Future<ResponseModel> updateAppInstance({
    required String appId,
    required TransportType transportType,
    required String transportToken,
    required String icId,
    String? extId,
  }) async {
    var params = {
      "transport_type": transportType.value,
      "transport_token": transportToken,
      "platform_type": LocaleInfo.getPlatformName(),
      "platform_name": LocaleInfo.getPlatformName(),
      "lang": LocaleInfo.getCurrentLanguage(),
      "county": LocaleInfo.getCurrentCountry(),
      if (extId != null) "ext_id": extId,
      "tz_sec": LocaleInfo.getTimeZoneOffsetInSeconds()
    };

    final response = await dio.put(
      "https://core.push.express/api/r/v2/apps/$appId/instances/$icId/info",
      data: params,
    );

    return ResponseModel.fromJson(
      response,
      response.data,
    );
  }

  @override
  Future<ResponseModel> sendNotificationEvent({
    required String msgId,
    required Events event,
    required String appId,
    required String icId,
  }) async {
    final response = await dio.post(
      'https://core.push.express/api/r/v2/apps/$appId/instances/$icId/events/notification',
      data: {
        'msg_id': msgId,
        'event': event.name,
      },
    );

    return ResponseModel.fromJson(
      response,
      response.data,
    );
  }

  @override
  Future<ResponseModel> sendLifecycleEvent({
    required Events event,
    required String appId,
    required String icId,
  }) async {
    final response = await dio.post(
      'https://core.push.express/api/r/v2/apps/$appId/instances/$icId/events/lifecycle',
      data: {'event': event.name},
    );

    return ResponseModel.fromJson(
      response.data,
      null,
    );
  }
}

import 'package:push_express_lib/enums/common.dart';
import 'package:push_express_lib/src/models/api/response_model.dart';

abstract class ICommonRepo {
  Future<ResponseModel> createAppInstance({
    required String appId,
    required TransportType transportType,
    required String icId,
  });
  Future<ResponseModel> updateAppInstance({
    required String appId,
    required TransportType transportType,
    required String transportToken,
    required String icId,
    required String extId,
  });
  Future<ResponseModel> sendNotificationEvent({
    required String msgId,
    required Events event,
    required String appId,
    required String icId,
  });
  Future<ResponseModel> sendLifecycleEvent({
    required Events event,
    required String appId,
    required String icId,
  });
}

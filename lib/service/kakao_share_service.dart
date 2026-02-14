import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import '../util/logger.dart';

class KakaoShareService {
  Future<void> shareMailbox(String mailboxNumber, String nickname) async {
    try {
      final isInstalled =
          await ShareClient.instance.isKakaoTalkSharingAvailable();

      if (!isInstalled) {
        logger.w("카카오톡 미설치");
        return;
      }

      const templateId = 128526;

      final uri = await ShareClient.instance.shareCustom(
        templateId: templateId,
        templateArgs: {
          "NICKNAME": nickname,
          "MAILBOX": mailboxNumber,
        },
      );

      await ShareClient.instance.launchKakaoTalk(uri);

      logger.i("카카오 카드 공유 성공");
    } catch (e, st) {
      logger.e("카카오 공유 실패: $e", stackTrace: st);
    }
  }
}

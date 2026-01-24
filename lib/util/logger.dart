// MARK: - logger 설정
import 'package:logger/logger.dart';

Logger logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0, // 메서드 호출 표시 개수
    errorMethodCount: 0, // 에러 시 표시되는 호출 스택 개수
    lineLength: 50, // 한 줄에 표시할 최대 문자 수
    colors: true, // 색상 사용 여부
    printEmojis: true, // 이모지 사용 여부
    printTime: false, // 로그에 시간 표시
  ),
);

import 'package:flutter_test/flutter_test.dart';

import 'package:plant_identifier_app/services/chatbot/chatbot_service.dart';

void main() {
  final service = ChatbotService.instance;

  test('responds with fertilizer guidance', () {
    final response = service.respond('How often should I fertilize?');
    expect(response.toLowerCase(), contains('fertiliz'));
  });

  test('returns generic guidance for unknown questions', () {
    final response = service.respond('What is the meaning of life?');
    expect(response.toLowerCase(), contains('watering schedules'));
  });
}

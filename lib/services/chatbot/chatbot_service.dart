class ChatbotService {
  ChatbotService._();
  static final ChatbotService instance = ChatbotService._();

  /// A compact rule-based assistant that can be replaced with Dialogflow
  /// without changing the UI/controller contracts.
  String respond(String question) {
    final q = question.toLowerCase().trim();

    if (q.contains('fertiliz')) {
      return 'Most leafy plants benefit from light fertilizing every 2-4 weeks '
          'during active growth. Reduce feeding during dormancy and always '
          'follow package dilution guidelines.';
    }
    if (q.contains('yellow') || q.contains('chlorosis')) {
      return 'Yellowing often points to overwatering, nitrogen deficiency, '
          'or iron lockout from high pH soil. Check drainage, soil pH, and '
          'feed with a balanced fertilizer plus micronutrients.';
    }
    if (q.contains('water')) {
      return 'Water deeply when the top 2-3 cm of soil feels dry. Avoid '
          'shallow daily watering because it can weaken root development.';
    }
    if (q.contains('sun') || q.contains('light')) {
      return 'Match light needs to species type: full sun plants need '
          '6+ hours direct sun, while shade plants prefer indirect light.';
    }

    return 'I can help with watering schedules, nutrient deficiencies, and '
        'disease treatment steps. Try asking: "How often should I fertilize?"';
  }
}

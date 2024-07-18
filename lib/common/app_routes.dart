import 'package:flutter/material.dart';
import '../views/chatbot_screen.dart';
import '../views/on_boarding_screen.dart';

class Routes {

  static final Map<String, WidgetBuilder> routes = {

    '/': (context) =>    const OnBoardingScreen(),
    '/chat_bot': (context) =>     ChatBotScreen(),

  };

}
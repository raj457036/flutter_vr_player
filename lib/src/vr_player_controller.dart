import 'package:flutter/widgets.dart';

import 'event_message.dart';

abstract class VRPlayerObserver {
  void subscribeTo(List<int> event);
  void unSubscribeFrom(List<int> event);
  void subscribeToAllEvents();
  void unSubscribeFromAllEvents();
  void onEvent(int event, VoidCallback callback);
  void triggerCallback(EventMessage message);
}

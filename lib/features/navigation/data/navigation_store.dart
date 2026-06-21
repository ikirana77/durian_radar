import 'package:flutter/foundation.dart';

class NavigationStore extends ValueNotifier<int> {
  NavigationStore() : super(0);

  void goToMap() {
    value = 0;
  }

  void goToFresh() {
    value = 1;
  }

  void goToProfile() {
    value = 2;
  }

  void goToIndex(int index) {
    if (index < 0 || index > 2) {
      return;
    }

    value = index;
  }
}

final NavigationStore navigationStore = NavigationStore();

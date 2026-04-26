import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/event_model.dart';

class SavedEventsNotifier extends StateNotifier<List<EventModel>> {
  SavedEventsNotifier() : super([]);

  void toggleSave(EventModel event) {
    final isSaved = state.any((e) => e.id == event.id);
    if (isSaved) {
      state = state.where((e) => e.id != event.id).toList();
    } else {
      state = [...state, event];
    }
  }

  bool isSaved(String eventId) => state.any((e) => e.id == eventId);
}

final savedEventsProvider =
    StateNotifierProvider<SavedEventsNotifier, List<EventModel>>(
        (ref) => SavedEventsNotifier());
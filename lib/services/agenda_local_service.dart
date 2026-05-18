// lib/services/agenda_local_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class AgendaLocalService {
  static const String _keyAgendaItems = 'savedAgendaItemIds';

  /// Fetches the set of saved Program Item IDs.
  Future<Set<String>> getSavedAgendaItemIds() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedList = prefs.getStringList(_keyAgendaItems);

    if (savedList == null) {
      return <String>{};
    }
    return savedList.toSet();
  }

  /// Saves the set of Program Item IDs.
  Future<void> _saveAgendaItemIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyAgendaItems, ids.toList());
  }

  /// Toggles the state of an item in the agenda. Returns true if added, false if removed.
  // ✅ Note: This method correctly expects a String ID.
  Future<bool> toggleAgendaItem(String itemId) async {
    final ids = await getSavedAgendaItemIds();
    if (ids.contains(itemId)) {
      ids.remove(itemId);
      await _saveAgendaItemIds(ids);
      return false; // Removed
    } else {
      ids.add(itemId);
      await _saveAgendaItemIds(ids);
      return true; // Added
    }
  }

  /// Removes a program item ID from the agenda.
  Future<void> removeFromAgenda(String itemId) async {
    final ids = await getSavedAgendaItemIds();
    if (ids.remove(itemId)) {
      await _saveAgendaItemIds(ids);
    }
  }
}
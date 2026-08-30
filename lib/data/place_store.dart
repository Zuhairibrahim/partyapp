import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/place_item_model.dart';

/// Cloud Firestore-backed store for admin-added items (created from the
/// dashboard). Both apps talk to the SAME `places` collection in Firebase:
/// the dashboard writes its items (photos uploaded to Firebase Storage) and
/// the customer app reads them, so anything saved in the dashboard appears in
/// the customer app instantly — the `snapshots()` stream keeps the cache
/// in sync in real time, and `load()` returns it immediately (no delay).
class PlaceStore {
  PlaceStore._();

  static final PlaceStore instance = PlaceStore._();

  static const String _collection = 'places';

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  List<PlaceItem> _cache = const [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  final List<VoidCallback> _listeners = [];

  /// Snapshot of the current stored items (already de-duplicated).
  List<PlaceItem> get items => _cache;

  /// Starts listening to the `places` collection in real time. Safe to call
  /// more than once (the subscription is created only the first time).
  void init() {
    if (_sub != null) return;
    _sub = _db.collection(_collection).snapshots().listen(
      (snapshot) {
        final items = <PlaceItem>[];
        for (final doc in snapshot.docs) {
          try {
            items.add(PlaceItem.fromJson(doc.data()));
          } catch (_) {
            // Skip any malformed document; keep the rest.
          }
        }
        _cache = _dedupe(items);
        _notify();
      },
      onError: (Object _) {
        // Keep the last good cache on transient network errors.
      },
    );
  }

  void addListener(VoidCallback listener) {
    if (!_listeners.contains(listener)) _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  void _notify() {
    for (final listener in List<VoidCallback>.from(_listeners)) {
      listener();
    }
  }

  /// Loads the persisted items (cached for this process).
  Future<List<PlaceItem>> load() async {
    if (_cache.isNotEmpty) return _cache;
    return reload();
  }

  /// Removes duplicate entries (same name + category + price). Guards against
  /// repeated documents caused by accidental double taps on the dashboard save
  /// button, so a service never appears more than once.
  List<PlaceItem> _dedupe(List<PlaceItem> items) {
    final seen = <String>{};
    final result = <PlaceItem>[];
    for (final e in items) {
      final key = '${e.name}|${e.category}|${e.price}';
      if (seen.add(key)) result.add(e);
    }
    return result;
  }

  /// Force a reload from Firestore (used when the UI returns to the home
  /// screen so items added elsewhere show up right away).
  Future<List<PlaceItem>> reload() async {
    try {
      final snapshot = await _db.collection(_collection).get();
      final items = <PlaceItem>[];
      for (final doc in snapshot.docs) {
        try {
          items.add(PlaceItem.fromJson(doc.data()));
        } catch (_) {
          // Skip any malformed document; keep the rest.
        }
      }
      _cache = _dedupe(items);
    } catch (_) {
      _cache = const [];
    }
    _notify();
    return _cache;
  }

  /// Adds a new item to the shared store. Returns whether it was persisted.
  Future<bool> add(PlaceItem item) async {
    try {
      await _db.collection(_collection).doc(item.id).set(item.toJson());
      _cache = [..._cache, item];
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Replaces an existing item with the same id, keeping its position.
  /// Used by the admin dashboard when editing an item.
  Future<bool> update(PlaceItem item) async {
    final items = List<PlaceItem>.from(_cache);
    final index = items.indexWhere((e) => e.id == item.id);
    if (index == -1) {
      items.add(item);
    } else {
      items[index] = item;
    }
    _cache = items;
    try {
      await _db.collection(_collection).doc(item.id).set(item.toJson());
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Removes an item by id from the shared store.
  Future<bool> remove(String id) async {
    final items = List<PlaceItem>.from(_cache)
      ..removeWhere((e) => e.id == id);
    _cache = items;
    try {
      await _db.collection(_collection).doc(id).delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Converts picked image bytes into a base64 data URI (used by the admin
  /// dashboard when adding; the dashboard uploads these to Firebase Storage).
  static String toDataUri(Uint8List bytes) =>
      'data:image/jpeg;base64,${base64Encode(bytes)}';

  /// Decodes a base64 data URI back to bytes (for inline previews).
  static Uint8List memoryBytes(String dataUri) =>
      base64Decode(dataUri.split(',').last);

  /// Returns the subset of [builtIn] served by [catalogId], merging any
  /// user-added items for that category. Duplicate ids against the built-in
  /// list are dropped so the same service never shows twice.
  List<PlaceItem> forCategory(String catalogId, List<PlaceItem> builtIn) {
    final storeItems = _cache.where((e) => e.catalogId == catalogId).toList();
    final builtInIds = builtIn.map((e) => e.id).toSet();
    return [
      ...builtIn,
      ...storeItems.where((e) => !builtInIds.contains(e.id)),
    ];
  }
}
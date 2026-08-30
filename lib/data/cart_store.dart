import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/place_item_model.dart';
import 'booking_store.dart';

/// Customer-side cart backed by Firestore under the customer's own id, so the
/// same saved items ("سلاتك") follow the account. Items are added via
/// "احجز الآن" then confirmed into booking requests.
///
/// Optimized for speed and smoothness:
///  * a real-time snapshot subscription keeps [_cache] fresh in the background,
///  * mutations update the local cache + notify instantly and persist to
///    Firestore in the background (no blocking waits before the UI updates),
///  * the customer id is cached in memory after the first fetch.
class CartStore {
  CartStore._();

  static final CartStore instance = CartStore._();

  static const String _collection = 'carts';

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  List<PlaceItem> _cache = const [];
  String? _customerId;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;
  final List<VoidCallback> _listeners = [];

  /// Snapshot of the current cart items (already unique by item id).
  List<PlaceItem> get items => _cache;

  /// Starts listening to THIS customer's cart in real time. Safe to call more
  /// than once (the subscription is created only the first time).
  void init() {
    if (_sub != null) return;
    _startListening();
  }

  Future<void> _startListening() async {
    try {
      final id = await _myCartId();
      if (_sub != null) return;
      _sub = _db.collection(_collection).doc(id).snapshots().listen(
        (doc) {
          _cache = _parse(doc.data());
          _notify();
        },
        onError: (Object _) {
          // Keep the last good cache on transient network errors.
        },
      );
    } catch (_) {
      // No customer id available yet; the cart stays empty until a retry.
    }
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

  List<PlaceItem> _parse(Map<String, dynamic>? data) {
    final raw = data?['items'] as List?;
    final items = <PlaceItem>[];
    if (raw != null) {
      for (final e in raw) {
        try {
          items.add(PlaceItem.fromJson((e as Map).cast<String, dynamic>()));
        } catch (_) {
          // Skip any malformed entry; keep the rest.
        }
      }
    }
    return items;
  }

  /// Returns the cached items immediately if available, otherwise triggers a
  /// background refresh while still returning the current cache right away.
  List<PlaceItem> load() {
    if (_cache.isEmpty) unawaited(reload());
    return _cache;
  }

  /// Force a fresh fetch from Firestore (used by pull-to-refresh and the first
  /// open when the cache is empty). Also starts the real-time subscription.
  Future<List<PlaceItem>> reload() async {
    init();
    try {
      final id = await _myCartId();
      final doc = await _db.collection(_collection).doc(id).get();
      _cache = _parse(doc.data());
    } catch (_) {
      _cache = const [];
    }
    _notify();
    return _cache;
  }

  /// Adds an item optimistically: the cart updates instantly and the write is
  /// sent to Firestore in the background.
  Future<bool> add(PlaceItem item) async {
    final current = _cache;
    if (current.any((e) => e.id == item.id)) return true;
    final updated = [...current, item];
    _cache = updated;
    _notify();
    unawaited(_persist(updated));
    return true;
  }

  /// Removes an item optimistically (instant local update + background write).
  Future<bool> remove(String id) async {
    final updated = [for (final e in _cache) if (e.id != id) e];
    _cache = updated;
    _notify();
    unawaited(_persist(updated));
    return true;
  }

  /// Clears the cart optimistically.
  Future<bool> clear() {
    _cache = const [];
    _notify();
    unawaited(_persist(const []));
    return Future.value(true);
  }

  Future<void> _persist(List<PlaceItem> items) async {
    try {
      final id = await _myCartId();
      await _db.collection(_collection).doc(id).set({
        'customerId': id,
        'updatedAt': DateTime.now().toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
      });
    } catch (_) {
      // Offline / transient error: keep the optimistic local state; the
      // real-time listener re-syncs once the network is back.
    }
  }

  Future<String> _myCartId() async {
    final cached = _customerId;
    if (cached != null && cached.isNotEmpty) return cached;
    final id = await BookingStore.instance.getOrCreateCustomerId();
    _customerId = id;
    return id;
  }
}
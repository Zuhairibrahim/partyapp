import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/featured_provider.dart';

/// Real-time Firestore-backed store for the customer app's featured providers
/// strip (مقدمون مميزون). The dashboard writes to the SAME `featured`
/// collection, so as soon as an admin adds/edits/deletes a provider the
/// customer app updates immediately — no manual reload or restart needed.
class FeaturedStore {
  FeaturedStore._();

  static final FeaturedStore instance = FeaturedStore._();

  static const String _collection = 'featured';

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  List<FeaturedProvider> _cache = const [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  final List<VoidCallback> _listeners = [];

  /// Snapshot of the current featured providers in dashboard order.
  List<FeaturedProvider> get items => _cache;

  /// Starts listening to the `featured` collection. Safe to call more than
  /// once (the subscription is created only the first time).
  void init() {
    if (_sub != null) return;
    _sub = _db.collection(_collection).snapshots().listen(
      (snapshot) {
        final items = <FeaturedProvider>[];
        for (final doc in snapshot.docs) {
          try {
            items.add(FeaturedProvider.fromJson(doc.data()));
          } catch (_) {
            // Skip any malformed document; keep the rest.
          }
        }
        items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        _cache = items;
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
}
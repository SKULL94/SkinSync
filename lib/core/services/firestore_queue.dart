import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:convert';

class FirestoreQueueService {
  FirestoreQueueService._internal();
  static final FirestoreQueueService instance =
      FirestoreQueueService._internal();
  factory FirestoreQueueService() => instance;

  static const _queueKey = 'firestore_queue';
  final _firestore = FirebaseFirestore.instance;

  dynamic _serializeData(dynamic data) {
    if (data is Timestamp) {
      return {
        '__type__': 'Timestamp',
        'seconds': data.seconds,
        'nanoseconds': data.nanoseconds
      };
    }
    if (data is DateTime) {
      return {'__type__': 'DateTime', 'value': data.toIso8601String()};
    }
    if (data is Map) {
      return data.map((key, value) => MapEntry(key, _serializeData(value)));
    }
    if (data is List) {
      return data.map(_serializeData).toList();
    }
    return data;
  }

  dynamic _deserializeData(dynamic data) {
    if (data is Map && data['__type__'] == 'Timestamp') {
      return Timestamp(data['seconds'], data['nanoseconds']);
    }
    if (data is Map && data['__type__'] == 'DateTime') {
      return DateTime.parse(data['value']);
    }
    if (data is Map) {
      return data.map((key, value) => MapEntry(key, _deserializeData(value)));
    }
    if (data is List) {
      return data.map(_deserializeData).toList();
    }
    return data;
  }

  Future<void> addToQueue(
    String operation,
    String collection,
    String docId,
    dynamic data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final queueString = prefs.getString(_queueKey);
    final queue = queueString != null
        ? List<Map<String, dynamic>>.from(jsonDecode(queueString))
        : <Map<String, dynamic>>[];

    queue.add({
      'operation': operation,
      'collection': collection,
      'docId': docId,
      'data': _serializeData(data),
      'timestamp': DateTime.now().toIso8601String(),
    });

    await prefs.setString(_queueKey, jsonEncode(queue));
    _startBackgroundSync();
  }

  Future<void> processQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final queueString = prefs.getString(_queueKey);
    if (queueString == null) return;

    final queue = List<Map<String, dynamic>>.from(jsonDecode(queueString));

    for (final task in List.from(queue)) {
      try {
        final data = _deserializeData(task['data']);
        final docRef =
            _firestore.collection(task['collection']).doc(task['docId']);

        switch (task['operation']) {
          case 'set':
            await docRef.set(data, SetOptions(merge: true));
            break;
          case 'update':
            await docRef.update(data);
            break;
          default:
            debugPrint('Unknown operation: ${task['operation']}');
        }
        queue.remove(task);
      } catch (e) {
        debugPrint('Queue task failed: $e');
        if (e is FirebaseException && e.code == 'not-found') {
          await _firestore
              .collection(task['collection'])
              .doc(task['docId'])
              .set({});
        }
      }
    }
    await prefs.setString(_queueKey, jsonEncode(queue));
  }

  void _startBackgroundSync() {
    Workmanager().registerOneOffTask(
      'firestoreSync',
      'firestoreSyncTask',
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      final queue = FirestoreQueueService();
      await queue.processQueue();
      return true;
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:workmanager/workmanager.dart';

class FirestoreQueueService {
  static const _queueKey = 'firestore_queue';
  final _storage = GetStorage();
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

  void addToQueue(
      String operation, String collection, String docId, dynamic data) {
    final queue = List<Map<String, dynamic>>.from(
      _storage.read(_queueKey) ?? [],
    );
    queue.add({
      'operation': operation,
      'collection': collection,
      'docId': docId,
      'data': _serializeData(data),
      'timestamp': DateTime.now().toIso8601String(),
    });
    _storage.write(_queueKey, queue);
    _startBackgroundSync();
  }

  Future<void> processQueue() async {
    final queue = List<Map<String, dynamic>>.from(
      _storage.read(_queueKey) ?? [],
    );

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
            print('Unknown operation: ${task['operation']}');
        }
        queue.remove(task);
      } catch (e) {
        print('Queue task failed: $e');
        if (e is FirebaseException && e.code == 'not-found') {
          await _firestore
              .collection(task['collection'])
              .doc(task['docId'])
              .set({});
        }
      }
    }
    _storage.write(_queueKey, queue);
  }

  void _startBackgroundSync() {
    Workmanager().registerOneOffTask(
      'firestoreSync',
      'firestoreSyncTask',
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static void initialize() {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
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

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class Counter {
  int id;
  int value;
  Counter({this.id, this.value});
}

abstract class Database {
  Future<void> createCounter();
  Future<void> setCounter(Counter counter);
  Future<void> deleteCounter(Counter counter);
  Stream<List<Counter>> counterStream();
}

//Realtime Database
class AppDatabase implements Database {
  static final String rootPath = 'counters';

  Future<void> createCounter() async {
    int now = DateTime.now().millisecondsSinceEpoch;
    Counter counter = Counter(id: now, value: 0);
    await setCounter(counter);
  }

  Future<void> setCounter(Counter counter) async {
    DatabaseReference databaseReference = _databaseReference(counter);
    await databaseReference.set(counter.value);
  }

  Future<void> deleteCounter(Counter counter) async {
    DatabaseReference databaseReference = _databaseReference(counter);
    await databaseReference.remove();
  }

  Stream<List<Counter>> counterStream() {
    return _DatabaseStream<List<Counter>>(
      apipath: rootPath,
      parser: _DatabaseCountersParser(),
    ).stream;
  }

  DatabaseReference _databaseReference(Counter counter) {
    var path = '$rootPath/${counter.id}';
    return FirebaseDatabase.instance.reference().child(path);
  }
}

class _DatabaseStream<T> {
  Stream<T> stream;
  _DatabaseStream({String apipath, DatabaseNodeParser<T> parser}) {
    FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
    DatabaseReference databaseReference =
        firebaseDatabase.reference().child(apipath);
    var eventStream = databaseReference.onValue;
    stream = eventStream.map((event) => parser.parse(event));
  }
}

abstract class DatabaseNodeParser<T> {
  T parse(Event event);
}

///parse stream and sort the ids
class _DatabaseCountersParser implements DatabaseNodeParser<List<Counter>> {
  List<Counter> parse(Event event) {
    Map<dynamic, dynamic> values = event.snapshot.value;
    if (values != null) {
      Iterable<String> keys = values.keys.cast<String>();
      var counters = keys
          .map((key) => Counter(id: int.parse(key), value: values[key]))
          .toList();
      counters.sort((lhs, rhs) => rhs.id.compareTo(lhs.id));
      return counters;
    } else {
      return [];
    }
  }
}

class AppFirestore implements Database {

  Future<void> createCounter() async {
    int now = DateTime.now().millisecondsSinceEpoch;
    Counter counter = Counter(id: now, value: 0);
    await setCounter(counter);
  }
  Future<void> setCounter(Counter counter) async {

    _documentReference(counter).setData({
      'value' : counter.value,
    });
  }

  Future<void> deleteCounter(Counter counter) async {
    _documentReference(counter).delete();
  }

  Stream<List<Counter>> countersStream() {
    return _FirestoreStream<List<Counter>>(
      apiPath: rootPath,
      parser: FirestoreCountersParser(),
    ).stream;
  }

  DocumentReference _documentReference(Counter counter) {
    return Firestore.instance.collection(rootPath).document('${counter.id}');
  }

  static final String rootPath = 'counters';

  @override
  Stream<List<Counter>> counterStream() {
    // TODO: implement counterStream
    return null;
  }
}

abstract class FirestoreNodeParser<T> {

  T parse(QuerySnapshot querySnapshot);
}

class FirestoreCountersParser extends FirestoreNodeParser<List<Counter>> {
  List<Counter> parse(QuerySnapshot querySnapshot) {
    var counters = querySnapshot.documents.map((documentSnapshot) {
      return Counter(
        id: int.parse(documentSnapshot.documentID),
        value: documentSnapshot['value'],
      );
    }).toList();
    counters.sort((lhs, rhs) => rhs.id.compareTo(lhs.id));
    return counters;
  }
}

class _FirestoreStream<T> {
  _FirestoreStream({String apiPath, FirestoreNodeParser<T> parser}) {
    CollectionReference collectionReference = Firestore.instance.collection(apiPath);
    Stream<QuerySnapshot> snapshots = collectionReference.snapshots();
    stream = snapshots.map((snapshot) => parser.parse(snapshot));
  }

  Stream<T> stream;
}
import 'package:cloud_firestore/cloud_firestore.dart';

class DbOperations {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath;

  DbOperations({required this.collectionPath});

  factory DbOperations.fromSettings({String collectionPath = 'peaks'}) {
    return DbOperations(collectionPath: collectionPath);
  }

  Future<List<Map<String, dynamic>>> readCollection() async {
    QuerySnapshot querySnapshot =
        await _firestore.collection(collectionPath).get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<void> addElement(Map<String, dynamic> element) async {
    await _firestore.collection(collectionPath).add(element);
    print('Peak added successfully');
  }

  Future<void> removeElement(String key) async {
    await _firestore.collection(collectionPath).doc(key).delete();
    print('Peak removed successfully: $key');
  }

  Future<void> updateElement(String key, Map<String, dynamic> element) async {
    try {
      await _firestore.collection(collectionPath).doc(key).update(element);
      print('Peak updated successfully: $key');
    } catch (e) {
      print('Error updating peak: $e'); // Додайте логування
    }
  }

  Future<List<Map<String, dynamic>>> readCollectionWithKeys() async {
    QuerySnapshot querySnapshot =
        await _firestore.collection(collectionPath).get();
    return querySnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['key'] = doc.id; // Додаємо ключ до даних
      return data;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> loadByPopularTag() async {
    QuerySnapshot querySnapshot =
        await _firestore
            .collection(collectionPath)
            .where('isPopular', isEqualTo: true)
            .get();
    return querySnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['key'] = doc.id;
      return data;
    }).toList();
  }
}

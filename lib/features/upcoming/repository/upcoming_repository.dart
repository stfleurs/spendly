import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spendly/core/models/bill.dart';
import 'package:spendly/core/models/bill_template.dart';

class UpcomingRepository {
  final FirebaseFirestore _firestore;

  UpcomingRepository(this._firestore);

  // Bills
  Stream<List<Bill>> getBills(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('bills')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Bill.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> addBill(Bill bill) async {
    final data = bill.toJson();
    data.remove('id');
    await _firestore
        .collection('users')
        .doc(bill.userId)
        .collection('bills')
        .doc(bill.id)
        .set(data);
  }

  Future<void> updateBill(Bill bill) async {
    final data = bill.toJson();
    data.remove('id');
    await _firestore
        .collection('users')
        .doc(bill.userId)
        .collection('bills')
        .doc(bill.id)
        .update(data);
  }

  Future<void> deleteBill(String userId, String billId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('bills')
        .doc(billId)
        .delete();
  }

  // Bill Templates
  Stream<List<BillTemplate>> getBillTemplates(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('bill_templates')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BillTemplate.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> addBillTemplate(BillTemplate template) async {
    final data = template.toJson();
    data.remove('id');
    await _firestore
        .collection('users')
        .doc(template.userId)
        .collection('bill_templates')
        .doc(template.id)
        .set(data);
  }

  Future<void> updateBillTemplate(BillTemplate template) async {
    final data = template.toJson();
    data.remove('id');
    await _firestore
        .collection('users')
        .doc(template.userId)
        .collection('bill_templates')
        .doc(template.id)
        .update(data);
  }

  Future<void> deleteBillTemplate(String userId, String templateId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('bill_templates')
        .doc(templateId)
        .delete();
  }
}

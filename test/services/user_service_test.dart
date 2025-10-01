// test/services/user_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'user_service_test.mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avivamiento_app/services/user_service.dart';
import 'package:avivamiento_app/models/user_model.dart';

void main() {
  late UserService userService;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionReference;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollectionReference = MockCollectionReference<Map<String, dynamic>>();
    mockDocumentReference = MockDocumentReference<Map<String, dynamic>>();
    userService = UserService(mockFirestore);

    when(mockFirestore.collection('users')).thenReturn(mockCollectionReference);
    when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
  });

  test(
    'getUserProfile debería devolver un UserModel si el documento existe',
    () async {
      final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      when(mockSnapshot.exists).thenReturn(true);
      when(mockSnapshot.data()).thenReturn({
        'nombre': 'Test User',
        'email': 'test@test.com',
        'rol': 'Miembro',
        'fechaRegistro': Timestamp.now(),
      });
      when(mockSnapshot.id).thenReturn('123');
      when(mockDocumentReference.get()).thenAnswer((_) async => mockSnapshot);

      final user = await userService.getUserProfile('123');

      expect(user, isA<UserModel>());
      expect(user?.nombre, 'Test User');
    },
  );
}

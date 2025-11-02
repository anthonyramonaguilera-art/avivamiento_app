// test/services/auth_service_test.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Importa el servicio que vamos a probar.
import 'package:avivamiento_app/services/auth_service.dart'; // Importa el archivo de mocks que generamos.
import 'auth_service_test.mocks.dart';

// Esta anotación le dice a la herramienta `build_runner` que cree un mock
// para la clase FirebaseAuth. Esto nos permite simular su comportamiento.
@GenerateMocks([FirebaseAuth])
void main() {
  // "group" nos permite agrupar pruebas relacionadas.
  group('AuthService Unit Tests', () {
    // Declaramos las variables que usaremos en las pruebas.
    late MockFirebaseAuth mockFirebaseAuth;
    late AuthService authService;

    // "setUp" es una función especial que se ejecuta ANTES de cada prueba.
    // Es el lugar perfecto para inicializar nuestros objetos.
    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      authService = AuthService(mockFirebaseAuth);
    });

    // "test" define un caso de prueba individual.
    test('signOut llama a signOut de FirebaseAuth', () async {
      // Arrange: Preparamos el escenario.
      // Le decimos al mock que cuando se llame a `signOut`, no debe hacer nada y devolver un Future completado.
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async => {});

      // Act: Ejecutamos la acción que queremos probar.
      await authService.signOut();

      // Assert: Verificamos que el resultado es el esperado.
      // Comprobamos que el método `signOut` de nuestro mock fue llamado exactamente una vez.
      verify(mockFirebaseAuth.signOut()).called(1);
    });

    test('signInAnonymously funciona correctamente', () async {
      // Arrange: Preparamos el escenario para el login anónimo.
      // Aquí necesitamos simular un UserCredential y un User, ya que son las respuestas esperadas.
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();

      // Cuando se llame a signInAnonymously en el mock, devolverá el mockUserCredential.
      when(
        mockFirebaseAuth.signInAnonymously(),
      ).thenAnswer((_) async => mockUserCredential);
      // Cuando se acceda a la propiedad 'user' del mockUserCredential, devolverá nuestro mockUser.
      when(mockUserCredential.user).thenReturn(mockUser);
      assert(
        mockUserCredential.user != null,
        'El mockUserCredential.user es null',
      );
      // Finalmente, cuando se acceda a la propiedad 'uid' del mockUser, devolverá un ID falso.
      when<String>(mockUser.uid).thenReturn('test_uid_anonimo');

      // Act: Llamamos a nuestro método.
      final result = await authService.signInAnonymously();

      // Assert: Verificamos que el resultado es el UID que definimos en el mock.
      expect(result, 'test_uid_anonimo');
    });
  });
}

// Creamos clases Mock adicionales que no se generan automáticamente
// porque son el resultado de otros métodos.
class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {
  @override
  String get uid => super.noSuchMethod(
    Invocation.getter(#uid),
    returnValue: 'test_uid_anonimo',
    returnValueForMissingStub: 'test_uid_anonimo',
  );
}

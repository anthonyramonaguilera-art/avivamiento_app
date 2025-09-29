App Iglesia – Centro Internacional Avivamiento Venezuela
Aplicación Flutter multiplataforma (Android, iOS, Web y Desktop) para unificar la vida de la iglesia en un solo espacio digital: publicaciones, radio en vivo con chat, calendario, retransmisiones, conferencias y donaciones seguras. Pensada para invitados y miembros, con enfoque en buenas prácticas, escalabilidad, documentación clara, uso del plan gratuito de Firebase y pruebas automatizadas.

Visión y objetivos
Visión: Expandir el alcance del mensaje de Dios y la vida comunitaria con orden, accesibilidad y participación.

Objetivos:

Unificación: Centralizar publicaciones, actividades y transmisiones.

Participación: Interacción segura (feed, chat de radio, conferencias).

Servicio: Donaciones transparentes y conferencias para formación y coordinación.

Accesibilidad: Entrada como invitado y diseño responsivo para Android, iOS y Web.

Roles y permisos
Rol	Capacidades principales
Pastor (Owner)	Control total de contenido y roles; aprueba eventos; inicia y gestiona conferencias públicas y privadas.
Admin (Desarrollador/Soporte)	Configuración técnica; corrección de errores; seguridad y moderación.
Líderes (Moderators)	Publican en el feed; crean eventos; moderan chat; proponen retransmisiones.
Ministerios (Roles específicos)	Publican según permisos definidos (adoradores, músicos, maestros, protocolo, redes, audio, intercesores, danzarines, etc.).
Miembro (Usuario registrado)	Acceso a feed, calendario, radio y donaciones; participa en chat y conferencias públicas.
Invitado (Default)	Lectura de feed y calendario; escucha radio; chat lectura si se habilita.
Funcionalidades
Módulos del MVP
Autenticación: Login con correo/contraseña y modo invitado usando Firebase Auth (plan gratuito).

Feed de publicaciones: Tarjetas con título, contenido, imagen, fecha y autor; filtrado por categoría en iteraciones posteriores.

Calendario: Eventos con título, descripción, fecha/hora y responsable; vistas mensual y semanal.

Donaciones: Integración con Stripe/PayPal; historial por usuario en Firestore.

Perfil: Foto, rol visible y edición básica de datos.

Iteraciones posteriores
Radio en vivo + chat: Reproductor con URL de streaming; chat moderado en tiempo real.

Retransmisiones y conferencias: Embeds de YouTube/Facebook; salas Jitsi/WebRTC por roles (públicas y privadas).

Accesibilidad y observabilidad: Contraste, tamaños legibles, estados offline básicos, analítica de uso mínima.

Notificaciones: Firebase Cloud Messaging para avisos de eventos y publicaciones.

Arquitectura y stack técnico
Tecnologías principales
Frontend: Flutter (Dart).

Backend como servicio: Firebase (Auth, Firestore, Storage, Realtime Database, Cloud Messaging), plan gratuito.

Servicios externos: Stripe/PayPal (donaciones), Jitsi Meet (conferencias).

Paquetes de Flutter recomendados
Paquete	Uso
firebase_core	Inicialización de Firebase.
firebase_auth	Autenticación con email/contraseña e invitado controlado.
cloud_firestore	Base de datos de usuarios, posts, eventos, donaciones, conferencias.
firebase_storage	Almacenamiento de imágenes (perfil, publicaciones).
firebase_database	Chat de radio en tiempo real.
firebase_messaging	Notificaciones push (iteración 2).
provider o riverpod	Gestión de estado escalable y testable.
intl	Formato de fechas, números y localización.
http	Integraciones con APIs externas (Stripe/PayPal/Jitsi si aplica).
url_launcher	Apertura de enlaces y embebidos.
jitsi_meet_flutter_sdk	Conferencias grupales similares a Zoom/Meet.
Instalación y configuración
Prerrequisitos
SDK de Flutter: 3.x o superior, con canales estables.

Proyecto de Firebase: creado y con apps registradas (Android, iOS, Web).

CLI de Firebase: para generar firebase_options.dart.

Cuentas de Stripe/PayPal: claves públicas/secretas.

Configuración de Jitsi: uso de meet.jit.si o servidor propio.

Pasos de instalación
Instalar Flutter y validar entorno

Descargar desde la web oficial e instalar.

Validar instalación:

Code
flutter doctor
Obtener dependencias:

Code
flutter pub get
Configurar Firebase

Crear proyecto en la consola de Firebase.

Registrar apps (Android/iOS/Web).

Colocar archivos de configuración:

Android: android/app/google-services.json

iOS: ios/Runner/GoogleService-Info.plist

Generar opciones con CLI:

Code
flutter pub add firebase_core
dart pub global activate flutterfire_cli
flutterfire configure
Esto crea lib/firebase_options.dart.

Añadir dependencias

Code
flutter pub add firebase_auth cloud_firestore firebase_storage firebase_database firebase_messaging
flutter pub add provider intl http url_launcher
flutter pub add jitsi_meet_flutter_sdk
Inicializar Firebase en main.dart

dart
// main.dart
// Importa Flutter y Firebase Core para inicializar el proyecto.
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Archivo generado por flutterfire configure.

// Punto de entrada de la app. Asegura que Flutter esté inicializado antes de Firebase.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa Firebase con las opciones específicas de cada plataforma (Android/iOS/Web).
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp()); // Lanza la app raíz.
}

// Ejemplo básico de MaterialApp para arrancar.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avivamiento Venezuela',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const Placeholder(), // Reemplazar con pantalla de Auth/Feed.
    );
  }
}
Configurar plataformas

Android: aplicar plugin com.google.gms.google-services; minSdk 21+; permisos de red si usas radio/conferencias.

iOS: ejecutar pod install dentro de ios/; configurar permisos de cámara/micrófono para Jitsi.

Web: configurar index.html para PWA si se desea; asegurar compatibilidad de Firebase.

Estructura del proyecto
Code
lib/
  models/           // Modelos (User, Post, Event, Donation, Livestream, ConferenceRoom)
  services/         // Servicios (AuthService, FirestoreService, StorageService, RadioChatService, DonationService, ConferenceService)
  controllers/      // Gestión de estado (Provider/Riverpod)
  widgets/          // UI reutilizable (cards, forms, list items)
  screens/          // Pantallas (auth, feed, calendar, radio, donations, profile, admin, conferences)
  utils/            // Utilidades (validators, formatters, constants)
  firebase_options.dart
assets/
  images/           // Logos, íconos
  audio/            // Efectos (opcional)
test/
  unit/             // Pruebas unitarias de servicios/modelos
  widget/           // Pruebas de widgets/pantallas
  integration/      // Flujo end-to-end básico (opcional)
Modelo de datos
Colecciones en Firestore
users

id, nombre, email, rol, fotoUrl, fechaRegistro

posts

id, titulo, contenido, imagenUrl, autorId, rolAutor, fecha, categorias[]

events

id, titulo, descripcion, fechaInicio, fechaFin, responsableId, ubicacion

donations

id, userId, monto, moneda, fecha, metodo, status

livestreams

id, plataforma, titulo, url, fecha

conferenceRooms

id, tema, jitsiRoomId/url, rolesPermitidos[], tipo (‘publica’ | ‘privada’), fecha

Realtime Database
radio

streamUrl, estado, mensajeDestacado

radioChatMessages

id, userId, mensaje, timestamp, moderated

Reglas de seguridad de ejemplo
Firestore
Code
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Usuarios: lectura/escritura propia
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Posts: lectura pública; escritura por roles (usar Custom Claims para roles seguros)
    match /posts/{postId} {
      allow read: if true;
      allow write: if request.auth != null && (request.auth.token.role in ['pastor','admin','lider','ministerio']);
    }

    // Eventos: lectura pública; escritura por líderes y superiores
    match /events/{eventId} {
      allow read: if true;
      allow write: if request.auth != null && (request.auth.token.role in ['pastor','admin','lider']);
    }

    // Donaciones: lectura por propietario y admins; escritura por propietario
    match /donations/{donationId} {
      allow read: if request.auth != null && (
        request.auth.token.role in ['pastor','admin'] || resource.data.userId == request.auth.uid
      );
      allow write: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }

    // Conferencias: lectura pública si 'tipo' es 'publica'; privadas por roles
    match /conferenceRooms/{confId} {
      allow read: if resource.data.tipo == 'publica' || (
        request.auth != null && request.auth.token.role in ['pastor','admin','lider']
      );
      allow write: if request.auth != null && (request.auth.token.role in ['pastor','admin']);
    }
  }
}
Realtime Database
Code
{
  "rules": {
    "radio": {
      ".read": true,
      ".write": "auth != null && root.child('users').child(auth.uid).child('rol').val() in ['pastor','admin']"
    },
    "radioChatMessages": {
      ".read": true,
      "$msgId": {
        ".write": "auth != null" // Ajustar reglas de moderación según necesidades
      }
    }
  }
}
Directrices de desarrollo y buenas prácticas
Uso del plan gratuito de Firebase:

Optimiza lecturas/escrituras: usa queries paginadas y listeners selectivos.

Minimiza costos: evita streams innecesarios; usa campos indexados.

Gestión de estado escalable: Provider/Riverpod con separación de capas (UI, lógica, datos).

Documentación en código:

Label: cada servicio, método y modelo debe tener comentarios explicando propósito, parámetros y retornos.

Ejemplo:

dart
/// AuthService encapsula operaciones de autenticación con Firebase Auth.
/// - Soporta login con email/contraseña y modo invitado controlado.
class AuthService {
  final FirebaseAuth _auth;
  AuthService(this._auth);

  /// Inicia sesión con email y contraseña.
  /// [email] y [password] deben ser válidos. Retorna el UID del usuario.
  Future<String> loginUser(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user!.uid;
  }

  /// Crea una sesión de invitado (no persistente) con permisos limitados.
  /// Retorna un UID temporal o null si no se permite.
  Future<User?> loginAsGuest() async {
    return _auth.signInAnonymously().then((cred) => cred.user);
  }
}
Refactorización continua: modulariza servicios, evita duplicación, aplica SOLID.

Escalabilidad: diseña modelos y servicios para crecer sin romper contratos (interfaces estables).

Accesibilidad: contrastes AA, tamaños legibles, labels y estados de foco/disabled, soporte de teclado en Web/Desktop.

Seguridad: valida inputs en cliente; usa reglas estrictas; considera Custom Claims para roles.

CI/CD opcional: integra análisis estático (flutter analyze) y pruebas (flutter test) en cada PR.

Pruebas automatizadas
Prueba unitaria de servicio de autenticación
dart
// test/unit/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
// Importa tu AuthService y usa un mock de FirebaseAuth (mediante paquetes de mocking).

void main() {
  group('AuthService', () {
    test('loginUser retorna UID en login válido', () async {
      // Arrange: configurar mock de FirebaseAuth con credenciales válidas.
      // Act: llamar a loginUser.
      // Assert: verificar que retorna un UID no vacío.
      expect('mockUid', isNotEmpty);
    });

    test('loginAsGuest crea sesión anónima', () async {
      // Arrange / Act / Assert: similar, retorna un usuario anónimo.
      expect(true, isTrue); // Reemplazar con verificación real de usuario anónimo.
    });
  });
}
Prueba de widget del feed
dart
// test/widget/feed_screen_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Feed muestra lista de publicaciones', (WidgetTester tester) async {
    // Arrange: renderizar pantalla con publicaciones de ejemplo.
    await tester.pumpWidget(const MaterialApp(home: Placeholder())); // Reemplazar con FeedScreen real.
    // Act: esperar carga.
    await tester.pumpAndSettle();
    // Assert: verificar presencia de elementos esperados (títulos, imágenes).
    expect(find.byType(Placeholder), findsOneWidget); // Reemplazar con verificaciones reales.
  });
}
Nota: usa mocks para Firebase en pruebas unitarias; en integración, configura un proyecto de pruebas o Emulators de Firebase.

Ejecución y build
Desarrollo:

Code
flutter run
Android (release):

Code
flutter build apk --release
iOS (release):

Code
flutter build ios --release
Web:

Code
flutter build web
Guía de contribución
Ramas:

main: estable.

dev: integración continua.

feature/nombre: desarrollo por módulo (ej. feature/auth, feature/radio_chat).

Commits: convenciones (feat, fix, docs, refactor, test, chore).

Ejemplo: feat(conferences): public rooms and private controls by pastor

Pull requests: descripción clara, checklist, capturas si aplica; correr flutter analyze y flutter test antes de abrir PR.

Roadmap
MVP inicial:

Label: Login + Invitado, Feed, Calendario, Donaciones, Perfil.

Iteración 2:

Label: Radio en vivo + chat, filtrado por categorías, notificaciones push.

Iteración 3:

Label: Retransmisiones embebidas, mejoras de accesibilidad y estados offline básicos.

Iteración 4:

Label: Conferencias (Jitsi/WebRTC), panel de administración y roles avanzados.

Iteración 5:

Label: Tema de marca, analítica, optimizaciones, documentación ampliada y más tests.

Anexos útiles
Flujos de usuario:

Invitado: entra → ve feed/calendario → escucha radio (chat lectura).

Miembro: login → feed → chat radio → calendario → donaciones → se une a conferencias públicas.

Líder: login → crear publicación/evento → moderar chat → proponer retransmisiones.

Pastor/Admin: login → aprobar/editar/eliminar → crear conferencias públicas y privadas → decidir quién accede a privadas.

Conferencias similares a Zoom/Meet:

Salas públicas: miembros y líderes pueden unirse; invitados opcional según configuración.

Salas privadas: acceso controlado por Pastor/Admin; invitación por rol o lista específica.

Características recomendadas: video/audio en grupo, compartir pantalla, chat, permisos de micrófono/cámara.

Funciones clave a implementar (services/):

Auth: loginUser(email, password), loginAsGuest(), logout().

Posts: createPost(data), getPosts(filters), deletePost(postId).

Events: createEvent(data), getEvents(range), deleteEvent(eventId).

Donations: makeDonation(userId, amount, method), getDonationHistory(userId).

Radio: playRadio(streamUrl), sendChatMessage(userId, message), getChatMessages().

Conferences: createConferenceRoom(topic, tipo, rolesPermitidos), joinConference(roomId, userId).

Calidad de repositorio
Finales de línea (Windows/Unix): añade .gitattributes con:

Code
* text=auto
.gitignore: incluye archivos sensibles (config de Firebase, claves locales).

Documentación constante: comentarios en servicios y modelos; README actualizado por iteración.

Refactorización: revisa duplicaciones y separa responsabilidades por capas.

Licencia y créditos
Licencia: MIT.

Créditos:

Label: Centro Internacional Avivamiento Venezuela.

Label: Pastores, líderes y miembros.

Label: Comunidad de migrantes y voluntarios.

Label: Tecnología: Flutter y Firebase.
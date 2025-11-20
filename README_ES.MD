📱 App Iglesia – Centro Internacional Avivamiento Venezuela
🙌 Descripción

La App Avivamiento de la iglesia Centro Internacional Avivamiento Venezuela es una aplicación multiplataforma (Android, iOS, Web y Desktop) desarrollada en Flutter que busca unificar la vida comunitaria de la iglesia en un solo espacio digital. Actualmente, muchos miembros están dispersos en diversas redes sociales que algunos no saben usar o simplemente no utilizan. Con esta app, centralizamos todo el contenido y permitimos que invitados externos conozcan lo que hacemos en el Centro Internacional Avivamiento Venezuela.
🎯 Visión y Objetivos

    Expandir la comunidad del Centro Internacional Avivamiento Venezuela.

    Hacer accesible el mensaje de Dios y su bondad a cualquier persona.

    Unificar a todos los miembros en un solo espacio digital.

    Permitir experiencias interactivas: escuchar la radio en directo, participar en chats y realizar conferencias grupales entre pastores y líderes.

👥 Usuarios y Roles

    Pastor (Owner): Control total de la app y toma de decisiones.

    Admin (Desarrollador/Soporte): Administración técnica y soporte.

    Líderes (Moderators): Publican mensajes, gestionan actividades y moderan.

    Ministerios: Roles específicos (adoradores, músicos, maestros, protocolo, redes, audio, intercesores, danzarines, etc.).

    Miembro: Usuario registrado con acceso al feed, calendario, radio y donaciones.

    Invitado: Acceso limitado al feed y calendario.

✨ Funcionalidades (MVP y más allá)

    🔐 Autenticación: Login con correo/contraseña y modo invitado.

    📰 Feed de publicaciones: Tarjetas con título, contenido, imagen y autor.

    📅 Calendario: Eventos con vistas mensual y semanal.

    📻 Radio en vivo + chat: Streaming con interacción moderada en tiempo real.

    🎥 Retransmisiones: Embeds de YouTube/Facebook.

    📞 Conferencias: Salas grupales vía Jitsi/WebRTC.

    💳 Donaciones seguras: Stripe/PayPal con historial por usuario.

    👤 Perfil de usuario: Foto, rol visible y edición básica.

🛠️ Evolución Técnica del Proyecto
🔹 Fase Firebase (MVP inicial)

    Auth: Firebase Auth (login + invitado).

    DB: Firestore (colecciones: users, posts, events, donations, livestreams, conferenceRooms).

    Storage: Firebase Storage para imágenes.

    Realtime Database: Chat de radio en vivo.

    Mensajería: Firebase Cloud Messaging para notificaciones.

🔹 Refundación AWS (Arquitectura Serverless)

Tras un análisis de costos y escalabilidad, se decidió migrar de Firebase a AWS Serverless.

Nuevo Stack:

    Frontend: Flutter (Android, iOS, Web).

    Autenticación: Amazon Cognito (User Pools & Identity Pools).

    Base de Datos: Amazon DynamoDB (Single-Table Design).

    Almacenamiento: Amazon S3 con URLs Prefirmadas para subida segura.

    Backend: AWS Lambda (Python/Node.js).

    API: Amazon API Gateway con autorización Cognito.

    Observabilidad: CloudWatch (logs, métricas, alarmas).

    (Futuro) IA: Amazon Bedrock (Claude 3, Titan) + OpenSearch Serverless (Vector Engine) para búsquedas semánticas y RAG.

Principios arquitectónicos:

    Serverless-First: Toda la lógica vive en Lambdas.

    Seguridad de mínimo privilegio: Cada Lambda con su propio rol IAM.

    Infraestructura como Código: Diseño pensando en AWS CDK/Terraform.

    Single-Table Design en DynamoDB: Todas las entidades (users, posts, events, donations, chatMessages) en una sola tabla.

🚀 Roadmap

    MVP inicial (Firebase): Login + Invitado, Feed, Calendario, Donaciones.

    Iteración 2: Radio en vivo + chat, notificaciones push.

    Iteración 3: Retransmisiones embebidas, mejoras de accesibilidad.

    Iteración 4: Conferencias (Jitsi/WebRTC), panel de administración.

    Iteración 5: Tema de marca, analítica, optimizaciones, documentación ampliada.

    Refundación AWS (en progreso): Migración completa de Auth, DB y Storage a AWS Serverless.

📂 Documentación

    PRD.md: Documento de requisitos del producto.

    PRD-BD-AVIVAMIENTOAP.docx: Plano de ingeniería AWS Serverless.

    README_ES.md: Arquitectura AWS y roadmap de migración.

    README.md (este archivo): Presentación consolidada del proyecto.

🤝 Contribución

Este proyecto es un legado comunitario y una oportunidad de aprendizaje en Cloud Engineering y Flutter. Buscamos colaboradores en:

    Arquitectura Serverless en AWS.

    Diseño avanzado de DynamoDB.

    Desarrollo de microservicios de IA.

    Documentación y pruebas automatizadas.

📜 Licencia

MIT License – Uso, modificación y distribución libre, siempre con fines de expansión del Reino de Dios y beneficio comunitario.
🙏 Créditos

    Centro Internacional Avivamiento Venezuela

    Pastores, líderes y miembros que inspiran este proyecto.

    Comunidad de migrantes y voluntarios que aportan ideas y necesidades.

    Tecnología: Flutter, Firebase (MVP inicial), AWS Serverless (refundación).

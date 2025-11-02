PRD (Product Requirements Document o Documento de Requisitos del Producto) de la app de iglesia Centro Internacional Avivamiento Venezuela


Resumen ejecutivo
Propósito: Unificar a la comunidad de la iglesia en un solo espacio digital, simplificando el acceso a contenido y actividades para quienes no usan todas las redes sociales.

Alcance: Mostrar el mensaje y la vida comunitaria del Centro Internacional Avivamiento Venezuela a miembros e invitados, con acceso a publicaciones, radio en vivo, calendario, retransmisiones, conferencias y donaciones.

Valor: Reduce la dispersión de contenido, mejora la participación y facilita la comunicación y el apoyo económico a la obra.

Visión y objetivos
Visión: Expandir el alcance del mensaje de Dios y la comunidad del Centro Internacional Avivamiento Venezuela de manera accesible, ordenada y participativa.

Objetivos:

Unificación: Centralizar publicaciones, actividades y transmisiones.

Participación: Habilitar interacción segura (feed, chat en radio).

Servicio: Facilitar donaciones transparentes y /o anonimas si el donador asi lo prefiere,y conferencias grupales para formación y coordinación.

Accesibilidad: Permitir entrada como invitado y diseño responsivo para Android, iOS y Web.

Usuarios y roles
Pastor (Owner): Control total. Crea/edita/elimina contenido, gestiona roles, aprueba eventos, inicia conferencias.

Admin (Desarrollador/Soporte): Administración técnica y operativa. Configura servicios, corrige errores, gestiona moderación y seguridad.

Líderes (Moderators): Publican en el feed, crean eventos, proponen retransmisiones, moderan chat.

Ministerios (Roles específicos): Adoradores, maestros, músicos, protocolo, redes, audio, intercesores, danzarines, etc. Publican según permisos definidos por el Pastor/Admin.

Miembro (Usuario registrado): Accede al feed, calendario, radio y donaciones; participa en chat según reglas.

Invitado (Default): Acceso de lectura a feed y calendario; sin publicar ni chatear (o chat sólo lectura si se habilita).

Requisitos funcionales
Autenticación:

Login con correo/contraseña (Firebase Auth).

Acceso como invitado sin registro.

Feed de publicaciones (Firestore):

Tarjetas con título, contenido, imagen opcional, fecha y autor.

Filtrado por categoría/ministerio (opcional en iteración 2).

Mi perfil:

Foto de perfil (Storage).

Rol de usuario visible (Adorador, Redes Sociales, Predicador, etc.).

Edición de datos básicos; permisos en función del rol.

Radio en vivo + chat:

Reproductor con URL de streaming.

Chat en tiempo real (Realtime Database) con moderación básica.

Transmisiones en vivo:

Lista de retransmisiones (YouTube/Facebook/otros) en un solo lugar.

Visualización embebida cuando sea posible.

Calendario de actividades:

Eventos con título, descripción, fecha/hora y responsable.

Vistas mensual/semanal; notificaciones push (iteración 2).

Conferencias (Jitsi/WebRTC):

Salas de videollamadas grupales según rol o invitación.

Acceso moderado por Pastor/Admin.

Donaciones (Stripe/PayPal):

Formulario de donación segura.

Registro de historial por usuario en Firestore.

Requisitos no funcionales
Responsividad: Compatible con Android, iOS y Web.

Seguridad: Reglas de seguridad de Firebase por rol; validación de entrada.

Escalabilidad: Objetivo 500+ usuarios simultáneos; mejorar según métricas reales.

Disponibilidad: Manejo de errores y estados offline básicos (iteración 2).

Privacidad: Manejo responsable de datos personales; política visible.

Accesibilidad: Contraste adecuado, tamaños legibles, etiquetas y estados (iteración 2).

Observabilidad: Logs mínimos y analítica de uso para priorizar mejoras (iteración 2).

Modelo de datos (vista general)
users

id, nombre, email, rol, fotoUrl, fechaRegistro

posts

id, titulo, contenido, imagenUrl, autorId, rolAutor, fecha, categorias[]

events

id, titulo, descripcion, fechaInicio, fechaFin, responsableId, ubicacion

radio

streamUrl, estado, mensajeDestacado

radioChatMessages

id, userId, mensaje, timestamp, moderated

livestreams

id, plataforma, titulo, url, fecha

donations

id, userId, monto, moneda, fecha, metodo, status

conferenceRooms

id, tema, jitsiRoomId/url, rolesPermitidos[], fecha

Flujos de usuario
Invitado:

Abre app → “Entrar como invitado” → ve feed → abre calendario → puede escuchar radio (chat lectura).

Miembro registrado:

Login → ve feed → puede comentar en chat de radio → consultar calendario → realizar donaciones.

Líder:

Login → crear publicación → crear evento → moderar chat.

Pastor/Admin:

Login → aprobar/editar/eliminar contenidos → crear conferencias → asignar roles.

Criterios de aceptación
Acceso invitado: Puede ver feed y calendario sin crear cuenta.

Eventos en tiempo real: Pastor/Líder crea evento y aparece de inmediato en calendario.

Donación registrada: Al completar pago, se guarda en Firestore con fecha, monto, usuario y estado.

Radio con chat: Reproductor funciona; mensajes aparecen en tiempo real; moderación puede ocultar un mensaje.

Perfil: Usuario puede ver/editar su perfil y ver su rol; permisos se aplican según rol.

Roadmap de MVP e iteraciones
MVP (Primera entrega):

Login + invitado, feed, calendario, donaciones básicas, perfil básico.

Iteración 2:

Radio en vivo + chat, filtrado por categorías en feed, notificaciones push.

Iteración 3:

Retransmisiones embebidas, mejoras de accesibilidad y estados offline.

Iteración 4:

Conferencias (Jitsi/WebRTC), panel de administración de roles.

Iteración 5:

Estética avanzada (tema de marca), analítica, optimizaciones y documentación ampliada.

Gobernanza, privacidad y moderación
Gobernanza: Pastor define lineamientos; Admin mantiene infraestructura; Líderes operan contenidos.

Moderación: Reglas comunitarias visibles; herramientas para ocultar/bloquear mensajes y usuarios en chat.

Privacidad: Aviso de privacidad y términos de uso accesibles; datos mínimos necesarios; manejo de donaciones conforme a la pasarela elegida.

Transparencia: Historial de cambios en eventos y publicaciones (iteración futura).

Instalación y documentos del repositorio
README.md: Guía de instalación, uso y contribución.

PRD.md: Este documento; requisitos y criterios de aceptación.

MVP-Roadmap.md: Lista de tareas por iteración con estados.

CONTRIBUTING.md: Normas para colaborar (commits, ramas, PRs).

.env / firebase_options.dart: Configuración segura (no exponer llaves en público).
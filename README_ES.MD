# 📱 App Iglesia – Centro Internacional Avivamiento Venezuela (Arquitectura AWS)

## 🙌 Descripción
Esta aplicación unifica a los miembros de la iglesia y expande nuestro alcance digital. Tras completar nuestro MVP inicial, el proyecto ha entrado en una fase de **refundación arquitectónica**, migrando de una plataforma BaaS (Firebase) a una pila **Serverless robusta, escalable y segura sobre Amazon Web Services (AWS)**.

---

## 🏗️ Arquitectura Técnica (El Nuevo Stack)
Esta aplicación está construida con una mentalidad de "Infraestructura como Código" y separación de responsabilidades.

* **Frontend:** Flutter (iOS, Android, Web)
* **Autenticación:** Amazon Cognito (User Pools & Identity Pools)
* **Base de Datos:** Amazon DynamoDB (NoSQL Serverless)
* **Almacenamiento de Archivos:** Amazon S3 (Simple Storage Service)
* **Backend (Lógica de Negocio):** AWS Lambda (Funciones Serverless en Python/Node.js)
* **API:** Amazon API Gateway (Endpoints RESTful seguros)
* **(Futuro) IA & RAG:** Amazon Bedrock (Modelos de IA) y Amazon OpenSearch (Base de Datos Vectorial)

---

## 🚀 Roadmap de Infraestructura y Features


1.  **Fase 1: Fundación AWS (En Progreso)**
    * [X] **Almacenamiento:** Implementar subida segura a S3 (con URLs Prefirmadas generadas por Lambda).
    * [ ] **Autenticación:** Migrar usuarios y lógica de Firebase Auth a Amazon Cognito.
    * [ ] **Base de Datos:** Diseñar y migrar esquemas de Firestore a tablas de Amazon DynamoDB.
    * [ ] **API Backend:** Desplegar los primeros endpoints (Lambda + API Gateway) para gestionar posts y usuarios.

2.  **Fase 2: Paridad de Funcionalidad**
    * [ ] **Feed:** Reconstruir el feed sobre la nueva API (DynamoDB + S3).
    * [ ] **Radio y Chat:** Migrar Realtime Database a DynamoDB (para chat) o a un servicio como AWS IoT Core (para WebSockets).
    * [ ] **Calendario y Donaciones:** Reimplementar la lógica de negocio en funciones Lambda.

3.  **Fase 3: Expansión y Modernización (IA)**
    * [ ] **Microservicio de IA:** Desarrollar un backend RAG (Retrieval-Augmented Generation) en Python (FastAPI/Lambda).
    * [ ] **Base de Datos Vectorial:** Implementar Amazon OpenSearch Serverless para indexar sermones y documentos.
    * [ ] **Modelos de IA:** Integrar Amazon Bedrock (ej. Claude 3) para responder preguntas sobre la Biblia o la iglesia.

---

## 🤝 Contribución
Este proyecto es un **legado comunitario** y ahora también una **oportunidad de aprendizaje de alto nivel en Cloud Engineering**.

Buscamos colaboradores interesados en:
* Arquitectura Serverless en AWS.
* Diseño avanzado de DynamoDB.
* Gestión de infraestructura (Terraform/CDK - *opcional*).
* Desarrollo de microservicios de IA.

(El resto de secciones: Licencia, Créditos... pueden permanecer similares)
# Hirafi - Application Mobile de Mise en Relation Artisans

Hirafi est une plateforme complète permettant de connecter des demandeurs de services avec des artisans qualifiés (plombiers, électriciens, menuisiers, etc.).

## Architecture
- **Backend**: Spring Boot 3.2, Spring Security (JWT), Spring Data JPA, MySQL 8.0.
- **Frontend**: Flutter (Mobile), State Management (Provider), Networking (Dio).

## Fonctionnalités
- **Utilisateur (Client)**: Recherche d'artisans, suivi de publications, envoi de demandes de service.
- **Artisan (Worker)**: Publication de réalisations, gestion de portfolio, réception et gestion des demandes.
- **Admin**: Validation des artisans, modération des contenus, statistiques globales.

## Installation et Démarrage

### 1. Base de données
- Créez une base de données MySQL nommée `hirafi_db`.
- Utilisez le script fourni dans `hirafi-backend/src/main/resources/schema.sql`.

### 2. Backend (Spring Boot)
- Assurez-vous d'avoir JDK 17 installé.
- Modifiez `src/main/resources/application.properties` avec vos identifiants MySQL.
- Lancez l'application via votre IDE (HirafiApplication) ou via Maven:
  ```bash
  mvn spring-boot:run
  ```

### 3. Frontend (Flutter)
- Naviguez vers le dossier `hirafi_frontend`.
- Installez les dépendances:
  ```bash
  flutter pub get
  ```
- Pour tester sur un émulateur, vérifiez l'adresse IP dans `lib/core/constants/api_constants.dart`.
- Lancez l'application:
  ```bash
  flutter run
  ```

## Variables d'Environnement
- `app.jwt.secret`: Clé secrète pour les tokens JWT (Backend).
- `app.upload.dir`: Dossier de stockage des images (Backend).

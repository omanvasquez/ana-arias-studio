<div align="center">

  <img src="assets/images/logo.png" alt="Ana Arias Studio Logo" width="120" height="120" style="border-radius: 24px; box-shadow: 0 4px 20px rgba(0,0,0,0.1);" />

  # Ana Arias Studio

  ### Sistema Clínico de Fichas, Sesiones y Consentimiento Digital · MVP Fase 1

  [![Flutter](https://img.shields.io/badge/Flutter-3.x_PWA-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-Spark_Free-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
  [![Riverpod](https://img.shields.io/badge/State-Riverpod_Feature--First-blueviolet?style=for-the-badge)](https://riverpod.dev)
  [![Production](https://img.shields.io/badge/Deploy-Hosting_Live-success?style=for-the-badge)](https://ana-arias-studio.web.app)

  **[🌐 Ver Aplicación en Producción](https://ana-arias-studio.web.app)** · **[📂 Repositorio en GitHub](https://github.com/omanvasquez/ana-arias-studio)**

</div>

---

## 📋 Descripción del Proyecto

**Ana Arias Studio** es una Progressive Web App (PWA) de alto rendimiento diseñada para digitalizar y centralizar al 100% la operación clínica de estética y micropigmentación del estudio.

La aplicación opera bajo un **modelo de uso centralizado**:
* **Uso exclusivo del personal administrativo:** La administradora gestiona la agenda, fichas de clientes, historial cronológico de sesiones y diagnósticos.
* **Interacción del cliente:** El cliente/paciente **únicamente interactúa con el dispositivo al momento de firmar su consentimiento** en la pantalla táctil mediante el **Modo Kiosco**.

---

## 🎯 Alcance y Funcionalidades (Fase 1)

### 1. Fichas de Clientes & Alertas Médicas
* **Directorio Reactivo:** Buscador en tiempo real por nombre, teléfono o correo electrónico.
* **Alertas Médicas Estandarizadas:** Formulario estricto con switches booleanos para condiciones clave:
  * Embarazo y lactancia
  * Hipertensión y diabetes
  * Tendencia a cicatrización queloide
  * Alergias conocidas a pigmentos o anestésicos
  * Tratamiento con anticoagulantes
  * Afecciones activas en la zona de la piel
* **Regla de Oro:** **Cero texto libre para datos técnicos**. Solo opciones estructuradas para garantizar coherencia clínica.

### 2. Bloqueo de Seguridad Médica (*Hard Block*)
* El sistema valida en tiempo real la compatibilidad entre el historial médico del cliente y el procedimiento seleccionado.
* **Contraindicaciones Críticas:** Si un cliente presenta condiciones absolutas y se intenta programar un tratamiento invasivo (*Microblading, Micropigmentación, Nanoblading, Laminados fuertes, Tatuaje cosmético*), la aplicación despliega un banner de advertencia grave en rojo puro y **bloquea físicamente el botón de guardado**.

### 3. Agenda & Gestión de Sesiones
* **Arquitectura NoSQL Desacoplada:** La colección `sesiones` se almacena de forma **independiente en la raíz** de Firestore (prohibida la anidación dentro del cliente).
* Parámetros técnicos estandarizados: Tono de pigmento, técnica/aguja utilizada, anestesia tópica y pruebas de sensibilidad.
* **Notas Internas:** Es el único campo de texto libre habilitado para observaciones técnicas privadas de la administración.

### 4. Módulo de Firma Digital (Modo Kiosco - Crítico)
* **Aislamiento Total:** Al presionar "Firmar Consentimiento", la app entra en **Modo Kiosco** a pantalla completa, bloqueando la navegación para que el cliente no acceda al resto del sistema.
* **Lienzo Táctil Interactivo:** Dibujo vectorial fluido con curvas bezier (`CustomPainter`).
* **Optimización y Cero PDFs:** El trazo se exporta directamente a **PNG con fondo transparente** y se comprime en el cliente (< 25 KB) para persistirse en Firestore como Data URL. **Prohibida la generación de PDFs pesados**.

### 5. Fotografías Antes y Después
* Captura directa desde la cámara del dispositivo o selector de galería.
* **Compresión Cliente Estricta:** Las imágenes se redimensionan y comprimen en el frontend a resolución estándar (< 180 KB), permitiendo almacenar las fotos sin costo en el plan gratuito.

---

## 🛡️ Auditoría de Seguridad & Garantía de Cero Facturación

Este proyecto fue concebido bajo el principio de **Cero Costo Operativo y Máxima Seguridad**:

### 1. Plan Firebase Spark (100% Gratuito)
* El proyecto está configurado bajo el **Plan Spark** de Firebase.
* **No hay tarjetas de crédito ni cuentas de facturación vinculadas.** Es técnicamente imposible que Google genere una factura o cobro imprevisto.

### 2. Llaves Públicas de Firebase vs Secretos Privados
* **Llave `FIREBASE_API_KEY` (`AIzaSy...`):** En Firebase para aplicaciones Web/PWA, el API Key es un **identificador público del proyecto**, no una clave secreta (se incluye en el JavaScript cliente compilado).
* **Ausencia de Credenciales Privadas:** El repositorio **no contiene ni rastrea** archivos de Service Account (`serviceAccountKey.json`), llaves privadas `.pem`, ni credenciales de administración de Google Cloud.
* Las reglas del archivo `.gitignore` protegen activamente cualquier archivo sensible o log de depuración.

### 3. Reglas de Seguridad en Base de Datos (Firestore Rules)
El acceso a la lectura y escritura de clientes y sesiones está protegido por reglas de seguridad a nivel de servidor:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAdmin() {
      return request.auth != null && (
        request.auth.token.email == 'omanpago@gmail.com' ||
        request.auth.token.email == 'bdog1731@gmail.com'
      );
    }

    match /clientes/{clienteId} {
      allow read, write: if isAdmin();
    }

    match /sesiones/{sesionId} {
      allow read, write: if isAdmin();
    }

    match /{document=**} {
      allow read, write: if isAdmin();
    }
  }
}
```

> [!NOTE]
> Cualquier usuario no autorizado que intente leer o escribir datos mediante la API pública de Firestore recibirá un error `403 PERMISSION_DENIED` automático del servidor de Firebase.

### 4. Control de Acceso Frontend
Solo las cuentas de Google autorizadas tienen acceso a la interfaz administrativa:
* `omanpago@gmail.com`
* `bdog1731@gmail.com`

---

## 🏗️ Arquitectura del Proyecto (Feature-First)

```
lib/
├── app.dart                                # Router de autenticación y tema principal
├── firebase_options.dart                   # Configuración del proyecto Firebase
├── main.dart                               # Punto de entrada e inicialización
├── core/
│   ├── constants/
│   │   ├── app_colors.dart                 # Paleta oficial (#F5F5F5, Rojo Alerta, etc.)
│   │   └── firebase_constants.dart         # Nombres de colecciones y límites de cuota
│   ├── errors/
│   │   └── app_exception.dart              # Excepciones personalizadas
│   ├── theme/
│   │   └── app_theme.dart                  # Tipografías (Playfair Display & Montserrat)
│   └── utils/
│       └── image_compressor.dart           # Compresión de imágenes y firmas en el cliente
├── features/
│   ├── auth/                               # Autenticación con Google y Guard de Admin
│   ├── clients/                            # Fichas de clientes y switches de alertas
│   ├── dashboard/                          # Panel con navegación por pestañas
│   ├── kiosk_signature/                    # Lienzo de firma en Modo Kiosco
│   ├── medical_alerts/                     # Motor de validación y Hard Block
│   ├── photos/                             # Captura y compresión de fotos antes/después
│   └── sessions/                           # Citas, tratamientos y consentimientos
└── shared/
    ├── providers/
    │   └── firebase_providers.dart         # Inyección de dependencias con Riverpod
    └── widgets/
        └── smart_image.dart                # Renderizado híbrido (Data URL / Network)
```

---

## 🚀 Puesta en Marcha Local

### Prerrequisitos
* Flutter SDK (3.x o superior)
* Navegador Google Chrome

### Instalación y Ejecución

```bash
# 1. Clonar el repositorio
git clone git@github.com:omanvasquez/ana-arias-studio.git
cd ana-arias-studio

# 2. Obtener dependencias
flutter pub get

# 3. Ejecutar en modo desarrollo en Chrome
flutter run -d chrome
```

---

## 🚢 Compilación y Despliegue en Producción

Para compilar la versión optimizada de producción y desplegarla en Firebase Hosting:

```bash
# 1. Compilar para la Web (PWA)
flutter build web

# 2. Desplegar reglas de Firestore y Hosting
firebase deploy --only hosting,firestore:rules
```

---

## 📱 Instalación como PWA (Móviles & Escritorio)
1. Ingresa a [https://ana-arias-studio.web.app](https://ana-arias-studio.web.app) desde Google Chrome o Safari.
2. En la barra de direcciones o menú de opciones, presiona **"Instalar aplicación"** o **"Añadir a pantalla de inicio"**.
3. La aplicación se ejecutará con ventana dedicada sin barras de navegador, con el icono oficial y carga instantánea.

---

<div align="center">
  <sub>Desarrollado para <b>Ana Arias Studio</b> · Operación 100% Digital</sub>
</div>

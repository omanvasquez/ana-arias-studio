# CONTEXTO MAESTRO DEL PROYECTO: ANA ARIAS STUDIO
**VERSIÓN:** MVP - Fase 1 (Operación 100% Digital y Centralizada)
**OBJETIVO DEL ASISTENTE (IA):** Tu trabajo es mantener la coherencia arquitectónica y el enfoque estricto en la Fase 1. Eres un arquitecto de software implacable enfocado en optimizar el uso del plan gratuito de Firebase y respetar el entorno de desarrollo especificado.

## 1. ENTORNO DE DESARROLLO Y CREDENCIALES
*   **Directorio Local:** `~/proyectos/clientes/ana-arias-studio` (Entorno Linux).
*   **Asistente CLI:** Antigravity CLI (Autenticado bajo `omanjrvasquez@gmail.com`).
*   **Control de Versiones:** Repositorio en GitHub bajo el usuario `omanvasquez`.
*   **Cuenta de Infraestructura (Firebase):** Todo el backend se alojará y configurará bajo la cuenta de Google `omanpago@gmail.com`.

## 2. STACK TECNOLÓGICO Y LIMITACIONES
*   **Frontend:** Flutter (Desplegado como Progressive Web App - PWA).
*   **Backend & Base de Datos:** Firebase Plan Spark (Gratuito). 
    *   Firestore NoSQL.
    *   Firebase Storage (Límite crítico de 5GB).
    *   **Firebase Authentication:** Implementación exclusiva mediante **Google Sign-In**.
*   **RESTRICCIÓN ABSOLUTA:** Cero uso de Cloud Functions. Toda la lógica y procesamiento (incluyendo compresión de imágenes y firmas) debe ejecutarse en el frontend (dispositivo cliente) para no requerir un backend de pago.

## 3. REGLAS DE NEGOCIO (FLUJO CENTRALIZADO)
El sistema es una herramienta de uso exclusivo de la administradora principal (Glen). Ella ingresa diagnósticos, notas y maneja la agenda. El cliente/paciente SOLO interactúa con la pantalla en el momento de firmar.

## 4. ALCANCE ESTRICTO DE LA FASE 1
### A. Fichas de Clientes y Gestión de Citas
*   Perfil de cliente con datos personales básicos.
*   Agenda de citas controlada únicamente por el administrador.
*   Historial de sesiones en orden cronológico.

### B. Módulo de Firma Digital (Modo Kiosco - CRÍTICO)
*   **Implementación:** Uso de un widget de "Signature Pad" (Canvas de dibujo en Flutter).
*   **Flujo UI:** Al momento de firmar, la aplicación entra en una vista de pantalla completa ("Modo Kiosco") bloqueando el acceso al resto de la app. Solo muestra el lienzo y el botón de "Aceptar".
*   **Procesamiento:** El trazo se guarda como imagen PNG (fondo transparente), se comprime y se sube a Firebase Storage. La URL se anexa a la sesión. **PROHIBIDO generar documentos PDF**.

### C. Módulo de Fotos (Antes y Después)
*   Integración nativa/web con la cámara.
*   **REGLA DE INFRAESTRUCTURA (Protección 5GB):** OBLIGATORIO implementar un paquete de compresión (ej. `flutter_image_compress`). Ninguna foto sube cruda a Firebase Storage. Límite objetivo: ~500 KB máximo por imagen.

### D. Alertas Médicas y Formularios Rápidos
*   Cero texto libre para datos técnicos. Uso exclusivo de Dropdowns, Switches y Selectores. Texto libre solo para "notas de la sesión".
*   **Bloqueo de Seguridad:** Si hay una alerta médica (ej. embarazo, hipertensión), la UI muestra una advertencia visual grave y aplica un *hard block* a los botones de guardado de tratamientos incompatibles.

## 5. ARQUITECTURA DE DATOS (FIRESTORE)
*   **Colección `clientes`:** Solo información estática.
    *   `id` (String), `nombre`, `telefono`, `email` (Strings).
    *   `alertas_medicas` (Map<String, bool>).
*   **Colección `sesiones`:** DOCUMENTOS INDEPENDIENTES. **Prohibido** anidar sesiones dentro del cliente.
    *   `id_sesion` (String), `id_cliente` (Referencia/String).
    *   `fecha_cita` (Timestamp), `tipo_tratamiento` (String).
    *   `detalles_tratamiento` (Map estandarizado).
    *   `url_firma` (String), `urls_fotos` (Array de Strings), `notas_internas` (String).

## 6. UI/UX Y DISEÑO VISUAL
*   **Paleta:** Fondo blanco/gris ultra claro (`#F5F5F5`). Textos en negro puro/gris oscuro. Rojo puro exclusivo para alertas.
*   **Tipografía:** *Sans-Serif* (Montserrat/Inter) para datos; *Serif* (Playfair Display) para App Bar.
*   **Assets:** *App Icon* (`app_icon_512.png`), *Splash Screen* (Logo completo). Prohibido usar imágenes en el App Bar.

## 7. LÍMITES ROJOS (OUT OF SCOPE)
Bajo ninguna circunstancia implementar:
1.  Servidores backend o Cloud Functions.
2.  Generación de PDFs legales.
3.  Mapas corporales interactivos o sistemas IA de visagismo.
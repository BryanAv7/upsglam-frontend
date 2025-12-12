# UPSGlam 2.0 - Flutter GPU Image Social App

UPSGlam 2.0 es una plataforma social tipo Instagram que permite a los usuarios aplicar filtros de imagen con procesamiento GPU y publicar sus fotos. La aplicación combina Flutter en el frontend con un backend basado en microservicios (Spring WebFlux) y almacenamiento en Firebase.

---

## Contenido

- [Arquitectura](#arquitectura)
- [Instalación y Despliegue](#instalación-y-despliegue)
- [Uso de la Aplicación](#uso-de-la-aplicación)
- [Filtros de Imagen](#filtros-de-imagen)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Servicios](#servicios)
- [Dependencias](#dependencias)

---

## Arquitectura

La app se basa en la siguiente arquitectura:

- **Frontend:** Flutter para Android/iOS con vistas:
  - Login/Registro (con email y Google)
  - Home / Perfil / Pantalla de filtros
- **Procesamiento de imagen:** GPU (PyCUDA en el backend)
- **Backend:** Microservicios reactivos con Spring WebFlux
- **Autenticación:** JWT + OAuth Google
- **Almacenamiento de imágenes:** Firebase Storage
- **Configuración dinámica:** SharedPreferences en Flutter para IP del servidor


---

## Instalación y Despliegue

1. **Requisitos locales:**
   - Flutter 3.x o superior
   - Android Studio / VSCode
   - Emulador o dispositivo físico
   - Python 3.x + PyCUDA + CUDA Toolkit (para el backend de filtros)
   - Backend Spring Boot corriendo en la IP/puerto configurados

2. **Configurar IP del servidor:**
   - Abrir `Settings` en la app
   - Ingresar `IP:Puerto` donde corre el backend
   - Guardar cambios

3. **Ejecutar la app:**
```bash
flutter pub get
flutter run
```

---


## Uso de la Aplicación

1. **Login/Registro**
- Crear usuario con email y contraseña o iniciar sesión con Google.
-Foto de perfil opcional en el registro.

2. **Home**
- Vista principal de publicaciones.
- Barra inferior con botones: Home, Crear Publicación, Perfil.

3. **Aplicar filtros**
- Seleccionar imagen desde la galería.
- Abrir pantalla de filtros (FilterScreen).
- Elegir filtro y ajustar parámetros (si aplica).
-Publicar imagen procesada al backend y Firebase Storage.

4. **Perfil**
- Ver información personal y publicaciones.


---


## Filtros de Imagen

- **`emboss`**: Aplica un efecto de relieve (embossing) a la imagen, destacando bordes mediante diferencias de intensidad.
- **`sobel`**: Detecta bordes usando el operador Sobel, resaltando cambios bruscos en la intensidad de la imagen.
- **`gauss`**: Aplica un desenfoque gaussiano para suavizar la imagen y reducir ruido.
- **`sharpen`**: Realza los detalles y bordes mediante un filtro de enfoque (sharpening).
- **`sombras_epico`**: Aumenta los destellos/luz alta y aplica viñeteo para dar un efecto dramático y cinematográfico.
- **`resaltado_frio`**: Refuerza los tonos fríos (azules) y aumenta el contraste para una estética fría y definida.
- **`marcoUPS`**: Añade un marco decorativo alrededor de la imagen en representación de la Universidad.

---

## Estructura del proyecto

```
lib/
├─ models/
│  ├─ filter_config_model.dart
│  └─ user_model.dart
├─ screens/
│  ├─ login_screen.dart
│  ├─ register_screen.dart
│  ├─ home_screen.dart
│  ├─ filter_screen.dart
│  └─ settings_screen.dart
├─ services/
│  ├─ auth_service.dart
│  ├─ filter_service.dart
│  └─ post_service.dart
├─ utils/
│  └─ constants.dart (AppConfig para IP/URL base)
```

---

## Servicios

- **AuthService:** Registro/Login con email o Google, gestión de JWT.
- **FilterService:** Envío de imágenes y parámetros al backend para procesamiento GPU.
- **PostService:** Subida de imágenes procesadas al backend y Firebase Storage


---

## Dependencias

1. flutter_svg para iconos SVG.
2. shared_preferences para almacenamiento local.
3. image_picker para selección de imágenes.
4. http para peticiones HTTP.
5. google_sign_in para login OAuth Google.


---

## Observación

- Se requiere configurar correctamente la IP del backend antes de iniciar sesión.
- Los filtros en la opción "ninguno" no procesan la imagen en GPU.
- Las imágenes procesadas se almacenan en el servidor de Firebase.

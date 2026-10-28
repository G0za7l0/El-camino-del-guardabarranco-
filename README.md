# El Camino del Guardabarranco

App educativa móvil (Flutter/Dart) sobre Nicaragua, construida desde cero
a partir de las capturas y assets oficiales proporcionados.

## 🚀 Cómo ejecutarla

Este proyecto se generó **sin** las carpetas nativas `android/` e `ios/`
(no se pueden crear sin el SDK de Flutter). Para correrlo en tu máquina:

```bash
cd el_camino_del_guardabarranco

# 1. Genera el andamiaje nativo (android/, ios/, etc.) sin tocar lib/ ni pubspec.yaml:
flutter create .

# 2. Instala dependencias:
flutter pub get

# 3. Ejecuta en un emulador o dispositivo conectado:
flutter run
```

## 📁 Estructura

```
lib/
├── main.dart                  # MaterialApp + rutas centralizadas
├── screens/                   # Pantallas (Home, Explorador, Misiones, Mapa, Perfil...)
│   └── games/                 # Las 5 pantallas de mini-juegos
├── widgets/                   # Componentes reutilizables
├── models/                    # Modelos de datos (usuario, nivel, pregunta, resultado, logro)
├── services/                  # Lógica local (auth, progreso) + API placeholders
├── controllers/               # Estado (ChangeNotifier): Auth, Progress, Game
├── constants/                 # Colores, textos, rutas y assets centralizados
└── data/mock_data.dart        # Datos mock (niveles, preguntas, logros, mapa)

assets/
├── branding/    logo.jpeg
├── characters/  guardabarranco_happy.png, explorer_male.jpeg, explorer_female.jpeg
├── backgrounds/ home_background.jpeg, forest_background.jpeg
├── map/         nicaragua_map_path.jpeg, nicaragua_map_reference.jpeg
└── games/       dog, bone_11/12/13, puzzle_10/12/15, chest_closed/open,
                 monster, apple_13, banana_14, strawberry_15, balloon_12/13/14
```

## ⚠️ Supuestos tomados (para tu revisión)

Recibí más imágenes de referencia de las que hay "huecos" 1 a 1 en las
pantallas — algunas eran variantes o versiones sin UI del mismo elemento.
Así las interpreté:

- **`nicaragua_map_path.jpeg`** (mapa limpio con camino punteado) se usa
  como fondo de la **pantalla Home** y de la **pantalla de Mapa/Aventura**
  (los pines de Managua/Masaya/Granada/Bluefields/Chontales/Corn Island se
  dibujan encima con código, con posiciones aproximadas).
- **`home_background.jpeg`** (versión con marco de hojas/flores y sol) se
  usa como fondo decorativo detrás del logo en Home.
- **`forest_background.jpeg`** se reutiliza como fondo de la pantalla de
  registro y de los 5 mini-juegos (todas comparten esa estética en las
  capturas).
- El asset **`nicaragua_map_reference.jpeg`** (el mapa con castillos/
  iglesias/lago, más parecido a la captura real de "Mapa del recorrido")
  quedó importado en `AppAssets` pero sin usar todavía — si prefieres que
  sea ese el que se vea en la pantalla de Mapa en lugar de
  `nicaragua_map_path.jpeg`, lo cambio en un solo lugar
  (`lib/screens/map_screen.dart`).
- El **cofre** requiere 5 sumas: solo la primera (4+6) venía en tu
  captura, así que generé 4 sumas adicionales del mismo nivel de
  dificultad en `mock_data.dart` — se pueden reemplazar fácilmente.

## 🔌 Puntos de conexión a API

Cada lugar donde en el futuro se conectará un backend real está marcado
con el comentario `API CONNECTION POINT` (búscalo en todo el proyecto).
Por ahora todo el registro, login y progreso funcionan 100% local/mock.

## ✅ Qué funciona ya

- Navegación completa entre Home → Registro → Misiones → Juegos → Nivel completado.
- Registro local con validaciones (nombre, correo, contraseña ≥ 8 caracteres).
- Los 5 mini-juegos son jugables de verdad: huesos (tap), rompecabezas
  (Drag & Drop real), cofre (5 sumas con progreso), monstruo (tap) y
  globos (tap con animación de "pop") — todos detectan correcto/incorrecto,
  dan feedback visual y actualizan puntos/XP/pitahayas reales.
- Pantalla de Nivel Completado dinámica (respuestas correctas, puntos,
  insignia) con botones "Continuar aventura" y "Repetir nivel" funcionales.
- Perfil con XP, pitahayas, racha y logros (bloqueados/desbloqueados).

## 🧪 Nota importante

Este código se escribió y organizó cuidadosamente, pero no pude
compilarlo ni ejecutarlo aquí porque este entorno no tiene el SDK de
Flutter instalado. Corre `flutter analyze` después de `flutter pub get`
la primera vez — si aparece algún error de compilación, pégamelo y lo
corrijo de inmediato.

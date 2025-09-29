# RickAndMortyApp

Aplicación iOS creada con SwiftUI que consume la [Rick and Morty API](https://rickandmortyapi.com/) para mostrar personajes, permitir búsquedas avanzadas, guardar favoritos y consultar los episodios en los que participa cada personaje. El proyecto adopta un enfoque **MVVM + Swift Concurrency** y hace uso de **Core Data** y **MapKit** para enriquecer la experiencia.

## Características principales
- 📱 **Listado infinito de personajes** con precarga de imágenes y estado de carga/error vacíos diferenciados.
- 🔍 **Búsqueda en vivo** por nombre y filtros combinados por especie y estado.
- ⭐ **Favoritos persistentes** usando Core Data, con bloqueo por biometría antes de mostrar la pestaña.
- 🗺️ **Mapa con ubicación simulada** para cada personaje.
- 📺 **Detalle enriquecido** con información general y lista de episodios marcables como favoritos.
- 🔐 **Autenticación biométrica (Face ID/Touch ID)** para proteger la sección de favoritos.

## Arquitectura y módulos
- **Model**: Modelos de dominio (`RMCharacter`, `RMEpisode`, `Location`, `Origin`) y modelos de respuesta de red (`ResponseCharacterModel`, `ResponseEpisodeModel`). Contiene también la capa de persistencia (`PersistenceController`).
- **ViewModel**: `CharactersViewModel` coordina la carga paginada, filtros, favoritos, biometría e imágenes; `EpisodeViewModel` gestiona la carga de episodios y su estado de favorito. `FavoriteCharacterViewModel` sirve para leer la lista persistida desde Core Data.
- **View**: Conjunto de pantallas SwiftUI (`MainTabView`, `CharactersView`, `FavoriteCharactersView`, `CharacterDetailShowSheetView`, vistas auxiliares para filtros y mapas) que reaccionan al estado publicado por los ViewModels.
- **Tests**: `RickAndMortyAppTests` cubre casos de favoritos, eliminación y generación de coordenadas simuladas en el ViewModel principal.

## Requisitos previos
| Herramienta | Versión recomendada |
|-------------|---------------------|
| Xcode       | 15.4 o superior (SDK iOS 17+) |
| iOS SDK     | Configurado en el proyecto como 26.0; ajústalo a la versión soportada por tu Xcode si es necesario |
| Swift       | 5.9 o superior |

> ℹ️ **Nota:** El `PersistenceController` está configurado en memoria (`inMemory: true`). Si deseas persistir los datos entre ejecuciones, cambia el parámetro a `false` en `PersistenceController`.

## Configuración y ejecución
1. **Clona el repositorio**:
   ```bash
   git clone <url-del-repo>
   cd RickAndMortyApp
   ```
2. **Abre el proyecto en Xcode** (`RickAndMortyApp.xcodeproj`).
3. **Selecciona un simulador o dispositivo** (por ejemplo, *iPhone 15*).
4. **Compila y ejecuta** con `⌘R`.
5. Si encuentras un error relacionado con la versión mínima de iOS, abre *Project > Info* y ajusta `iOS Deployment Target` a una versión disponible en tu entorno.

## Ejecución de pruebas
- Desde Xcode: `Product > Test` (`⌘U`).
- Desde terminal:
  ```bash
  xcodebuild test \
    -project RickAndMortyApp.xcodeproj \
    -scheme RickAndMortyApp \
    -destination 'platform=iOS Simulator,name=iPhone 15'
  ```

## Estructura del proyecto
```
RickAndMortyApp/
├── RickAndMortyAppApp.swift       # Punto de entrada SwiftUI
├── ContentView.swift              # Vista placeholder generada por Xcode
├── Assets.xcassets/               # Recursos gráficos
├── Model/
│   ├── Data/PersistenceController.swift
│   ├── MainModels/                # Modelos de dominio
│   └── ResponseModels/            # Modelos de respuesta API
├── ViewModel/
│   ├── CharactersViewModel.swift
│   ├── FavoriteCharacterViewModel.swift
│   └── EpisodesViewModel.swift
└── View/
    ├── MainTabView.swift
    ├── CharactersView.swift
    ├── FavoriteCharactersView.swift
    ├── CharacterDetailShowSheetView.swift
    ├── CharacterMapView.swift
    ├── FiltersSheetView.swift
    └── SheetMapCharactersView.swift
```

## Buenas prácticas y convenciones
- **Swift Concurrency** (`async/await`) para todas las llamadas de red.
- **Separación de responsabilidades**: la vista solo consume estado publicado por el ViewModel.
- **Estados explícitos** (`ViewStatus`) para manejar cargando, vacío y errores en la UI.
- **MapKit**: `CharacterMapView` recibe coordenadas simuladas mediante `fetchSimulatedLocation()`.
- **Core Data**: Favoritos de personajes y episodios almacenados en entidades `CDCharacter` y `CDEpisode`.
- **Accesibilidad**: Identificadores en botones clave para UI Tests (`favoriteButton_<id>`, `mapButton`, `detailButton`).

## Recursos externos
- [Documentación de la API](https://rickandmortyapi.com/documentation)
- [Guía de SwiftUI](https://developer.apple.com/tutorials/swiftui)
- [Core Data Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/)

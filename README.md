# MLCodeChallenge JW

La app consiste de una Challenge Tecnico con el objetivo de mostrar 2 pantallas:

- Lista de usuarios
  
  - Botones de accion: Llamada, email y maps.

- Mapa con posicionamiento del usuario

Siguiendo con el punto de "Funcionalidad a tu criterio" decidi agregar 3 pantallas mas:

- Detalle de usuario

- Albums

- Detalle del album (listado de fotos)

Razones las cuales se explican luego en este documento.

---

## Screenshots

| Usuarios | Mapa | Detalle |
| -------- | ------- | ------- |
| <img src="https://github.com/ccxdnb/MLCodeChallenge/blob/main/Demo%20Images/UserListView.png?raw=true" width="300" alt="Users List View"> | <img src="https://github.com/ccxdnb/MLCodeChallenge/blob/main/Demo%20Images/MapView.png?raw=true" width="300" alt="Map View"> | <img src="https://github.com/ccxdnb/MLCodeChallenge/blob/main/Demo%20Images/UserDetailView.png?raw=true" width="300" alt="User Detail View"> |

| Albumes | Fotos | Pantalla Completa |
| ----- | ----------------- | ---- |
|<img src="https://github.com/ccxdnb/MLCodeChallenge/blob/main/Demo%20Images/AlbumListView.png?raw=true" width="300" alt="Album List View">| <img src="https://github.com/ccxdnb/MLCodeChallenge/blob/main/Demo%20Images/PhotoListView.png?raw=true" width="300" alt="Photos List View"> | <img src="https://github.com/ccxdnb/MLCodeChallenge/blob/main/Demo%20Images/FullSizePhotoView.png?raw=true" width="300" alt="Full Screen View"> |

---

## Cómo correrlo

```bash
git clone https://github.com/ccxdnb/MLCodeChallenge.git
cd MLCodeChallenge
open MLCodeChallenge.xcodeproj
```

Idealmente "Build & Run", no hay que instalar ni configurar nada.

|                   |                                                 |
| ----------------- | ----------------------------------------------- |
| Xcode             | 26.3 o superior                                 |
| Deployment target | iOS 26                                          |
| Dependencias      | Google Maps iOS SDK (vía SPM, se resuelve solo) |
| Linter            | Swiftlint local y en CI                         |

---

## Sobre el alcance

Tome la interpretacion sobre "Funcionalidad a tu criterio" que me permita explorar distintos mecanismos dentro de iOS. Elegi ir por la opcion de incluir albumes/fotos ya que es la unica que me permite trabajar con un volumen que se acerca un poco mas a lo real (5000 fotos con paginado y carga asyncrona de imagenes). Continuar por los post/comentarios es agregar mas CRUD de texto, lo cual considero redudante ya teniendo la lista de usuarios. 
El detalle de usuario nace de la opcion de no contaminar la celda con mas botones y parece el lugar apropiado para incluir la redireccion hacia los albumes asociados con el usuario. 
Cache offline, favoritos guardados, design system propio, quedan fuera del scope de este Challenge ya que considero que las 5 pantallas propuestas alcanzan para demostrar Arquitectura, buenas practicas, patrones de diseño, concurrencia y testing.

---

## Arquitectura

MVVM-C con una capa de servicios. Dependencias unidireccionales.

```
View  →  ViewModel  →  Service  →  HTTPClient
                ↓
          AppCoordinator
```

```
MLCodeChallenge/
├── App/                  AppRootView y App component
├── Core/
│   ├── Configuration/    Configs generales de la app
│   ├── Navigation/       Coordinator y routes
│   ├── Network/          HTTPClient, EndpointType, APIError
│   ├── Services/         Servicios que exponen la API
│   └── UI/               Componentes generales de UI 
├── Features/             Pantallas separadas por carpetas con sub-componentes
├── Models/               Modelos Codable
└── Resources/            Asset folder, localizables, plist
```

### Inyección de dependencias

La inyeccion de dependencias se hace mediante una struct Dependencies definida dentro de los ViewModels. Personalmente me gusta este approach ya que permite ver directamente que es lo que un ViewModel necesita sin necesidad de redireccionar a una interfaz (protocol). Tambien permite un testeo rapido por substitucion mediante un Mock.

```swift
@Observable
final class UsersListViewModel {
    struct Dependencies {
        let usersService: UsersServiceProtocol
        let coordinator: AppCoordinatorProtocol
    }

    private let dependencies: Dependencies
}
```

Tambien considere una implementacion por composicion de protocolos:

```swift
typealias Dependencies = HasUsersService & HasCoordinator}
```

La cual permite una mayor escalabilidad a medida que va creciento pero considero que para un challenge de 5 pantallas es infrastructura que no va a ser utilizada.

El proposito de `ServiceFactory` es poder tener un punto de composicion que le permita a los ViewModels sobrevivir a las re-evaluaciones de las vistas de SwiftUI de forma tal que no creen nuevos servicios por cada evaluacion.

### Navegación

En este caso tenemos a AppCoordinator quien se encarga de manejar el ruteo ya que toma control del path en `NavigationStack`. Los `ViewModels` dependen del protocolo `AppCoordinatorProtocol` para abrir la posibilidad de testing  de navegacion mediante un spy.

### Estados de carga

Se define un unico enum para poder unificar el comportamiento y los estados de las vistas. 

```swift
enum ViewState<T> {
    case idle, loading, loaded(T), empty, failed(String)
}
```

---

## Decisiones técnicas

### Por qué MVVM y no Clean

Considero que el alcance del proyecto define la arquitectura y que en este caso generar interactors, workers, presenters y otras entidades terminaria por generar codigo vacio que no resuelve un problema de infraestructura. En un proyecto con reglas de negocio reales cobra mas sentido incluirlas y es el camino eligiria.

### Por qué un coordinator plano

En SwiftUI tenemos un NavigationStack que solo tiene un unico path, si bien aplicar child-coordinators es posible lo que sucede es que como no pueden tener un stack independiente (como en UIKit) no son realmente necesarios ya que se soluciona la navegacion estableciendo una jerarqua de rutas por features (usando sub-enums).
Ejemplo:

```swift
enum Route: Hashable, Identifiable {
    enum OnboardingRoute: Hashable, Identifiable {
        case initial
        case userData(User)
    }

    case userList()
    case onboarding(OnboardingRoute)
}
```

Dentro del coordinator no existe un goBack() ya que para esta App la navegacion se maneja con el back nativo porque el path es un binding y funciona en ambas direcciones. 
Para una app mas compleja donde existiesen acciones que deriven en un back incluiria esta opcion ya que desacopla la navegacion del BackButton nativo. 

### Cache de imágenes de dos niveles

Esta implementacion nace de una persecucion personal de conseguir una agradable experiencia de scrolling en listado de fotos con distintos layouts. 
`AsyncImage` es la primera opcion y lo que nos ofrece la libreria de SwiftUI pero no termina de resolver el problema ya que el costo real no es la descarga, es el `decoding`. 

De esta forma nace la implementacion de este sistema de cache de imagenes de 2 niveles. `UIImage` (que esta contenido en AsyncImage) se encarga de hacer la decodificacion en el main-thread a la hora de de dibujar (presentar) por lo tanto produce un scrolling con perdidas de frames y flickering que arruina la experiencia. Por eso el cache presenta 2 tiers, en uno se encuentra la imagen comprimida y en el otro la imagen decodificada a la resolucion que va a ocupar en la pantalla teniendo en cuenta el `displayScale`.

Gracias a la ventaja de swift y su actor-isolation podemos, en `ImageLoader` guardar la `Task` con la que se pide una imagen y asi evitar duplicacion de pedidos, si otro pide la misma imagen, se va a colgar del `Task` inicial sin generar otro.

NSCache se auto-vacia por presion de memoria pero si iOS considera que la App esta consumiendo mucha memoria y dispara un `didReceiveMemoryWarningNotification` este mismo dispara el flush del cache (idealmente las imagenes decodificadas) ya que si conservamos las comprimidas, el costo posterior es simplemente un decoding y no una descarga.

En un proyecto Real analizaria la opcion de usar alguna libreria como `Kingfisher`, ya que mi implementacion de `ImageLoader` requiere trabajo y mantencion a largo plazo pero decidi hacerlo manual en este Challenge para poder mostrar como pienso en resolver un problema mas alla de elegir una libreria.

### Concurrencia

El proyecto tiene el flag `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` habilitado por lo que me ahorra de tener que agregar `@MainActor` annotation a los view models. Esto invierte la logica que se venia usando y se soluciona agregando nonisolated a las definiciones de modelos y endpoints ya que son datos puros sin mutacion de estados.

Esto es parte de una decision conciente de proteger los estados de data races y errores de concurrencia. Por ejemplo:

- `HTTPClient`: Esta definido como final class y sendable ya que unicamente tiene propiedades LET y no precisa de proteccion de mutacion de estados

- `ImageLoader`: Esta definido como `actor` ya que almacena un diccionaro de `Tasks` las cuales y la logica de chekeo para prevenir duplicacion de request de una misma imagen que se realiza desde distintos componentes.

- `ImageCache`: Esta definido como `final class` y con el polemico `@unchecked Sendable` ya que segun la documentacion de apple NSCache es thread safe pero aun no conforma con el protocolo `Sendable` por lo tanto no hace falta transformarlo en un `actor` porque ya esta protegido.

Decidi no propagar `URLError.canceled` ya que usualmente no es un error que el usuario deba ver, por ejemplo si sale de una pantalla donde aun estaba esperando la respuesta de la api.

### Paginación

En este caso la paginacion esta dentro del estado .loaded ya que "no podemos paginar datos que no existen" y en caso de que hubieran otros estados que si tengan se podria extraer a un protocolo.

Me encontre con 2 bugs de concurrencia:

- la carga incial y la carga de paginas usaban la misma Task por lo que llegar rapido al final de la pagina cancelaba la carga de la incial. Se soluciono independizando los Tasks de carga inicial y paginacion.

- `isLoadingMore`  se seteaba despues de dentro del task y un `onAppear` puede dispararse mas de una vez por lo que generaba paginas duplicadas

### Delete

Decidi implementar un swipe to delete que le mande la peticion a la api. Dentro del delete decidi hacer que el delete suceda primero (visual) y luego se revierta si la llamada falla. A nivel experiencia de usuario, dejar una row con el gesture de delete "colgada" se siente como un error, y el delete "optimista" permite un mejor flujo y mejor navegacion. Si la llamada al delete falla no se hace la re-insercion sino se restaura la lista completa para prevenir duplicacion si es que algun dato cambia.

### Búsqueda: sin caché y sin debounce

El filtrado se realiza mediante una computed property que se consume del ViewModel observable.

Entiendo que no es la decision mas optima y que si fuera un listado grande (miles de items) implementaria cosas como:

- Debounce de algunos segundos sobre el input de la busqueda ya que cada busqueda requiere un trabajo costoso. 

- Cachear el resultado mediante 2 fuentes de verdad que deban ser sincronizadas a mano para liberar costos de CPU, cosa que no aplica a un listado de 10 usuarios.

### Google Maps

Google maps aun no tiene una vista en SwiftUI dentro de su SDK por lo cual se hace necesario el uso de `UIViewRepresentable`. Lo importante es crear el marker en `MakeUIView` y usar el patron `Coordinator` para guardarlo ya que `updateUIView` compara las coordenadas nuevas con las que estan y permite escapar si las coordenadas no cambiaron lo que previene la reposicion de la camara en cada re-evaluacion de la vista.

### La API key está commiteada a propósito

La api key esta comiteada en el proyecto por la siguiente razon fundamental:

- la Key viaja dentro del binario y cualquiera puede sacarla de un IPA, no es necesario esconderla.

- La proteccion real viene por reestriccion de `BundleID` y limitada al SDK. No hay otra persona que pueda usar esta key porque esta asociada a mi `BundleID` los cuales son unicos en apple.

- En un proyecto que requiera distintos entornos esta key iria por fuera del control de versiones expuesto por `info.plist`

### Sobre el diseño

Implementar un design system o una identidad visual propia esta por fuera del scope de este challenge por lo cual priorize utilizar:

- Colores semanticos

- Componentes nativos

- SF Symbols

- Estilos de texto/fuentes en vez de tamaños fijos.

Lo cual da la ventaja de tener DynamicType, Dark mode, Content adaptation automaticamente.

Cabe destacar que la `PhotoListView` implementa un sistema de pre-fetching para hacer la experiencia del scroll mas uniforme y evitar mostrar muchos loading spinner en una velocidad de scroling esperable.

En iPad implemente `readableContentWidth()` para poder acotar el contenido y prevenir que el contenido simplemente se estire para completar la pantalla. Por ejemplo en la lista de usuarios los action buttons de la informacion tenian un espacio de mas de 1000p.

---

## Cosas de la API que vale saber

JSONPlaceholder tiene 3 cositas que condicionaron levemente la implementacion.

- Las coordenadas de `Geo` son falsas y se exponen como string.
  
  - La conversion de String a Float se realiza en el decoding, de esta forma prevenimos generar modelos que puedan tener errores en sus datos y romper en runtime.
  
  - No coinciden con la city propuesta en el modelo address por lo que la posicion en el mapa difiere.

- El host de fotos esta caido y no devuelve ninguna foto. Esto lo verifique directamente antes de construir la feature por lo que me tome el atrevimiento de usar el ID de la foto para pegarle a otra API https://picsum.photos y de esta forma poder crear el listado de fotos sobre los albumes de los usuarios.
  
  - Se establecen 3 tipos de fotos que podemos obtener mediante la manipulacion de la resolucion en el request:
    
    - `thumbnailURL`: Se usa para mostrar imagenes chicas en una grilla, y para minificar el tamaño de la descarga y el impacto en scrolling
    
    - `bannerURL`: Levemente mas grande que thumbnailURL y se usa para un listado que muestre las imagenes ocupando el ancho de la pantalla
    
    - `fullSizeURL`: Trae como prueba la imagen full size (hardcodeado a 1920x1080 para este challenge) y se usa cuando el usuario quiere ver la imagen full size en una pantalla dedicada.

- El DELETE no es persistente
  
  - Por lo que si bien el hit a DELETE devuelve 200, no impacta en el dato real y refrescar la lista devuelve el usuario que fue "borrado"
  
  - Decidi incluir esto ya que la api al devolver 200 permite probar un flujo real de borrado aunque no modifique verdaderamente el listado a nivel API. 

---

## Tests

Tests unitarios echos con SwiftTesting, para tambien salir un poco de la zona de confort (XCTest).

| Área         | Qué cubre                                                                                                                            |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------ |
| Modelos      | Decoding, conversión string→Double de coordenadas, campos faltantes o inválidos, URLs derivadas                                      |
| Networking   | Mapeo de status codes, mapeo de `URLError`, fallas de decoding, armado de query params, respuestas sin body                          |
| Presentación | Transiciones de estado de cada view model, errores que llegan a la UI, paginación, delete optimista con rollback, navegación con spy |

Dado el contexto de este proyecto es que tambien se usa `URLProtocol` y no una libreria de mocking. Mas simple la implementacion, no crea dependencias externa y permite testear el `HTTPClient` con stubs y el resultado es deterministico. De esta forma se previenen los test de integracion contra una API real que harian mucho mas lento el proceso y dependen de internet.

En `ImageCache` es necesario testear la no inversion de los niveles ya que puede ser un bug que no genere un error sino hacer mas lenta la app por lo cual es dificil de debuggear.

De esta formalas vistas de SwiftUI, test de UI, test de SDK de Google y Apple no estan incluidos en este Challenge.

---

## Qué agregaría después

- Cache offline para albums y usuarios asi la app funciona sin conexion.

- Guardado de favoritos.

- Mover prefetch al PhotoListViewModel

- Permisos sobre location services para mostrar ubicacion actual del usuario en mapas

- Analytics y crash reports para monitorear el uso general.

- `NavigationSplitView` para el layout de 2 columnas que suele haber en iPad

- Prefetch de la pagina siguiente antes que el usuario llegue al final de la lista

- Hero transition para zoom de imagen y map tap icon

- Localized Strings with keys.

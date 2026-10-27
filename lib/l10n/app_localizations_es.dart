// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get greetingMorning => 'Buenos días';

  @override
  String get greetingAfternoon => 'Buenas tardes';

  @override
  String get greetingEvening => 'Buenas noches';

  @override
  String get howToConnect => 'Cómo conectar';

  @override
  String get profiles => 'Perfiles';

  @override
  String get settings => 'Ajustes';

  @override
  String get permissionsPending => 'Permisos pendientes';

  @override
  String get back => 'Atrás';

  @override
  String get gotIt => 'Entendido';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get name => 'Nombre';

  @override
  String get connectTitle => 'Conectar un mando';

  @override
  String get tipUsbTitle => 'USB';

  @override
  String get tipUsb => 'Conecta el cable. El mando aparecerá aquí en unos segundos.';

  @override
  String get tipBluetoothTitle => 'Bluetooth';

  @override
  String get tipBluetooth => 'Pon el mando en modo de emparejamiento y conéctalo en Ajustes del Sistema › Bluetooth.';

  @override
  String get tipXbox360Title => 'Xbox 360 inalámbrico';

  @override
  String get tipXbox360 => 'No usa Bluetooth: necesita el receptor inalámbrico de Microsoft.';

  @override
  String get tipPs3Title => 'PS3 por USB';

  @override
  String get tipPs3 => 'Puede que tengas que pulsar el botón PS una vez.';

  @override
  String get tipHidTitle => 'Mandos genéricos';

  @override
  String get tipHid => 'Necesitan el permiso de Monitorización de Entrada para ser detectados.';

  @override
  String get connected => 'Conectado';

  @override
  String get genericHid => 'HID genérico';

  @override
  String get controllerFallback => 'Mando';

  @override
  String get noController => 'No hay ningún mando conectado';

  @override
  String get noControllerHint => 'Conéctalo por USB o Bluetooth. Aparecerá aquí automáticamente.';

  @override
  String get editAnyway => 'Editar perfil de todos modos';

  @override
  String get switchActiveProfile => 'Cambiar perfil en uso';

  @override
  String get profileInUse => 'Perfil en uso:';

  @override
  String get mappingEnable => 'Activar mapeo';

  @override
  String get mappingDisable => 'Desactivar mapeo';

  @override
  String get mappingActive => 'Mapeo activo';

  @override
  String get mappingPaused => 'Mapeo en pausa';

  @override
  String get profileEditor => 'Editor de perfil';

  @override
  String get detectButton => 'Detectar botón';

  @override
  String get waitingController => 'Esperando el mando…';

  @override
  String get switchProfile => 'Cambiar perfil';

  @override
  String get profileLabel => 'Perfil:';

  @override
  String get manageProfiles => 'Gestionar perfiles…';

  @override
  String get inUse => 'En uso';

  @override
  String get useThisProfile => 'Usar este perfil';

  @override
  String get statusCapturing => 'Pulsa un botón o gatillo, o mueve un joystick del mando';

  @override
  String get statusOffline => 'No hay ningún mando conectado — aún puedes editar el perfil';

  @override
  String get statusConnected => 'Haz clic en un punto del mando para asignar una acción';

  @override
  String get statusDisconnected => 'Mando desconectado';

  @override
  String get assignments => 'Asignaciones';

  @override
  String actionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count acciones',
      one: '1 acción',
      zero: 'Ninguna acción',
    );
    return '$_temp0';
  }

  @override
  String actionsInProfile(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count acciones en este perfil',
      one: '1 acción en este perfil',
      zero: 'Ninguna acción en este perfil',
    );
    return '$_temp0';
  }

  @override
  String get allControls => 'Todos los controles';

  @override
  String get bothFireWarning => 'El joystick completo y sus direcciones están asignados a la vez; ambos se activarán.';

  @override
  String get notAssigned => 'Sin asignar';

  @override
  String get leftStick => 'Joystick izquierdo';

  @override
  String get rightStick => 'Joystick derecho';

  @override
  String get dpad => 'Cruceta';

  @override
  String get triangle => 'Triángulo';

  @override
  String get square => 'Cuadrado';

  @override
  String get circle => 'Círculo';

  @override
  String get cross => 'Equis';

  @override
  String get wholeStick => 'Joystick completo';

  @override
  String get dirUp => 'Arriba';

  @override
  String get dirDown => 'Abajo';

  @override
  String get dirLeft => 'Izquierda';

  @override
  String get dirRight => 'Derecha';

  @override
  String get press => 'Pulsar';

  @override
  String pressNamed(String name) {
    return 'Pulsar ($name)';
  }

  @override
  String get kindNone => 'Ninguna';

  @override
  String get kindKey => 'Tecla';

  @override
  String get kindClick => 'Clic';

  @override
  String get kindMove => 'Mover ratón';

  @override
  String get kindScroll => 'Desplazar';

  @override
  String get mouseLeft => 'Izquierdo';

  @override
  String get mouseMiddle => 'Central';

  @override
  String get mouseRight => 'Derecho';

  @override
  String get clickHint => 'Mantén pulsado para arrastrar. Dos pulsaciones rápidas hacen doble clic.';

  @override
  String get responseCurve => 'Curva de respuesta';

  @override
  String get curveLinear => 'Lineal';

  @override
  String get curveQuadratic => 'Cuadrática';

  @override
  String get curveExponential => 'Exponencial';

  @override
  String get deadzone => 'Zona muerta';

  @override
  String get speed => 'Velocidad';

  @override
  String get speedAll => 'Todas';

  @override
  String get sameSpeedAllDirections => 'Igual en todas las direcciones';

  @override
  String get vertical => 'Vertical';

  @override
  String get horizontal => 'Horizontal';

  @override
  String get invertDirection => 'Invertir dirección';

  @override
  String get linesPerStep => 'Líneas por paso';

  @override
  String get triggerFrom => 'Activar a partir de';

  @override
  String get actionMoveMouse => 'Mover ratón';

  @override
  String get actionClickLeft => 'Clic izquierdo';

  @override
  String get actionClickRight => 'Clic derecho';

  @override
  String get actionClickMiddle => 'Clic central';

  @override
  String get actionScrollUp => 'Desplazar arriba';

  @override
  String get actionScrollDown => 'Desplazar abajo';

  @override
  String get actionScrollLeft => 'Desplazar a la izquierda';

  @override
  String get actionScrollRight => 'Desplazar a la derecha';

  @override
  String keyFallback(int code) {
    return 'Tecla $code';
  }

  @override
  String get keySpace => 'Espacio';

  @override
  String keyRight(String name) {
    return '$name derecho';
  }

  @override
  String get pressAKey => 'Pulsa una tecla…';

  @override
  String get clickToRecord => 'Haz clic para grabar';

  @override
  String get record => 'Grabar';

  @override
  String get newProfile => 'Nuevo perfil';

  @override
  String get import => 'Importar';

  @override
  String get restoreSamples => 'Restaurar perfiles de ejemplo';

  @override
  String get defaultProfileName => 'Mi perfil';

  @override
  String imported(String name) {
    return '“$name” importado';
  }

  @override
  String get invalidProfileFile => 'El archivo no es un perfil válido';

  @override
  String get samplesRestored => 'Perfiles de ejemplo restaurados';

  @override
  String errorLoadingProfiles(String error) {
    return 'No se pudieron cargar los perfiles: $error';
  }

  @override
  String get profileExported => 'Perfil exportado';

  @override
  String deleteProfileTitle(String name) {
    return '¿Eliminar “$name”?';
  }

  @override
  String get cannotBeUndone => 'Esta acción no se puede deshacer.';

  @override
  String get renameProfile => 'Renombrar perfil';

  @override
  String get moreActions => 'Más acciones';

  @override
  String get rename => 'Renombrar';

  @override
  String get duplicate => 'Duplicar';

  @override
  String get exportMenu => 'Exportar…';

  @override
  String copyName(String name) {
    return '$name (copia)';
  }

  @override
  String get profileFileType => 'Perfil de PadPilot';

  @override
  String get welcome => 'Te damos la bienvenida a PadPilot';

  @override
  String get permissions => 'Permisos';

  @override
  String get tagline => 'Usa tu mando para controlar cualquier app o juego en tu Mac.';

  @override
  String get accessibility => 'Accesibilidad';

  @override
  String get accessibilityDesc => 'Permite que PadPilot simule teclado, ratón, clics y desplazamiento.';

  @override
  String get inputMonitoring => 'Monitorización de Entrada';

  @override
  String get inputMonitoringDesc =>
      'Solo es necesaria para mandos HID genéricos. Los mandos de Xbox, PlayStation y Switch funcionan sin ella.';

  @override
  String get permissionsAutoUpdate =>
      'Tras activarlo en Ajustes del Sistema el estado se actualiza solo. Si no cambia, cierra y vuelve a abrir PadPilot.';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get continueAnyway => 'Continuar de todos modos';

  @override
  String get required => 'Obligatorio';

  @override
  String get optional => 'Opcional';

  @override
  String get allowed => 'Permitido';

  @override
  String get openSystemSettings => 'Abrir Ajustes del Sistema';

  @override
  String get general => 'General';

  @override
  String get launchAtLogin => 'Abrir al iniciar sesión';

  @override
  String get launchAtLoginDesc => 'PadPilot se inicia en la barra de menús al iniciar sesión.';

  @override
  String couldNotChange(String error) {
    return 'No se pudo cambiar: $error';
  }

  @override
  String get globalShortcut => 'Atajo global';

  @override
  String get globalShortcutDesc => 'Activa y desactiva el mapeo desde cualquier lugar.';

  @override
  String get shortcutNeedsModifier => 'Usa al menos un modificador (⌘, ⌥, ⌃ o ⇧).';

  @override
  String get shortcutInUse => 'Otra app ya usa ese atajo.';

  @override
  String get removeShortcut => 'Quitar atajo';

  @override
  String get permissionDenied => 'No permitido';

  @override
  String get permissionUnknown => 'No solicitado';

  @override
  String get managePermissions => 'Gestionar permisos';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Predeterminado del sistema';

  @override
  String get trayMappingActive => 'Mapeo activo';

  @override
  String trayProfile(String name) {
    return 'Perfil: $name';
  }

  @override
  String get trayOpen => 'Abrir PadPilot';

  @override
  String get trayQuit => 'Salir de PadPilot';

  @override
  String get sampleMediaPlayer => 'Reproductor multimedia';

  @override
  String get sampleNavigation => 'Navegación';

  @override
  String get samplePhotoEditing => 'Edición de fotos';

  @override
  String get diagnostics => 'Diagnóstico del mando';

  @override
  String get diagnosticsShort => 'Diagnóstico';

  @override
  String get resetStats => 'Reiniciar mediciones';

  @override
  String eventsPerSecond(int rate) {
    return '$rate eventos/s';
  }

  @override
  String get rangeX => 'Rango X';

  @override
  String get rangeY => 'Rango Y';

  @override
  String get resolution => 'Resolución';

  @override
  String resolutionValue(String bits, int levels) {
    return '≈$bits bits ($levels pasos)';
  }

  @override
  String get measuring => 'Mueve el joystick para medir';

  @override
  String get outerRadius => 'Alcance medio en el borde';

  @override
  String get circularityError => 'Error de circularidad';

  @override
  String get center => 'Desplazamiento del centro';

  @override
  String get noise => 'Ruido en reposo (σ)';

  @override
  String get suggestedDeadzone => 'Zona muerta sugerida';

  @override
  String get calibrateCenter => 'Calibrar centro';

  @override
  String calibrating(int seconds) {
    return 'No lo muevas… ${seconds}s';
  }

  @override
  String calibrationSamples(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count muestras en reposo',
      one: '1 muestra en reposo',
      zero: 'Sin movimiento en reposo (estable)',
    );
    return '$_temp0';
  }

  @override
  String get applyDeadzone => 'Aplicar al perfil';

  @override
  String deadzoneApplied(int percent, String profile) {
    return 'Zona muerta del $percent% aplicada a “$profile”';
  }

  @override
  String get noMouseMapping =>
      'En el perfil en uso este joystick no mueve el ratón, así que no hay zona muerta que aplicar.';

  @override
  String get triggers => 'Gatillos';

  @override
  String get rawHid => 'HID sin procesar';

  @override
  String get rawHidDesc =>
      'Valores del sensor directamente del informe HID, antes del filtrado y la normalización de GameController en macOS. Requiere Monitorización de Entrada.';

  @override
  String get rawHidEmpty =>
      'Aún no hay datos HID sin procesar. Mueve un joystick; si no aparece nada, concede Monitorización de Entrada.';

  @override
  String get gcNote =>
      'Los valores de arriba vienen de GameController, que macOS ya normaliza. Usa HID sin procesar para ver la señal real del sensor.';

  @override
  String get waitingInput => 'Mueve un joystick o gatillo para empezar';

  @override
  String get games => 'Juegos';

  @override
  String get gameHub => 'Centro de juegos';

  @override
  String get rowContinue => 'Seguir jugando';

  @override
  String get rowPinned => 'Fijados';

  @override
  String get rowNeedsPadPilot => 'Necesitan PadPilot';

  @override
  String get rowReady => 'Listos para jugar';

  @override
  String get rowUnmapped => 'Aún sin perfil';

  @override
  String get rowNative => 'Compatibilidad nativa con mando';

  @override
  String get rowOwned => 'En tu biblioteca, sin instalar';

  @override
  String get rowWindowsOnly => 'Solo Windows';

  @override
  String get rowFeatured => 'Destacados en Steam';

  @override
  String get rowSearch => 'Resultados de búsqueda';

  @override
  String get badgeFull => 'Compatibilidad total con mando';

  @override
  String get badgePartial => 'Compatibilidad parcial con mando';

  @override
  String get badgeNone => 'Sin compatibilidad con mando';

  @override
  String get badgeWindowsOnly => 'Solo Windows';

  @override
  String get badgeInstalled => 'Instalado';

  @override
  String discount(int percent) {
    return '-$percent%';
  }

  @override
  String get play => 'Jugar';

  @override
  String get details => 'Detalles';

  @override
  String get openStore => 'Página de la tienda';

  @override
  String get padpilotForGame => 'PadPilot en este juego';

  @override
  String get profileForGame => 'Perfil';

  @override
  String get useProfileInUse => 'Usar el perfil en uso';

  @override
  String get autoSwitch => 'Cambiar automáticamente';

  @override
  String get autoSwitchDesc => 'Usa este perfil mientras el juego esté en primer plano y luego vuelve al anterior.';

  @override
  String get padpilotOffForGame => 'Desactivar PadPilot en este juego';

  @override
  String get padpilotOffDesc => 'Recomendado si el juego ya es compatible con mando, para evitar entradas duplicadas.';

  @override
  String get hideGame => 'Ocultar del centro';

  @override
  String get pinGame => 'Fijar arriba';

  @override
  String get createProfileForGame => 'Nuevo perfil para este juego';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String suggested(String name) {
    return 'Sugerido: $name';
  }

  @override
  String get useSuggestion => 'Usar';

  @override
  String get playtime => 'Tiempo de juego';

  @override
  String playtimeHours(String hours) {
    return '$hours h';
  }

  @override
  String get lastPlayed => 'Última sesión';

  @override
  String get installSize => 'Tamaño en disco';

  @override
  String get releaseDate => 'Lanzamiento';

  @override
  String get genres => 'Géneros';

  @override
  String get developer => 'Desarrollador';

  @override
  String get platforms => 'Plataformas';

  @override
  String nowPlaying(String game, String profile) {
    return 'Jugando a $game · perfil $profile';
  }

  @override
  String nowPlayingPaused(String game) {
    return 'Jugando a $game · PadPilot desactivado';
  }

  @override
  String gamesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count juegos',
      one: '1 juego',
      zero: 'Ningún juego',
    );
    return '$_temp0';
  }

  @override
  String get steamNotFound => 'Steam no está instalado en este Mac';

  @override
  String get steamNotFoundDesc =>
      'Instala Steam para ver tus juegos aquí, o vincula tu cuenta de Steam para ver los juegos que tienes.';

  @override
  String get linkSteam => 'Vincular cuenta de Steam';

  @override
  String get steamAccount => 'Cuenta de Steam';

  @override
  String linkedAs(String name) {
    return 'Vinculada como $name';
  }

  @override
  String get unlink => 'Desvincular';

  @override
  String get apiKey => 'Clave de la Web API';

  @override
  String get steamId => 'SteamID64';

  @override
  String get getApiKey => 'Obtener una clave';

  @override
  String get linkSteamDesc =>
      'Opcional: añade los juegos que tienes pero no has instalado, y el tiempo de juego. La clave se guarda en el Llavero de macOS y solo se envía a Steam.';

  @override
  String linkFailed(String error) {
    return 'No se pudo vincular: $error';
  }

  @override
  String get invalidKey => 'Steam rechazó esta clave o SteamID.';

  @override
  String get privateProfileHint =>
      'Steam no devolvió juegos. Comprueba que los detalles de juego de tu perfil sean públicos.';

  @override
  String get link => 'Vincular';

  @override
  String get searchGames => 'Buscar juegos';

  @override
  String get offlineError => 'No se pudo conectar con Steam. Mostrando lo guardado en caché.';

  @override
  String get noDescription => 'No hay descripción disponible.';

  @override
  String get loading => 'Cargando…';

  @override
  String get diagStep1 => 'Gira cada joystick despacio pegado al borde, unas cuantas vueltas completas.';

  @override
  String get diagStep2 => 'Suéltalo, pulsa “Calibrar centro” y no lo muevas durante 2 s.';

  @override
  String get diagStep3 => 'Aplica la zona muerta sugerida al perfil en uso.';

  @override
  String get groupSignal => 'Señal';

  @override
  String get groupCircularity => 'Circularidad';

  @override
  String get groupCenter => 'Centro en reposo';

  @override
  String get positionX => 'Posición X';

  @override
  String get positionY => 'Posición Y';

  @override
  String get coverageShort => 'Borde recorrido';

  @override
  String get rotateMore => 'Gira más para medir';

  @override
  String get legendEnvelope => 'Contorno del borde';

  @override
  String get legendDeadzone => 'Zona muerta';

  @override
  String get legendCenter => 'Centro medido';

  @override
  String get legendTrail => 'Movimiento reciente';

  @override
  String get verdictGood => 'Bien';

  @override
  String get verdictWarn => 'Revisar';

  @override
  String get verdictBad => 'Mal';

  @override
  String get notMeasured => 'Sin medir';

  @override
  String get triggerLeft => 'Gatillo izquierdo';

  @override
  String get triggerRight => 'Gatillo derecho';

  @override
  String get axis => 'Eje';

  @override
  String get bits => 'Bits';

  @override
  String get toggleShortcutTitle => 'Activar/desactivar el mapeo';

  @override
  String get open => 'Abrir';

  @override
  String get padpilotOffShort => 'PadPilot desactivado';

  @override
  String get notListedHint =>
      '¿PadPilot no aparece en la lista? Haz clic en “+” en Ajustes del Sistema y elige PadPilot.app.';

  @override
  String get revealApp => 'Mostrar app en el Finder';

  @override
  String get restartApp => 'Reiniciar PadPilot';

  @override
  String get restartRequiredDesc => 'Monitorización de Entrada permitida. Reinicia PadPilot para que surta efecto.';

  @override
  String get windowsPreview =>
      'Vista previa en Windows: los perfiles y el centro de juegos funcionan, pero el mapeo del mando aún no está disponible en Windows.';
}

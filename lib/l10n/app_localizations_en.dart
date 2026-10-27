// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get howToConnect => 'How to connect';

  @override
  String get profiles => 'Profiles';

  @override
  String get settings => 'Settings';

  @override
  String get permissionsPending => 'Permissions pending';

  @override
  String get back => 'Back';

  @override
  String get gotIt => 'Got it';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get name => 'Name';

  @override
  String get connectTitle => 'Connect a controller';

  @override
  String get tipUsbTitle => 'USB';

  @override
  String get tipUsb => 'Plug in the cable. The controller shows up here in a few seconds.';

  @override
  String get tipBluetoothTitle => 'Bluetooth';

  @override
  String get tipBluetooth => 'Put the controller in pairing mode and connect it in System Settings › Bluetooth.';

  @override
  String get tipXbox360Title => 'Wireless Xbox 360';

  @override
  String get tipXbox360 => 'Doesn\'t use Bluetooth: it needs Microsoft\'s wireless receiver.';

  @override
  String get tipPs3Title => 'PS3 over USB';

  @override
  String get tipPs3 => 'You may need to press the PS button once.';

  @override
  String get tipHidTitle => 'Generic controllers';

  @override
  String get tipHid => 'Require the Input Monitoring permission to be detected.';

  @override
  String get connected => 'Connected';

  @override
  String get genericHid => 'Generic HID';

  @override
  String get controllerFallback => 'Controller';

  @override
  String get noController => 'No controller connected';

  @override
  String get noControllerHint => 'Connect via USB or Bluetooth. It will show up here automatically.';

  @override
  String get editAnyway => 'Edit profile anyway';

  @override
  String get switchActiveProfile => 'Switch profile in use';

  @override
  String get profileInUse => 'Profile in use:';

  @override
  String get mappingEnable => 'Turn mapping on';

  @override
  String get mappingDisable => 'Turn mapping off';

  @override
  String get mappingActive => 'Mapping on';

  @override
  String get mappingPaused => 'Mapping paused';

  @override
  String get profileEditor => 'Profile editor';

  @override
  String get detectButton => 'Detect button';

  @override
  String get waitingController => 'Waiting for controller…';

  @override
  String get switchProfile => 'Switch profile';

  @override
  String get profileLabel => 'Profile:';

  @override
  String get manageProfiles => 'Manage profiles…';

  @override
  String get inUse => 'In use';

  @override
  String get useThisProfile => 'Use this profile';

  @override
  String get statusCapturing => 'Press a button or trigger, or move a stick on the controller';

  @override
  String get statusOffline => 'No controller connected — you can still edit the profile';

  @override
  String get statusConnected => 'Click a point on the controller to assign an action';

  @override
  String get statusDisconnected => 'Controller disconnected';

  @override
  String get assignments => 'Assignments';

  @override
  String actionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actions',
      one: '1 action',
      zero: 'No actions',
    );
    return '$_temp0';
  }

  @override
  String actionsInProfile(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actions in this profile',
      one: '1 action in this profile',
      zero: 'No actions in this profile',
    );
    return '$_temp0';
  }

  @override
  String get allControls => 'All controls';

  @override
  String get bothFireWarning => 'The whole stick and its directions are both assigned; both will fire.';

  @override
  String get notAssigned => 'Not assigned';

  @override
  String get leftStick => 'Left stick';

  @override
  String get rightStick => 'Right stick';

  @override
  String get dpad => 'D-pad';

  @override
  String get triangle => 'Triangle';

  @override
  String get square => 'Square';

  @override
  String get circle => 'Circle';

  @override
  String get cross => 'Cross';

  @override
  String get wholeStick => 'Whole stick';

  @override
  String get dirUp => 'Up';

  @override
  String get dirDown => 'Down';

  @override
  String get dirLeft => 'Left';

  @override
  String get dirRight => 'Right';

  @override
  String get press => 'Press';

  @override
  String pressNamed(String name) {
    return 'Press ($name)';
  }

  @override
  String get kindNone => 'None';

  @override
  String get kindKey => 'Key';

  @override
  String get kindClick => 'Click';

  @override
  String get kindMove => 'Move mouse';

  @override
  String get kindScroll => 'Scroll';

  @override
  String get mouseLeft => 'Left';

  @override
  String get mouseMiddle => 'Middle';

  @override
  String get mouseRight => 'Right';

  @override
  String get clickHint => 'Hold to drag. Two quick presses make a double-click.';

  @override
  String get responseCurve => 'Response curve';

  @override
  String get curveLinear => 'Linear';

  @override
  String get curveQuadratic => 'Quadratic';

  @override
  String get curveExponential => 'Exponential';

  @override
  String get deadzone => 'Dead zone';

  @override
  String get speed => 'Speed';

  @override
  String get speedAll => 'All';

  @override
  String get sameSpeedAllDirections => 'Same in every direction';

  @override
  String get vertical => 'Vertical';

  @override
  String get horizontal => 'Horizontal';

  @override
  String get invertDirection => 'Invert direction';

  @override
  String get linesPerStep => 'Lines per step';

  @override
  String get triggerFrom => 'Fire from';

  @override
  String get actionMoveMouse => 'Move mouse';

  @override
  String get actionClickLeft => 'Left click';

  @override
  String get actionClickRight => 'Right click';

  @override
  String get actionClickMiddle => 'Middle click';

  @override
  String get actionScrollUp => 'Scroll up';

  @override
  String get actionScrollDown => 'Scroll down';

  @override
  String get actionScrollLeft => 'Scroll left';

  @override
  String get actionScrollRight => 'Scroll right';

  @override
  String keyFallback(int code) {
    return 'Key $code';
  }

  @override
  String get keySpace => 'Space';

  @override
  String keyRight(String name) {
    return 'Right $name';
  }

  @override
  String get pressAKey => 'Press a key…';

  @override
  String get clickToRecord => 'Click to record';

  @override
  String get record => 'Record';

  @override
  String get newProfile => 'New profile';

  @override
  String get import => 'Import';

  @override
  String get restoreSamples => 'Restore sample profiles';

  @override
  String get defaultProfileName => 'My profile';

  @override
  String imported(String name) {
    return '“$name” imported';
  }

  @override
  String get invalidProfileFile => 'This file isn\'t a valid profile';

  @override
  String get samplesRestored => 'Sample profiles restored';

  @override
  String errorLoadingProfiles(String error) {
    return 'Couldn\'t load profiles: $error';
  }

  @override
  String get profileExported => 'Profile exported';

  @override
  String deleteProfileTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get cannotBeUndone => 'This can\'t be undone.';

  @override
  String get renameProfile => 'Rename profile';

  @override
  String get moreActions => 'More actions';

  @override
  String get rename => 'Rename';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get exportMenu => 'Export…';

  @override
  String copyName(String name) {
    return '$name (copy)';
  }

  @override
  String get profileFileType => 'PadPilot profile';

  @override
  String get welcome => 'Welcome to PadPilot';

  @override
  String get permissions => 'Permissions';

  @override
  String get tagline => 'Use your controller to drive any app or game on your Mac.';

  @override
  String get accessibility => 'Accessibility';

  @override
  String get accessibilityDesc => 'Lets PadPilot simulate keyboard, mouse, clicks and scrolling.';

  @override
  String get inputMonitoring => 'Input Monitoring';

  @override
  String get inputMonitoringDesc =>
      'Only needed for generic HID controllers. Xbox, PlayStation and Switch controllers work without it.';

  @override
  String get permissionsAutoUpdate =>
      'After you enable it in System Settings the status updates by itself. If it doesn\'t, quit and reopen PadPilot.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get continueAnyway => 'Continue anyway';

  @override
  String get required => 'Required';

  @override
  String get optional => 'Optional';

  @override
  String get allowed => 'Allowed';

  @override
  String get openSystemSettings => 'Open System Settings';

  @override
  String get general => 'General';

  @override
  String get launchAtLogin => 'Launch at login';

  @override
  String get launchAtLoginDesc => 'PadPilot starts in the menu bar when you log in.';

  @override
  String couldNotChange(String error) {
    return 'Couldn\'t change this: $error';
  }

  @override
  String get globalShortcut => 'Global shortcut';

  @override
  String get globalShortcutDesc => 'Turns mapping on and off from anywhere.';

  @override
  String get shortcutNeedsModifier => 'Use at least one modifier (⌘, ⌥, ⌃ or ⇧).';

  @override
  String get shortcutInUse => 'That shortcut is already used by another app.';

  @override
  String get removeShortcut => 'Remove shortcut';

  @override
  String get permissionDenied => 'Not allowed';

  @override
  String get permissionUnknown => 'Not requested';

  @override
  String get managePermissions => 'Manage permissions';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get trayMappingActive => 'Mapping on';

  @override
  String trayProfile(String name) {
    return 'Profile: $name';
  }

  @override
  String get trayOpen => 'Open PadPilot';

  @override
  String get trayQuit => 'Quit PadPilot';

  @override
  String get sampleMediaPlayer => 'Media Player';

  @override
  String get sampleNavigation => 'Browsing';

  @override
  String get samplePhotoEditing => 'Photo editing';

  @override
  String get diagnostics => 'Controller diagnostics';

  @override
  String get diagnosticsShort => 'Diagnostics';

  @override
  String get resetStats => 'Reset measurements';

  @override
  String eventsPerSecond(int rate) {
    return '$rate events/s';
  }

  @override
  String get rangeX => 'X range';

  @override
  String get rangeY => 'Y range';

  @override
  String get resolution => 'Resolution';

  @override
  String resolutionValue(String bits, int levels) {
    return '≈$bits bits ($levels steps)';
  }

  @override
  String get measuring => 'Move the stick to measure';

  @override
  String get outerRadius => 'Average edge reach';

  @override
  String get circularityError => 'Roundness error';

  @override
  String get center => 'Center offset';

  @override
  String get noise => 'Noise at rest (σ)';

  @override
  String get suggestedDeadzone => 'Suggested dead zone';

  @override
  String get calibrateCenter => 'Calibrate center';

  @override
  String calibrating(int seconds) {
    return 'Keep still… ${seconds}s';
  }

  @override
  String calibrationSamples(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count samples at rest',
      one: '1 sample at rest',
      zero: 'No movement at rest (stable)',
    );
    return '$_temp0';
  }

  @override
  String get applyDeadzone => 'Apply to profile';

  @override
  String deadzoneApplied(int percent, String profile) {
    return 'Dead zone $percent% applied to “$profile”';
  }

  @override
  String get noMouseMapping =>
      'In the profile in use this stick doesn\'t move the mouse, so there\'s no dead zone to apply.';

  @override
  String get triggers => 'Triggers';

  @override
  String get rawHid => 'Raw HID';

  @override
  String get rawHidDesc =>
      'Sensor counts straight from the HID report, before macOS GameController filtering and normalization. Requires Input Monitoring.';

  @override
  String get rawHidEmpty => 'No raw HID data yet. Move a stick; if nothing shows up, grant Input Monitoring.';

  @override
  String get gcNote =>
      'Values above come from GameController, which macOS already normalizes. Use Raw HID to inspect the real sensor signal.';

  @override
  String get waitingInput => 'Move a stick or trigger to start';

  @override
  String get games => 'Games';

  @override
  String get gameHub => 'Game hub';

  @override
  String get rowContinue => 'Continue playing';

  @override
  String get rowPinned => 'Pinned';

  @override
  String get rowNeedsPadPilot => 'Needs PadPilot';

  @override
  String get rowReady => 'Ready to play';

  @override
  String get rowUnmapped => 'No profile yet';

  @override
  String get rowNative => 'Native controller support';

  @override
  String get rowOwned => 'Owned, not installed';

  @override
  String get rowWindowsOnly => 'Windows only';

  @override
  String get rowFeatured => 'Featured on Steam';

  @override
  String get rowSearch => 'Search results';

  @override
  String get badgeFull => 'Full controller support';

  @override
  String get badgePartial => 'Partial controller support';

  @override
  String get badgeNone => 'No controller support';

  @override
  String get badgeWindowsOnly => 'Windows only';

  @override
  String get badgeInstalled => 'Installed';

  @override
  String discount(int percent) {
    return '-$percent%';
  }

  @override
  String get play => 'Play';

  @override
  String get details => 'Details';

  @override
  String get openStore => 'Store page';

  @override
  String get padpilotForGame => 'PadPilot for this game';

  @override
  String get profileForGame => 'Profile';

  @override
  String get useProfileInUse => 'Use the profile in use';

  @override
  String get autoSwitch => 'Switch automatically';

  @override
  String get autoSwitchDesc => 'Uses this profile while the game is in front, then goes back to the previous one.';

  @override
  String get padpilotOffForGame => 'Turn PadPilot off for this game';

  @override
  String get padpilotOffDesc => 'Recommended when the game supports controllers natively, to avoid double input.';

  @override
  String get hideGame => 'Hide from hub';

  @override
  String get pinGame => 'Pin to the top';

  @override
  String get createProfileForGame => 'New profile for this game';

  @override
  String get editProfile => 'Edit profile';

  @override
  String suggested(String name) {
    return 'Suggested: $name';
  }

  @override
  String get useSuggestion => 'Use';

  @override
  String get playtime => 'Playtime';

  @override
  String playtimeHours(String hours) {
    return '$hours h';
  }

  @override
  String get lastPlayed => 'Last session';

  @override
  String get installSize => 'Size on disk';

  @override
  String get releaseDate => 'Release';

  @override
  String get genres => 'Genres';

  @override
  String get developer => 'Developer';

  @override
  String get platforms => 'Platforms';

  @override
  String nowPlaying(String game, String profile) {
    return 'Playing $game · profile $profile';
  }

  @override
  String nowPlayingPaused(String game) {
    return 'Playing $game · PadPilot off';
  }

  @override
  String gamesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count games',
      one: '1 game',
      zero: 'No games',
    );
    return '$_temp0';
  }

  @override
  String get steamNotFound => 'Steam isn\'t installed on this Mac';

  @override
  String get steamNotFoundDesc =>
      'Install Steam to see your games here, or link your Steam account to see the games you own.';

  @override
  String get linkSteam => 'Link Steam account';

  @override
  String get steamAccount => 'Steam account';

  @override
  String linkedAs(String name) {
    return 'Linked as $name';
  }

  @override
  String get unlink => 'Unlink';

  @override
  String get apiKey => 'Web API key';

  @override
  String get steamId => 'SteamID64';

  @override
  String get getApiKey => 'Get a key';

  @override
  String get linkSteamDesc =>
      'Optional: adds games you own but haven\'t installed, plus playtime. The key is stored in the macOS Keychain and only sent to Steam.';

  @override
  String linkFailed(String error) {
    return 'Couldn\'t link: $error';
  }

  @override
  String get invalidKey => 'Steam rejected this key or SteamID.';

  @override
  String get privateProfileHint => 'Steam returned no games. Check that your profile\'s game details are public.';

  @override
  String get link => 'Link';

  @override
  String get searchGames => 'Search games';

  @override
  String get offlineError => 'Couldn\'t reach Steam. Showing what\'s cached.';

  @override
  String get noDescription => 'No description available.';

  @override
  String get loading => 'Loading…';

  @override
  String get diagStep1 => 'Rotate each stick slowly along its edge, a few full turns.';

  @override
  String get diagStep2 => 'Let go, then tap “Calibrate center” and keep it still for 2 s.';

  @override
  String get diagStep3 => 'Apply the suggested dead zone to the profile in use.';

  @override
  String get groupSignal => 'Signal';

  @override
  String get groupCircularity => 'Circularity';

  @override
  String get groupCenter => 'Center at rest';

  @override
  String get positionX => 'X position';

  @override
  String get positionY => 'Y position';

  @override
  String get coverageShort => 'Edge covered';

  @override
  String get rotateMore => 'Rotate more to measure';

  @override
  String get legendEnvelope => 'Edge outline';

  @override
  String get legendDeadzone => 'Dead zone';

  @override
  String get legendCenter => 'Measured center';

  @override
  String get legendTrail => 'Recent movement';

  @override
  String get verdictGood => 'Good';

  @override
  String get verdictWarn => 'Check';

  @override
  String get verdictBad => 'Poor';

  @override
  String get notMeasured => 'Not measured';

  @override
  String get triggerLeft => 'Left trigger';

  @override
  String get triggerRight => 'Right trigger';

  @override
  String get axis => 'Axis';

  @override
  String get bits => 'Bits';

  @override
  String get toggleShortcutTitle => 'Turn mapping on/off';

  @override
  String get open => 'Open';

  @override
  String get padpilotOffShort => 'PadPilot off';

  @override
  String get notListedHint => 'PadPilot not in the list? Click “+” in System Settings and pick PadPilot.app.';

  @override
  String get revealApp => 'Show app in Finder';

  @override
  String get restartApp => 'Restart PadPilot';

  @override
  String get restartRequiredDesc => 'Input Monitoring was allowed. Restart PadPilot for it to take effect.';

  @override
  String get windowsPreview =>
      'Windows preview: profiles and the game hub work, but controller mapping isn\'t available on Windows yet.';
}

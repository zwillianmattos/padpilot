import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('es'), Locale('pt')];

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @howToConnect.
  ///
  /// In en, this message translates to:
  /// **'How to connect'**
  String get howToConnect;

  /// No description provided for @profiles.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get profiles;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @permissionsPending.
  ///
  /// In en, this message translates to:
  /// **'Permissions pending'**
  String get permissionsPending;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @connectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect a controller'**
  String get connectTitle;

  /// No description provided for @tipUsbTitle.
  ///
  /// In en, this message translates to:
  /// **'USB'**
  String get tipUsbTitle;

  /// No description provided for @tipUsb.
  ///
  /// In en, this message translates to:
  /// **'Plug in the cable. The controller shows up here in a few seconds.'**
  String get tipUsb;

  /// No description provided for @tipBluetoothTitle.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth'**
  String get tipBluetoothTitle;

  /// No description provided for @tipBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Put the controller in pairing mode and connect it in System Settings › Bluetooth.'**
  String get tipBluetooth;

  /// No description provided for @tipXbox360Title.
  ///
  /// In en, this message translates to:
  /// **'Wireless Xbox 360'**
  String get tipXbox360Title;

  /// No description provided for @tipXbox360.
  ///
  /// In en, this message translates to:
  /// **'Doesn\'t use Bluetooth: it needs Microsoft\'s wireless receiver.'**
  String get tipXbox360;

  /// No description provided for @tipPs3Title.
  ///
  /// In en, this message translates to:
  /// **'PS3 over USB'**
  String get tipPs3Title;

  /// No description provided for @tipPs3.
  ///
  /// In en, this message translates to:
  /// **'You may need to press the PS button once.'**
  String get tipPs3;

  /// No description provided for @tipHidTitle.
  ///
  /// In en, this message translates to:
  /// **'Generic controllers'**
  String get tipHidTitle;

  /// No description provided for @tipHid.
  ///
  /// In en, this message translates to:
  /// **'Require the Input Monitoring permission to be detected.'**
  String get tipHid;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @genericHid.
  ///
  /// In en, this message translates to:
  /// **'Generic HID'**
  String get genericHid;

  /// No description provided for @controllerFallback.
  ///
  /// In en, this message translates to:
  /// **'Controller'**
  String get controllerFallback;

  /// No description provided for @noController.
  ///
  /// In en, this message translates to:
  /// **'No controller connected'**
  String get noController;

  /// No description provided for @noControllerHint.
  ///
  /// In en, this message translates to:
  /// **'Connect via USB or Bluetooth. It will show up here automatically.'**
  String get noControllerHint;

  /// No description provided for @editAnyway.
  ///
  /// In en, this message translates to:
  /// **'Edit profile anyway'**
  String get editAnyway;

  /// No description provided for @switchActiveProfile.
  ///
  /// In en, this message translates to:
  /// **'Switch profile in use'**
  String get switchActiveProfile;

  /// No description provided for @profileInUse.
  ///
  /// In en, this message translates to:
  /// **'Profile in use:'**
  String get profileInUse;

  /// No description provided for @mappingEnable.
  ///
  /// In en, this message translates to:
  /// **'Turn mapping on'**
  String get mappingEnable;

  /// No description provided for @mappingDisable.
  ///
  /// In en, this message translates to:
  /// **'Turn mapping off'**
  String get mappingDisable;

  /// No description provided for @mappingActive.
  ///
  /// In en, this message translates to:
  /// **'Mapping on'**
  String get mappingActive;

  /// No description provided for @mappingPaused.
  ///
  /// In en, this message translates to:
  /// **'Mapping paused'**
  String get mappingPaused;

  /// No description provided for @profileEditor.
  ///
  /// In en, this message translates to:
  /// **'Profile editor'**
  String get profileEditor;

  /// No description provided for @detectButton.
  ///
  /// In en, this message translates to:
  /// **'Detect button'**
  String get detectButton;

  /// No description provided for @waitingController.
  ///
  /// In en, this message translates to:
  /// **'Waiting for controller…'**
  String get waitingController;

  /// No description provided for @switchProfile.
  ///
  /// In en, this message translates to:
  /// **'Switch profile'**
  String get switchProfile;

  /// No description provided for @profileLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile:'**
  String get profileLabel;

  /// No description provided for @manageProfiles.
  ///
  /// In en, this message translates to:
  /// **'Manage profiles…'**
  String get manageProfiles;

  /// No description provided for @inUse.
  ///
  /// In en, this message translates to:
  /// **'In use'**
  String get inUse;

  /// No description provided for @useThisProfile.
  ///
  /// In en, this message translates to:
  /// **'Use this profile'**
  String get useThisProfile;

  /// No description provided for @statusCapturing.
  ///
  /// In en, this message translates to:
  /// **'Press a button or trigger, or move a stick on the controller'**
  String get statusCapturing;

  /// No description provided for @statusOffline.
  ///
  /// In en, this message translates to:
  /// **'No controller connected — you can still edit the profile'**
  String get statusOffline;

  /// No description provided for @statusConnected.
  ///
  /// In en, this message translates to:
  /// **'Click a point on the controller to assign an action'**
  String get statusConnected;

  /// No description provided for @statusDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Controller disconnected'**
  String get statusDisconnected;

  /// No description provided for @assignments.
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get assignments;

  /// No description provided for @actionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No actions} =1{1 action} other{{count} actions}}'**
  String actionsCount(int count);

  /// No description provided for @actionsInProfile.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No actions in this profile} =1{1 action in this profile} other{{count} actions in this profile}}'**
  String actionsInProfile(int count);

  /// No description provided for @allControls.
  ///
  /// In en, this message translates to:
  /// **'All controls'**
  String get allControls;

  /// No description provided for @bothFireWarning.
  ///
  /// In en, this message translates to:
  /// **'The whole stick and its directions are both assigned; both will fire.'**
  String get bothFireWarning;

  /// No description provided for @notAssigned.
  ///
  /// In en, this message translates to:
  /// **'Not assigned'**
  String get notAssigned;

  /// No description provided for @leftStick.
  ///
  /// In en, this message translates to:
  /// **'Left stick'**
  String get leftStick;

  /// No description provided for @rightStick.
  ///
  /// In en, this message translates to:
  /// **'Right stick'**
  String get rightStick;

  /// No description provided for @dpad.
  ///
  /// In en, this message translates to:
  /// **'D-pad'**
  String get dpad;

  /// No description provided for @triangle.
  ///
  /// In en, this message translates to:
  /// **'Triangle'**
  String get triangle;

  /// No description provided for @square.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get square;

  /// No description provided for @circle.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get circle;

  /// No description provided for @cross.
  ///
  /// In en, this message translates to:
  /// **'Cross'**
  String get cross;

  /// No description provided for @wholeStick.
  ///
  /// In en, this message translates to:
  /// **'Whole stick'**
  String get wholeStick;

  /// No description provided for @dirUp.
  ///
  /// In en, this message translates to:
  /// **'Up'**
  String get dirUp;

  /// No description provided for @dirDown.
  ///
  /// In en, this message translates to:
  /// **'Down'**
  String get dirDown;

  /// No description provided for @dirLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get dirLeft;

  /// No description provided for @dirRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get dirRight;

  /// No description provided for @press.
  ///
  /// In en, this message translates to:
  /// **'Press'**
  String get press;

  /// No description provided for @pressNamed.
  ///
  /// In en, this message translates to:
  /// **'Press ({name})'**
  String pressNamed(String name);

  /// No description provided for @kindNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get kindNone;

  /// No description provided for @kindKey.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get kindKey;

  /// No description provided for @kindClick.
  ///
  /// In en, this message translates to:
  /// **'Click'**
  String get kindClick;

  /// No description provided for @kindMove.
  ///
  /// In en, this message translates to:
  /// **'Move mouse'**
  String get kindMove;

  /// No description provided for @kindScroll.
  ///
  /// In en, this message translates to:
  /// **'Scroll'**
  String get kindScroll;

  /// No description provided for @mouseLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get mouseLeft;

  /// No description provided for @mouseMiddle.
  ///
  /// In en, this message translates to:
  /// **'Middle'**
  String get mouseMiddle;

  /// No description provided for @mouseRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get mouseRight;

  /// No description provided for @clickHint.
  ///
  /// In en, this message translates to:
  /// **'Hold to drag. Two quick presses make a double-click.'**
  String get clickHint;

  /// No description provided for @responseCurve.
  ///
  /// In en, this message translates to:
  /// **'Response curve'**
  String get responseCurve;

  /// No description provided for @curveLinear.
  ///
  /// In en, this message translates to:
  /// **'Linear'**
  String get curveLinear;

  /// No description provided for @curveQuadratic.
  ///
  /// In en, this message translates to:
  /// **'Quadratic'**
  String get curveQuadratic;

  /// No description provided for @curveExponential.
  ///
  /// In en, this message translates to:
  /// **'Exponential'**
  String get curveExponential;

  /// No description provided for @deadzone.
  ///
  /// In en, this message translates to:
  /// **'Dead zone'**
  String get deadzone;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @speedAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get speedAll;

  /// No description provided for @sameSpeedAllDirections.
  ///
  /// In en, this message translates to:
  /// **'Same in every direction'**
  String get sameSpeedAllDirections;

  /// No description provided for @vertical.
  ///
  /// In en, this message translates to:
  /// **'Vertical'**
  String get vertical;

  /// No description provided for @horizontal.
  ///
  /// In en, this message translates to:
  /// **'Horizontal'**
  String get horizontal;

  /// No description provided for @invertDirection.
  ///
  /// In en, this message translates to:
  /// **'Invert direction'**
  String get invertDirection;

  /// No description provided for @linesPerStep.
  ///
  /// In en, this message translates to:
  /// **'Lines per step'**
  String get linesPerStep;

  /// No description provided for @triggerFrom.
  ///
  /// In en, this message translates to:
  /// **'Fire from'**
  String get triggerFrom;

  /// No description provided for @actionMoveMouse.
  ///
  /// In en, this message translates to:
  /// **'Move mouse'**
  String get actionMoveMouse;

  /// No description provided for @actionClickLeft.
  ///
  /// In en, this message translates to:
  /// **'Left click'**
  String get actionClickLeft;

  /// No description provided for @actionClickRight.
  ///
  /// In en, this message translates to:
  /// **'Right click'**
  String get actionClickRight;

  /// No description provided for @actionClickMiddle.
  ///
  /// In en, this message translates to:
  /// **'Middle click'**
  String get actionClickMiddle;

  /// No description provided for @actionScrollUp.
  ///
  /// In en, this message translates to:
  /// **'Scroll up'**
  String get actionScrollUp;

  /// No description provided for @actionScrollDown.
  ///
  /// In en, this message translates to:
  /// **'Scroll down'**
  String get actionScrollDown;

  /// No description provided for @actionScrollLeft.
  ///
  /// In en, this message translates to:
  /// **'Scroll left'**
  String get actionScrollLeft;

  /// No description provided for @actionScrollRight.
  ///
  /// In en, this message translates to:
  /// **'Scroll right'**
  String get actionScrollRight;

  /// No description provided for @keyFallback.
  ///
  /// In en, this message translates to:
  /// **'Key {code}'**
  String keyFallback(int code);

  /// No description provided for @keySpace.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get keySpace;

  /// No description provided for @keyRight.
  ///
  /// In en, this message translates to:
  /// **'Right {name}'**
  String keyRight(String name);

  /// No description provided for @pressAKey.
  ///
  /// In en, this message translates to:
  /// **'Press a key…'**
  String get pressAKey;

  /// No description provided for @clickToRecord.
  ///
  /// In en, this message translates to:
  /// **'Click to record'**
  String get clickToRecord;

  /// No description provided for @record.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get record;

  /// No description provided for @newProfile.
  ///
  /// In en, this message translates to:
  /// **'New profile'**
  String get newProfile;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @restoreSamples.
  ///
  /// In en, this message translates to:
  /// **'Restore sample profiles'**
  String get restoreSamples;

  /// No description provided for @defaultProfileName.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get defaultProfileName;

  /// No description provided for @imported.
  ///
  /// In en, this message translates to:
  /// **'“{name}” imported'**
  String imported(String name);

  /// No description provided for @invalidProfileFile.
  ///
  /// In en, this message translates to:
  /// **'This file isn\'t a valid profile'**
  String get invalidProfileFile;

  /// No description provided for @samplesRestored.
  ///
  /// In en, this message translates to:
  /// **'Sample profiles restored'**
  String get samplesRestored;

  /// No description provided for @errorLoadingProfiles.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load profiles: {error}'**
  String errorLoadingProfiles(String error);

  /// No description provided for @profileExported.
  ///
  /// In en, this message translates to:
  /// **'Profile exported'**
  String get profileExported;

  /// No description provided for @deleteProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String deleteProfileTitle(String name);

  /// No description provided for @cannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone.'**
  String get cannotBeUndone;

  /// No description provided for @renameProfile.
  ///
  /// In en, this message translates to:
  /// **'Rename profile'**
  String get renameProfile;

  /// No description provided for @moreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get moreActions;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// No description provided for @exportMenu.
  ///
  /// In en, this message translates to:
  /// **'Export…'**
  String get exportMenu;

  /// No description provided for @copyName.
  ///
  /// In en, this message translates to:
  /// **'{name} (copy)'**
  String copyName(String name);

  /// No description provided for @profileFileType.
  ///
  /// In en, this message translates to:
  /// **'PadPilot profile'**
  String get profileFileType;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to PadPilot'**
  String get welcome;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Use your controller to drive any app or game on your Mac.'**
  String get tagline;

  /// No description provided for @accessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility;

  /// No description provided for @accessibilityDesc.
  ///
  /// In en, this message translates to:
  /// **'Lets PadPilot simulate keyboard, mouse, clicks and scrolling.'**
  String get accessibilityDesc;

  /// No description provided for @inputMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Input Monitoring'**
  String get inputMonitoring;

  /// No description provided for @inputMonitoringDesc.
  ///
  /// In en, this message translates to:
  /// **'Only needed for generic HID controllers. Xbox, PlayStation and Switch controllers work without it.'**
  String get inputMonitoringDesc;

  /// No description provided for @permissionsAutoUpdate.
  ///
  /// In en, this message translates to:
  /// **'After you enable it in System Settings the status updates by itself. If it doesn\'t, quit and reopen PadPilot.'**
  String get permissionsAutoUpdate;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @continueAnyway.
  ///
  /// In en, this message translates to:
  /// **'Continue anyway'**
  String get continueAnyway;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @allowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get allowed;

  /// No description provided for @openSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'Open System Settings'**
  String get openSystemSettings;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @launchAtLogin.
  ///
  /// In en, this message translates to:
  /// **'Launch at login'**
  String get launchAtLogin;

  /// No description provided for @launchAtLoginDesc.
  ///
  /// In en, this message translates to:
  /// **'PadPilot starts in the menu bar when you log in.'**
  String get launchAtLoginDesc;

  /// No description provided for @couldNotChange.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t change this: {error}'**
  String couldNotChange(String error);

  /// No description provided for @globalShortcut.
  ///
  /// In en, this message translates to:
  /// **'Global shortcut'**
  String get globalShortcut;

  /// No description provided for @globalShortcutDesc.
  ///
  /// In en, this message translates to:
  /// **'Turns mapping on and off from anywhere.'**
  String get globalShortcutDesc;

  /// No description provided for @shortcutNeedsModifier.
  ///
  /// In en, this message translates to:
  /// **'Use at least one modifier (⌘, ⌥, ⌃ or ⇧).'**
  String get shortcutNeedsModifier;

  /// No description provided for @shortcutInUse.
  ///
  /// In en, this message translates to:
  /// **'That shortcut is already used by another app.'**
  String get shortcutInUse;

  /// No description provided for @removeShortcut.
  ///
  /// In en, this message translates to:
  /// **'Remove shortcut'**
  String get removeShortcut;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Not allowed'**
  String get permissionDenied;

  /// No description provided for @permissionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Not requested'**
  String get permissionUnknown;

  /// No description provided for @managePermissions.
  ///
  /// In en, this message translates to:
  /// **'Manage permissions'**
  String get managePermissions;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @trayMappingActive.
  ///
  /// In en, this message translates to:
  /// **'Mapping on'**
  String get trayMappingActive;

  /// No description provided for @trayProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile: {name}'**
  String trayProfile(String name);

  /// No description provided for @trayOpen.
  ///
  /// In en, this message translates to:
  /// **'Open PadPilot'**
  String get trayOpen;

  /// No description provided for @trayQuit.
  ///
  /// In en, this message translates to:
  /// **'Quit PadPilot'**
  String get trayQuit;

  /// No description provided for @sampleMediaPlayer.
  ///
  /// In en, this message translates to:
  /// **'Media Player'**
  String get sampleMediaPlayer;

  /// No description provided for @sampleNavigation.
  ///
  /// In en, this message translates to:
  /// **'Browsing'**
  String get sampleNavigation;

  /// No description provided for @samplePhotoEditing.
  ///
  /// In en, this message translates to:
  /// **'Photo editing'**
  String get samplePhotoEditing;

  /// No description provided for @diagnostics.
  ///
  /// In en, this message translates to:
  /// **'Controller diagnostics'**
  String get diagnostics;

  /// No description provided for @diagnosticsShort.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get diagnosticsShort;

  /// No description provided for @resetStats.
  ///
  /// In en, this message translates to:
  /// **'Reset measurements'**
  String get resetStats;

  /// No description provided for @eventsPerSecond.
  ///
  /// In en, this message translates to:
  /// **'{rate} events/s'**
  String eventsPerSecond(int rate);

  /// No description provided for @rangeX.
  ///
  /// In en, this message translates to:
  /// **'X range'**
  String get rangeX;

  /// No description provided for @rangeY.
  ///
  /// In en, this message translates to:
  /// **'Y range'**
  String get rangeY;

  /// No description provided for @resolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get resolution;

  /// No description provided for @resolutionValue.
  ///
  /// In en, this message translates to:
  /// **'≈{bits} bits ({levels} steps)'**
  String resolutionValue(String bits, int levels);

  /// No description provided for @measuring.
  ///
  /// In en, this message translates to:
  /// **'Move the stick to measure'**
  String get measuring;

  /// No description provided for @outerRadius.
  ///
  /// In en, this message translates to:
  /// **'Average edge reach'**
  String get outerRadius;

  /// No description provided for @circularityError.
  ///
  /// In en, this message translates to:
  /// **'Roundness error'**
  String get circularityError;

  /// No description provided for @center.
  ///
  /// In en, this message translates to:
  /// **'Center offset'**
  String get center;

  /// No description provided for @noise.
  ///
  /// In en, this message translates to:
  /// **'Noise at rest (σ)'**
  String get noise;

  /// No description provided for @suggestedDeadzone.
  ///
  /// In en, this message translates to:
  /// **'Suggested dead zone'**
  String get suggestedDeadzone;

  /// No description provided for @calibrateCenter.
  ///
  /// In en, this message translates to:
  /// **'Calibrate center'**
  String get calibrateCenter;

  /// No description provided for @calibrating.
  ///
  /// In en, this message translates to:
  /// **'Keep still… {seconds}s'**
  String calibrating(int seconds);

  /// No description provided for @calibrationSamples.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No movement at rest (stable)} =1{1 sample at rest} other{{count} samples at rest}}'**
  String calibrationSamples(int count);

  /// No description provided for @applyDeadzone.
  ///
  /// In en, this message translates to:
  /// **'Apply to profile'**
  String get applyDeadzone;

  /// No description provided for @deadzoneApplied.
  ///
  /// In en, this message translates to:
  /// **'Dead zone {percent}% applied to “{profile}”'**
  String deadzoneApplied(int percent, String profile);

  /// No description provided for @noMouseMapping.
  ///
  /// In en, this message translates to:
  /// **'In the profile in use this stick doesn\'t move the mouse, so there\'s no dead zone to apply.'**
  String get noMouseMapping;

  /// No description provided for @triggers.
  ///
  /// In en, this message translates to:
  /// **'Triggers'**
  String get triggers;

  /// No description provided for @rawHid.
  ///
  /// In en, this message translates to:
  /// **'Raw HID'**
  String get rawHid;

  /// No description provided for @rawHidDesc.
  ///
  /// In en, this message translates to:
  /// **'Sensor counts straight from the HID report, before macOS GameController filtering and normalization. Requires Input Monitoring.'**
  String get rawHidDesc;

  /// No description provided for @rawHidEmpty.
  ///
  /// In en, this message translates to:
  /// **'No raw HID data yet. Move a stick; if nothing shows up, grant Input Monitoring.'**
  String get rawHidEmpty;

  /// No description provided for @gcNote.
  ///
  /// In en, this message translates to:
  /// **'Values above come from GameController, which macOS already normalizes. Use Raw HID to inspect the real sensor signal.'**
  String get gcNote;

  /// No description provided for @waitingInput.
  ///
  /// In en, this message translates to:
  /// **'Move a stick or trigger to start'**
  String get waitingInput;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// No description provided for @gameHub.
  ///
  /// In en, this message translates to:
  /// **'Game hub'**
  String get gameHub;

  /// No description provided for @rowContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue playing'**
  String get rowContinue;

  /// No description provided for @rowPinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get rowPinned;

  /// No description provided for @rowNeedsPadPilot.
  ///
  /// In en, this message translates to:
  /// **'Needs PadPilot'**
  String get rowNeedsPadPilot;

  /// No description provided for @rowReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to play'**
  String get rowReady;

  /// No description provided for @rowUnmapped.
  ///
  /// In en, this message translates to:
  /// **'No profile yet'**
  String get rowUnmapped;

  /// No description provided for @rowNative.
  ///
  /// In en, this message translates to:
  /// **'Native controller support'**
  String get rowNative;

  /// No description provided for @rowOwned.
  ///
  /// In en, this message translates to:
  /// **'Owned, not installed'**
  String get rowOwned;

  /// No description provided for @rowWindowsOnly.
  ///
  /// In en, this message translates to:
  /// **'Windows only'**
  String get rowWindowsOnly;

  /// No description provided for @rowFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured on Steam'**
  String get rowFeatured;

  /// No description provided for @rowSearch.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get rowSearch;

  /// No description provided for @badgeFull.
  ///
  /// In en, this message translates to:
  /// **'Full controller support'**
  String get badgeFull;

  /// No description provided for @badgePartial.
  ///
  /// In en, this message translates to:
  /// **'Partial controller support'**
  String get badgePartial;

  /// No description provided for @badgeNone.
  ///
  /// In en, this message translates to:
  /// **'No controller support'**
  String get badgeNone;

  /// No description provided for @badgeWindowsOnly.
  ///
  /// In en, this message translates to:
  /// **'Windows only'**
  String get badgeWindowsOnly;

  /// No description provided for @badgeInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get badgeInstalled;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'-{percent}%'**
  String discount(int percent);

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @openStore.
  ///
  /// In en, this message translates to:
  /// **'Store page'**
  String get openStore;

  /// No description provided for @padpilotForGame.
  ///
  /// In en, this message translates to:
  /// **'PadPilot for this game'**
  String get padpilotForGame;

  /// No description provided for @profileForGame.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileForGame;

  /// No description provided for @useProfileInUse.
  ///
  /// In en, this message translates to:
  /// **'Use the profile in use'**
  String get useProfileInUse;

  /// No description provided for @autoSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch automatically'**
  String get autoSwitch;

  /// No description provided for @autoSwitchDesc.
  ///
  /// In en, this message translates to:
  /// **'Uses this profile while the game is in front, then goes back to the previous one.'**
  String get autoSwitchDesc;

  /// No description provided for @padpilotOffForGame.
  ///
  /// In en, this message translates to:
  /// **'Turn PadPilot off for this game'**
  String get padpilotOffForGame;

  /// No description provided for @padpilotOffDesc.
  ///
  /// In en, this message translates to:
  /// **'Recommended when the game supports controllers natively, to avoid double input.'**
  String get padpilotOffDesc;

  /// No description provided for @hideGame.
  ///
  /// In en, this message translates to:
  /// **'Hide from hub'**
  String get hideGame;

  /// No description provided for @pinGame.
  ///
  /// In en, this message translates to:
  /// **'Pin to the top'**
  String get pinGame;

  /// No description provided for @createProfileForGame.
  ///
  /// In en, this message translates to:
  /// **'New profile for this game'**
  String get createProfileForGame;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @suggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested: {name}'**
  String suggested(String name);

  /// No description provided for @useSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get useSuggestion;

  /// No description provided for @playtime.
  ///
  /// In en, this message translates to:
  /// **'Playtime'**
  String get playtime;

  /// No description provided for @playtimeHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String playtimeHours(String hours);

  /// No description provided for @lastPlayed.
  ///
  /// In en, this message translates to:
  /// **'Last session'**
  String get lastPlayed;

  /// No description provided for @installSize.
  ///
  /// In en, this message translates to:
  /// **'Size on disk'**
  String get installSize;

  /// No description provided for @releaseDate.
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get releaseDate;

  /// No description provided for @genres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get genres;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @platforms.
  ///
  /// In en, this message translates to:
  /// **'Platforms'**
  String get platforms;

  /// No description provided for @nowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing {game} · profile {profile}'**
  String nowPlaying(String game, String profile);

  /// No description provided for @nowPlayingPaused.
  ///
  /// In en, this message translates to:
  /// **'Playing {game} · PadPilot off'**
  String nowPlayingPaused(String game);

  /// No description provided for @gamesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No games} =1{1 game} other{{count} games}}'**
  String gamesCount(int count);

  /// No description provided for @steamNotFound.
  ///
  /// In en, this message translates to:
  /// **'Steam isn\'t installed on this Mac'**
  String get steamNotFound;

  /// No description provided for @steamNotFoundDesc.
  ///
  /// In en, this message translates to:
  /// **'Install Steam to see your games here, or link your Steam account to see the games you own.'**
  String get steamNotFoundDesc;

  /// No description provided for @linkSteam.
  ///
  /// In en, this message translates to:
  /// **'Link Steam account'**
  String get linkSteam;

  /// No description provided for @steamAccount.
  ///
  /// In en, this message translates to:
  /// **'Steam account'**
  String get steamAccount;

  /// No description provided for @linkedAs.
  ///
  /// In en, this message translates to:
  /// **'Linked as {name}'**
  String linkedAs(String name);

  /// No description provided for @unlink.
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get unlink;

  /// No description provided for @apiKey.
  ///
  /// In en, this message translates to:
  /// **'Web API key'**
  String get apiKey;

  /// No description provided for @steamId.
  ///
  /// In en, this message translates to:
  /// **'SteamID64'**
  String get steamId;

  /// No description provided for @getApiKey.
  ///
  /// In en, this message translates to:
  /// **'Get a key'**
  String get getApiKey;

  /// No description provided for @linkSteamDesc.
  ///
  /// In en, this message translates to:
  /// **'Optional: adds games you own but haven\'t installed, plus playtime. The key is stored in the macOS Keychain and only sent to Steam.'**
  String get linkSteamDesc;

  /// No description provided for @linkFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t link: {error}'**
  String linkFailed(String error);

  /// No description provided for @invalidKey.
  ///
  /// In en, this message translates to:
  /// **'Steam rejected this key or SteamID.'**
  String get invalidKey;

  /// No description provided for @privateProfileHint.
  ///
  /// In en, this message translates to:
  /// **'Steam returned no games. Check that your profile\'s game details are public.'**
  String get privateProfileHint;

  /// No description provided for @link.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get link;

  /// No description provided for @searchGames.
  ///
  /// In en, this message translates to:
  /// **'Search games'**
  String get searchGames;

  /// No description provided for @offlineError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach Steam. Showing what\'s cached.'**
  String get offlineError;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description available.'**
  String get noDescription;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @diagStep1.
  ///
  /// In en, this message translates to:
  /// **'Rotate each stick slowly along its edge, a few full turns.'**
  String get diagStep1;

  /// No description provided for @diagStep2.
  ///
  /// In en, this message translates to:
  /// **'Let go, then tap “Calibrate center” and keep it still for 2 s.'**
  String get diagStep2;

  /// No description provided for @diagStep3.
  ///
  /// In en, this message translates to:
  /// **'Apply the suggested dead zone to the profile in use.'**
  String get diagStep3;

  /// No description provided for @groupSignal.
  ///
  /// In en, this message translates to:
  /// **'Signal'**
  String get groupSignal;

  /// No description provided for @groupCircularity.
  ///
  /// In en, this message translates to:
  /// **'Circularity'**
  String get groupCircularity;

  /// No description provided for @groupCenter.
  ///
  /// In en, this message translates to:
  /// **'Center at rest'**
  String get groupCenter;

  /// No description provided for @positionX.
  ///
  /// In en, this message translates to:
  /// **'X position'**
  String get positionX;

  /// No description provided for @positionY.
  ///
  /// In en, this message translates to:
  /// **'Y position'**
  String get positionY;

  /// No description provided for @coverageShort.
  ///
  /// In en, this message translates to:
  /// **'Edge covered'**
  String get coverageShort;

  /// No description provided for @rotateMore.
  ///
  /// In en, this message translates to:
  /// **'Rotate more to measure'**
  String get rotateMore;

  /// No description provided for @legendEnvelope.
  ///
  /// In en, this message translates to:
  /// **'Edge outline'**
  String get legendEnvelope;

  /// No description provided for @legendDeadzone.
  ///
  /// In en, this message translates to:
  /// **'Dead zone'**
  String get legendDeadzone;

  /// No description provided for @legendCenter.
  ///
  /// In en, this message translates to:
  /// **'Measured center'**
  String get legendCenter;

  /// No description provided for @legendTrail.
  ///
  /// In en, this message translates to:
  /// **'Recent movement'**
  String get legendTrail;

  /// No description provided for @verdictGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get verdictGood;

  /// No description provided for @verdictWarn.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get verdictWarn;

  /// No description provided for @verdictBad.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get verdictBad;

  /// No description provided for @notMeasured.
  ///
  /// In en, this message translates to:
  /// **'Not measured'**
  String get notMeasured;

  /// No description provided for @triggerLeft.
  ///
  /// In en, this message translates to:
  /// **'Left trigger'**
  String get triggerLeft;

  /// No description provided for @triggerRight.
  ///
  /// In en, this message translates to:
  /// **'Right trigger'**
  String get triggerRight;

  /// No description provided for @axis.
  ///
  /// In en, this message translates to:
  /// **'Axis'**
  String get axis;

  /// No description provided for @bits.
  ///
  /// In en, this message translates to:
  /// **'Bits'**
  String get bits;

  /// No description provided for @toggleShortcutTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn mapping on/off'**
  String get toggleShortcutTitle;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @padpilotOffShort.
  ///
  /// In en, this message translates to:
  /// **'PadPilot off'**
  String get padpilotOffShort;

  /// No description provided for @notListedHint.
  ///
  /// In en, this message translates to:
  /// **'PadPilot not in the list? Click “+” in System Settings and pick PadPilot.app.'**
  String get notListedHint;

  /// No description provided for @revealApp.
  ///
  /// In en, this message translates to:
  /// **'Show app in Finder'**
  String get revealApp;

  /// No description provided for @restartApp.
  ///
  /// In en, this message translates to:
  /// **'Restart PadPilot'**
  String get restartApp;

  /// No description provided for @restartRequiredDesc.
  ///
  /// In en, this message translates to:
  /// **'Input Monitoring was allowed. Restart PadPilot for it to take effect.'**
  String get restartRequiredDesc;

  /// No description provided for @windowsPreview.
  ///
  /// In en, this message translates to:
  /// **'Windows preview: profiles and the game hub work, but controller mapping isn\'t available on Windows yet.'**
  String get windowsPreview;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

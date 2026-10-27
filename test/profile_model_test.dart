import 'dart:convert';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:padpilot/features/mapping_editor/action_labels.dart';
import 'package:padpilot/features/profiles/sample_profiles.dart';
import 'package:padpilot/l10n/l10n.dart';
import 'package:padpilot/models/input_source.dart';
import 'package:padpilot/models/output_action.dart';
import 'package:padpilot/models/profile.dart';

/// The example profile from the spec (section 6).
const specJson = '''
{
  "id": "fps-default",
  "name": "FPS",
  "mappings": [
    {"input": {"type": "stickDirection", "stick": "left", "direction": "up", "threshold": 0.4},
     "action": {"type": "key", "keyCode": 13, "modifiers": []}},
    {"input": {"type": "stickAxis", "stick": "right"},
     "action": {"type": "mouseMove", "speed": {"up": 12, "down": 12, "left": 14, "right": 14},
                "deadzone": 0.15, "curve": "quadratic"}},
    {"input": {"type": "trigger", "trigger": "right", "threshold": 0.5},
     "action": {"type": "mouseClick", "button": "left"}},
    {"input": {"type": "button", "button": "start"},
     "action": {"type": "key", "keyCode": 12, "modifiers": ["command"]}},
    {"input": {"type": "dpad", "direction": "down"},
     "action": {"type": "scroll", "axis": "vertical", "amount": -3}}
  ]
}
''';

void main() {
  test('parses the spec profile and round-trips to identical JSON', () {
    final json = jsonDecode(specJson) as Map<String, dynamic>;
    final profile = Profile.fromJson(json);

    expect(profile.mappings, hasLength(5));
    expect(profile.mappings[0].input, isA<StickDirectionInput>());
    expect((profile.mappings[1].action as MouseMoveAction).speed.left, 14);
    expect((profile.mappings[3].action as KeyAction).modifiers, [KeyModifier.command]);
    expect((profile.mappings[4].action as ScrollWheelAction).amount, -3);
    expect(jsonDecode(jsonEncode(profile.toJson())), json);
  });

  test('withMapping replaces by input identity and removes on null', () {
    var profile = const Profile(id: 'p', name: 'P');
    profile = profile.withMapping(const TriggerInput(Side.left), const MouseClickAction(MouseButtonType.right));
    profile = profile.withMapping(
      const TriggerInput(Side.left, threshold: 0.8),
      const MouseClickAction(MouseButtonType.left),
    );

    expect(profile.mappings, hasLength(1));
    expect((profile.mappings.single.input as TriggerInput).threshold, 0.8);
    expect((profile.mappings.single.action as MouseClickAction).button, MouseButtonType.left);

    profile = profile.withMapping(const TriggerInput(Side.left), null);
    expect(profile.mappings, isEmpty);
  });

  test('input keys match native capture names', () {
    expect(const ButtonInput(GamepadButton.a).key, 'button:a');
    expect(const DpadInput(Direction.up).key, 'dpad:up');
    expect(const StickDirectionInput(Side.left, Direction.right).key, 'stick:left:right');
    expect(const TriggerInput(Side.right).key, 'trigger:right');
  });

  test('liveValue reads normalized native state', () {
    const values = {'leftStickX': -0.7, 'leftStickY': 0.2, 'dpadDown': 1.0, 'rightTrigger': 0.4};
    expect(const StickDirectionInput(Side.left, Direction.left).liveValue(values), closeTo(0.7, 1e-9));
    expect(const StickDirectionInput(Side.left, Direction.right).liveValue(values), 0);
    expect(const DpadInput(Direction.down).liveValue(values), 1);
    expect(const TriggerInput(Side.right).liveValue(values), 0.4);
  });

  test('sample profiles serialize and use localized names', () {
    final pt = sampleProfiles(lookupAppLocalizations(const Locale('pt')));
    final es = sampleProfiles(lookupAppLocalizations(const Locale('es')));
    expect(pt.map((p) => p.name), contains('Edição de fotos'));
    expect(es.map((p) => p.name), contains('Edición de fotos'));
    for (final p in pt) {
      expect(
        Profile.fromJson(jsonDecode(jsonEncode(p.toJson())) as Map<String, dynamic>).mappings.length,
        p.mappings.length,
      );
    }
  });

  test('action summaries are localized', () {
    const action = KeyAction(49, modifiers: [KeyModifier.shift, KeyModifier.command]);
    expect(actionSummary(action, const {}, lookupAppLocalizations(const Locale('en'))), '⇧⌘Space');
    expect(actionSummary(action, const {}, lookupAppLocalizations(const Locale('pt'))), '⇧⌘Espaço');
    expect(actionSummary(null, const {}, lookupAppLocalizations(const Locale('es'))), 'Sin asignar');
  });
}

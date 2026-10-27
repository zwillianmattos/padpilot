import 'dart:math';

import 'input_source.dart';
import 'mapping.dart';
import 'output_action.dart';

class Profile {
  const Profile({required this.id, required this.name, this.mappings = const []});

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'] as String,
    name: json['name'] as String,
    mappings: [
      for (final m in (json['mappings'] as List? ?? const [])) Mapping.fromJson((m as Map).cast<String, dynamic>()),
    ],
  );

  final String id;
  final String name;
  final List<Mapping> mappings;

  static String newId() =>
      '${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}-${Random().nextInt(1 << 20).toRadixString(36)}';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'mappings': [for (final m in mappings) m.toJson()],
  };

  Profile copyWith({String? id, String? name, List<Mapping>? mappings}) =>
      Profile(id: id ?? this.id, name: name ?? this.name, mappings: mappings ?? this.mappings);

  Mapping? mappingFor(String inputKey) {
    for (final m in mappings) {
      if (m.input.key == inputKey) return m;
    }
    return null;
  }

  /// Assigns [action] to [input], replacing any mapping for the same input.
  /// A null action removes the mapping.
  Profile withMapping(InputSource input, OutputAction? action) {
    final index = mappings.indexWhere((m) => m.input.key == input.key);
    final next = [...mappings];
    if (action == null) {
      if (index >= 0) next.removeAt(index);
    } else if (index >= 0) {
      next[index] = Mapping(input: input, action: action);
    } else {
      next.add(Mapping(input: input, action: action));
    }
    return copyWith(mappings: next);
  }
}

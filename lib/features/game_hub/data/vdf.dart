/// Parser for Valve's text KeyValues format (.vdf / .acf):
///
/// ```
/// "AppState" { "appid" "570" "name" "Dota 2" }
/// ```
///
/// Values are either strings or nested maps. Keys keep their original case;
/// use [VdfMap.get] for Valve's case-insensitive lookups.
typedef VdfMap = Map<String, Object>;

VdfMap parseVdf(String source) {
  final tokens = _tokenize(source);
  var i = 0;

  VdfMap readObject({required bool braced}) {
    final map = <String, Object>{};
    while (i < tokens.length) {
      final token = tokens[i];
      if (token == _close) {
        i++;
        if (braced) return map;
        continue;
      }
      final key = token;
      i++;
      if (i >= tokens.length) break;
      final value = tokens[i];
      if (value == _open) {
        i++;
        map[key] = readObject(braced: true);
      } else if (value == _close) {
        // Key with no value right before a closing brace; leave it for the loop.
        map[key] = '';
      } else {
        i++;
        map[key] = value;
      }
    }
    return map;
  }

  return readObject(braced: false);
}

const _open = '\u0000{';
const _close = '\u0000}';

List<String> _tokenize(String s) {
  final tokens = <String>[];
  var i = 0;
  while (i < s.length) {
    final c = s[i];
    if (c == '"') {
      final buffer = StringBuffer();
      i++;
      while (i < s.length && s[i] != '"') {
        if (s[i] == r'\' && i + 1 < s.length) {
          final next = s[i + 1];
          buffer.write(switch (next) {
            'n' => '\n',
            't' => '\t',
            _ => next,
          });
          i += 2;
        } else {
          buffer.write(s[i++]);
        }
      }
      i++;
      tokens.add(buffer.toString());
    } else if (c == '{') {
      tokens.add(_open);
      i++;
    } else if (c == '}') {
      tokens.add(_close);
      i++;
    } else if (c == '/' && i + 1 < s.length && s[i + 1] == '/') {
      while (i < s.length && s[i] != '\n') {
        i++;
      }
    } else if (c.trim().isEmpty) {
      i++;
    } else {
      // Unquoted token (rare, but valid KeyValues).
      final start = i;
      while (i < s.length && s[i].trim().isNotEmpty && s[i] != '{' && s[i] != '}' && s[i] != '"') {
        i++;
      }
      tokens.add(s.substring(start, i));
    }
  }
  return tokens;
}

extension VdfMapX on VdfMap {
  Object? get(String key) {
    final lower = key.toLowerCase();
    for (final e in entries) {
      if (e.key.toLowerCase() == lower) return e.value;
    }
    return null;
  }

  String? string(String key) {
    final value = get(key);
    return value is String ? value : null;
  }

  VdfMap? child(String key) {
    final value = get(key);
    return value is Map ? value.cast<String, Object>() : null;
  }
}

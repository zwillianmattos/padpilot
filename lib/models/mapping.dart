import 'input_source.dart';
import 'output_action.dart';

class Mapping {
  const Mapping({required this.input, required this.action});

  factory Mapping.fromJson(Map<String, dynamic> json) => Mapping(
    input: InputSource.fromJson((json['input'] as Map).cast<String, dynamic>()),
    action: OutputAction.fromJson((json['action'] as Map).cast<String, dynamic>()),
  );

  final InputSource input;
  final OutputAction action;

  Map<String, dynamic> toJson() => {'input': input.toJson(), 'action': action.toJson()};
}

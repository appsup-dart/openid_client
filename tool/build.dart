import 'package:build_runner/build_runner.dart';

import 'package:source_gen/generators/json_literal_generator.dart' as literal;
import 'json_serializable_generator.dart' as json;
import 'package:source_gen/source_gen.dart';

final PhaseGroup phases = new PhaseGroup.singleAction(
    new GeneratorBuilder(const [
      const json.JsonSerializableGenerator(),
      const literal.JsonLiteralGenerator()
    ]),
    new InputSet('openid_client', const ['lib/src/model.dart']));

main() {
  build(phases, deleteFilesByDefault: true);
}

import 'package:file_picker/file_picker.dart';

abstract class SentenceRepository {
  Stream<Map<String, dynamic>> extractSentenceStream(
    PlatformFile file,
    int userId,
  );
}

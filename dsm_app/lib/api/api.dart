import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class Api {
  static const String baseUrl = 'http://localhost:8080';

  static Future<http.Response> uploadFile(XFile file, Map<String, String> headers) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/file/upload'));
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    var response = await request.send();
    return await http.Response.fromStream(response);
  }
}
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
class Tones extends StatefulWidget {
  const Tones({Key? key}) : super(key: key);

  @override
  State<Tones> createState() => _TonesState();
}

class _TonesState extends State<Tones> {
  Future<String?> pickToneFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      return result.files.single.path;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return  Container();
  }
}

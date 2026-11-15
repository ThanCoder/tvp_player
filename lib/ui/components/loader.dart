import 'package:material_ui/material_ui.dart';

class Loader extends StatelessWidget {
  const new({super.key});

  static Widget random() {
    return Loader();
  }

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator.adaptive();
  }
}

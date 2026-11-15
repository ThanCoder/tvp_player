import 'package:material_ui/material_ui.dart';

class ScrollableColumn extends StatelessWidget {
  const new({
    super.key,
    required this.children,
    this.spacing = 8,
    this.padding = const EdgeInsets.all(8.0),
  });
  final List<Widget> children;
  final double spacing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: padding,
        child: Column(spacing: spacing, children: children),
      ),
    );
  }
}

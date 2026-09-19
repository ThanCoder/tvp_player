import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:tvp_player/core/controllers/i_controller.dart';
import 'package:tvp_player/core/controllers/v_file_controller.dart';
import 'package:tvp_player/core/models/v_file.dart';
import 'package:tvp_player/funcs.dart';
import 'package:tvp_player/platforms/components/v_file_grid_item.dart';
import 'package:tvp_player/routers.dart';

class VfSearchPage extends StatefulWidget {
  const new({super.key});

  @override
  State<VfSearchPage> createState() => _VfSearchPageState();
}

class _VfSearchPageState extends State<VfSearchPage> {
  final con = ControllerManager.read<VFileController>();
  ColorScheme get col => Theme.of(context).colorScheme;

  bool isSearch = false;
  List<VFile> result = [];
  final searchCon = TextEditingController();
  final searchFos = FocusNode();

  void onSearch(String val) {
    if (val.isEmpty) {
      setState(() {
        isSearch = false;
      });
    }

    result = con.files.where((e) => e.name.upper.contains(val.upper)).toList();
    setState(() {
      isSearch = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search')),
      body: _body(),
    );
  }

  Widget _body() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              controller: searchCon,
              focusNode: searchFos,
              hintText: 'Search...',
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: .circular(15)),
              ),
              onChanged: onSearch,
              trailing: [
                if (isSearch)
                  IconButton(
                    onPressed: () {
                      result.clear();
                      searchCon.text = '';
                      setState(() {
                        isSearch = false;
                      });
                      searchFos.unfocus();
                    },
                    icon: Icon(Icons.clear_all_outlined),
                  ),
              ],
            ),
          ),
        ),
        if (!isSearch)
          SliverFillRemaining(
            child: Center(child: Text('Search For Someting...')),
          ),
        if (result.isEmpty)
          SliverFillRemaining(child: Center(child: Text('Not Found!...'))),

        // result
        SliverPadding(
          padding: .all(10),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 240,
              crossAxisSpacing: 10,
              mainAxisSpacing: 16,
              childAspectRatio: 240 / 210,
            ),
            itemCount: result.length,
            itemBuilder: (context, index) => VFileGridItem(
              file: result[index],
              onClicked: (file) {
                goVfPlayer(context, file);
              },
              onMenu: (file) {
                showVFileMenu(context, file);
              },
            ),
          ),
        ),
      ],
    );
  }
}

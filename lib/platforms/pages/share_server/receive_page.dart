import 'dart:convert';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_client/t_client.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:tvp_player/core/models/v_file.dart';
import 'package:tvp_player/core/util/platform_util.dart';
import 'package:tvp_player/platforms/components/dialog/error_alert_dialog.dart';

import 'active_host_scanner_dialog.dart';
import 'share_download_menu.dart';
import 'share_downloader_dialog.dart';
import 'share_grid_item.dart';

String? _connectAddress;

class ReceivePage extends StatefulWidget {
  const new({super.key});

  @override
  State<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((e) => init());
    super.initState();
  }

  @override
  void dispose() {
    client.close();
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  final client = TClient();
  bool isLoading = false;

  List<VFile> files = [];
  List<VFile> result = [];

  TSortItem sortItem = .dateTSortItem;

  Future<void> init() async {
    try {
      _connectAddress ??= await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => ActiveHostScannerDialog(),
      );
      if (_connectAddress == null) return;
      if (!mounted) return;
      setState(() {
        isLoading = true;
      });
      final url = 'http://$_connectAddress/api';
      final apiRes = await client.get(url);
      if (apiRes.isErr) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        _connectAddress = null;
        showErrorDialog(context, 'Api Url: $url\n${apiRes.unwrapError()}');
        return;
      }
      final apiInfo = apiRes.unwrap();
      if (apiInfo.statusCode != 200) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        showErrorDialog(
          context,
          'Api statusCode : $url\n${apiInfo.statusCode}',
        );
        return;
      }
      List<dynamic> jsonList = jsonDecode(apiInfo.body);
      files = jsonList.map((e) => VFile.fromMap(e)).toList();

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showErrorDialog(context, e.toString());
    }
  }

  void download(VFile file) async {
    final hostUrl = 'http://$_connectAddress';
    final downloadF = await showModalBottomSheet<VFile>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => ShareDownloadMenu(file: file, host: hostUrl),
    );
    if (downloadF == null) return;
    if (!mounted) return;

    final outPath = await PlatformUtil.getOutPath(file.name);
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          ShareDownloaderDialog(hostUrl: hostUrl, file: file, outPath: outPath),
    );
  }

  bool isSearch = false;
  final controller = TextEditingController();
  final focusNode = FocusNode();

  void onSearch(String val) {
    if (val.isEmpty) {
      if (!isSearch) return;
      isSearch = false;
      setState(() {});
      return;
    }
    result = files.where((e) => e.name.upper.contains(val.upper)).toList();
    isSearch = true;
    setState(() {});
  }

  void onSortChanged(TSortItem val) {
    sortItem = val;
    if (sortItem.id == TSortItem.dateTSortItem.id) {
      files.sortData(newest: sortItem.isTrue);
    }
    if (sortItem.id == TSortItem.nameTSortItem.id) {
      files.sortName(aToZ: sortItem.isTrue);
    }
    if (sortItem.id == TSortItem.sizeTSortItem.id) {
      files.sortSize(smallToBig: sortItem.isTrue);
    }
    setState(() {});
  }

  ColorScheme get col => Theme.of(context).colorScheme;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar(),
      body: RefreshIndicator.adaptive(
        onRefresh: init,
        child: isLoading
            ? Center(child: TLoaderRandom())
            : CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (_connectAddress == null)
                    SliverFillRemaining(child: _adressNullWidget()),
                  // search
                  SliverToBoxAdapter(child: _search()),
                  SliverPadding(
                    padding: .symmetric(vertical: 10, horizontal: 15),
                    sliver: _connectAddress == null ? null : _body,
                  ),
                ],
              ),
      ),
    );
  }

  AppBar _appbar() {
    return AppBar(
      title: Text('Receive Page'),
      actions: [
        if (TPlatform.isDesktop && !isLoading)
          IconButton(onPressed: init, icon: Icon(Icons.refresh_outlined)),
        TSortProviderButton(
          value: sortItem,
          list: [.dateTSortItem, .nameTSortItem, .sizeTSortItem],
          onApply: onSortChanged,
        ),
        SizedBox(width: 10),
      ],
    );
  }

  Padding _search() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SearchBar(
        controller: controller,
        focusNode: focusNode,
        hintText: 'Search....',
        onChanged: onSearch,
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: .circular(15)),
        ),
        trailing: [
          IconButton(
            onPressed: () {
              controller.text = '';
              focusNode.unfocus();
              isSearch = false;
              setState(() {});
            },
            icon: Icon(Icons.clear_all_outlined),
          ),
        ],
      ),
    );
  }

  Center _adressNullWidget() {
    return Center(
      child: Container(
        padding: .symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: col.surfaceContainer,
          borderRadius: .circular(15),
          border: .all(color: col.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: .center,
          mainAxisSize: .min,
          children: [
            Text('Rescan', style: TextStyle(fontSize: 20, fontWeight: .w700)),
            SizedBox(height: 10),
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: col.primary,
                foregroundColor: col.onPrimary,
              ),
              onPressed: init,
              icon: Icon(Icons.repeat),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _body {
    var list = files;
    if (isSearch) {
      list = result;
    }
    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        crossAxisSpacing: 10,
        mainAxisSpacing: 16,
        childAspectRatio: 240 / 210,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final file = list[index];
        return ShareGridItem(
          file: file,
          host: _connectAddress!,
          onClicked: download,
        );
      },
    );
  }
}

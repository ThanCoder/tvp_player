import 'dart:convert';
import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:t_server/t_server.dart';
import 'package:tvp_player/core/controllers/i_controller.dart';
import 'package:tvp_player/core/controllers/v_file_controller.dart';
import 'package:tvp_player/core/util/app_util.dart';
import 'package:tvp_player/core/util/platform_util.dart';

class ShareController {
  static final ShareController instance = ShareController._();
  ShareController._();
  factory ShareController() => instance;

  final server = TServer();
  final _router = THttpRouter();
  VFileController get _allCon => ControllerManager.read<VFileController>();
  int port = 7000;

  Future<void> init() async {
    _router.clearRoutes();
    _router.get('/', (ctx) async {
      await ctx.response.json({
        'message': 'TVP Player Api Server',
        '/api': 'video file list',
        '/api/thumbnail/:id': 'cover data',
        '/api/video/:id': 'book data && download data',
      });
    });
    _router.get('/api', (ctx) async {
      final json = _allCon.files.map((e) => e.toMap()).toList();
      final jsonString = JsonEncoder.withIndent(' ').convert(json);
      await ctx.response.jsonString(jsonString);
    });
    _router.get('/api/thumbnail/:id', (ctx) async {
      final id = ctx.params['id'];
      if (id == null) {
        await ctx.response.json({'message': 'id not found!', 'success': false});
        return;
      }
      final item = _allCon.getById(id);
      if (item == null) {
        await ctx.response.json({
          'message': 'book not found!',
          'success': false,
        });
        return;
      }
      final coverFile = File(
        AppUtil.instance.getPlatformCachePath('${item.name.onlyName}.jpg'),
      );
      if (!coverFile.existsSync()) {
        await PlatformUtil.genThumbnail(item, coverFile);
      }

      await ctx.response.download(coverFile);
    });

    _router.get('/api/video/:id', (ctx) async {
      final id = ctx.params['id'];
      if (id == null) {
        await ctx.response.json({'message': 'id not found!', 'success': false});
        return;
      }
      final item = _allCon.getById(id);
      if (item == null) {
        await ctx.response.json({
          'message': 'video not found!',
          'success': false,
        });
        return;
      }
      final itemFile = File(item.path);

      await ctx.response.download(itemFile);
    });
    server.setRouter(_router);
  }

  Future<void> start() async {
    await server.start(address: '0.0.0.0', port: port);
  }
}

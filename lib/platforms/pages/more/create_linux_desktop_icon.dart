import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:mediatag_bin/core/utils.dart';
import 'package:than_pkg_linux/than_pkg_linux.dart';
import 'package:tvp_player/ui/build_context_x.dart';
import 'package:tvp_player/ui/dialog/index.dart';

class CreateLinuxDesktopIcon extends StatefulWidget {
  const new({super.key});

  @override
  State<CreateLinuxDesktopIcon> createState() => _CreateLinuxDesktopIconState();
}

class _CreateLinuxDesktopIconState extends State<CreateLinuxDesktopIcon> {
  final pkg = ThanPkgLinux.getInstance.pathHandler;
  void _createDesktop() async {
    final env = Platform.environment['HOME'];
    if (env == null) return;
    final desktopF = File(env.join('Desktop').join('tvp.player.desktop'));
    final execPath = Platform.resolvedExecutable;
    final contents = createDesktopData(
      execPath,
      pkg
          .getExecutableFlutterAssetsPath()
          .join('assets')
          .join('logo')
          .join('logo1.png'),
    );
    await desktopF.writeAsString(contents);
    if (!mounted) return;
    showSuccessDialog(context, 'Desktop File Created');
  }

  @override
  Widget build(BuildContext context) {
    final col = context.colorScheme;

    return ListTile(
      title: Text('Create Desktop Icon'),
      tileColor: col.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: .circular(15)),
      leading: Icon(Icons.install_desktop_outlined),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: _createDesktop,
    );
  }
}

String createDesktopData(String execPath, String iconPath) {
  return """
[Desktop Entry]
Version=1.0
Type=Application
Name=TVP media player
GenericName=Media player
Comment=Read, capture, broadcast your multimedia streams
TryExec=$execPath
StartupNotify=true
Exec=$execPath %U
Icon=$iconPath
Categories=AudioVideo;Player;Recorder;
X-KDE-Protocols=ftp,http,https,mms,rtmp,rtsp,sftp,smb
Keywords=Player;Capture;DVD;Audio;Video;Server;Broadcast;

X-KDE-Protocols=ftp,http,https,mms,rtmp,rtsp,sftp,smb
Keywords=Player;Capture;DVD;Audio;Video;Server;Broadcast;
""";
}

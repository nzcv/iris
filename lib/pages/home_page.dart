import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iris/info.dart';
import 'package:iris/pages/alert_dialog/show_webdav_alert_dialog.dart';
import 'package:iris/widgets/storages.dart';
import 'package:iris/widgets/title_bar.dart';

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar(
        title: INFO.title,
        bgColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Storages(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showWebDAVAlertDialog(context),
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}

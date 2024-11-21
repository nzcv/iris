import 'package:flutter/material.dart';
import 'package:iris/widgets/title_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const title = 'Settings';
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TitleBar(title: title),
      body: Placeholder(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:viddroid_flutter_desktop/provider/providers.dart';
import 'package:viddroid_flutter_desktop/util/setting/settings.dart';

import '../provider/provider.dart';

class ProviderSelectionView extends StatefulWidget {
  const ProviderSelectionView({Key? key}) : super(key: key);

  @override
  State<ProviderSelectionView> createState() => _ProviderSelectionViewState();
}

class _ProviderSelectionViewState extends State<ProviderSelectionView> {
  final List<SiteProvider> _selectedProviders = [];

  @override
  void initState() {
    Future.microtask(() async {
      _selectedProviders.addAll(await Settings().getSelectedProviders());
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    Settings().saveSelectedProviders(_selectedProviders);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Providers'),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(30),
        children: Providers()
            .siteProviders
            .map((e) => InkWell(
                  onTap: () {
                    setState(() {
                      if(_selectedProviders.contains(e)) {
                        _selectedProviders.remove(e);
                      } else {
                        _selectedProviders.add(e);
                      }
                    });
                  },
                  // TODO: Add provider to selected providers, save in setting.
                  child: Card(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.name, textScaleFactor: 1.2),
                              Text(e.mainUrl),
                            ],
                          ),
                          Checkbox(value: _selectedProviders.contains(e), onChanged: null)
                        ],
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

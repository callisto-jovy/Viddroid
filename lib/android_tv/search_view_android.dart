import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:shimmer/shimmer.dart';
import 'package:viddroid/util/extensions/iterable_extension.dart';
import 'package:viddroid/widgets/cards/search_response_card.dart';

import '../provider/providers.dart';
import '../util/capsules/media.dart';
import '../util/capsules/search.dart';
import '../widgets/snackbars.dart';

class AndroidSearchView extends StatefulWidget {
  const AndroidSearchView({Key? key}) : super(key: key);

  @override
  State<AndroidSearchView> createState() => _AndroidSearchViewState();
}

class _AndroidSearchViewState extends State<AndroidSearchView> {
  final TextEditingController _searchController = TextEditingController();

  final List<TvType> _currentSelectedValues = TvType.values;

  final StreamController<List<SearchResponse>> _searchResults =
      StreamController<List<SearchResponse>>();

  final GlobalKey<FormFieldState> _formFieldKey = GlobalKey<FormFieldState>();

  @override
  void dispose() {
    _searchController.dispose();
    _searchResults.close();
    super.dispose();
  }

  Widget _buildSearchField() {
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    return MediaQuery(
      data: MediaQueryData(
        navigationMode: NavigationMode.directional,
        accessibleNavigation: mediaQuery.accessibleNavigation,
        displayFeatures: mediaQuery.displayFeatures,
      ),
      child: Flexible(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: TextFormField(
              autofocus: true,
              key: _formFieldKey,
              controller: _searchController,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15.0)))),
              validator: (String? val) =>
                  (val == null || val.isEmpty) ? 'Please enter a search term first.' : null,
              onFieldSubmitted: (value) {
                if (_formFieldKey.currentState != null && _formFieldKey.currentState!.validate()) {
                  final List<SearchResponse> totalResponses = [];
                  Providers().search(value, _currentSelectedValues).listen((event) {
                    totalResponses.addAll(event);
                    _searchResults.add(totalResponses);
                  }).onError((error, stackTrace) {
                    ScaffoldMessenger.of(context).showSnackBar(errorSnackbar(error.toString()));
                    if (kDebugMode) {
                      print(stackTrace);
                    }
                  });
                }
              }),
        ),
      ),
    );
  }

  Widget _buildSearchStreamBuilder() {
    return StreamBuilder(
      stream: _searchResults.stream,
      builder: (context, AsyncSnapshot<List<SearchResponse>> snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final List<String> validProviders = snapshot.data!.map((e) => e.apiName).unique(
                (element) => element,
              );

          return CustomScrollView(
            primary: false,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
//            controller: ScrollController(),
            slivers: validProviders.map((provider) {
              List<SearchResponse> resp =
                  snapshot.data!.where((element) => element.apiName == provider).toList();

              return SliverStickyHeader(
                header: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.secondaryContainer),
                  child: Text(
                    provider,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                sliver: SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 30,
                      mainAxisSpacing: 30,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final SearchResponse searchResponse = resp[index];
                        return GridTile(child: SearchResponseCard(searchResponse));
                      },
                      childCount: resp.length,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        } else if (snapshot.hasError) {
          return Text('Something went wrong. ${snapshot.error!}');
        } else {
          return _buildShimmerPlaceholder();
        }
      },
    );
  }

  Widget _buildShimmerPlaceholder() {
    //Placeholder with shimmer
    return Shimmer.fromColors(
      baseColor: Colors.black12,
      highlightColor: Colors.grey.shade800,
      period: const Duration(milliseconds: 2500),
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 8,
        //It is not possible to show more 8 items
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, i) {
          return const Card();
        },
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildSearchField(),
          Expanded(
            flex: 4,
            child: _buildSearchStreamBuilder(),
          ),
        ],
      ),
    );
  }
}

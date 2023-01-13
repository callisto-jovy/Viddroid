import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:viddroid_flutter_desktop/widgets/search_response_card_widget.dart';

import '../provider/providers.dart';
import '../util/search.dart';
import '../widgets/snackbars.dart';
import '../widgets/text_search_field_widget.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final List<SearchType> _currentSelectedValues = [SearchType.movie, SearchType.tv];
  final StreamController<List<SearchResponse>> _searchResults =
      StreamController<List<SearchResponse>>();
  final GlobalKey<FormFieldState> _formFieldKey = GlobalKey<FormFieldState>();

  @override
  void dispose() {
    _searchController.dispose();
    _searchResults.close();

    super.dispose();
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
          TextSearchField(
            controller: _searchController,
            onSubmitted: (text) {
              _searchResults.addStream(Providers().search(text, _currentSelectedValues)).onError(
                  (error, stackTrace) => ScaffoldMessenger.of(context)
                      .showSnackBar(errorSnackbar(stackTrace.toString())));
            },
            formFieldKey: _formFieldKey,
          ),
          Row(
              children: SearchType.values
                  .map((e) => Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: FilterChip(
                              label: Text(e.name),
                              selected: _currentSelectedValues.contains(e),
                              onSelected: (value) => {
                                    setState(() {
                                      if (value) {
                                        _currentSelectedValues.add(e);
                                      } else {
                                        _currentSelectedValues.remove(e);
                                      }
                                    })
                                  }),
                        ),
                      ))
                  .toList()),
          Expanded(
            flex: 4,
            child: StreamBuilder(
              stream: _searchResults.stream,
              builder: (context, AsyncSnapshot<List<SearchResponse>> snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return GridView.builder(
                    primary: false,
                    padding: const EdgeInsets.all(20),
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, i) {
                      final SearchResponse searchResponse = snapshot.data![i];
                      return SearchResponseCard(searchResponse);
                    },
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Text('Something went wrong.');
                } else {
                  //Placeholder with shimmer
                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: 8, //It is not possible to show more 8 items
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, i) {
                      return Shimmer.fromColors(
                          baseColor: Theme.of(context).colorScheme.primaryContainer,
                          highlightColor: Theme.of(context).colorScheme.inverseSurface,
                          child: const Card());
                    },
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

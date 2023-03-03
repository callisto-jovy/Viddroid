import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:viddroid_flutter_desktop/widgets/cards/search_response_card.dart';

import '../provider/providers.dart';
import '../util/capsules/media.dart';
import '../util/capsules/search.dart';
import '../widgets/snackbars.dart';
import '../widgets/text_search_field_widget.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final List<TvType> _currentSelectedValues = [TvType.movie, TvType.tv];

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
    return TextSearchField(
      controller: _searchController,
      onSubmitted: (text) {
        final List<SearchResponse> totalResponses = [];
        Providers().search(text, _currentSelectedValues).listen((event) {
          totalResponses.addAll(event);
          _searchResults.add(totalResponses);
        }).onError((error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(errorSnackbar(error.toString()));
          if (kDebugMode) {
            print(stackTrace);
          }
        });
      },
      formFieldKey: _formFieldKey,
    );
  }

  Widget _buildSearchStreamBuilder() {
    return StreamBuilder(
      stream: _searchResults.stream,
      builder: (context, AsyncSnapshot<List<SearchResponse>> snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView.builder(
            itemCount: Providers().siteProviders.length,
            itemBuilder: (context, index) {
              final List<SearchResponse> resp = snapshot.data!
                  .where((element) => element.apiName == Providers().siteProviders[index].name)
                  .toList();

              return StickyHeader(
                header: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  alignment: Alignment.centerLeft,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Text(
                    Providers().siteProviders[index].name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                content: GridView.builder(
                  primary: false,
                  padding: const EdgeInsets.all(20),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(),
                  itemCount: resp.length,
                  itemBuilder: (context, i) {
                    final SearchResponse searchResponse = resp[i];
                    return SearchResponseCard(searchResponse);
                  },
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                ),
              );
            },
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

  List<Widget> _buildTvTypeChips() {
    return TvType.values
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
        .toList();
  }

  Widget _buildTopRow() {
    return Row(
      children: [
        ..._buildTvTypeChips(),
        //TODO: More options
      ],
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
          _buildTopRow(),
          Expanded(
            flex: 4,
            child: _buildSearchStreamBuilder(),
          ),
        ],
      ),
    );
  }
}

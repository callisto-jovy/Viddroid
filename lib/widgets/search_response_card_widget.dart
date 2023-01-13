import 'package:flutter/material.dart';
import 'package:viddroid_flutter_desktop/util/search.dart';

import 'cards/general_card.dart';

class SearchResponseCard extends StatelessWidget {

  final SearchResponse _searchResponse;
  const SearchResponseCard(this._searchResponse, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GeneralPurposeCard(title: _searchResponse.title, thumbnail: _searchResponse.thumbnail, onTap: () => print(_searchResponse.apiName + _searchResponse.url));
  }
}

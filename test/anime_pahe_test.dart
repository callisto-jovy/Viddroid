import 'package:flutter_test/flutter_test.dart';
import 'package:viddroid/provider/providers/anime_pahe.dart';
import 'package:viddroid/util/capsules/fetch.dart';
import 'package:viddroid/util/capsules/link.dart';
import 'package:viddroid/util/capsules/search.dart';

Future<void> main() async {
  final List<SearchResponse> searchResults = await AnimePahe().search('Darling in the franxx');
  final SearchResponse searchResponse = searchResults[0];

  test('Search Result test', () async {
    expect(searchResults.isNotEmpty, true);
  });

  // Fetch from service
  final FetchResponse fetchResponse = await AnimePahe().fetch(searchResponse);

  test('Fetch details test', () async {
    expect(fetchResponse is TvFetchResponse, true);
    expect((fetchResponse as TvFetchResponse).episodes.isNotEmpty, true);
  });

  test('Fetch episode test', () async {
    final List<LinkResponse> responses = await AnimePahe()
        .load((fetchResponse as TvFetchResponse).episodes[0].toLoadRequest())
        .toList();

    expect(responses.isNotEmpty, true);
  });
}

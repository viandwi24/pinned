import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pinned/utils/create_pinned_items.dart';

class SearchAnimeScreen extends StatefulWidget {
  const SearchAnimeScreen({super.key});

  @override
  State<SearchAnimeScreen> createState() => _SearchAnimeScreenState();
}

class _SearchAnimeScreenState extends State<SearchAnimeScreen> {
  Timer? _debounce;
  final _searchController = TextEditingController();
  final List<Map<String, dynamic>> _list = [];
  bool _isLoading = false;

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () {
        print('searching...');
        print(_searchController.text);
        if (query.isNotEmpty) {
          _searchAnimes();
        }
      },
    );
  }

  Future _searchAnimes() async {
    var url = 'https://api.jikan.moe/v4/anime?q=${_searchController.text}';
    print(url);

    // create request
    setState(() {
      _isLoading = true;
    });
    var request = await http.get(Uri.parse(url));

    // process
    try {
      var body = jsonDecode(request.body);
      if (body is Map) {
        if (body['data'] is List) {
          var data = body['data'] as List;
          _list.clear();
          for (var i = 0; i < data.length; i++) {
            var item = data[i];
            if (item is Map) {
              _list.add(item as Map<String, dynamic>);
            }
          }
        }
      }
    } catch (e) {}

    // ok
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = _isLoading
        ? Container(
            child: Center(
              child: Text(
                'Searching anime...',
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          )
        : ListView.builder(
            itemCount: _list.length,
            itemBuilder: (context, index) {
              final anime = _list[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context, anime);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: randomColor(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 12,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  anime['images']?['jpg']?['small_image_url'] ??
                                      '',
                                  fit: BoxFit.fitHeight,
                                  errorBuilder: (ctx, ex, st) {
                                    return Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 10,
                        child: Container(
                          margin: EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${anime['title'] ?? ''} (${anime['title_japanese'] ?? ''})',
                                style:
                                    Theme.of(context).textTheme.caption?.merge(
                                          TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                              ),
                              Text(
                                'Year : ${anime['year'] ?? ''} Episodes : ${anime['episodes'] ?? ''} / rating : ${anime['rating'] ?? ''}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    ?.merge(
                                      TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: CupertinoSearchTextField(
          placeholder: 'Search Anime...',
          controller: _searchController,
          onChanged: _onSearchChanged,
        ),
        trailing: SizedBox(),
      ),
      child: SafeArea(child: content),
    );
  }
}

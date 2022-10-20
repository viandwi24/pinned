import 'dart:convert';

import 'package:eventify/eventify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pinned/components/button.dart';
import 'package:pinned/components/card_item.dart';
import 'package:pinned/constant.dart';
import 'package:pinned/models/pinned_item.dart';
import 'package:pinned/screens/create_screen.dart';
import 'package:pinned/utils/create_pinned_items.dart';
import 'package:pinned/utils/db.dart';
import 'package:pinned/utils/generate_uuid.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  bool isFetched = false;
  String _currentCat = 'all';
  List<dynamic> _listeners = [];
  List<PinnedItem> _items = [];

  @override
  void initState() {
    super.initState();
    // post frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getData();
      // _updateList();
    });
    _listeners.add(DB.emitter.on('updated', context, _onDBUpdated));
  }

  @override
  void dispose() {
    for (var listener in _listeners) {
      DB.emitter.off(listener);
    }
    super.dispose();
  }

  _onDBUpdated(Event ev, Object? obj) {
    // getData();
    _updateList();
  }

  _updateList() {
    _items.clear();
    if (_currentCat == 'all') {
      setState(() {
        _items = DB.getAll();
      });
      print('fetch all categories total : ${_items.length}');
    } else {
      setState(() {
        _items = DB.getItemsByCategory(_currentCat);
      });
      print('fetch category: $_currentCat total : ${_items.length}');
    }
  }

  _getPopupChangeCategories(BuildContext ctx) {
    // show action sheet
    var possiblesCategories = DB.getCategories();
    // possiblesCategories;
    showCupertinoModalPopup(
      context: ctx,
      builder: (BuildContext ctx) {
        return CupertinoActionSheet(
          title: const Text('Change Categories'),
          actions: [
            for (var category in possiblesCategories)
              CupertinoActionSheetAction(
                child: Text(category),
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _currentCat = category;
                    _updateList();
                  });
                },
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(ctx);
            },
          ),
        );
      },
    );
  }

  Future getData() async {
    // delay 1 second
    if (DB.isEmpty()) {
      await Future.delayed(const Duration(milliseconds: 700))
          .then((value) async {
        final urls = [
          // 'https://github.com/viandwi24',
          // 'https://github.com/riosiu',
          // 'https://tiktok.com',
          // 'http://dribbble.com/',
          // 'https://www.bilibili.tv/id',
        ];

        for (var i = 0; i < urls.length; i++) {
          final url = urls[i];
          var uuid = generateUUID();
          try {
            final item = await createPinnedItemTypeWebsite(uuid, url);
            DB.add(item);
          } catch (e) {}
        }
        setState(() {
          isFetched = true;
          isLoading = false;
        });
      });
    } else {
      setState(() {
        isFetched = true;
        isLoading = false;
      });
    }
    _updateList();
  }

  _showMenuItem(BuildContext ctx, PinnedItem item) {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text('Menu'),
          actions: [
            CupertinoActionSheetAction(
              child: const Text('Edit'),
              onPressed: () async {
                await Navigator.push(context,
                    CupertinoPageRoute(builder: (context) {
                  return CreateScreen(
                    editMode: true,
                    item: item,
                  );
                }));
                Navigator.pop(context);
              },
            ),
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              child: const Text('Delete'),
              onPressed: () async {
                // show alert confirm
                await showCupertinoDialog(
                  context: context,
                  builder: (context) {
                    return CupertinoAlertDialog(
                      title: const Text(
                        'Delete Item',
                      ),
                      content: const Text(
                        'Are you sure want to delete this item?',
                      ),
                      actions: [
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          child: const Text(
                            'Delete',
                          ),
                          onPressed: () {
                            DB.remove(item.id);
                            Navigator.pop(context);
                          },
                        ),
                        CupertinoDialogAction(
                          child: const Text(
                            'Cancel',
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: TextButton(
        style: ElevatedButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: kPrimaryColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: const Icon(
                CupertinoIcons.add,
                color: Colors.white,
              ),
            ),
            const Text(
              'Add Item',
              style: TextStyle(
                color: kDarkTextColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
        onPressed: () {
          Navigator.push(context, CupertinoPageRoute(builder: (context) {
            return const CreateScreen();
          }));
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildWithList(context),
            // Flexible(
            //   fit: FlexFit.tight,
            //   flex: 1,
            //   child: Container(
            //     color: Colors.teal,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  _buildBanner(BuildContext ctx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, right: 10),
            child: const Text(
              '👏',
              style: TextStyle(
                fontSize: 50,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                child: Text(
                  'Pinned',
                  style: Theme.of(context).textTheme.headline2?.merge(
                        const TextStyle(
                          height: 0.1,
                        ),
                      ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _getPopupChangeCategories(context);
                },
                child: Container(
                  // color: Colors.orange,
                  child: Text(
                    _currentCat,
                    style: Theme.of(context).textTheme.bodyText1?.merge(
                          TextStyle(
                            fontSize: 12,
                            color: kTextColor.withOpacity(0.6),
                            // height: .2,
                          ),
                        ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _buildWithList(BuildContext ctx) {
    return Expanded(
      flex: 12,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBanner(ctx),
              // list view
              Builder(
                builder: (context) {
                  if (isLoading || (!isFetched && _items.isEmpty)) {
                    return Column(
                      children: [
                        // for 2 items
                        for (var i = 0; i < 4; i++)
                          SizedBox(
                            height: 100,
                            width: double.infinity,
                            child: Shimmer.fromColors(
                              baseColor: kPlaceholderCardColor.withOpacity(0.7),
                              highlightColor: kPlaceholderCardColor,
                              child: Container(
                                margin: const EdgeInsets.only(
                                  bottom: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          )
                      ],
                    );
                  } else if (_items.isEmpty) {
                    return Container(
                      child: Column(
                        children: [
                          Lottie.asset('assets/anims/empty.json'),
                          Text(
                            'Nothing item here',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: kTextColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return GestureDetector(
                        onLongPress: () => _showMenuItem(context, item),
                        onTap: () => _showMenuItem(context, item),
                        child: Container(
                          margin: const EdgeInsets.only(
                            bottom: 20,
                          ),
                          child: CardItem(
                            item: _items[index],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

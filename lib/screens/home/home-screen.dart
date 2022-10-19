import 'dart:convert';

import 'package:eventify/eventify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinned/components/card_item.dart';
import 'package:pinned/constant.dart';
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

  List<dynamic> _listeners = [];

  @override
  void initState() {
    super.initState();
    // post frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getData();
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
    getData();
    if (!DB.isEmpty()) {
      DB.getAll();
    }
  }

  getData() {
    // delay 1 second
    if (DB.isEmpty()) {
      Future.delayed(const Duration(milliseconds: 2000)).then((value) async {
        final urls = [
          'https://github.com/viandwi24',
          'https://github.com/riosiu',
          'https://tiktok.com',
          'https://www.bilibili.tv/id',
          'http://dribbble.com/',
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
            Expanded(
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
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 10, right: 10),
                              child: const Text(
                                '👏',
                                style: TextStyle(
                                  fontSize: 40,
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline2
                                        ?.merge(
                                          const TextStyle(
                                            height: .2,
                                          ),
                                        ),
                                  ),
                                ),
                                Text(
                                  'all categories',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      ?.merge(
                                        TextStyle(
                                          fontSize: 12,
                                          color: kTextColor.withOpacity(0.6),
                                          height: .2,
                                        ),
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // list view
                      Builder(
                        builder: (context) {
                          if (isLoading || (!isFetched && DB.isEmpty())) {
                            return Column(
                              children: [
                                // for 2 items
                                for (var i = 0; i < 4; i++)
                                  SizedBox(
                                    height: 100,
                                    width: double.infinity,
                                    child: Shimmer.fromColors(
                                      baseColor: kPlaceholderCardColor
                                          .withOpacity(0.7),
                                      highlightColor: kPlaceholderCardColor,
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 20,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  )
                              ],
                            );
                          }
                          return ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: DB.getAll().length,
                            itemBuilder: (context, index) {
                              final item = DB.getAll()[index];
                              return GestureDetector(
                                onLongPress: () {
                                  showCupertinoModalPopup(
                                    context: context,
                                    builder: (context) {
                                      return CupertinoActionSheet(
                                        title: const Text('Menu'),
                                        actions: [
                                          CupertinoActionSheetAction(
                                            child: const Text('Edit'),
                                            onPressed: () async {
                                              await Navigator.push(context,
                                                  CupertinoPageRoute(
                                                      builder: (context) {
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
                                                        isDestructiveAction:
                                                            true,
                                                        child: const Text(
                                                          'Delete',
                                                        ),
                                                        onPressed: () {
                                                          DB.remove(item.id);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                      CupertinoDialogAction(
                                                        child: const Text(
                                                          'Cancel',
                                                        ),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
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
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    bottom: 20,
                                  ),
                                  child: CardItem(
                                    item: DB.getAll()[index],
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
            ),
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
}

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pinned/components/button.dart';
import 'package:pinned/constant.dart';
import 'package:pinned/models/pinned_item.dart';
import 'package:pinned/utils/create_pinned_items.dart';
import 'package:pinned/utils/db.dart';
import 'package:pinned/utils/generate_uuid.dart';

import 'parts/search_anime_screen.dart';

class FormTextInput extends StatefulWidget {
  const FormTextInput({
    super.key,
    required this.label,
    required this.controller,
    this.margin,
    this.enabled,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final EdgeInsets? margin;
  final bool? enabled;
  final TextInputType? keyboardType;

  @override
  State<FormTextInput> createState() => _FormTextInputState();
}

class _FormTextInputState extends State<FormTextInput> {
  @override
  Widget build(BuildContext context) {
    var enabled = widget.enabled ?? true;
    return Container(
      margin: widget.margin,
      child: TextFormField(
        enabled: enabled,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        maxLines: null,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(
            color: kBorderInputColor.withOpacity(0.7),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: kBorderInputColor.withOpacity(0.7),
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: kBorderInputColor.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }
}

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key, this.editMode = false, this.item});

  final bool editMode;
  final PinnedItem? item;

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  String _selectedType = 'website';
  bool isLoading = false;
  Map<String, TextEditingController> _controllers = {};
  String _tmpData = '';

  TextEditingController _getController(String key) {
    final findCon = _controllers[key];
    if (findCon != null) {
      return findCon;
    }
    final con = TextEditingController();
    _controllers[key] = con;
    return con;
  }

  Future<void> _showLoading({String? title, bool? show}) {
    setState(() {
      isLoading = (show == null || show == true);
    });
    title ??= 'Loading...';
    if (show == null || show == true) {
      return EasyLoading.show(
        status: title,
        maskType: EasyLoadingMaskType.black,
      );
    } else {
      return EasyLoading.dismiss();
    }
  }

  bool _checkCanSave() {
    var canSave = true;
    if (_selectedType == 'anime') {
      if (_getController('animeTitle').text == '') {
        canSave = false;
      }
    } else if (_selectedType == 'website') {
      if (_getController('webUrl').text == '') {
        canSave = false;
      }
    }
    return canSave;
  }

  @override
  void initState() {
    super.initState();
    if (widget.editMode && widget.item != null) {
      _onEditInit(widget.item as PinnedItem);
    }
  }

  _onEditInit(PinnedItem item) {
    _getController('category').text = item.category;
    if (item.type == PinnedItemType.anime) {
      _selectedType = 'anime';
      final attr = widget.item?.attribute as PinnedItemAttributeAnime;
      _getController('animeTitle').text = attr.title;
    } else if (item.type == PinnedItemType.website) {
      _selectedType = 'website';
      final attr = widget.item?.attribute as PinnedItemAttributeWebsite;
      _getController('webTitle').text = attr.title;
      _getController('webUrl').text = attr.url;
      _getController('webDescription').text = attr.description;
    } else if (item.type == PinnedItemType.notes) {
      _selectedType = 'notes';
      final attr = widget.item?.attribute as PinnedItemAttributeNotes;
      _getController('notesTitle').text = attr.title;
      _getController('notesDescription').text = attr.description;
      _getController('notesContent').text = attr.content;
      _getController('notesTopics').text = attr.topics;
    }
  }

  _buildMainData(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Data',
            style: Theme.of(context).textTheme.headline6,
          ),
          FormTextInput(
            label: 'Category',
            controller: _getController('category'),
          ),
          // drodpwon
          // Container(
          //   margin: EdgeInsets.only(top: 10),
          //   child: DropdownButton<String>(
          //     value: _selectedType,
          //     icon: const Icon(Icons.arrow_downward),
          //     iconSize: 24,
          //     elevation: 16,
          //     style: const TextStyle(color: Colors.deepPurple),
          //     underline: Container(
          //       height: 2,
          //       color: Colors.deepPurpleAccent,
          //     ),
          //     onChanged: (String? newValue) {
          //       setState(() {
          //         _selectedType = newValue!;
          //       });
          //     },
          //     items: <String>['anime', 'website']
          //         .map<DropdownMenuItem<String>>((String value) {
          //       return DropdownMenuItem<String>(
          //         value: value,
          //         child: Text(value),
          //       );
          //     }).toList(),
          //   ),
          // ),
          // FormTextInput(
          //   label: 'Description',
          //   controller: _getController('description'),
          //   keyboardType: TextInputType.multiline,
          // ),
        ],
      ),
    );
  }

  _buildAttributesBuilder(BuildContext context) {
    if (_selectedType == 'website') {
      return Column(
        children: [
          // buildMainData(context),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMainData(context),
                Text(
                  'Website Attributes',
                  style: Theme.of(context).textTheme.headline6,
                ),
                if (widget.editMode) ...[
                  FormTextInput(
                    label: 'Title',
                    controller: _getController('webTitle'),
                  ),
                  FormTextInput(
                    label: 'Description',
                    controller: _getController('webDescription'),
                    keyboardType: TextInputType.multiline,
                  ),
                ],
                FormTextInput(
                  label: 'Url',
                  controller: _getController('webUrl'),
                ),
                // FormTextInput(label: 'Description'),
              ],
            ),
          ),
        ],
      );
    } else if (_selectedType == 'anime') {
      return Column(
        children: [
          _buildMainData(context),
          Container(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Anime Attributes',
                  style: Theme.of(context).textTheme.headline6,
                ),
                Container(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: FormTextInput(
                          label: 'Title',
                          controller: _getController('animeTitle'),
                          enabled: false,
                        ),
                      ),
                      const SizedBox(width: 20),
                      PinnedButton(
                        title: 'Search Anime',
                        icon: CupertinoIcons.search,
                        onPressed: () async {
                          var result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SearchAnimeScreen(),
                            ),
                          );

                          if (result != null && result is Map) {
                            if (result['title'] != null) {
                              try {
                                _getController('animeTitle').text =
                                    result['title'];
                                _tmpData = jsonEncode(result);
                              } catch (e) {}
                            }
                          }
                        },
                      )
                    ],
                  ),
                ),
                // FormTextInput(label: 'Description'),
              ],
            ),
          ),
        ],
      );
    } else if (_selectedType == 'notes') {
      return Column(
        children: [
          // buildMainData(context),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMainData(context),
                Text(
                  'Notes Attributes',
                  style: Theme.of(context).textTheme.headline6,
                ),
                FormTextInput(
                  label: 'Title',
                  controller: _getController('notesTitle'),
                ),
                FormTextInput(
                  label: 'Description',
                  controller: _getController('notesDescription'),
                  keyboardType: TextInputType.multiline,
                ),
                FormTextInput(
                  label: 'Notes',
                  controller: _getController('notesContent'),
                  keyboardType: TextInputType.multiline,
                ),
                FormTextInput(
                  label: 'Topics',
                  controller: _getController('notesTopics'),
                ),
                // FormTextInput(label: 'Description'),
              ],
            ),
          ),
        ],
      );
    }
    return Container();
  }

  _buildButtonBuilder(BuildContext context) {
    return PinnedButton(
      title: 'Save',
      icon: Icons.save_rounded,
      margin: const EdgeInsets.all(10),
      onPressed: () {
        if (!_checkCanSave()) {
          EasyLoading.showError(
            'Please fill all required fields',
            duration: const Duration(seconds: 2),
          );
          return;
        }
        save(context);
      },
    );
  }

  _onBeforeSave(BuildContext context) async {
    await _showLoading(show: true);
    print('onBeforeSave');
  }

  _onSaving(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 1));

    var category = _getController('category').text;

    try {
      var makeEdit = false;
      if (_selectedType == 'website') {
        if (!widget.editMode) {
          var url = _getController('webUrl').text;
          var uuid = generateUUID();
          final item = await createPinnedItemTypeWebsite(uuid, url);
          item.category = category;
          DB.add(item);
        } else {
          var id = widget.item?.id ?? '';
          var item = widget.item as PinnedItem;
          var attr = item.attribute as PinnedItemAttributeWebsite;
          attr.title = _getController('webTitle').text;
          attr.url = _getController('webUrl').text;
          attr.description = _getController('webDescription').text;
          item = updatePinnedItemTypeWebsite(item);
          item.category = category;
          DB.update(id, item);
        }
      } else if (_selectedType == 'anime') {
        if (widget.editMode) {
          final item = widget.item as PinnedItem;
          final attr = item.attribute as PinnedItemAttributeAnime;
          if (attr.title != _getController('animeTitle').text) {
            makeEdit = true;
          }
        }
        if (!makeEdit) {
          var title = _getController('animeTitle').text;
          var uuid = generateUUID();
          var data = jsonDecode(_tmpData);
          if (data is Map) {
            final item = await createPinnedItemTypeAnime(
              uuid,
              data as Map<String, dynamic>,
            );
            item.category = category;
            DB.add(item);
          }
        } else {
          var data = jsonDecode(_tmpData) as Map<String, dynamic>;
          var id = widget.item?.id ?? '';
          final item = await createPinnedItemTypeAnime(id, data);
          item.category = category;
          DB.update(id, item);
        }
      } else if (_selectedType == 'notes') {
        if (!widget.editMode) {
          var uuid = generateUUID();
          final item = await createPinnedItemTypeNotes(
            uuid,
            _getController('notesTitle').text,
            _getController('notesDescription').text,
            _getController('notesContent').text,
            _getController('notesTopics').text,
          );
          item.category = category;
          DB.add(item);
          print('add notes $item');
        } else {
          var id = widget.item?.id ?? '';
          var item = widget.item as PinnedItem;
          var attr = item.attribute as PinnedItemAttributeNotes;
          attr.title = _getController('notesTitle').text;
          attr.description = _getController('notesDescription').text;
          attr.content = _getController('notesContent').text;
          attr.topics = _getController('notesTopics').text;
          item = await updatePinnedItemTypeNotes(item);
          item.category = category;
          print('add notes $item');
          DB.update(id, item);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  _onAfterSave(BuildContext context) async {
    print('onAfterSave');
    await _showLoading(show: false);
    Navigator.pop(context);
  }

  save(BuildContext context) async {
    await this._onBeforeSave(context);
    await this._onSaving(context);
    await this._onAfterSave(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: AbsorbPointer(
        absorbing: isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.chevron_left),
                        Text('Back'),
                      ],
                    ),
                  ),
                  Container(
                    child: Text(
                      widget.editMode ? 'Edit Item' : 'New item',
                      style: Theme.of(context).textTheme.headline2?.merge(
                            const TextStyle(
                              // height: .2,
                              fontSize: 28,
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (!widget.editMode)
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Type Data'),
                          DropdownButton(
                            value: _selectedType,
                            items: [
                              ['anime', 'Anime'],
                              ['website', 'Website'],
                              ['notes', 'Notes'],
                            ].map((data) {
                              return DropdownMenuItem(
                                value: data[0],
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    top: 2,
                                    bottom: 2,
                                  ),
                                  child: Text(
                                    data[1],
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        ?.merge(
                                          const TextStyle(
                                            fontSize: 18,
                                            color: Colors.black87,
                                          ),
                                        ),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value as String;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  _buildAttributesBuilder(context),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildButtonBuilder(context),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

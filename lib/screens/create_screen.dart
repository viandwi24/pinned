import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pinned/components/button.dart';
import 'package:pinned/constant.dart';
import 'package:pinned/utils/create_pinned_items.dart';
import 'package:pinned/utils/db.dart';
import 'package:pinned/utils/generate_uuid.dart';

import 'parts/search_anime_screen.dart';

class FormTextInput extends StatefulWidget {
  const FormTextInput(
      {super.key,
      required this.label,
      required this.controller,
      this.margin,
      this.enabled});

  final String label;
  final TextEditingController controller;
  final EdgeInsets? margin;
  final bool? enabled;

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
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(color: kBorderInputColor.withOpacity(0.7)),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: kBorderInputColor.withOpacity(0.7)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: kBorderInputColor.withOpacity(0.7)),
          ),
        ),
      ),
    );
  }
}

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

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

  _buildMainData(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data',
            style: Theme.of(context).textTheme.headline6,
          ),
          FormTextInput(label: 'Title', controller: _getController('title')),
          FormTextInput(
              label: 'Description', controller: _getController('description')),
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
                Text(
                  'Website Attributes',
                  style: Theme.of(context).textTheme.headline6,
                ),
                FormTextInput(
                    label: 'Url', controller: _getController('webUrl')),
                // FormTextInput(label: 'Description'),
              ],
            ),
          ),
        ],
      );
    } else if (_selectedType == 'anime') {
      return Column(
        children: [
          // buildMainData(context),
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
                      SizedBox(width: 20),
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
                                print('dataya $_tmpData');
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
            duration: Duration(seconds: 2),
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
    await Future.delayed(Duration(seconds: 1));
    if (_selectedType == 'website') {
      var url = _getController('webUrl').text;
      var uuid = generateUUID();
      try {
        final item = await createPinnedItemTypeWebsite(uuid, url);
        setState(() {
          DB.add(item);
        });
      } catch (e) {}
    } else if (_selectedType == 'anime') {
      var title = _getController('animeTitle').text;
      var uuid = generateUUID();
      try {
        print('saving anime');
        print(_tmpData);
        var data = jsonDecode(_tmpData);
        if (data is Map) {
          print('data is map');
          final item = await createPinnedItemTypeAnime(
              uuid, data as Map<String, dynamic>);
          print('item created : ${item.toJson().toString()}');
          setState(() {
            DB.add(item);
          });
        }
      } catch (e) {
        print('error saving anime');
        print(e);
      }
    }
  }

  _onAfterSave(BuildContext context) async {
    print('onAfterSave');
    await _showLoading(show: false);
  }

  save(BuildContext context) async {
    await this._onBeforeSave(context);
    await this._onSaving(context);
    await this._onAfterSave(context);
    Navigator.pop(context);
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
                      'New item',
                      style: Theme.of(context).textTheme.headline2?.merge(
                            const TextStyle(
                              // height: .2,
                              fontSize: 28,
                            ),
                          ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20, bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Type Data'),
                        DropdownButton(
                          value: _selectedType,
                          items: const [
                            DropdownMenuItem(
                              value: 'website',
                              child: Text('Website'),
                            ),
                            DropdownMenuItem(
                              value: 'anime',
                              child: Text('Anime'),
                            ),
                            DropdownMenuItem(
                              value: 'wattpad',
                              child: Text('Wattpad'),
                            ),
                          ],
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

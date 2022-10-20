// enum type
import 'dart:math';
import 'package:flutter/material.dart';

enum PinnedItemType {
  website,
  anime,
  notes,
}

class PinnedItemAttributeNotes {
  PinnedItemAttributeNotes({
    required this.title,
    required this.description,
    required this.content,
    required this.topics,
  });

  String title;
  String description;
  String content;
  String topics;

  // to json
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'topics': topics,
    };
  }
}

class PinnedItemAttributeWebsite {
  String url;
  String title;
  String description;
  String imageUrl;

  PinnedItemAttributeWebsite({
    required this.url,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  // to json
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}

class PinnedItemAttributeAnime {
  String url;
  String title;
  String imageUrl;
  String synopsis;

  PinnedItemAttributeAnime({
    required this.url,
    required this.title,
    required this.imageUrl,
    required this.synopsis,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'imageUrl': imageUrl,
      'synopsis': synopsis,
    };
  }
}

class PinnedItem {
  String id;
  String title;
  String description;
  String? imageUrl;
  PinnedItemType type;
  dynamic attribute;
  Color color;
  String category;

  PinnedItem(
      {required this.id,
      required this.title,
      required this.description,
      required this.imageUrl,
      required this.type,
      required this.attribute,
      required this.color,
      required this.category}) {
    // type
    if (type == PinnedItemType.website) {
      assert(attribute is PinnedItemAttributeWebsite);
    } else if (type == PinnedItemType.anime) {
      assert(attribute is PinnedItemAttributeAnime);
    } else if (type == PinnedItemType.notes) {
      assert(attribute is PinnedItemAttributeNotes);
    } else {
      throw Exception('Unknown type for Pinned Item');
    }
  }

  // to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'type': type.toString(),
      'color': color.toString(),
      'attribute': attribute!.toJson(),
    };
  }

  // from json
  factory PinnedItem.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final attribute = json['attribute'] as Map<String, dynamic>;

    var _attrInst;
    var _type;
    if (type == 'PinnedItemType.website') {
      _type = PinnedItemType.website;
      _attrInst = PinnedItemAttributeWebsite(
        url: attribute['url'] as String,
        title: attribute['title'] as String,
        description: attribute['description'] as String,
        imageUrl: attribute['imageUrl'] as String,
      );
    } else if (type == 'PinnedItemType.anime') {
      _type = PinnedItemType.anime;
      _attrInst = PinnedItemAttributeAnime(
        url: attribute['url'] as String,
        title: attribute['title'] as String,
        imageUrl: attribute['imageUrl'] as String,
        synopsis: attribute['synopsis'] as String,
      );
    } else if (type == 'PinnedItemType.notes') {
      _type = PinnedItemType.notes;
      _attrInst = PinnedItemAttributeNotes(
        title: attribute['title'] as String,
        description: attribute['description'] as String,
        content: attribute['content'] as String,
        topics: attribute['topics'] as String,
      );
    } else {
      throw Exception('Unknown type for Pinned Item');
    }

    String valueColorString = json['color'].split('(0x')[1].split(')')[0];
    int valueColor = int.parse(valueColorString, radix: 16);

    return PinnedItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      type: _type,
      attribute: _attrInst,
      color: Color(valueColor),
      category: '',
    );
  }
}

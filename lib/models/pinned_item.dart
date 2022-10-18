// enum type
import 'dart:math';
import 'package:flutter/material.dart';

enum PinnedItemType {
  website,
  anime,
}

class PinnedItemAttributeWebsite {
  final String url;
  final String title;
  final String description;
  final String imageUrl;

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
  final String url;
  final String title;
  final String imageUrl;
  final String synopsis;

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
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final PinnedItemType type;
  final dynamic attribute;
  final Color color;
  final String category;

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
    } else {
      throw Exception('Unknown type');
    }

    // type::builder
    if (type == PinnedItemType.website) {
      applyWebsiteType();
    }
  }

  Future applyWebsiteType() async {
    // final website = attribute as PinnedItemAttributeWebsite;
    // Metadata? _metadata = await AnyLinkPreview.getMetadata(
    //   link: website.url,
    // );
    // print(title);
    // print(_metadata?.title);
    // print(_metadata?.image);
    // print('===========================');
  }

  // to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'type': type.toString(),
      'attribute': attribute!.toJson(),
    };
  }
}

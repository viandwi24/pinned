import 'dart:math';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:pinned/models/pinned_item.dart';

Color randomColor() {
  // if color null, random color
  final List<Color> _colors = [
    // 3FBE91, 0698C7, 48C0D5, 8A6BAD, E56868, EAAE6C, EED25F, 66C3B8, 486FAD
    const Color(0xFFCD5F98),
    const Color(0xFF3FBE91),
    const Color(0xFF0698C7),
    const Color(0xFF48C0D5),
    const Color(0xFF8A6BAD),
    const Color(0xFFE56868),
    const Color(0xFFEAAE6C),
    // const Color(0xFFEED25F),
    const Color(0xFF66C3B8),
    const Color(0xFF486FAD),
  ];
  return _colors[Random().nextInt(_colors.length)];
}

Future<PinnedItem> createPinnedItemTypeWebsite(String id, String url) async {
  Metadata? metadata = await AnyLinkPreview.getMetadata(
    link: url,
    cache: Duration(days: 7),
  );

  return PinnedItem(
    id: id,
    title: metadata?.title ?? '',
    description: metadata?.desc ?? 'No Description',
    imageUrl: metadata?.image ?? '',
    type: PinnedItemType.website,
    color: randomColor(),
    category: '',
    attribute: PinnedItemAttributeWebsite(
      url: url,
      title: metadata?.title ?? '',
      imageUrl: metadata?.image ?? '',
      description: metadata?.desc ?? '',
    ),
  );
}

Future<PinnedItem> createPinnedItemTypeAnime(
    String id, Map<String, dynamic> data) async {
  final animeTitle =
      '${data['title'] ?? ''} (${data['title_japanese'] ?? ''})' ?? '';
  final animeImage = data['images']?['jpg']?['small_image_url'] ?? '';
  final animeSynopsis = data['synopsis'] ?? '';
  return PinnedItem(
    id: id,
    title: animeTitle,
    description: animeSynopsis ?? 'No Description',
    imageUrl: animeImage ?? '',
    type: PinnedItemType.anime,
    color: randomColor(),
    category: '',
    attribute: PinnedItemAttributeAnime(
      url: data['url'] ?? '',
      title: animeTitle,
      imageUrl: animeImage,
      synopsis: animeSynopsis,
    ),
  );
}

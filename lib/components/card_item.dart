import 'dart:convert';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:pinned/constant.dart';
import 'package:pinned/models/pinned_item.dart';

class CardItem extends StatefulWidget {
  const CardItem({super.key, required this.item});

  final PinnedItem item;

  @override
  State<CardItem> createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  bool imageUrlError = false;

  String getShortDescription() {
    const maxChar = 75;
    final description = widget.item.description;
    if (description.length > maxChar) {
      return '${description.substring(0, maxChar)}...';
    }
    return description;
  }

  String getShortTitle() {
    const maxChar = 30;
    final title = widget.item.title;
    if (title.length > maxChar) {
      return '${title.substring(0, maxChar)}...';
    }
    return title;
  }

  buildTypeWebsite(BuildContext context) {
    final website = widget.item.attribute as PinnedItemAttributeWebsite;
    return Row(
      children: [
        Expanded(
          flex: 8,
          child: Container(
            padding: EdgeInsets.only(right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 6),
                  child: Text(
                    widget.item.title,
                    style: Theme.of(context).textTheme.caption?.merge(
                          const TextStyle(
                            color: kDarkTextColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                  ),
                ),
                if (getShortDescription().length > 26)
                  Container(
                    margin: EdgeInsets.only(bottom: 6),
                    child: Text(
                      getShortDescription(),
                      style: Theme.of(context).textTheme.bodyText1?.merge(
                            TextStyle(color: kDarkTextColor.withOpacity(0.7)),
                          ),
                    ),
                  ),
                Text(
                  website.url,
                  style: Theme.of(context).textTheme.bodyText1?.merge(
                        TextStyle(
                          overflow: TextOverflow.ellipsis,
                          color: kDarkTextColor.withOpacity(0.9),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                ),
              ],
            ),
          ),
        ),
        if (!imageUrlError)
          Expanded(
            flex: 4,
            // show full cover image from imageUrl
            child: Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  website.imageUrl,
                  fit: BoxFit.fitHeight,
                  errorBuilder: (BuildContext ctx, Object ex, StackTrace? st) {
                    Future.delayed(Duration.zero, () async {
                      setState(() {
                        imageUrlError = true;
                      });
                    });
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  buildTypeAnime(BuildContext context) {
    final website = widget.item.attribute as PinnedItemAttributeAnime;
    return Row(
      children: [
        Expanded(
          flex: 8,
          child: Container(
            padding: EdgeInsets.only(right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 6),
                  child: Text(
                    getShortTitle(),
                    style: Theme.of(context).textTheme.caption?.merge(
                          const TextStyle(
                            color: kDarkTextColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                  ),
                ),
                if (getShortDescription().length > 26)
                  Container(
                    margin: EdgeInsets.only(bottom: 6),
                    child: Text(
                      getShortDescription(),
                      style: Theme.of(context).textTheme.bodyText1?.merge(
                            TextStyle(color: kDarkTextColor.withOpacity(0.7)),
                          ),
                    ),
                  ),
                Text(
                  website.url,
                  style: Theme.of(context).textTheme.bodyText1?.merge(
                        TextStyle(
                          overflow: TextOverflow.ellipsis,
                          color: kDarkTextColor.withOpacity(0.9),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                ),
              ],
            ),
          ),
        ),
        if (!imageUrlError)
          Expanded(
            flex: 4,
            // show full cover image from imageUrl
            child: Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  website.imageUrl,
                  fit: BoxFit.fitHeight,
                  errorBuilder: (BuildContext ctx, Object ex, StackTrace? st) {
                    Future.delayed(Duration.zero, () async {
                      setState(() {
                        imageUrlError = true;
                      });
                    });
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 26,
        vertical: 18,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.item.color,
        borderRadius: BorderRadius.circular(12),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.1),
        //     blurRadius: 10,
        //     offset: const Offset(0, 5),
        //   ),
        // ],
      ),
      child: Builder(
        builder: (context) {
          if (widget.item.type == PinnedItemType.website) {
            return buildTypeWebsite(context);
          } else if (widget.item.type == PinnedItemType.anime) {
            return buildTypeAnime(context);
          }

          // defaults
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item.title,
                style: Theme.of(context).textTheme.caption?.merge(
                      const TextStyle(
                        color: kDarkTextColor,
                      ),
                    ),
              ),
              Text(
                getShortDescription(),
                style: Theme.of(context).textTheme.bodyText1?.merge(
                      TextStyle(
                        color: kDarkTextColor.withOpacity(0.7),
                      ),
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}

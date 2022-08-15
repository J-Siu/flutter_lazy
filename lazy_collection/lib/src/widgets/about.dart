import '../flutter.dart' as lazy;
import '../extensions/list.dart';
import 'package:flutter/material.dart';

/// ### Lazy [About] - let you fill in fields and generate a popup
///
/// - Skip blank/null fields automatically
class About {
  String? author;
  String? blog;
  String? blogUrl;
  String? copyright;
  String? homepage;
  String? homepageUrl;
  String? license;
  String? licenseUrl;
  String? privacyPolicyUrl;
  String? project;
  String? repo;
  String? repoUrl;
  String? title;
  String? version;
  Widget? logo;

  /// Used as [children] in [popup]
  List<Widget> content = [];

  /// Use as [title] in [popup]
  /// - extend this class and `override` to change order/behavior
  Widget? widgetTitle() {
    if (title != null) {
      return Text(
        title!,
        textAlign: TextAlign.center,
      );
    }
    return null;
  }

  /// Clear and fill in the [content] list
  /// - extend this class and `override` to change
  void fill(BuildContext context) {
    content.clear();
    if (content.isEmpty) {
      content.lazyAdd(logo);
      content.lazyAdd(lazy.textField(context, text: author));
      content.lazyAdd(lazy.textField(context, text: version));
      content.lazyAdd(lazy.textField(context, text: copyright));
      content.lazyAdd(lazy.urlButton(context, text: license, url: licenseUrl));
      content.lazyAdd(lazy.urlButton(context, text: repo, url: repoUrl));
      content.lazyAdd(lazy.urlButton(context, text: 'Privacy Policy', url: privacyPolicyUrl));
      content.lazyAdd(lazy.urlButton(context, text: homepage, url: homepageUrl));
      content.lazyAdd(lazy.urlButton(context, text: blog, url: blogUrl));
    }
  }

  /// Show [About] popup
  void popup(BuildContext context) async {
    fill(context);
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: widgetTitle(),
        children: content,
      ),
    );
  }
}

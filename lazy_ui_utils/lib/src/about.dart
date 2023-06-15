import 'flutter.dart' as lazy;
import 'package:flutter/material.dart';
import 'package:lazy_extensions/lazy_extensions.dart' as lazy;

/// ### Lazy [About] - let you fill in fields and generate a popup
///
/// - Skip blank/null fields automatically
class About {
  String? author;
  String? blog;
  String? blogUrl;
  String? copyright;
  String? help;
  String? helpUrl;
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
      content
        ..lazyAdd(logo)
        ..lazyAdd(lazy.textField(context, text: author))
        ..lazyAdd(lazy.textField(context, text: version))
        ..lazyAdd(lazy.textField(context, text: copyright))
        ..lazyAdd(lazy.urlButton(context, text: help, url: helpUrl))
        ..lazyAdd(lazy.urlButton(context, text: license, url: licenseUrl))
        ..lazyAdd(lazy.urlButton(context, text: repo, url: repoUrl))
        ..lazyAdd(lazy.urlButton(context,
            text: 'Privacy Policy', url: privacyPolicyUrl))
        ..lazyAdd(lazy.urlButton(context, text: homepage, url: homepageUrl))
        ..lazyAdd(lazy.urlButton(context, text: blog, url: blogUrl));
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

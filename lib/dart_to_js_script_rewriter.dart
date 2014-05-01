library dart_to_js_script_rewriter;

import 'package:html5lib/parser.dart' show parse;
import 'package:html5lib/dom.dart' show Document;
import 'package:barback/barback.dart' show Asset, Transform, Transformer;
import 'dart:async' show Future;

/// Finds script tags with type equals application/dart
/// and rewrites them to point to the JS version.
/// This eliminates a 404 get on the .dart file and
/// speeds up initial loads. Win!
class DartToJsScriptRewriter extends Transformer {
  DartToJsScriptRewriter.asPlugin();
  
  String get allowedExtensions => ".html";
  
  Future apply(Transform transform) {
    var id = transform.primaryInput.id;
    return transform.primaryInput.readAsString().then((content) {
      var document = parse(content);

      removeDartDotJsTags(document);
      rewriteDartTags(document);
      
      return document;
    }).then((document) {
      return transform.addOutput(new Asset.fromString(id, document.outerHtml));
    });
  }

  void removeDartDotJsTags(Document document) {
    document.querySelectorAll('script').where((tag) {
      return tag.attributes['src'] != null &&
             tag.attributes['src'].endsWith('dart.js');
    }).forEach((tag) => tag.remove());
  }

  void rewriteDartTags(Document document) {
    document.querySelectorAll('script').where((tag) {
      return tag.attributes['type'] == 'application/dart' &&
             tag.attributes['src'] != null;
    }).forEach((tag) {
      var src = tag.attributes['src'];
      tag.attributes['src'] = '$src.js';
      tag.attributes.remove('type');
    });
  }
}
Assortment
==========

Simple sortable DOM elements in Dart using HTML5 drag and drop

## Usage ##
To use this library in your code :

* add a dependency in your `pubspec.yaml` :

```yaml
dependencies:
  assortment: ">=0.1.0 <1.0.0"
```

* add import in your `dart` code :

```dart
import 'package:assortment/assortment.dart';
```

* create an Assortment within an element

```dart
var a = new Assortment(querySelector('#sortable-container'));
```

* add children to the Assortment

```dart
a.addElements(querySelectorAll('#sortable-container .sortable-entry'));
```

* rearrange elements by dragging and dropping

* listen for events to run code during drags

```dart
a.onDragEnter.listen((AssortmentEvent event) {
  // update model
}
```

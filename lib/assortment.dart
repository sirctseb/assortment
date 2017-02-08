// Copyright (c) 2013, Christopher Best
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

library Assortment;

import "dart:html";
import "dart:async";
import "package:dnd/dnd.dart";

/// An event that occurs during a drag on a sortable element
class AssortmentEvent {
  /// The [MouseEvent] that instigated this event
  MouseEvent mouseEvent;

  /// The [Element] being dragged
  Element dragElement;

  /// The [Element] being entered
  Element enterElement;

  /// The [Element] the cursor is coming from
  Element fromElement;

  AssortmentEvent._(MouseEvent this.mouseEvent, Element this.dragElement,
      {Element this.enterElement, Element this.fromElement}) {}
}

/// A simple collection of elements that can be sorted by dragging and dropping
class Assortment {
  /// Construct an assortment within parent
  Assortment(Element parent) {
    _parent = parent;
  }

  Element _parent;

  /// The parent element of the sortable elements
  Element get parent => _parent;

  // The last element that the cursor entered
  Element _fromElement;
  // The element begin dragged
  Element _dragElement;

  // Expose event streams
  StreamController<AssortmentEvent> _dragStartStreamController =
      new StreamController<AssortmentEvent>();

  /// Stream of events that occur when drags start
  Stream<AssortmentEvent> get onDragStart => _dragStartStreamController.stream;

  StreamController<AssortmentEvent> _dragEnterStreamController =
      new StreamController<AssortmentEvent>();

  /// Stream of events that occur when drags enter an element in the assortment
  Stream<AssortmentEvent> get onDragEnter => _dragEnterStreamController.stream;

  StreamController<AssortmentEvent> _dragEndStreamController =
      new StreamController<AssortmentEvent>();

  /// Stream of evenst that occur when a drag ends
  Stream<AssortmentEvent> get onDragEnd => _dragEndStreamController.stream;

  bool get isDragging => _dragging;
  bool _dragging = false;

  // drag event subscriptions by elementxevent
  Map<int, List<StreamSubscription>> _subscriptions = {};
  void _addListener(Element el, StreamSubscription sub) {
    if (!_subscriptions.containsKey(el.hashCode)) {
      _subscriptions[el.hashCode] = [sub];
    } else {
      _subscriptions[el.hashCode].add(sub);
    }
  }

  /// Add an element to the assortment
  void addElement(Element element) {
    var draggable =
        new Draggable(element, avatarHandler: new AvatarHandler.clone());

    draggable.onDragEnd.listen((DraggableEvent event) {
      _dragEndStreamController.add(
          new AssortmentEvent._(event.originalEvent, event.draggableElement));
    });

    var dropzone = new Dropzone(element);
    dropzone.onDragOver.listen((DropzoneEvent event) {
      swapElements(event.draggableElement, event.dropzoneElement);
    });
  }

  /// Simple function to swap two elements.
  void swapElements(Element elm1, Element elm2) {
    var parent1 = elm1.parent;
    var next1 = elm1.nextElementSibling;
    var parent2 = elm2.parent;
    var next2 = elm2.nextElementSibling;

    parent1.insertBefore(elm2, next1);
    parent2.insertBefore(elm1, next2);
  }

  void restOfAddElement(Element element) {
    // make element draggable
    element.attributes["draggable"] = "true";

    // add drag start handler
    _addListener(element, element.onDragStart.listen((event) {
      _dragging = true;
      // use the drag icon for moving
      event.dataTransfer.effectAllowed = "move";
      event.dataTransfer.setData('text/plain', '');
      // set the drag element
      _dragElement = event.currentTarget;
      // add assortment event to stream
      _dragStartStreamController
          .add(new AssortmentEvent._(event, _dragElement));
    }));

    // prevent the animation that occurs when a drag fails
    _addListener(element, element.onDragOver.listen((event) {
      event.preventDefault();
    }));

    // add enter handler
    // TODO check that dragged element is in the assortment
    _addListener(element, element.onDragEnter.listen((MouseEvent event) {
      // cache the current from element
      Element fromElement = _fromElement;

      // update the from element
      _fromElement = event.target;

      // if we are moving within a single sortable element, bail
      if ((event.currentTarget as Element).contains(fromElement)) return;

      // get the index of the element begin dragged
      int dragIndex = parent.children.indexOf(_dragElement);

      // get the index of the element being dragged into
      int preIndex = parent.children.indexOf(event.currentTarget);

      // move the dragged element before or after the entered element depending on their positions
      if (dragIndex < preIndex) {
        (event.currentTarget as Element)
            .insertAdjacentElement("afterEnd", _dragElement);
      } else {
        (event.currentTarget as Element)
            .insertAdjacentElement("beforeBegin", _dragElement);
      }

      // add assortment event to stream
      _dragEnterStreamController.add(new AssortmentEvent._(event, _dragElement,
          enterElement: event.currentTarget, fromElement: _fromElement));
    }));

    // add end handler
    _addListener(element, element.onDragEnd.listen((event) {
      _dragging = false;
      // add assortment event to stream
      _dragEndStreamController.add(new AssortmentEvent._(event, _dragElement));
    }));
  }

  /// Add a set of elements to the assortment
  void addElements(Iterable<Element> elements) {
    // add individually
    elements.forEach((element) => addElement(element));
  }

  void removeElement(Element element) {
    // check that we are subscribed on element
    if (_subscriptions.containsKey(element.hashCode)) {
      // cancel subscriptions
      for (var sub in _subscriptions[element.hashCode]) {
        sub.cancel();
      }
      // remove _subs entry
      _subscriptions.remove(element.hashCode);
      // remove draggable attribute
      element.attributes.remove('draggable');
    }
  }
}

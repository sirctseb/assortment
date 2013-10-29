library Assortment;

import "dart:html";
import "dart:async";

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

  AssortmentEvent(MouseEvent this.mouseEvent, Element this.dragElement,
      { Element this.enterElement, Element this.fromElement }) {}
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

  // The set of elements that are sortable
  Set<Element> _elements = new Set();
  // The last element that the cursor entered
  Element _fromElement;
  // The element begin dragged
  Element _dragElement;

  // Expose event streams
  StreamController<AssortmentEvent> _dragStartStreamController = new StreamController<AssortmentEvent>();
  /// Stream of events that occur when drags start
  Stream<AssortmentEvent> get onDragStart => _dragStartStreamController.stream;

  StreamController<AssortmentEvent> _dragEnterStreamController = new StreamController<AssortmentEvent>();
  /// Stream of events that occur when drags enter an element in the assortment
  Stream<AssortmentEvent> get onDragEnter => _dragEnterStreamController.stream;

  StreamController<AssortmentEvent> _dragEndStreamController = new StreamController<AssortmentEvent>();
  /// Stream of evenst that occur when a drag ends
  Stream<AssortmentEvent> get onDragEnd => _dragEndStreamController.stream;

  /// Add an element to the assortment
  void addElement(Element element) {
    // add to the element set
    _elements.add(element);

    // make element draggable
    element.attributes["draggable"] = "true";

    // add drag start handler
    element.onDragStart.listen((event) {
      // use the drag icon for moving
      event.dataTransfer.effectAllowed = "move";
      // set the drag element
      _dragElement = event.currentTarget;
      // add assortment event to stream
      _dragStartStreamController.add(new AssortmentEvent(event, _dragElement));
    });

    // prevent the animation that occurs when a drag fails
    element.onDragOver.listen((event) {
      event.preventDefault();
    });

    // add enter handler
    // TODO check that dragged element is in the assortment
    element.onDragEnter.listen((MouseEvent event) {

      // cache the current from element
      Element fromElement = _fromElement;

      // update the from element
      _fromElement = event.target;

      // if we are moving within a single sortable element, bail
      if((event.currentTarget as Element).contains(fromElement)) return;

      // get the index of the element begin dragged
      int dragIndex = parent.children.indexOf(_dragElement);

      // get the index of the element being dragged into
      int preIndex = parent.children.indexOf(event.currentTarget);

      // move the dragged element before or after the entered element depending on their positions
      if(dragIndex < preIndex) {
        (event.currentTarget as Element).insertAdjacentElement("afterEnd", _dragElement);
      } else {
        (event.currentTarget as Element).insertAdjacentElement("beforeBegin", _dragElement);
      }

      // add assortment event to stream
      _dragEnterStreamController.add(new AssortmentEvent(event, _dragElement, enterElement: event.currentTarget, fromElement: _fromElement));
    });

    // add end handler
    element.onDragEnd.listen((event) {
      // add assortment event to stream
      _dragEndStreamController.add(new AssortmentEvent(event, _dragElement));
    });
  }
  /// Add a set of elements to the assortment
  void addElements(Iterable<Element> elements) {
    // add individually
    elements.forEach((element) => addElement(element));
  }
}


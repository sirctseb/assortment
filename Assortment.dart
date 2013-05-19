part of Tabasci;

// TODO can we subclass from Event?
/// An event that occurs during a drag on a sortable element 
class AssortmentEventDetails {
  /// The [MouseEvent] that instigated this event
  MouseEvent mouseEvent;
  /// The [Element] being dragged
  Element dragElement;
  /// The [Element] being entered
  Element enterElement;
  CloseEvent blah;
  /// The [Element] the cursor is coming from
  Element fromElement;
  
  AssortmentEventDetails(MouseEvent this.mouseEvent, Element this.dragElement,
      { Element this.enterElement, Element this.fromElement });
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
  
  // TODO figure out how to provide a stream
  // TODO which subclass of Stream to use? _EventStream?
  //Stream _onDragStart = new Stream<CustomEvent>();
  //Stream<CustomEvent> onDragStart => 
  
  /// Add an element to the assortment
  void addElement(Element element) {
    // add to the element set
    _elements.add(element);
    
    // make line draggable
    element.attributes["draggable"] = "true";
    
    // add drag start handler
    element.onDragStart.listen((event) {
      // use the drag icon for moving
      event.dataTransfer.effectAllowed = "move";
      // set the drag element
      _dragElement = event.currentTarget;
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
    });
    
    // add end handler
    element.onDragEnd.listen((event) {
      // callback
    });
  }
  /// Add a set of elements to the assortment
  void addElements(Iterable<Element> elements) {
    // add individually
    elements.forEach((element) => addElement(element));
  }
}


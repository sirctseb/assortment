part of Tabasci;

class Sortable {

  Sortable(Element this.parent);
  Element parent;
  Set<Element> _elements = new Set();
  Element _fromElement;
  Element _dragElement;
  void addElement(Element element) {
    _elements.add(element);
    
    // make line draggable
    element.attributes["draggable"] = "true";
    // add drag start handler
    element.onDragStart.listen((event) {
      // use the drag icon for moving
      event.dataTransfer.effectAllowed = "move";
      _dragElement = event.currentTarget;
    });

    // this prevents the animation that occurs when a drag fails
    element.onDragOver.listen((event) {
      event.preventDefault();
    });
    // notify the delegate that a line was dragged over this so it can move them
    element.onDragEnter.listen((MouseEvent event) {
      
      Element lastEnter = _fromElement;
      
      _fromElement = event.target;
      
      if((event.currentTarget as Element).contains(lastEnter)) return;
      
      int dragIndex = parent.children.indexOf(_dragElement);
      int preIndex = parent.children.indexOf(event.currentTarget);
      if(dragIndex < preIndex) {
        (event.currentTarget as Element).insertAdjacentElement("afterEnd", _dragElement);
      } else {
        (event.currentTarget as Element).insertAdjacentElement("beforeBegin", _dragElement);
      }
    });
    element.onDragEnd.listen((event) {
      // callback
    });
  }
  void addElements(Collection<Element> elements) {
    elements.forEach((element) => addElement(element));
  }
}


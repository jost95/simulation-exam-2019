class EventList {
    private Node first;

    EventList() {
        this.first = null;
    }

    void put(Event event) {
        Node newNode = new Node(event);

        if (first == null) {
            first = newNode;
        } else if (first.next == null) {
            if (event.getTime() < first.event.getTime()) {
                Node tmp = first;
                first = newNode;
                first.next = tmp;
            } else {
                first.next = newNode;
            }
        } else {
            Node prevNode = first;
            Node currNode = first.next;

            if (event.getTime() < prevNode.event.getTime()) {
                first = newNode;
                first.next = prevNode;
            } else {
                while (currNode != null) {
                    if (event.getTime() < currNode.event.getTime()) {
                        break;
                    }

                    prevNode = currNode;
                    currNode = currNode.next;
                }

                prevNode.next = newNode;
                newNode.next = currNode;
            }
        }
    }

    Event pop() {
        if (first == null) {
            return null;
        } else {
            Node tmp = first;
            first = first.next;
            return tmp.event;
        }
    }

    private class Node {
        private Event event;
        private Node next;

        private Node(Event event) {
            this.event = event;
            this.next = null;
        }
    }
}

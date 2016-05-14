package  {
	import Node;

	public class Queue {
		private var first:Node;
	    private var last:Node;
		private var size:int;
		public function isEmpty():Boolean {
    	    return (first == null);
	    }

		public function Queue() {
			// constructor code
		}
		public function push(data:Object) {
			var node:Node = new Node();
			node.data = data;
			node.next = null;
			if (isEmpty()) {
				first = node;
				last = node;
			} else {
				last.next = node;
				last = node;
			}
			size++;
   		}
    
		public function pop() {
			if (isEmpty()) {
				trace("Error: \n\t Objects of type Queue must contain data before being dequeued.");
				return;
			}
			size--;
			var data = first.data;
			first = first.next;
			return data;
		}
    
		public function peek():Object
		{
			if (isEmpty()) {
				trace("Error: \n\t Objects of type Queue must contain data before you can peek.");
				return false;
			}
			return first.data;
		}
	}
}

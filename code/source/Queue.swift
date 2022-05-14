import Foundation

// Queue object to enable using queue further in program
struct Queue<T> {
  private var elements: [T] = []

  mutating func enqueue(_ value: T) {
    elements.append(value)
  }

  mutating func dequeue() -> T? {
    guard !elements.isEmpty else {
      return nil
    }
    return elements.removeFirst()
  }

  var head: T? {
    return elements.first
  }
  var tail: T? {
    return elements.last
  }
    
    var size: Int?{
        return elements.count
    }
    
    func seeElements() -> [T]?{
        return elements
    }
}

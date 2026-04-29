/// Собственная реализация динамических массивов
public struct DynamicArray<T> {
  /// указатель на помять с элементами
  private var buffer: UnsafeMutablePointer<T>
  /// количество определённых элементов
  private(set) var count: Int
  /// выделенная память (в кол-ве элементов)
  private var capacity: Int

  /// конструктор (по дефолту выделяет на 4 элемента)
  public init(capacity: Int = 4) {
    self.capacity = Swift.max(capacity, 1)
    self.count = 0
    buffer = UnsafeMutablePointer<T>.allocate(capacity: self.capacity)
  }

  /// Определение поведения при вызове структуры с []
  public subscript(index: Int) -> T {
    // геттер
    get {
      precondition(index >= 0 && index < count, "Index out of range")
      return buffer[index]
    }
    // сеттер
    set {
      precondition(index >= 0 && index < count, "Index out of range")
      buffer[index] = newValue
    }
  }

  /// деалокация массива в памяти
  public mutating func deallocate() {
    buffer.deinitialize(count: count)
    buffer.deallocate()
  }

  /// реалокация с новым размером
  private mutating func resize(to newCapacity: Int) {
    let newBuffer = UnsafeMutablePointer<T>.allocate(capacity: newCapacity)
    // перемещает элементы в новую память
    newBuffer.moveInitialize(from: buffer, count: count)
    buffer = newBuffer
    capacity = newCapacity
  }

  /// Добавление нового элемента в конец массива
  public mutating func append(_ element: T) {
    if count == capacity {
      resize(to: capacity * 2)
    }
    buffer.advanced(by: count).initialize(to: element)
    count += 1
  }

  /// Вставка элемента в позицию по индексу
  public mutating func insert(_ element: T, at index: Int) {
    precondition(index >= 0 && index <= count, "Index out of range")
    if count == capacity {
      resize(to: capacity * 2)
    }
    // инициализирует новый элемент в конце (копируя последний)
    buffer.advanced(by: count).initialize(to: buffer[count - 1])
    // перемещает все элементы до позиции вставки вправо
    for i in (index+1..<count).reversed() {
      buffer[i] = buffer[i-1]
    }
    buffer[index] = element
    count += 1
  }

  /// вставка в нулевой индекс
  public mutating func push(_ element: T) {
    insert(element, at: 0)
  }

  /// выплёвывает последний элемент массива. Возвращает nil, если массив пустой
  @discardableResult
  public mutating func pop() -> T? {
    guard count != 0 else { return nil }
    return remove(at: count - 1)
  }

  /// Удаляет элемент на позиции, сдвигая остальные. Возвращает удалённый
  @discardableResult
  public mutating func remove(at index: Int) -> T {
    precondition(index >= 0 && index < count, "Index out of range")
    let removed = buffer[index]
    // shift elements
    for i in index..<(count - 1) {
      buffer[i] = buffer[i + 1]
    }
    buffer.advanced(by: count - 1).deinitialize(count: 1)
    count -= 1
    // making buffer smaller if less than 25% of the capacity is used
    if count > 0 && count <= capacity / 4 {
      resize(to: capacity / 2)
    }
    return removed
  }
}

/// Определение протокола превращения в строку для возможности вывода в принт
/// (либо простого получения строки)
extension DynamicArray: CustomStringConvertible {
  public var description: String {
    let elements = (0..<count).map { "\(buffer[$0])" }.joined(separator: ", ")
    return "[\(elements)]"
  }
}

/// Строка откладки (содержит информацию о текущем размере)
extension DynamicArray : CustomDebugStringConvertible {
  public var debugDescription: String {
    return "Capacity: \(capacity)"
  }
}

/// Определение протокола итератора для возможной итерации по массиву.
extension DynamicArray: Sequence {
  public func makeIterator() -> IndexingIterator<[T]> {
    return (0..<count).map { buffer[$0] }.makeIterator()
  }
}


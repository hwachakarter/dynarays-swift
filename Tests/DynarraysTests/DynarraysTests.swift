import Testing
@testable import Dynarrays

@Test("Создание массива с ёмкостью 100") func creation() {
    var arr = DynamicArray<Int>(capacity: 100)
    #expect(arr.debugDescription == "Capacity: 100")
    arr.deallocate()  
}

@Test("Заполнение массива и итерация по нему") func iteration() {
    var arr = DynamicArray<Int>()
    for i in 0...10 {
        arr.append(i)
    }

    // проверка итерации и доступа по индексу
    var count = 0
    for i in arr {
        count += arr[i]
    }
    #expect(count == 55)
    
    // проверка функционального метода
    #expect(arr.reduce(0, +) == 55)
    arr.deallocate()
}

@Test("Пуш и поп") func pushPop() {
    var arr = DynamicArray<Int>()
    // эджкейс: массив пуст, поп должен вернуть nil
    #expect(arr.pop() == nil)
    
    (0...10).forEach {i in arr.append(i)}
    arr.push(5)
    #expect(arr[0] == 5)
    
    #expect(arr.pop() == 10)
    // если поп верно извлёк элемент, то повторный вызов вернёт иной элемент
    #expect(arr.pop() == 9)
    arr.deallocate()
}

@Test("удаление на позиции") func delAt() {
    var arr = DynamicArray<Int>()
    (1...10).forEach { i in arr.append(i) }
    arr.remove(at: 4) // удалить пятёрку
    #expect(arr.reduce(0, +) == 50) // 55 - 5 = 50
    arr.deallocate()
}

@Test("Превращение в строку") func toString() {
    var arr = DynamicArray<Int>()
    (1...5).forEach { i in arr.append(i) }
    // print вызывает переменную description для вывода
    #expect(arr.description == "[1, 2, 3, 4, 5]")
    arr.deallocate()
}

@Test("Проверка вставки") func insertion() {
    var arr = DynamicArray<Int>()
    (1...5).forEach { i in arr.append(i) }
    arr.insert(67, at: 3)
    #expect(arr.description == "[1, 2, 3, 67, 4, 5]")
    arr.deallocate()
}

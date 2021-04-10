var array = [Int](1 ... 20).shuffled()
print(array)

array.heapSort()
print(array)
array.heapSort(by: >)
print(array)

print(array.heapSorted())
print(array.heapSorted(by: >))

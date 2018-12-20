//
//  Array.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 12/20/18.
//

import Foundation

typealias DiffResults<Element: Diffable> = (updated: [Element], removed: [Element], inserted: [Element])
typealias DiffResultsIndexes = (updated: [Int], removed: [Int], inserted: [Int])

extension Array where Element: Diffable {
    func diff(with second: [Element]) -> DiffResults<Element> {
        let combinations = compactMap { firstElement in (firstElement, second.first { secondElement in firstElement.primaryKey == secondElement.primaryKey }) }
        let common = combinations.filter { $0.1 != nil }.compactMap { $0.0 }
        let removed = combinations.filter { $0.1 == nil }.compactMap { ($0.0) }
        let inserted = second.filter { secondElement in !common.contains { $0.primaryKey == secondElement.primaryKey } }
        let updated = compactMap { firstElement in
            second.first { secondElement in
                firstElement.primaryKey == secondElement.primaryKey && !firstElement.isEqual(to: secondElement)
            }
        }
        
        return (updated: updated, removed: removed, inserted: inserted)
    }
    
    func diffIndexes(with second: [Element]) -> DiffResultsIndexes {
        let diff = self.diff(with: second)
        let updatedIndexes = diff.updated
            .compactMap { updated in self.firstIndex { element in updated.primaryKey == element.primaryKey}}
        let removedIndexes = diff.removed
            .compactMap { removed in self.firstIndex { element in removed.primaryKey == element.primaryKey}}
        var lastIndex = count - removedIndexes.count
        let insertedIndexes = diff.inserted.map { _ -> Int in
                lastIndex += 1
                return lastIndex - 1
        }
        return (updated: updatedIndexes, removed: removedIndexes, inserted: insertedIndexes)
    }

//    func indexes(of elements: [Element]) -> [Int] {
//        var indexes: [Int] = []
//        elements.forEach { element in
//            if let index = index(of: element) {
//                indexes.append(index)
//            }
//        }
//
//        return indexes
//    }
}

public protocol Diffable {
    var primaryKey: String { get }
    
    func isEqual(to element: Self) -> Bool
}

//
//  Presentables+UITableView.swift
//  Presentables
//
//  Created by Ondrej Rafaj on 24/07/2017.
//  Copyright © 2017 manGoweb UK Ltd. All rights reserved.
//

import Foundation
import UIKit


fileprivate extension Array where Element == UITableViewCell.Type {
    
    func contains(className: AnyClass) -> Bool {
        return self.filter({$0 === className}).count > 0
    }
    
}

extension Array where Element == Int {

    func numbersAreInOrder() -> Bool {
        for (num, nextNum) in zip(self, dropFirst())
            where nextNum <= num { return false }
        return true
    }

    func missingIndexes() -> [Int] {
        var indexes: [Int] = []
        var currentIndex = 0
        for index in self {
            if index != currentIndex {
                indexes.append(contentsOf: (currentIndex..<index))
            }
            currentIndex = index + 1
        }
        return indexes
    }
}

extension UITableView: PresentableCollectionElement {
    
    func safeReloadData() {
        if Thread.isMainThread {
            reloadData()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.reloadData()
            }
        }
    }
    
    public func bind(withPresentableManager manager: inout PresentableManager) {
        dataSource = manager as? UITableViewDataSource
        delegate = manager as? UITableViewDelegate
        
        let m = manager
        manager.bindableData.bind { [weak m, weak self] (data) in
            guard let self = self, let data = m?.data else { return }
            // If sections gets shuffled around better use a basic reloadData or it is impossible to guess if there where some deletions, or if data gets cleared
            guard data.compactMap({ $0.sectionIndex }).numbersAreInOrder(), data.count > 0 else {
                print("Need reload - Kevin")
                data.enumerated().forEach { index, section in
                    self.register(section: section)
                    section.sectionIndex = index
                }
                self.safeReloadData()
                return
            }

            // Check for missing indexes from previously section index assigned.
            let removedIndexes = data.compactMap { $0.sectionIndex }.missingIndexes()

            // simply look for nil indexes for new sections.
            let unassigned = data.enumerated().compactMap { index, section -> (Int, PresentableSection)? in
                if section.sectionIndex == nil { return (index, section) }
                return nil
            }
            unassigned.forEach { self.register(section: $0.1) }
            data.enumerated().forEach { index, section in section.sectionIndex = index }

            // Group indexes per animation type, not sure if we really want that but it works.
            let insertIndexesPerAnimation = Dictionary(uniqueKeysWithValues:
                Dictionary.init(grouping: unassigned) { $0.1.presenterAnimation }
                    .map { key, value in
                        (key, value.map { $0.0 })
            })

            if removedIndexes.count > 0 {
                print("removing: \(removedIndexes) - Kevin")
                self.performBatchUpdates({
                    self.deleteSections(IndexSet(removedIndexes), with: .none)
                }) { completed in
                    print("deletion finished - Kevin")
                }
            }

            if insertIndexesPerAnimation.count > 0 {
                self.performBatchUpdates({
                    insertIndexesPerAnimation.forEach { animation, indexes in
                        print("inserting: \(indexes) - Kevin")
                        self.insertSections(IndexSet(indexes), with: animation)
                    }
                }) { completed in
                    print("insertion finished - Kevin")
                }
            }

            // Can't guess if a section needed reload. Expect user to use PresentableTableViewDataManager.reload(section: Int) for that.
            if removedIndexes.count == 0 && insertIndexesPerAnimation.count == 0 {
                print("Nothing to reload - Kevin")
            }
        }
        
        register(presentableSections: &manager.data)
        
        manager.needsReloadData = {
            self.safeReloadData()
        }

        if let manager = manager as? PresentableTableViewDataManager {
            manager.tableView = self
        }
    }
    
    func register(presentableSections sections: inout PresentableSections) {
        guard sections.count > 0 else {
            return
        }
        
        for  i in 0 ... (sections.count - 1) {
            let section: PresentableSection = sections[i]
            register(section: section)
        }
        
        safeReloadData()
    }
    
    // MARK: Helpers
    
    func register(section: PresentableSection) {
        DispatchQueue.global().async {
            if section.bindableHeader.listener == nil {
                section.bindableHeader.bind(listener: { (header) in
                    self.safeReloadData()
                })
            }
            if section.bindableFooter.listener == nil {
                section.bindableFooter.bind(listener: { (footer) in
                    self.safeReloadData()
                })
            }
            if section.bindablePresenters.listener == nil {
                section.bindablePresenters.bind(listener: { (presenters) in
                    self.safeReloadData()
                })
            }
        }
    }
    
}

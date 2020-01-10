//
//  TableViewController.swift
//  Presentables
//
//  Created by Ondrej Rafaj on 08/14/2017.
//  Copyright (c) 2017 Ondrej Rafaj. All rights reserved.
//

import UIKit
import Presentables


class TableViewController: UITableViewController {
    
    var manager: PresentableManager = TableDataManager()
    
    
    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "UITableView"
        
        tableView.bind(withPresentableManager: &manager)

        guard let manager = manager as? TableDataManager else { return }
        
        manager.data.append(manager.addNewSection(2))
        manager.data.append(manager.addNewSection(5))
        manager.data.append(manager.addNewSection(8))
        manager.data.remove(at: 1) // remove 5
        manager.data.append(manager.addNewSection(11))
        manager.data.append(manager.addNewSection(14))
        manager.data.remove(at: 2) // remove 11
        manager.data.append(manager.addNewSection(17))
        manager.data.append(manager.addNewSection(20))

        var newData = manager.data
        newData.remove(at: 0) // remove 2
        newData.remove(at: 2) // remove 17
        manager.data = newData

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
             manager.data.append(manager.addNewSection(23))
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            manager.data.insert(manager.addNewSection(100), at: 0)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Basically this should trigger nothing anymore
            manager.data = manager.data
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            manager.data[0].presentables.compactMap { $0 as? Presentable<TableViewCell2> }.forEach { presentable in
                presentable.configure = { $0.textLabel?.text = "Reloaded" }
            }
            manager.reload(section: 0)
        }
    }
}


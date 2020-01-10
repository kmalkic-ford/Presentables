//
//  TableDataManager.swift
//  Presentables_Example
//
//  Created by Ondrej Rafaj on 30/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import Presentables


class TableDataManager: PresentableTableViewDataManager {
    
    // MARK: Initialization
    
    override init() {
        super.init()
        
        selectedCell = { info in
            info.tableView.deselectRow(at: info.indexPath, animated: true)
            print("Did select cell no. \((info.indexPath.row + 1))")
        }
    }

    func addNewSection(_ start: Int) -> PresentableSection {
        print("Add new section - Kevin")
        let section = PresentableSection()

        let header = Presentable<TableViewHeader>.create { (header) in
            header.titleLabel.text = "It works :)"
        }
        section.header = header

        let presentable = Presentable<TableViewCell1>.create({ (cell) in
            cell.textLabel?.text = "First cell"
        }).cellSelected {
            print("First cell has been selected")
        }
        section.append(presentable)

        for i in start...start+2 {
            let presentable = Presentable<TableViewCell2>.create({ (cell) in
                cell.textLabel?.text = "Id: \((i))"
            })
            section.append(presentable)
        }

        return section
    }

    // MARK: Overriding table view delegate (optional)
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
}


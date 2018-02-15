//
//  ResultTableViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 22/08/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import Gini_iOS_SDK

/**
 Presents a dictionary of results from the analysis process in a table view.
 Values from the dictionary will be used as the cells titles and keys as the cells subtitles.
 */
final class ResultTableViewController: UITableViewController {
    
    /**
     The result dictionary from the analysis process.
     */
    var result: GINIResult!
    
    /**
     The document the results have been extracted from.
     Can be used for further processing.
     */
    var document: GINIDocument!
    
    fileprivate var sortedKeys: [String] {
        return Array(result.keys).sorted(by: <)
    }
}

extension ResultTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedKeys.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)
        let key = sortedKeys[indexPath.row]
        cell.textLabel?.text = result[key]?.value
        cell.detailTextLabel?.text = key
        return cell
    }
}

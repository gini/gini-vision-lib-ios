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
class ResultTableViewController: UITableViewController {
    
    /**
     The result dictionary from the analysis process.
     */
    var result: GINIResult!
    
    /**
     The document the results have been extracted from.
     Can be used for further processing.
     */
    var document: GINIDocument!
    
    private var sortedKeys: [String] {
        return Array(result.keys).sort(<)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Add feedback
    }
}

extension ResultTableViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedKeys.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("resultCell", forIndexPath: indexPath)
        let key = sortedKeys[indexPath.row]
        cell.textLabel?.text = result[key]?.value
        cell.detailTextLabel?.text = key
        return cell
    }
}

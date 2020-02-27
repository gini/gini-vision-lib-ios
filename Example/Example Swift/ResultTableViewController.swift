//
//  ResultTableViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 22/08/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import Gini
import GiniVision

/**
 Presents a dictionary of results from the analysis process in a table view.
 Values from the dictionary will be used as the cells titles and keys as the cells subtitles.
 */
final class ResultTableViewController: UITableViewController {
    
    /**
     The result from the analysis process.
     */
    var result: AnalysisResult? {
        
        didSet {
            let specificExtractions = result?.extractions.map({ $0.value }).sorted(by: { ($0.name ?? "") < ($1.name ?? "") }) ?? []
            let lineItems = result?.lineItems ?? []
            
            model = [("Specific Extractions", specificExtractions)]
            
            var index = 1
            
            for lineItem in lineItems {
                model += [("Line Item \(index)", lineItem.sorted(by: { ($0.name ?? "") < ($1.name ?? "") }))]
                index += 1
            }
            
            tableView.reloadData()
        }
    }
    
    private var model: [(String, [Extraction])] = []
}

extension ResultTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model[section].1.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let extraction = model[indexPath.section].1[indexPath.item]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)
        cell.textLabel?.text = extraction.value
        cell.detailTextLabel?.text = extraction.name
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return model[section].0
    }
}

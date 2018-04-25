//
//  EstimatedParametersTableViewController.swift
//  Loop
//
//
//  Copyright © 2018 LoopKit Authors. All rights reserved.
//

import Foundation

import UIKit
import LoopKit
import HealthKit


final class EstimatedParametersTableViewController: TextFieldTableViewController {
    
    var displayEstimatedParameter: [String] = []
    let hoursAgo: String
    
    private let valueNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        return formatter
    }()
    
    init(parameters: LoopDataManager.EstimatedParameters) {
        
        let isfMultiplier = valueNumberFormatter.string(
            from: NSNumber(value: parameters.insulinSensitivityMultipler))!
        let isfConfidence = valueNumberFormatter.string(
            from: NSNumber(value: parameters.insulinSensitivityConfidence))!
        let crMultiplier = valueNumberFormatter.string(
            from: NSNumber(value: parameters.carbRatioMultiplier))!
        let crConfidence = valueNumberFormatter.string(
            from: NSNumber(value: parameters.carbRatioConfidence))!
        let basalMultiplier = valueNumberFormatter.string(
            from: NSNumber(value: parameters.basalMultiplier))!
        let basalConfidence = valueNumberFormatter.string(
            from: NSNumber(value: parameters.basalConfidence))!
        let unexpectedPostiveDiscrepancy = valueNumberFormatter.string(
            from: NSNumber(value: parameters.unexpectedPositiveDiscrepancyPercentage))!
        let unexpectedNegativeDiscrepancy = valueNumberFormatter.string(
            from: NSNumber(value: parameters.unexpectedNegativeDiscrepancyPercentage))!
        displayEstimatedParameter.append(
            "ISF Multiplier = " + isfMultiplier + " (" + isfConfidence + "% confidence)")
        displayEstimatedParameter.append(
            "CR Multiplier = " + crMultiplier + " (" + crConfidence + "% confidence)")
        displayEstimatedParameter.append(
            "Basal Multiplier = " + basalMultiplier + " (" + basalConfidence + "% confidence)")
        displayEstimatedParameter.append(
            "Unexpected +BG Discrepancies: " + unexpectedPostiveDiscrepancy + "%")
        displayEstimatedParameter.append(
            "Unexpected -BG Discrepancies: " + unexpectedNegativeDiscrepancy + "%")
        hoursAgo = valueNumberFormatter.string(
            from: NSNumber(value: 0.04 * parameters.estimationBufferPercentage))!

        super.init(style: .grouped)

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayEstimatedParameter.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Approximately " + self.hoursAgo + " hours ago:"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
    
        cell.textLabel?.text = self.displayEstimatedParameter[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

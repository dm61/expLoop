//
//  GlucoseThresholdTableViewController.swift
//  Loop
//
//  Created by Pete Schwamb on 1/1/17.
//  Copyright © 2017 LoopKit Authors. All rights reserved.
//

import Foundation

import UIKit
import LoopKit
import HealthKit


final class EstimatedParametersTableViewController: TextFieldTableViewController {
    
    var showEstimatedParameters: [String] = ["0","1","2","3","4","5"]
    
    private let valueNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        return formatter
    }()
    
    init(parameters: LoopDataManager.EstimatedParameters) {
        
        let isfMultiplier = valueNumberFormatter.string(from: NSNumber(value: parameters.insulinSensitivityMultipler))!
        let isfConfidence = valueNumberFormatter.string(from: NSNumber(value: parameters.insulinSensitivityConfidence))!
        let crMultiplier = valueNumberFormatter.string(from: NSNumber(value: parameters.carbRatioMultiplier))!
        let crConfidence = valueNumberFormatter.string(from: NSNumber(value: parameters.carbRatioConfidence))!
        let basalMultiplier = valueNumberFormatter.string(from: NSNumber(value: parameters.basalMultiplier))!
        let basalConfidence = valueNumberFormatter.string(from: NSNumber(value: parameters.basalConfidence))!
        let estimationBuffer = valueNumberFormatter.string(from: NSNumber(value: parameters.estimationBufferPercentage))!
        let unexpectedPostiveDiscrepancy = valueNumberFormatter.string(from: NSNumber(value: parameters.unexpectedPositiveDiscrepancyPercentage))!
        let unexpectedNegativeDiscrepancy = valueNumberFormatter.string(from: NSNumber(value: parameters.unexpectedNegativeDiscrepancyPercentage))!
        showEstimatedParameters[0] = "ISF Multiplier = " + isfMultiplier + " (" + isfConfidence + "% confidence)"
        showEstimatedParameters[1] = "CR Multiplier = " + crMultiplier + " (" + crConfidence + "% confidence)"
        showEstimatedParameters[2] = "Basal Multiplier = " + basalMultiplier + " (" + basalConfidence + "% confidence)"
        showEstimatedParameters[3] = "Unexpected +BG Discrepancies: " + unexpectedPostiveDiscrepancy + "%"
        showEstimatedParameters[4] = "Unexpected -BG Discrepancies: " + unexpectedNegativeDiscrepancy + "%"
        showEstimatedParameters[5] = "Estimation data buffer is " + estimationBuffer + "% full"

        super.init(style: .grouped)

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
    
        cell.textLabel?.text = self.showEstimatedParameters[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

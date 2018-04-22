//
//  NSUserDefaults.swift
//  Naterade
//
//  Created by Nathan Racklyeft on 8/30/15.
//  Copyright © 2015 Nathan Racklyeft. All rights reserved.
//

import Foundation
import LoopKit
import InsulinKit
import MinimedKit
import HealthKit

extension UserDefaults {

    private enum Key: String {
        case basalRateSchedule = "com.loudnate.Naterade.BasalRateSchedule"
        case batteryChemistry = "com.loopkit.Loop.BatteryChemistry"
        case cgmSettings = "com.loopkit.Loop.cgmSettings"
        case carbRatioSchedule = "com.loudnate.Naterade.CarbRatioSchedule"
        case connectedPeripheralIDs = "com.loudnate.Naterade.ConnectedPeripheralIDs"
        case loopSettings = "com.loopkit.Loop.loopSettings"
        case insulinCounteractionEffects = "com.loopkit.Loop.insulinCounteractionEffects"
        case insulinModelSettings = "com.loopkit.Loop.insulinModelSettings"
        case insulinSensitivitySchedule = "com.loudnate.Naterade.InsulinSensitivitySchedule"
        case preferredInsulinDataSource = "com.loudnate.Loop.PreferredInsulinDataSource"
        case pumpID = "com.loudnate.Naterade.PumpID"
        case pumpModelNumber = "com.loudnate.Naterade.PumpModelNumber"
        case pumpRegion = "com.loopkit.Loop.PumpRegion"
        case pumpTimeZone = "com.loudnate.Naterade.PumpTimeZone"
        case retrospectiveInsulinEffects = "com.loopkit.Loop.retrospectiveInsulinEffects"
        case retrospectiveCarbEffects = "com.loopkit.Loop.retrospectiveCarbEffects"
        case retrospectiveBasalEffects = "com.loopkit.Loop.retrospectiveBasalEffects"
        case retrospectiveDiscrepancies = "com.loopkit.Loop.retrospectiveDiscrepancies"
    }

    var basalRateSchedule: BasalRateSchedule? {
        get {
            if let rawValue = dictionary(forKey: Key.basalRateSchedule.rawValue) {
                return BasalRateSchedule(rawValue: rawValue)
            } else {
                return nil
            }
        }
        set {
            set(newValue?.rawValue, forKey: Key.basalRateSchedule.rawValue)
        }
    }

    var carbRatioSchedule: CarbRatioSchedule? {
        get {
            if let rawValue = dictionary(forKey: Key.carbRatioSchedule.rawValue) {
                return CarbRatioSchedule(rawValue: rawValue)
            } else {
                return nil
            }
        }
        set {
            set(newValue?.rawValue, forKey: Key.carbRatioSchedule.rawValue)
        }
    }

    var cgm: CGM? {
        get {
            if let rawValue = dictionary(forKey: Key.cgmSettings.rawValue) {
                return CGM(rawValue: rawValue)
            } else {
                // Migrate the "version 0" case. Further format changes should be handled in the CGM initializer
                defer {
                    removeObject(forKey: "com.loopkit.Loop.G5TransmitterEnabled")
                    removeObject(forKey: "com.loudnate.Loop.G4ReceiverEnabled")
                    removeObject(forKey: "com.loopkit.Loop.FetchEnliteDataEnabled")
                    removeObject(forKey: "com.loudnate.Naterade.TransmitterID")
                }

                if bool(forKey: "com.loudnate.Loop.G4ReceiverEnabled") {
                    self.cgm = .g4
                    return .g4
                }

                if bool(forKey: "com.loopkit.Loop.FetchEnliteDataEnabled") {
                    self.cgm = .enlite
                    return .enlite
                }

                if let transmitterID = string(forKey: "com.loudnate.Naterade.TransmitterID"), transmitterID.count == 6 {
                    self.cgm = .g5(transmitterID: transmitterID)
                    return .g5(transmitterID: transmitterID)
                }

                return nil
            }
        }
        set {
            set(newValue?.rawValue, forKey: Key.cgmSettings.rawValue)
        }
    }

    var connectedPeripheralIDs: [String] {
        get {
            return array(forKey: Key.connectedPeripheralIDs.rawValue) as? [String] ?? []
        }
        set {
            set(newValue, forKey: Key.connectedPeripheralIDs.rawValue)
        }
    }

    var loopSettings: LoopSettings? {
        get {
            if let rawValue = dictionary(forKey: Key.loopSettings.rawValue) {
                return LoopSettings(rawValue: rawValue)
            } else {
                // Migrate the version 0 case
                defer {
                    removeObject(forKey: "com.loudnate.Naterade.DosingEnabled")
                    removeObject(forKey: "com.loudnate.Naterade.GlucoseTargetRangeSchedule")
                    removeObject(forKey: "com.loudnate.Naterade.MaximumBasalRatePerHour")
                    removeObject(forKey: "com.loudnate.Naterade.MaximumBolus")
                    removeObject(forKey: "com.loopkit.Loop.MinimumBGGuard")
                    removeObject(forKey: "com.loudnate.Loop.RetrospectiveCorrectionEnabled")
                }

                let glucoseTargetRangeSchedule: GlucoseRangeSchedule?
                if let rawValue = dictionary(forKey: "com.loudnate.Naterade.GlucoseTargetRangeSchedule") {
                    glucoseTargetRangeSchedule = GlucoseRangeSchedule(rawValue: rawValue)
                } else {
                    glucoseTargetRangeSchedule = nil
                }

                let suspendThreshold: GlucoseThreshold?
                if let rawValue = dictionary(forKey: "com.loopkit.Loop.MinimumBGGuard") {
                    suspendThreshold = GlucoseThreshold(rawValue: rawValue)
                } else {
                    suspendThreshold = nil
                }

                var maximumBasalRatePerHour: Double? = double(forKey: "com.loudnate.Naterade.MaximumBasalRatePerHour")
                if maximumBasalRatePerHour! <= 0 {
                    maximumBasalRatePerHour = nil
                }

                var maximumBolus: Double? = double(forKey: "com.loudnate.Naterade.MaximumBolus")
                if maximumBolus! <= 0 {
                    maximumBolus = nil
                }

                let settings = LoopSettings(
                    dosingEnabled: bool(forKey: "com.loudnate.Naterade.DosingEnabled"),
                    glucoseTargetRangeSchedule: glucoseTargetRangeSchedule,
                    maximumBasalRatePerHour: maximumBasalRatePerHour,
                    maximumBolus: maximumBolus,
                    suspendThreshold: suspendThreshold,
                    retrospectiveCorrectionEnabled: bool(forKey: "com.loudnate.Loop.RetrospectiveCorrectionEnabled")
                )
                self.loopSettings = settings

                return settings
            }
        }
        set {
            set(newValue?.rawValue, forKey: Key.loopSettings.rawValue)
        }
    }

    var insulinModelSettings: InsulinModelSettings? {
        get {
            if let rawValue = dictionary(forKey: Key.insulinModelSettings.rawValue) {
                return InsulinModelSettings(rawValue: rawValue)
            } else {
                // Migrate the version 0 case
                let insulinActionDurationKey = "com.loudnate.Naterade.InsulinActionDuration"
                defer {
                    removeObject(forKey: insulinActionDurationKey)
                }

                let value = double(forKey: insulinActionDurationKey)
                return value > 0 ? .walsh(WalshInsulinModel(actionDuration: value)) : nil
            }
        }
        set {
            set(newValue?.rawValue, forKey: Key.insulinModelSettings.rawValue)
        }
    }

    var insulinCounteractionEffects: [GlucoseEffectVelocity]? {
        get {
            guard let rawValue = array(forKey: Key.insulinCounteractionEffects.rawValue) as? [GlucoseEffectVelocity.RawValue] else {
                return nil
            }
            return rawValue.compactMap {
                GlucoseEffectVelocity(rawValue: $0)
            }
        }
        set {
            set(newValue?.map({ $0.rawValue }), forKey: Key.insulinCounteractionEffects.rawValue)
        }
    }

    var retrospectiveInsulinEffects: [GlucoseEffectVelocity]? {
        get {
            guard let rawValue = array(forKey: Key.retrospectiveInsulinEffects.rawValue) as? [GlucoseEffectVelocity.RawValue] else {
                return nil
            }
            return rawValue.compactMap {
                GlucoseEffectVelocity(rawValue: $0)
            }
        }
        set {
            set(newValue?.map({ $0.rawValue }), forKey: Key.retrospectiveInsulinEffects.rawValue)
        }
    }

    var retrospectiveCarbEffects: [GlucoseEffectVelocity]? {
        get {
            guard let rawValue = array(forKey: Key.retrospectiveCarbEffects.rawValue) as? [GlucoseEffectVelocity.RawValue] else {
                return nil
            }
            return rawValue.compactMap {
                GlucoseEffectVelocity(rawValue: $0)
            }
        }
        set {
            set(newValue?.map({ $0.rawValue }), forKey: Key.retrospectiveCarbEffects.rawValue)
        }
    }
    
    var retrospectiveBasalEffects: [GlucoseEffectVelocity]? {
        get {
            guard let rawValue = array(forKey: Key.retrospectiveBasalEffects.rawValue) as? [GlucoseEffectVelocity.RawValue] else {
                return nil
            }
            return rawValue.compactMap {
                GlucoseEffectVelocity(rawValue: $0)
            }
        }
        set {
            set(newValue?.map({ $0.rawValue }), forKey: Key.retrospectiveBasalEffects.rawValue)
        }
    }
    
    var retrospectiveDiscrepancies: [GlucoseEffectVelocity]? {
        get {
            guard let rawValue = array(forKey: Key.retrospectiveDiscrepancies.rawValue) as? [GlucoseEffectVelocity.RawValue] else {
                return nil
            }
            return rawValue.compactMap {
                GlucoseEffectVelocity(rawValue: $0)
            }
        }
        set {
            set(newValue?.map({ $0.rawValue }), forKey: Key.retrospectiveDiscrepancies.rawValue)
        }
    }
    
    var insulinSensitivitySchedule: InsulinSensitivitySchedule? {
        get {
            if let rawValue = dictionary(forKey: Key.insulinSensitivitySchedule.rawValue) {
                return InsulinSensitivitySchedule(rawValue: rawValue)
            } else {
                return nil
            }
        }
        set {
            set(newValue?.rawValue, forKey: Key.insulinSensitivitySchedule.rawValue)
        }
    }

    var preferredInsulinDataSource: InsulinDataSource? {
        get {
            return InsulinDataSource(rawValue: integer(forKey: Key.preferredInsulinDataSource.rawValue))
        }
        set {
            if let preferredInsulinDataSource = newValue {
                set(preferredInsulinDataSource.rawValue, forKey: Key.preferredInsulinDataSource.rawValue)
            } else {
                removeObject(forKey: Key.preferredInsulinDataSource.rawValue)
            }
        }
    }

    var pumpID: String? {
        get {
            return string(forKey: Key.pumpID.rawValue)
        }
        set {
            set(newValue, forKey: Key.pumpID.rawValue)
        }
    }

    var pumpModelNumber: String? {
        get {
            return string(forKey: Key.pumpModelNumber.rawValue)
        }
        set {
            set(newValue, forKey: Key.pumpModelNumber.rawValue)
        }
    }

    var pumpRegion: PumpRegion? {
        get {
            // Defaults to 0 / northAmerica
            return PumpRegion(rawValue: integer(forKey: Key.pumpRegion.rawValue))
        }
        set {
            set(newValue?.rawValue, forKey: Key.pumpRegion.rawValue)
        }
    }

    var pumpTimeZone: TimeZone? {
        get {
            if let offset = object(forKey: Key.pumpTimeZone.rawValue) as? NSNumber {
                return TimeZone(secondsFromGMT: offset.intValue)
            } else {
                return nil
            }
        } set {
            if let value = newValue {
                set(NSNumber(value: value.secondsFromGMT() as Int), forKey: Key.pumpTimeZone.rawValue)
            } else {
                removeObject(forKey: Key.pumpTimeZone.rawValue)
            }
        }
    }

    var batteryChemistry: BatteryChemistryType? {
        get {
            return BatteryChemistryType(rawValue: integer(forKey: Key.batteryChemistry.rawValue))
        }
        set {
            if let batteryChemistry = newValue {
                set(batteryChemistry.rawValue, forKey: Key.batteryChemistry.rawValue)
            } else {
                removeObject(forKey: Key.batteryChemistry.rawValue)
            }
        }
    }

}

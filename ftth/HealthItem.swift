//
//  HealthItem.swift
//  ftth
//
//  Created by Schappet, James C on 6/7/18.
//  Copyright © 2018 Schappet.com. All rights reserved.
//

import Foundation
import HealthKit

enum HealthItemType :String, Codable {
    case BloodPressureDiastolic
    case BloodPressureSystolic
    case Weight
    case HeartRate
    //case Mindfulness
    //case Activity
    case StepCount
    case NotImplemented
    func value() ->String {
        return self.rawValue
    }
    
    func idenifier() -> HKQuantityTypeIdentifier {
        switch self {
        case .BloodPressureDiastolic:
            return HKQuantityTypeIdentifier.bloodPressureDiastolic
        case .BloodPressureSystolic:
            return HKQuantityTypeIdentifier.bloodPressureSystolic
        case .HeartRate:
            return HKQuantityTypeIdentifier.heartRate
            //case .Mindfulness:
            //    return HKQuantityTypeIdentifier.bloodPressureDiastolic
        //case .Activity:
        case .StepCount:
            return HKQuantityTypeIdentifier.stepCount
        case .Weight:
            return HKQuantityTypeIdentifier.bodyMass
        case .NotImplemented:
            return HKQuantityTypeIdentifier.stepCount
        }
        
        
    }
    
}

struct HealthItem: Codable {
    var uuid: UUID
    var type: HealthItemType
    var startDate: Date
    var endDate: Date
    var deviceName: String
    var value: String
    
    init(quantitySample: HKQuantitySample) {
        self.uuid = quantitySample.uuid
        self.startDate = quantitySample.startDate
        self.endDate = quantitySample.endDate
        
        self.deviceName = quantitySample.sourceRevision.source.name
        var value1 : Any
        self.value=""
        switch quantitySample.quantityType {
            
        case HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate):
            self.type = .HeartRate
            value1 =  quantitySample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            self.value = "\(value1)"
            
        case HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureDiastolic):
            self.type = .BloodPressureDiastolic
            value1 = quantitySample.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
            self.value = "\(value1)"

            
        case HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureSystolic):
            self.type = .BloodPressureSystolic
            value1 = quantitySample.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
            self.value = "\(value1)"
            
        case HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass):
            self.type = .Weight
            let value1 = quantitySample.quantity.doubleValue(for: HKUnit.pound())
            self.value = "\(value1)"

        case HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount):
            self.type = .StepCount
            value1 =  quantitySample.quantity.doubleValue(for: HKUnit(from: "count/min"))

        default:
            self.type = .NotImplemented
            self.value =  ""
            
        }
        
        
        
    }

    init?(sample: HKSample) {
        if let data1 = sample as? HKQuantitySample {
            // TODO: Get HeartRate for the
            
            self = HealthItem(quantitySample:  data1)
            
        } else {
            return nil
        }
        
    }

    func json() -> Any? {
        
        var json: Any?
        let encodedData = try? JSONEncoder().encode(self)
        
        if let data = encodedData {
            json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let json = json {
                //print("JSON:\n" + String(describing: json) + "\n")
                return json
            }
        }
        return nil
    }
    
}

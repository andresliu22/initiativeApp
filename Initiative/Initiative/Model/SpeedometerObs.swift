//
//  SpeedometerObs.swift
//  Initiative
//
//  Created by Andres Liu on 11/18/20.
//

import Foundation

class SpeedometerObs: ObservableObject {
    @Published var meterValue: Float
    
    init(meterValue: Float) {
        self.meterValue = meterValue
    }
}

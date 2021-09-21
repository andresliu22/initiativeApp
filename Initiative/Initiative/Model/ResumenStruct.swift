//
//  ResumenStruct.swift
//  Initiative
//
//  Created by Andres Liu on 12/7/20.
//

import Foundation

struct SummaryDigital {
    var name: String
    var sale: String
    var order: Int
}

struct SummaryConsumeRanking {
    var name: String
    var quantity: Float
    var order: Int
}

struct SummaryCampaign {
    var name: String
    var date: String
}

struct SummaryInversion {
    var description: String
    var value: Float
}

struct SummaryProjected {
    var fullYear: Float
    var ytd: Float
}

struct SummaryOrion {
    var consumption: Float
    var mediaCredits: Float
}

struct SummaryBilling {
    var consumption: Float
    var totalPaid: Float
}

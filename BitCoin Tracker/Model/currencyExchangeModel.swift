//
//  currencyExchangeModel.swift
//  BitCoin Tracker
//
//  Created by Irving Hsu on 1/19/18.
//  Copyright © 2018 Irving Hsu. All rights reserved.
//

import UIKit

class currencyExchangeModel {
    var BitcoinToUSD = ""
    var BitcoinToGBP: Double = 0.0
    var BitcoinToEUR: Double = 0.0
    var currencyToGetExchanged = ["USD", "GBP", "EUR"]
    var currencyToGetExchangesDictionary = [String: String]()
    var currencyPast30DaysDatesArray = [String]()
    var currencyPast30DaysPriceArray = [Double]()
    var yesterdaysPrice = 0.0
}

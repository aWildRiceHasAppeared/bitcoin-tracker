//
//  CurrencyExchangeTableViewCell.swift
//  BitCoin Tracker
//
//  Created by Irving Hsu on 1/19/18.
//  Copyright © 2018 Irving Hsu. All rights reserved.
//

import UIKit

class CurrencyExchangeTableViewCell: UITableViewCell {

    @IBOutlet weak var yesterdayCurrencyValueLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var exchangeValueLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

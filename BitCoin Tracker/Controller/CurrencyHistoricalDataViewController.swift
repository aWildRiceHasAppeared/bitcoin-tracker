//
//  CurrencyHistoricalDataViewController.swift
//  BitCoin Tracker
//
//  Created by Irving Hsu on 1/19/18.
//  Copyright © 2018 Irving Hsu. All rights reserved.
//

import UIKit
import Charts
import Alamofire
import SwiftyJSON

class CurrencyHistoricalDataViewController: UIViewController {
    
    @IBOutlet weak var chtChart: LineChartView!
    @IBOutlet weak var historicalCurrencyLabel: UILabel!
    var historicalCurrency = ""
    var past30DaysDate = [String]()
    var past30DaysPrice = [Double]()
    var lineChartEnrty = [ChartDataEntry]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        historicalCurrencyLabel.text = "\(historicalCurrency) Past 30 days price"
//        print(past30DaysDate.last)
//        print(past30DaysPrice.last)
        
        plottingTheChart()
    }
    
    func plottingTheChart(){
        for i in 0..<self.past30DaysPrice.count {
            let value = ChartDataEntry(x: Double(i), y: self.past30DaysPrice[i])
            lineChartEnrty.append(value)
        }
        let line1 = LineChartDataSet(values: lineChartEnrty, label: "days")
        line1.colors = [NSUIColor.green]
        let data = LineChartData()
        data.addDataSet(line1)
        chtChart.data = data
        chtChart.borderColor = UIColor.clear
        chtChart.chartDescription?.textColor = UIColor.white
        chtChart.gridBackgroundColor = NSUIColor.clear
        chtChart.data?.setValueTextColor(NSUIColor.white)
        chtChart.xAxis.axisLineColor = UIColor.white
        chtChart.chartDescription?.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func coinDeskLinkbutton(_ sender: UIButton) {
        if let url = NSURL(string: "https://www.coindesk.com/price/"){
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

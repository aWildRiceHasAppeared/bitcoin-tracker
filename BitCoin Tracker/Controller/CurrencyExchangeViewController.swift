//
//  CurrencyExchangeViewController.swift
//  BitCoin Tracker
//
//  Created by Irving Hsu on 1/19/18.
//  Copyright © 2018 Irving Hsu. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import UserNotifications
import QuartzCore
import WatchConnectivity

class CurrencyExchangeViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, WCSessionDelegate {

    @IBOutlet weak var lastUpdatedTimeLabel: UILabel!
    @IBOutlet weak var searchCurrencyTextField: UITextField!
    @IBOutlet weak var currencyExchangeListTableView: UITableView!

    var wcSession: WCSession?
    let exchange = currencyExchangeModel()
    let defaults = UserDefaults.standard
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var past30DaysDateValueToPass = [String]()
    var past30DaysPriceValueToPass = [Double]()
    var yesterdayCurrencyPrice = [Double]()
    var valueToPass = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currencyExchangeListTableView.rowHeight = 50
        
        // Setup watch connectivity here
        if WCSession.isSupported(){
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
            print("Yay supported")
        } else {
            print("Something went wrong")
        }
    
        var message = ["message": "Hello World"]
        wcSession?.sendMessage(message, replyHandler: nil, errorHandler: { (error) in
            print(error.localizedDescription)
        })
        
        //Requesting permission & Sending Notifications to the User---------------------------------------------------------------------------------------------------------------------------------
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler:{ (didAllow, error) in
            if !didAllow {
                print("We need permission")
            }
        })
        notificationPopUp()
        
        // Saving User Default when app enters background

        var savedArray = defaults.object(forKey: "currencies")
        if  savedArray != nil {
            self.exchange.currencyToGetExchanged  = savedArray as! [String]
            self.initialRetrievingAndSavingData()
            print("There's something in the savedArray")
        } else {
            self.exchange.currencyToGetExchanged = ["USD","EUR","GBP"]
            self.initialRetrievingAndSavingData()
            print("There's somehow nothing here")
        }
        
        // UItableview make prettier
        currencyExchangeListTableView.layer.borderWidth = 1.0
        currencyExchangeListTableView.layer.borderColor = UIColor.white.cgColor
        currencyExchangeListTableView.layer.cornerRadius = 10
        
        // Call the functions to make API called every 60 seconds
        Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(CurrencyExchangeViewController.initialRetrievingAndSavingData), userInfo: nil, repeats: true)
        

        //UITableView stuff---------------------------------------------------------------------------------------------------------------------------------------------------
        currencyExchangeListTableView.tableFooterView = UIView()
        self.currencyExchangeListTableView.delegate = self
        self.currencyExchangeListTableView.dataSource = self
    }

    
//    func resetDefaults() {
//        let defaults = UserDefaults.standard
//        let dictionary = defaults.dictionaryRepresentation()
//        dictionary.keys.forEach { key in
//            defaults.removeObject(forKey: key)
//        }
//    }
    
    //WCSession methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    
    // Functions to get API calls and updates--------------------------------------------------------------------------------------------------------------------------
    func retrieveBitCoinData(currency: String){
        Alamofire.request("https://api.coindesk.com/v1/bpi/currentprice/\(currency).json").responseJSON { (responseData) in
            if responseData.result.value != nil {
                let responsedJSON = JSON(responseData.result.value!)
                self.updateExchangeData(json: responsedJSON)
            }
        }
    }
    
    func updateExchangeData(json: JSON){
        self.lastUpdatedTimeLabel.text = "Last Update: \(json["time"]["updated"])"
        for i in self.exchange.currencyToGetExchanged{
            let BitcoinToTemp = "\(json["bpi"][i]["rate"])"
            if BitcoinToTemp != "null"{
                self.exchange.currencyToGetExchangesDictionary[i] = BitcoinToTemp
            }
        }
        self.currencyExchangeListTableView.reloadData()
    }

    func getPastData(currency: String){
        Alamofire.request("https://api.coindesk.com/v1/bpi/historical/close.json?currency=\(currency)").responseJSON{ (responseData) in
            if responseData.result.value != nil {
                let responseJSON = JSON(responseData.result.value)["bpi"].dictionaryObject!
                let sortedArray = Array(responseJSON.keys).sorted()
                for i in sortedArray {
                    self.exchange.currencyPast30DaysPriceArray.append(responseJSON[i] as! Double)
                }
                self.exchange.currencyPast30DaysDatesArray = sortedArray
                self.performSegue(withIdentifier: "currencyHistorySegue", sender: self)
            }
            self.exchange.currencyPast30DaysPriceArray.removeAll()
        }
    }
    
    @objc func initialRetrievingAndSavingData(){
        for i in self.exchange.currencyToGetExchanged {
            retrieveBitCoinData(currency: i)
        }
    }
    
    func getYesrterdaysPrice(currency: String) {
        Alamofire.request("https://api.coindesk.com/v1/bpi/historical/close.json?for=yesterday&currency=\(currency)").responseJSON { (responseData) in
            if responseData.result.value != nil {
                let responseJSON = JSON(responseData.result.value)["bpi"].dictionaryObject!
                // Don't know why but it seems to work when making it into an array then print out the first item (well really only 1 item)
                self.yesterdayCurrencyPrice.append(Array(responseJSON.values)[0] as! Double)
            }
            //self.yesterdayCurrencyPrice.removeAll()
        }
    }

    // UIButtons actions ------------------------------------------------------------------------------------------------------------------------------------------------------------
    @IBAction func addCurrencyButton(_ sender: UIButton) {
        self.exchange.currencyToGetExchanged.append(self.searchCurrencyTextField.text!)
        self.retrieveBitCoinData(currency: self.searchCurrencyTextField.text!)
    }
    
    
    
    // Tableview Functions-----------------------------------------------------------------------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.exchange.currencyToGetExchangesDictionary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currencyExchangeCell", for: indexPath) as? CurrencyExchangeTableViewCell
        let sortedKeys = Array(self.exchange.currencyToGetExchangesDictionary.keys)
        let sortedValues = Array(self.exchange.currencyToGetExchangesDictionary.values)
        cell?.currencyLabel.text = sortedKeys[indexPath.row]
        cell?.exchangeValueLabel.text = sortedValues[indexPath.row]
        defaults.set(sortedKeys, forKey: "currencies")
        Alamofire.request("https://api.coindesk.com/v1/bpi/historical/close.json?for=yesterday&currency=\(sortedKeys[indexPath.row])").responseJSON { (responseData) in
            if responseData.result.value != nil {
                let responseJSON = JSON(responseData.result.value)["bpi"].dictionaryObject!
                // Don't know why but it seems to work when making it into an array then print out the first item (well really only 1 item)
                cell?.yesterdayCurrencyValueLabel.text = "\(Array(responseJSON.values)[0] as! Double)"
            }
        }
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow!
        let cell = tableView.cellForRow(at: indexPath) as? CurrencyExchangeTableViewCell
        valueToPass = Array(self.exchange.currencyToGetExchangesDictionary.keys)[indexPath.row]
        self.getPastData(currency: valueToPass)
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            self.exchange.currencyToGetExchangesDictionary.removeValue(forKey: Array(self.exchange.currencyToGetExchangesDictionary.keys)[indexPath.row])
            print(self.exchange.currencyToGetExchangesDictionary)
            currencyExchangeListTableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "currencyHistorySegue") {
            var viewController = segue.destination as? CurrencyHistoricalDataViewController
            viewController?.historicalCurrency = valueToPass
            viewController?.past30DaysPrice = self.exchange.currencyPast30DaysPriceArray
            viewController?.past30DaysDate = self.exchange.currencyPast30DaysDatesArray
        }
    }
    
     func notificationPopUp(){
        let content = UNMutableNotificationContent()
        content.title = "You might want to check the price for today"
        content.badge = 1
        
        // Send notification every three hour
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10800, repeats: false)
        let request = UNNotificationRequest(identifier: "update", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    
    // Function called to send data to watch--------------------------------------------------------------------------------------------------------------------------
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


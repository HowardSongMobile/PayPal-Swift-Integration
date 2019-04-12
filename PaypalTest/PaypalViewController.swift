//
//  PaypalViewController.swift
//  PaypalTest
//
//  Created by Song on 2019-04-08.
//  Copyright © 2019 Song. All rights reserved.
//

import Foundation
import UIKit
import BraintreeCore
import BraintreeDropIn
import BraintreeCard
import BraintreePayPal

//It is a demo for integrating Braintree SDK with iOS app
//for paypal checkout
//
class PaypalViewController: UIViewController, BTViewControllerPresentingDelegate {
    
    //use your key in Braintree dashboard
    let toKinizationKey = "your key"
    var braintreeClient: BTAPIClient?
    var transaction_id: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.paypalCheckout()
    }
    
    //MARK: - funcs
    func paypalCheckout() {
        //Initialize BTAPIClient
        braintreeClient = BTAPIClient(authorization: self.toKinizationKey)!
        let payPalDriver = BTPayPalDriver(apiClient: braintreeClient!)
        payPalDriver.viewControllerPresentingDelegate = self
        
        payPalDriver.authorizeAccount(completion: {(token, error) -> Void in
            if let nonce = token?.nonce {
                NSLog("got nonce")
                let amountToTest = "2"
                self.postNonceToServer(paymentMethodNonce: nonce, amount: amountToTest)
            }
        })
        return
    }
    
    func postNonceToServer(paymentMethodNonce: String, amount: String) {
        //For paypal, may not complete fully when server is on your local mac. May be to test logic only
        let url = "http://localhost:3000/paypal"
        let paymentURL = URL(string: url)!
        var request = URLRequest(url: paymentURL)
        request.httpMethod = "POST"
        
        let params = ["payment_method_nonce":"\(paymentMethodNonce)", "amount":amount] as [String : Any]
        let prettyPrinted:Bool = false
        let options = prettyPrinted ?
            JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: options)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //NEED ATP --> YES in info.plist to test http
        //Test Server - node.js in loacl mac and cloud
        URLSession.shared.dataTask(with: request) { [weak self](data, response, error) -> Void in
            // TODO: Handle success or failure
            guard let data = data else {
                NSLog("failure due to data format, check script in your node.js based server")
                return
            }
            
            do {
                let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                if let success = result?["success"] as? Bool {
                    if success {
                        print("nice")
                        self?.transaction_id = result?["transaction_id"] as? String
                        print("transaction_id = \(self?.transaction_id ?? "")")
                        //do something
                        return
                    }else{
                        print("failure, check script in your node.js based server")
                    }
                }
            }
            catch let error {
                NSLog("error -- \(error.localizedDescription)")
                return
            }
            
        }.resume()
    }
    
    //MARK: - delegate
    //if you want to support iOS 9 or less, need them
    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
    
    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    
}

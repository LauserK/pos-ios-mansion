//
//  tools.swift
//  Anfitrion Paseo
//
//  Created by Macbook on 26/10/17.
//  Copyright © 2017 Grupo Paseo. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ToolsPaseo {
    let webservice = SettingsBundleHelper.getAPIUrl()
    
    func loadingView(vc: UIViewController, msg: String){
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        vc.present(alert, animated: true, completion: nil)
    }
    
    
    // Method por make a http POST request to webservice and returning a JSON object
    func consultPOST(path: String, params: [String:String]?, completion:@escaping (JSON) -> Void){
        
        Alamofire.request("\(webservice)\(path)", method: .post, parameters:params).responseString {
            response in
            
            if let json = response.result.value {
                let data = JSON.init(parseJSON:json)
                completion(data)
            }
        }
        
    }
    
    // Method por make a http POST request to webservice and returning a JSON object
    func consultPOSTAlt(path: String, params: [String:String]?, completion:@escaping (JSON) -> Void){
        
        Alamofire.request("\(path)", method: .post, parameters:params).responseString {
            response in
            
            if let json = response.result.value {
                let data = JSON.init(parseJSON:json)
                completion(data)
            }
        }
    }
    
    // Method por make a http POST request to webservice and returning a JSON object
    func consultPOSTJSON(path: String, json: String, completion:@escaping (JSON) -> Void){
        
        Alamofire.request("\(path)", method: .post, parameters: [:], encoding: "\(json)", headers: [:]).responseString { response in
            
            if let json = response.result.value {
                let data = JSON.init(parseJSON:json)
                completion(data)
            }
            
            
        }
        
    }
    
    func moneyPretty(amount: Double) -> String{
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        return "\(fmt.string(for: amount)!)"
    }
    
    
}

extension String: ParameterEncoding {
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
}

// SUBSTRING IN ARRAY EXTENSION
public extension String {
    
    func substring(_ r: Range<Int>) -> String {
        let fromIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
        let toIndex = self.index(self.startIndex, offsetBy: r.upperBound)
        return self.substring(with: Range<String.Index>(uncheckedBounds: (lower: fromIndex, upper: toIndex)))
    }
    
}

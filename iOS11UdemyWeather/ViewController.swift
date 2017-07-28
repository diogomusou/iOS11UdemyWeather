//
//  ViewController.swift
//  iOS11UdemyWeather
//
//  Created by Diogo M Souza on 2017/07/28.
//  Copyright © 2017 Diogo M Souza. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    


    //Search and show result
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        resultLabel.text = ""
        var city = textField.text?.capitalized.trimmingCharacters(in: .whitespacesAndNewlines)
        if city?.replacingOccurrences(of: " ", with: "") != "" {
            city = city?.replacingOccurrences(of: " ", with: "-")
            showWeather(of: city ?? "")
        } else {
            resultLabel.text = "Please enter a city."
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
    
    private func showWeather(of city:String) {
        print(city)
        var message = ""
        if let url = URL(string: "http://www.weather-forecast.com/locations/\(city)/forecasts/latest") {
            print(url)
            let request = URLRequest(url: url)
            activityIndicator.startAnimating()
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("ERROR:")
                    print(error)
                }
                if let unwrappedData = data {
                    let dataString = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue)
                    print("DATA:")
                    print(dataString ?? "no data")
                    var stringSeparator = "Weather Forecast Summary:</b><span class=\"read-more-small\"><span class=\"read-more-content\"> <span class=\"phrase\">"
                    if let fullPageArray = dataString?.components(separatedBy: stringSeparator) {
                        if fullPageArray.count > 1 {
                            stringSeparator = "</span>"
                            let threeDaysWeatherArray = fullPageArray[1].components(separatedBy: stringSeparator)
                            if threeDaysWeatherArray.count > 1 {
                                let threeDaysWeather = threeDaysWeatherArray[0].replacingOccurrences(of: "&deg;", with: "º")
                                message = threeDaysWeather
                            }
                        } else {
                            //check for another HTML pattern
                            stringSeparator = "Weather Forecast Summary:</b> <span class=\"phrase\">"
                            if let newFullPageArray = dataString?.components(separatedBy: stringSeparator) {
                                if newFullPageArray.count > 1 {
                                    stringSeparator = "</span>"
                                    let threeDaysWeatherArray = newFullPageArray[1].components(separatedBy: stringSeparator)
                                    if threeDaysWeatherArray.count > 1 {
                                        let threeDaysWeather = threeDaysWeatherArray[0].replacingOccurrences(of: "&deg;", with: "º")
                                        message = threeDaysWeather
                                    }
                                } else {
                                    message = "Could not find the weather for this city"
                                }
                            }
                            
                        }
                    } else {
                        message = "Could not find the weather for this city"
                    }
                    DispatchQueue.main.async {
                        self.resultLabel.text = message
                        self.activityIndicator.stopAnimating()
                    }
                }
                
            }
            task.resume()
        } else {
            resultLabel.text = "Could not find the weather for this city"
        }
    }


}


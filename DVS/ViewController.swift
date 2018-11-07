/**
 * Copyright (c) 2018 Qualcomm Technologies, Inc.
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without modification, are permitted (subject to the limitations in the disclaimer below) provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the name of Qualcomm Technologies, Inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 * NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED BY THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit
import Material
import Alamofire
import SwiftyJSON
import ReCaptcha
import BarcodeScanner
import NYAlertViewController
import AVFoundation
import DTTextField

public extension String {
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
}

class ViewController: UIViewController{
    private struct Constants {
        static let webViewTag = 123
        static let testLabelTag = 321
    }
    
    private var recaptcha: ReCaptcha!
    
    
    var imei:String = ""
    fileprivate let constant: CGFloat = 32
    var labelValues = [
        "123456789012345",
        "Samsung",
        "J6",
        "Provisionally non-compliance",
        "stolen",
        "http://www.example.com",
        "N/A"
    ]
    
    @IBOutlet weak var submitButton: RaisedButton!
    var scanButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imeiTextField: DTTextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var endpoint = ReCaptcha.Endpoint.default
    
    //Declared at top of view controller
    var accessoryDoneButton: UIBarButtonItem!
    let accessoryToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
    
    override func viewDidLayoutSubviews() {
        scrollView.addSubview(contentView)//if the contentView is not already inside your scrollview in your xib/StoryBoard doc
        scrollView.contentSize = CGSize(
            width: self.contentView.frame.size.width,
            height: self.contentView.frame.size.height 
        ); //sets ScrollView content size
        
    }
    override func viewDidLoad() {
        
        
        //hiding activity indicator
        activityIndicator.isHidden = true
        
        //add Done button above keypad
        self.accessoryDoneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(self.donePressed))
        self.accessoryDoneButton.image = UIImage(named: "ic_cancel.png")
        self.accessoryToolBar.items = [self.accessoryDoneButton]
        self.imeiTextField.inputAccessoryView = self.accessoryToolBar
        
        
        scanButton = UIButton(type: .custom)
        scanButton.setImage(UIImage(named: "ic_barcode_scanner.png"), for: .normal)
        scanButton.imageEdgeInsets = UIEdgeInsetsMake(0, -16, 0, 0)
        scanButton.frame = CGRect(x: CGFloat(imeiTextField.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        scanButton.addTarget(self, action: #selector(self.scanButtonClick(_:)), for: .touchUpInside)
        imeiTextField.rightView = scanButton
        
        imeiTextField.rightViewMode = .always
        
        imeiTextField.placeholderColor = UIColor.lightGray
        imeiTextField.borderColor = UIColor.lightGray
        
        //setupReCaptcha()
    }
    
    @IBAction func didPressEndpointSegmentedControl(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0: endpoint = .default
        case 1: endpoint = .alternate
        default: assertionFailure("invalid index")
        }
        
        setupReCaptcha()
    }
    @IBAction func imeiTextFieldChanged(_ sender: DTTextField) {
        imei = sender.text!
        //to only allow 16 character a in imei
        if (imei.count > 16) {
            sender.deleteBackward()
        }
        
        //for live validation
        if (imei.count >= 14) && (imei.count <= 16) {
            if imei.range(of: "^(?=.[a-fA-F]*)(?=.[0-9]*)[a-fA-F0-9]+$", options: .regularExpression, range: nil, locale: nil) != nil {
                self.imeiTextField.hideError()
                
            }
            else{
                imeiTextField.errorMessage = getStringFromInfoPlist(key: "InvalidCharacterError")
                imeiTextField.showError()
                self.imeiTextField.becomeFirstResponder()
            }
        }
        else {
           
            imeiTextField.errorMessage = getStringFromInfoPlist(key: "LengthError")
            imeiTextField.showError()
            self.imeiTextField.becomeFirstResponder()
        }
    }
  
    
  
    
    @objc func donePressed() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func buttonClick(_ sender: Any) {
        
        imei = imeiTextField.text!
        
        
        if (imei.count >= 14) && (imei.count <= 16) {
            if imei.range(of: "^(?=.[a-fA-F]*)(?=.[0-9]*)[a-fA-F0-9]+$", options: .regularExpression, range: nil, locale: nil) != nil {
                
                //hide keypad
                self.view.endEditing(true)
                
                //hide error text from text field
                self.imeiTextField.hideError()
                
                setupReCaptcha()
                imeiAPICall(imei: self.imei,ishideLoader: true)
                
                
            }
            else{
                imeiTextField.errorMessage = getStringFromInfoPlist(key: "InvalidCharacterError")
                imeiTextField.showError()
                self.imeiTextField.becomeFirstResponder()
            }
        }
        else {
            
            imeiTextField.errorMessage = getStringFromInfoPlist(key: "LengthError")
            imeiTextField.showError()
            self.imeiTextField.becomeFirstResponder()
        }
        
        
    }
    func onScanComplete(data: String)
    {
        imeiTextField.text = data;
    }
    
    
    @IBAction func scanButtonClick(_ sender: Any) {
//        let scanViewController:ScannerViewController = ScannerViewController()
//        scanViewController.viewController = self
//        self.present(scanViewController, animated: true, completion: nil)
        let viewController = makeBarcodeScannerViewController()
        viewController.title = "Barcode Scanner"
        present(viewController, animated: true, completion: nil)
    }
    private func makeBarcodeScannerViewController() -> BarcodeScannerViewController {
        let viewController = BarcodeScannerViewController()
        viewController.codeDelegate = self
        viewController.errorDelegate = self
        viewController.dismissalDelegate = self
        viewController.cameraViewController.barCodeFocusViewType = .oneDimension
        viewController.metadata.remove(at: viewController.metadata.index(of: AVMetadataObject.ObjectType.qr)!)
        return viewController
    }
    
    
   
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResultSegue" {
            
            let rvc = segue.destination as! ResultViewController
            for i in 0..<self.labelValues.count {
                rvc.labelValues[i] = self.labelValues[i]
            }
        }
    }
    private func setupReCaptcha() {
        // swiftlint:disable:next force_try
        recaptcha = try! ReCaptcha(endpoint: endpoint)
        
        recaptcha.configureWebView { [weak self] webview in
            webview.frame = CGRect(center: (self?.view.bounds.center)!, size: CGSize(width: 302, height: 528))
            webview.tag = Constants.webViewTag
            webview.layer.zPosition = 1000
            
            self?.view.viewWithTag(Constants.testLabelTag)?.removeFromSuperview()
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            label.tag = Constants.testLabelTag
            label.accessibilityLabel = "webview"
            self?.view.addSubview(label)
        }
    }
    
    private func getStringFromInfoPlist(key: String) -> String {
        var resourceFileDictionary: NSDictionary?
        
        //Load content of Info.plist into resourceFileDictionary dictionary
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            resourceFileDictionary = NSDictionary(contentsOfFile: path)
        }
        
        if let resourceFileDictionaryContent = resourceFileDictionary {
            
            // Get something from our Info.plist like TykUrl
           
            return resourceFileDictionaryContent.object(forKey:key)! as! String
            
        }
        else{
            return ""
        }
    }
    
    public func imeiAPICall(imei:String, ishideLoader: Bool){
        //start loader and disable button
        
        if Reachability.isConnectedToNetwork(){
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            self.scanButton.isEnabled = false
            self.submitButton.isEnabled = false
        recaptcha.validate(on: view) { [weak self] (result: ReCaptchaResult) in
            do {
                let token = try? result.dematerialize()
                //self?.setupReCaptcha()
                self?.view.viewWithTag(Constants.webViewTag)?.removeFromSuperview()
                self?.view.viewWithTag(Constants.testLabelTag)?.removeFromSuperview()
                
                let tykUrl = self?.getStringFromInfoPlist(key: "ApiGatewayUrl")
                let apiUrl = tykUrl!+"api/v1/basicstatus?imei=\(imei)&token="+token!+"&source=ios"
                Alamofire.request(apiUrl).responseJSON { response in
                    //stop loader and enable button
                    if(ishideLoader){
                        self?.activityIndicator.stopAnimating()
                        self?.scanButton.isEnabled = true
                        self?.submitButton.isEnabled = true
                    }
                    switch response.result {
                    case .success(let value):
                        let statusCode = response.response?.statusCode
                        if statusCode == 200 {
                            let json = JSON(value)
                            print("JSON: \(json)")
                            //                        let rc = ResultViewController()
                            // imei from resuult
                            if let imeiNumber = json["imei"].string {
                                // imei found in the result
                                self?.labelValues[0] = imeiNumber
                            } else {
                                // imei not founc in the result
                                self?.labelValues[0] = "N/A"
                            }
                            
                            // brand from result
                            
                            if let brand = json["gsma"]["brand"].string {
                                // brand found in the result
                                self?.labelValues[1] = brand
                            } else {
                                // brand not founc in the result
                                self?.labelValues[1] = "N/A"
                            }
                            
                            // model_name from result
                            if let model = json["gsma"]["model_name"].string {
                                // model_name found in the result
                                self?.labelValues[2] = model
                            } else {
                                // model_name not founc in the result
                                self?.labelValues[2] = "N/A"
                            }
                            
                            // status from result
                            if let status = json["compliant"]["status"].string {
                                // model_name found in the result
                                self?.labelValues[3] = status
                            } else {
                                // model_name not founc in the result
                                self?.labelValues[3] = "N/A"
                            }
                            
                            
                            
                            //                        // inactivity_reasons from result
                            //                        if let inactivityReason = json["compliance"]["inactivity_reasons"][0].string {
                            //                            // inactivity_reasons found in the result
                            //                             self?.labelValues[4] = inactivityReason
                            //                        } else {
                            //                            // inactivity_reasons not founc in the result
                            //                            self?.labelValues[4] = "N/A"
                            //                        }
                            
                            if let items = json["compliant"]["inactivity_reasons"].array {
                                // inactivity_reasons found in the result
                                var reasons = ""
                                var i = 0
                                for item in items {
                                    
                                    if let title = item.string {
                                        if i > 0 {
                                            reasons = reasons + "\n " + title
                                        }
                                        else{
                                            reasons = reasons + " " + title
                                        }
                                    }
                                    
                                    i = i+1
                                }
                                self?.labelValues[4] = reasons
                            }
                            else{
                                // inactivity_reasons not founc in the result
                                self?.labelValues[4] = "N/A"
                            }
                            
                            // link_to_help from result
                            if let link = json["compliant"]["link_to_help"].string {
                                // link_to_help found in the result
                                self?.labelValues[5] = link
                            } else {
                                // link_to_help not founc in the result
                                self?.labelValues[5] = "N/A"
                            }
                            
                            // block_date from result
                            if let blockDate = json["compliant"]["block_date"].string {
                                // block_date found in the result
                                self?.labelValues[6] = blockDate
                            } else {
                                // block_date not founc in the result
                                self?.labelValues[6] = "N/A"
                            }
                            self?.performSegue(withIdentifier: "showResultSegue", sender: nil)
                        }
                        else
                        {
                            self?.showErrorAlert(title: "Oops!", message: "There was an error connecting to server. Please try again later.")
                        }
                    case .failure(let error):
                        print(error)
                        self?.showErrorAlert(title: "Oops!", message: "There was an error connecting to server. Please try again later.")
                        
                    }
                    
                    
                } // Alamofire request end
                
                
                
                
            } catch ReCaptchaError.htmlLoadError {
                if(ishideLoader){
                    self?.activityIndicator.stopAnimating()
                    self?.scanButton.isEnabled = true
                    self?.submitButton.isEnabled = true
                }
                print("html load error")
                self?.showErrorAlert(title: "Oops!", message: "There was an error connecting to server. Please try again later.")
            } catch ReCaptchaError.apiKeyNotFound {
                if(ishideLoader){
                    self?.activityIndicator.stopAnimating()
                    self?.scanButton.isEnabled = true
                    self?.submitButton.isEnabled = true
                }
                print("API key not found error")
                self?.showErrorAlert(title: "Oops!", message: "There was an error connecting to server. Please try again later.")
            } catch ReCaptchaError.baseURLNotFound {
                if(ishideLoader){
                    self?.activityIndicator.stopAnimating()
                    self?.scanButton.isEnabled = true
                    self?.submitButton.isEnabled = true
                }
                print("base URL not found error")
                self?.showErrorAlert(title: "Oops!", message: "There was an error connecting to server. Please try again later.")
            } catch ReCaptchaError.wrongMessageFormat {
                if(ishideLoader){
                    self?.activityIndicator.stopAnimating()
                    self?.scanButton.isEnabled = true
                    self?.submitButton.isEnabled = true
                }
                print("wrong message error")
                self?.showErrorAlert(title: "Oops!", message: "There was an error connecting to server. Please try again later.")
            }
        }// recaptcha validate end
        }
        else{
            self.showErrorAlert(title: "Oops!", message: "No internet connection.")
        }
    }
    func showErrorAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
}




// MARK: - BarcodeScannerCodeDelegate
extension ViewController: BarcodeScannerCodeDelegate {
    
    
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
            print("Barcode Data: \(code)")
            self.imeiTextField.text = code
            self.dismiss(animated: true, completion: nil)
           // confirmImei(imei: code, controller: controller)
        
	    }
    func confirmImei( imei:String, controller:BarcodeScannerViewController){
        //1. Create the alert controller.
        let alertViewController = NYAlertViewController()
        
        // Set a title and message
        alertViewController.title = "Confirm IMEI"
        alertViewController.message = "Please confirm the scanned IMEI and tap OK to see device status"
        alertViewController.addTextField { (imeiTextField) in
            imeiTextField?.text = imei
            
        }
        // Add alert actions
        let cancelAction = NYAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: { (action: NYAlertAction!) -> Void in
                controller.reset()
                controller.dismiss(animated: true, completion: nil)
                
        }
        )
        alertViewController.addAction(cancelAction)
        
        let okAction = NYAlertAction(
            title: "Ok",
            style: .default,
            handler: { (action: NYAlertAction!) -> Void in
                let textField = alertViewController.textFields![0] // Force unwrapping because we know it exists.
                let imei = (textField as! UITextField).text
                if ((imei?.count)! >= 14) && ((imei?.count)! <= 16) {
                    if imei?.range(of: "^(?=.[a-fA-F]*)(?=.[0-9]*)[a-fA-F0-9]+$", options: .regularExpression, range: nil, locale: nil) != nil {
                        //TODO add call to API
                        alertViewController.message = "Please confirm the scanned IMEI and tap OK to see device status"
                        alertViewController.messageColor = UIColor.black
                        self.dismiss(animated: true, completion: nil)
                        self.imeiAPICall(imei: imei!, ishideLoader: true)
                        
                        
                    }
                    else{
                        alertViewController.message = "IMEI must be a hexa-decimal number"
                        alertViewController.messageColor = UIColor.red
                        
                        
                    }
                }
                else {
                    //            prepareSnackbar()
                    //            animateSnackbar()
                    //            scheduleAnimation()
                    alertViewController.message = "IMEI must be 14 to 16 characters long"
                    alertViewController.messageColor = UIColor.red
                    
                }
                
        }
        )
        alertViewController.addAction(okAction)
        
        //add observer for text field changed
        
        controller.present(alertViewController, animated: true, completion: nil)
        
        //2. Add the text field. You can configure it however you need.
//        alert.addTextField { (textField:UITextField) in
//            textField.text = imei
//
//
//        }
//
//
//
//        // 3. Grab the value from the text field, and print it when the user clicks OK.
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
//
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak alert] (_) in
//            controller.reset()
//        }))
//
//        // 4. Present the alert.
//        controller.present(alert, animated: true, completion: nil)
    }
   
    
}

// MARK: - BarcodeScannerErrorDelegate
extension ViewController: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
        controller.isOneTimeSearch = true
        controller.reset(animated: true)
    }
}

// MARK: - BarcodeScannerDismissalDelegate
extension ViewController: BarcodeScannerDismissalDelegate {
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}












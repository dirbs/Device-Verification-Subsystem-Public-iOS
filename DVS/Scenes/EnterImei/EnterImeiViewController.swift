/**
 *  Copyright (c) 2018-2019 Qualcomm Technologies, Inc.
 * All rights reserved.
 *  Redistribution and use in source and binary forms, with or without modification, are permitted (subject to the limitations in the disclaimer below) provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the name of Qualcomm Technologies, Inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 * The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment is required by displaying the trademark/log as per the details provided here: [https://www.qualcomm.com/documents/dirbs-logo-and-brand-guidelines]
 * Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * This notice may not be removed or altered from any source distribution.
 NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED BY THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit
import ReCaptcha
import Material
import DTTextField
import BarcodeScanner
import AVFoundation
import Localize_Swift

protocol EnterImeiDisplayLogic: class
{
    func displaySucess(viewModel: EnterImei.ViewModel)
    func displayError()
}
protocol EnterImeiDataSource: class
{
    func getImeiStatus()
}


class EnterImeiViewController: UIViewController, EnterImeiDisplayLogic, EnterImeiDataSource,UITextFieldDelegate
{
    
    
    
    @IBOutlet var footerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var submitButton: RaisedButton!
  var scanButton: UIButton!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var imeiTextField: DTTextField!
    //  let imeiTextFieldController: MDCTextInputControllerOutlined
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  var interactor: EnterImeiBusinessLogic?
  var router: (NSObjectProtocol & EnterImeiRoutingLogic & EnterImeiDataPassing)?
  var isHideLoader: Bool!
    
//    Recaptcha Vars
  private var recaptcha: ReCaptcha!
  public var endpoint = ReCaptcha.Endpoint.default
  @IBOutlet var barcodeViewController: BarcodeScannerViewController!
    
    var accessoryDoneButton: UIBarButtonItem!
    //let accessoryToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
    

  // MARK: Object lifecycle
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
  {
//    imeiTextFieldController = MDCTextInputControllerOutlined(textInput: imeiTextField)
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder)
  {
//    imeiTextFieldController = MDCTextInputControllerOutlined(textInput: imeiTextField)
    super.init(coder: aDecoder)
    setup()
  }
  
  // MARK: Setup
  
  private func setup()
  {
    let viewController = self
    let interactor = EnterImeiInteractor()
    let presenter = EnterImeiPresenter()
    let router = EnterImeiRouter()
    viewController.interactor = interactor
    viewController.router = router
    interactor.presenter = presenter
    presenter.viewController = viewController
    router.viewController = viewController
    router.dataStore = interactor
  }
  
  // MARK: Routing
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    if let scene = segue.identifier {
      let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
      if let router = router, router.responds(to: selector) {
        router.perform(selector, with: segue)
      }
    }
  }
  
  // MARK: View lifecycle
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    Localize.setCurrentLanguage("en")
    
    
    
     
    setupViews()
   
    
  }
  
  // MARK: Get Imei Status from Backend API
    func getImeiStatus() {
        if Reachability.isConnectedToNetwork(){
            hideShowLoading(show: true)
            setupReCaptcha()
            recaptcha.validate(on: view, resetOnError: false) { [weak self] (result: ReCaptchaResult) in
                do {
                    let token = try result.dematerialize()
                    //self?.setupReCaptcha()
                    self?.view.viewWithTag(EnterImei.Constants.webViewTag)?.removeFromSuperview()
                    self?.view.viewWithTag(EnterImei.Constants.testLabelTag)?.removeFromSuperview()
                    let request = EnterImei.Request(imei: (self?.imeiTextField.text)!, token: token)
                    self?.interactor?.getImeiStatus(request: request)
                }
                catch _ {
                    self?.hideShowLoading(show: false)
                    let title = "Oops!".localized()
                    let recaptchaFailed = "Recaptcha failed".localized()
                    Helper.showErrorAlert(title: title, message: recaptchaFailed, vc: self!)
                }
            } // recaptcha validate end
        }
        else
        {
            let title = "Oops!".localized()
            let noConnection = "No internet connection".localized()
            Helper.showErrorAlert(title: title, message: noConnection, vc: self)
        }
    }
  
    // MARK: route to DisplayImeiStatusViewController with Data called on OK response from API
    func displaySucess(viewModel: EnterImei.ViewModel) {
        hideShowLoading(show: false)
        print(viewModel.imeiStatus)
        (router as! EnterImeiRouter).routeToDisplayImeiStatusViewController(segue: nil)
        
    }
    
    // MARK: show error text in alert dialog if API Call is unsuccessful
    func displayError() {
        hideShowLoading(show: false)
        let title = "Oops!".localized()
        let serverError = "Problem connecting to server. Please try again later".localized()
        
        Helper.showErrorAlert(title: title, message: serverError, vc: self)
    }
    
   
    
    // MARK: setup Recaptcha
    func setupReCaptcha() {
        // swiftlint:disable:next force_try
        recaptcha = try! ReCaptcha(endpoint: endpoint)
        
        recaptcha.configureWebView { [weak self] webview in
            webview.frame = CGRect(center: (self?.view.bounds.center)!, size: CGSize(width: 302, height: 528))
            webview.tag = EnterImei.Constants.webViewTag
            webview.layer.zPosition = 1000
            
            self?.view.viewWithTag(EnterImei.Constants.testLabelTag)?.removeFromSuperview()
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            label.tag = EnterImei.Constants.testLabelTag
            label.accessibilityLabel = "recaptcha-webview"
            self?.view.addSubview(label)
        }
    }
    
    // MARK: setup views
    func setupViews(){
        
        
        imeiTextField.delegate = self
        
        submitButton.title = "Submit".localized()
        footerLabel.text = "Dial *#06# to check the IMEI of device".localized()
        imeiTextField.placeholder = "Enter IMEI".localized()

        self.accessoryDoneButton = UIBarButtonItem(title: "Done".localized(), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.donePressed))
       
        let numberToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        numberToolbar.barStyle = UIBarStyle.default
        numberToolbar.items = [
            
            UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil),
            accessoryDoneButton]
        
        numberToolbar.sizeToFit()
        imeiTextField.inputAccessoryView = numberToolbar
        

        
        
        
        
        
        scanButton = UIButton(type: .custom)
        scanButton.setImage(UIImage(named: "ic_barcode_scanner.png"), for: .normal)
        if UIView.userInterfaceLayoutDirection(
            for: self.view.semanticContentAttribute) == .rightToLeft
        {
            print("is RTL true")
            scanButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -16)
        }
        else
        {
            scanButton.imageEdgeInsets = UIEdgeInsetsMake(0, -16, 0, 0)
        }
        
        scanButton.frame = CGRect(x: CGFloat(imeiTextField.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        scanButton.addTarget(self, action: #selector(self.scanButtonClick(_:)), for: .touchUpInside)
        
        imeiTextField.rightView = scanButton
        imeiTextField.rightViewMode = .always
        imeiTextField.borderColor = UIColor.darkGray
        imeiTextField.placeholderColor = UIColor.darkGray

        
        imeiTextField.translatesAutoresizingMaskIntoConstraints = false
        imeiTextField.clearButtonMode = .unlessEditing
        imeiTextField.becomeFirstResponder()
        
        titleLabel.text = "Check IMEI Status".localized()
//        let str = "Ù¾ Ú©ÛÙÙØ¨Ø§Ø¦Ù ÚÛÙØ§Ø¦Ø³ Ú©Ø§ (imei) PTA Ø³Û ØªØµØ¯ÙÙ Ø´Ø¯Û ÙÛÛÚº ÛÛ ÛÛ Ø§Ú¯Ø± Ø¢Ù¾ Ú©Ø§ ÙÙØ¨Ø§Ø¦Ù ÚÛÙØ§Ø¦Ø³ Ú©Ø³Û Ø¨Ú¾Û ÙÛÙ¹ ÙØ±Ú© Ù¾Ø± ÙÙØ³ÙÚ© ÛÙØ§ ØªÙ 60 Ø¯Ù Ú©Û Ø§ÙØ¯Ø±Ø¢Ù¾Ú©Ø§ ÙÙØ¨Ø§Ø¦Ù ÚÛÙØ§Ø¦Ø³ Ø¨ÙØ§Ú© Ú©Ø± Ø¯ÛØ§ Ø¬Ø§ÛÚ¯Ø§Û"
//        let receivedEncoding = APITextEncoding(rawValue: "iso-8859-1")
//
////        var s = str.urlPercentEncoded(withAllowedCharacters: .urlQueryAllowed,
////                                       encoding: .isoLatin1)
//////        s.unicodeScalars.append(contentsOf: buf.compactMap { UnicodeScalar($0) } )
//
////        print(String(bytes: Data(buf), encoding: .utf8))
//        let receivedText = String(data: str.data(using: .isoLatin1)!, encoding: .macOSRoman)
//        print(receivedText)
//        titleLabel.text = receivedText
        
        
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        
        
        
        return count <= 16
    }
    // MARK: respond to cancel btn of soft keyboard and close it
    @objc func donePressed() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        
        view.endEditing(true)
        submitButton.sendActions(for: .touchUpInside)
    }
    
    // MARK: open scanner when scan button clicked
    @IBAction func scanButtonClick(_ sender: Any) {
        let viewController = makeBarcodeScannerViewController()
        viewController.headerViewController.titleLabel.text = "Scan Barcode".localized()
          viewController.headerViewController.titleLabel.font = UIFont.systemFont(ofSize: 24.0, weight: .regular)
        viewController.headerViewController.closeButton.setTitle("", for: .normal)
        let image = UIImage(named: "ic_cancel.png");
        let sizeChange = CGSize.init(width: 25, height: 25)
        UIGraphicsBeginImageContextWithOptions(sizeChange, false, 0.0)
        image!.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        viewController.headerViewController.closeButton.setBackgroundImage(scaledImage, for: .normal)
        viewController.messageViewController.messages.scanningText = "Place the barcode within the window to scan the barcode of IMEI".localized()
        present(viewController, animated: true, completion: nil)
    }
    

    // MARK: setup barcode scanner
    private func makeBarcodeScannerViewController() -> BarcodeScannerViewController {
        barcodeViewController = BarcodeScannerViewController()
        barcodeViewController.codeDelegate = self
        barcodeViewController.errorDelegate = self
        barcodeViewController.dismissalDelegate = self
        barcodeViewController.cameraViewController.barCodeFocusViewType = .oneDimension
        barcodeViewController.metadata.remove(at: barcodeViewController.metadata.index(of: AVMetadataObject.ObjectType.qr)!)
        return barcodeViewController
    }
    
    // MARK: validate recaptcha and call API when submit btn clicked
    @IBAction func submitButtonClick(_ sender: Any) {
        if validateImei() {
            getImeiStatus()
        }
    }
    
    // MARK: validate imei on text change in imei field
    @IBAction func imeiTextChanged(_ sender: DTTextField) {
        let imei = sender.text!
        
        //to only allow 16 character a in imei
//        if (imei.count > 16) {
//            sender.deleteBackward()
//        }
        
        validateImei()
        
    }
    
    
    
    
    
    
    
    
    
    // MARK: validate text as valid alpha numeric character
    func validateImei() -> Bool{

        
        
        var imei = imeiTextField.text!

        imei = imeiTextField.text!
       
        if(imei.count == 0)
        {
            imeiTextField.errorMessage = "IMEI must be 14 to 16 characters long".localized()
            imeiTextField.showError()
            return false
            
    
        }
            
            
         
            
        else{
            
            
            
            
            if imei.range(of: "^(?=.[a-fA-F]*)(?=.[0-9]*)[a-fA-F0-9]+$", options: .regularExpression, range: nil, locale: nil) != nil {
                
                
                if(imei.count < 14) && (imei.count < 16)
                {
                    imeiTextField.errorMessage = "IMEI must be 14 to 16 characters long".localized()
                    imeiTextField.showError()
                    return false
                    
                }
                
                    
                    
                else{
                    
        
                    self.imeiTextField.hideError()
                    return true
                   
                    
                }
                
                
            }
                
                
                
            else{
                imeiTextField.errorMessage = "IMEI must contain A-F, a-f and 0-9 only".localized()
                imeiTextField.showError()
                self.imeiTextField.becomeFirstResponder()
                return false
                
            }
            
            
        }
        
        
        
        
    }
    
    
    
    // MARK: hide or show loading indicator based on boolean parameter
    func hideShowLoading(show: Bool){
        if show {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            self.scanButton.isEnabled = false
            self.submitButton.isEnabled = false
        }
        else{
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            self.scanButton.isEnabled = true
            self.submitButton.isEnabled = true
        }
    }
        
    
}

// MARK: - BarcodeScannerCodeDelegate
extension EnterImeiViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        print("Barcode Data: \(code)")
        self.imeiTextField.text = code
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - BarcodeScannerErrorDelegate
extension EnterImeiViewController: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
        controller.isOneTimeSearch = true
        controller.reset(animated: true)
    }
}

// MARK: - BarcodeScannerDismissalDelegate
extension EnterImeiViewController: BarcodeScannerDismissalDelegate {
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
extension DTTextField {
    open override func awakeFromNib() {
        super.awakeFromNib()
        if UIView.userInterfaceLayoutDirection(
            for: self.semanticContentAttribute) == .rightToLeft
        {
            print("rtl cursor")
            if textAlignment == .natural {
                self.textAlignment = .right
            }
        }
    }
}



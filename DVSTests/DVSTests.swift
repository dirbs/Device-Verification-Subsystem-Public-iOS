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

import XCTest
@testable import DVS
import BarcodeScanner
import UIKit
import ReCaptcha

class DVSTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    func testImeiPlaceholder() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let main = storyboard.instantiateInitialViewController() as! EnterImeiViewController
        let _ = main.view
        XCTAssertEqual("Enter IMEI", main.imeiTextField!.attributedPlaceholder?.string)
    }
//    func testImeiLength() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let main = storyboard.instantiateInitialViewController() as! EnterImeiViewController
//        let _ = main.view
//        main.imeiTextField.insertText("123456")
//        XCTAssertEqual("IMEI must be 14 to 16 characters long", main.imeiTextField!.errorMessage)
//    }
//    func testImeiAlpha() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let main = storyboard.instantiateInitialViewController() as! EnterImeiViewController
//        let _ = main.view
//        main.imeiTextField.insertText("123456asdfghjk")
//        XCTAssertEqual("IMEI must contain A-F, a-f and 0-9 only", main.imeiTextField!.errorMessage)
//    }
    func testButtonClick() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let main = storyboard.instantiateInitialViewController() as! EnterImeiViewController
        let _ = main.view
        main.submitButton.sendActions(for: .touchUpInside)
    }
    func testGetString(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let main = storyboard.instantiateInitialViewController() as! EnterImeiViewController
        let _ = main.view
        let lengthErrorStr = main.getStringFromInfoPlist(key: "LengthError")
        XCTAssertEqual(lengthErrorStr, "IMEI must be 14 to 16 characters long")

    }
//    func testSetupRecaptcha(){
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let main = storyboard.instantiateInitialViewController() as! ViewController
//        let _ = main.view
//        main.endpoint = ReCaptcha.Endpoint.default
//        main.setupReCaptcha()
//        main.view.viewWithTag(123)
//
//    }
//    func testParseJson(){
//        var value = "{\"imei\":\"123456789012345\",\"gsma\":{\"brand\":\"Test Brand\",\"model_name\":\"Test Model\"},\"compliant\":{\"status\":\"Test Status\",\"link_to_help\":\"test com\",\"block_date\":\"Test Date\",\"inactivity_reasons\":[\"Test Reason 1\",\"Test Reason 2\"]}}"
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let main = storyboard.instantiateInitialViewController() as! EnterImeiViewController
//        let _ = main.view
//        main.parseJson(value: value)
//    }
//    func testResultDone(){
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let resultViewController = storyboard.instantiateViewController(withIdentifier: "DisplayImeiStatusViewController") as! DisplayImeiStatusViewController
//        _ = resultViewController.view
//        resultViewController.cancelBtn.sendActions(for: .touchUpInside);
//    }
//    func testResultLink(){
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let resultViewController = storyboard.instantiateViewController(withIdentifier: "DisplayImeiStatusViewController") as! DisplayImeiStatusViewController
//        _ = resultViewController.view
//       
//        let tap = UITapGestureRecognizer(target: resultViewController, action: #selector(resultViewController.openUrl(_:)))
////        tap.delegate = resultViewController // This is not required
//    }
//    func testResultData(){
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let resultViewController = storyboard.instantiateViewController(withIdentifier: "DisplayImeiStatusViewController") as! DisplayImeiStatusViewController
//        _ = resultViewController.view
//        resultViewController.spreadsheetView.reloadData()
//    }
//    func testScanButtonClick() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let main = storyboard.instantiateInitialViewController() as! ViewController
//        let _ = main.view
//        main.scanButton.sendActions(for: .touchUpInside)
//
//
//    }
//    func testCells(){
//    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//    let resultViewController = storyboard.instantiateViewController(withIdentifier: "DisplayImeiStatusViewController") as! DisplayImeiStatusViewController
//    _ = resultViewController.view
//    
//        var titleCell = TitleCell()
//        var valueCell = ValueCell()
//        var blankCell = BlankCell()
//    resultViewController.spreadsheetView.register(TitleCell.self, forCellWithReuseIdentifier: String(describing: TitleCell.self))
//    resultViewController.spreadsheetView.register(ValueCell.self, forCellWithReuseIdentifier: String(describing: ValueCell.self))
//        resultViewController.spreadsheetView.register(BlankCell.self, forCellWithReuseIdentifier: String(describing: BlankCell.self))
//    }
    func testReachability(){
        var isNetConnected = Reachability.isConnectedToNetwork();
        XCTAssertEqual(isNetConnected, Reachability.isConnectedToNetwork())
    }
    
    
}

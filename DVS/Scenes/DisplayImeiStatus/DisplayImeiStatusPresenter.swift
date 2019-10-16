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
import SwiftyJSON
import Localize_Swift

protocol DisplayImeiStatusPresentationLogic
{
    func presentImeiStatus(response: DisplayImeiStatus.Response)
}

class DisplayImeiStatusPresenter: DisplayImeiStatusPresentationLogic
{
    weak var viewController: DisplayImeiStatusDisplayLogic?
    
    // MARK: Do something
    
    func presentImeiStatus(response: DisplayImeiStatus.Response)
    {
        let tableViewData = parseJson(value: response.imeiStatusResult)
        let viewModel = DisplayImeiStatus.ViewModel(tableViewData: tableViewData)
        viewController?.displayResult(viewModel: viewModel)
    }
    func parseJson(value: Any) -> [DisplayImeiStatus.CellData]{
        let json = JSON(value)
        print("JSON: \(json)")
        var tableViewData = [DisplayImeiStatus.CellData]()
        
        // imei from result
        
        
        tableViewData.append(DisplayImeiStatus.CellData(title: "IMEI".localized(), value: getElement(json: json, elementTag: "imei")))
        
        // brand from result
        tableViewData.append(DisplayImeiStatus.CellData(title:"Brand".localized(), value: getSubElement(json: json, objectTag: "gsma", elementTag: "brand")))
        
        // model_name from result
        tableViewData.append(DisplayImeiStatus.CellData(title: "Model Name".localized(), value: getSubElement(json: json, objectTag: "gsma", elementTag: "model_name")))
        
        // status from result
        tableViewData.append(DisplayImeiStatus.CellData(title: "IMEI Compliance Status".localized(), value: getSubElement(json: json, objectTag: "compliant", elementTag: "status")))
        
        // inactivity_reasons from result
        
       
        
        
      
        tableViewData.append(DisplayImeiStatus.CellData(title: "Reason for Non-Compliance".localized(), value: getArrayAsString(json: json, objectTag: "compliant", elementTag: "inactivity_reasons")))
        
        // link_to_help from result
        
       
        
        tableViewData.append(DisplayImeiStatus.CellData(title: "Link to Mitigation Help Content".localized(), value: getSubElement(json: json, objectTag: "compliant", elementTag: "link_to_help")))
        
        // block_date from result
        tableViewData.append(DisplayImeiStatus.CellData(title:"Block as of Date".localized(), value: getSubElement(json: json, objectTag: "compliant", elementTag: "block_date")))
        
        return tableViewData
    }
    func getElement(json: JSON, elementTag: String) -> String {
        if let element = json[elementTag].string {
            // element found in the result
            return element
        } else {
            // element not founc in the result
            return "N/A".localized()
        }
    }
    func getSubElement(json: JSON, objectTag: String, elementTag: String) -> String {
        if let element = json[objectTag][elementTag].string {
            // element found in the result
            return element
        } else {
            // element not founc in the result
            return "N/A".localized()
        }
    }
    func getArrayAsString(json: JSON, objectTag: String, elementTag: String) -> String {
        if let items = json[objectTag][elementTag].array {
            // array found in the result
            var strArr = ""
            var i = 0
            //loop array and append each element to a string
            for item in items {
                
                if let title = item.string {
                    if i > 0 {
                        strArr = strArr + "\n " + title
                    }
                    else{
                        strArr = strArr + " " + title
                    }
                }
                
                i = i+1
            }
            return strArr
        }
        else{
            // array not founc in the result
            return"N/A".localized()
        }
    }
}

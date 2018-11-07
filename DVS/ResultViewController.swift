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
import SpreadsheetView

class ResultViewController: UIViewController, SpreadsheetViewDataSource {
    @IBOutlet weak var spreadsheetView: SpreadsheetView!
    var resultStatus = [String: [String]]()
    var link = ""
    let labels = [
        "IMEI",
        "Brand",
        "Model Name",
        "IMEI Compliance Status",
        "Reason for Non-Compliance",
        "Link to Mitigation Help Content",
        "Block as of Date"
    ]
    var labelValues = [
        "123456789012345",
        "Samsung",
        "J6",
        "Provisionally non-compliance",
        "N/A",
        "http://www.example.com",
        "N/A"
    ]
    
    var slotInfo = [IndexPath: (Int, Int)]()
    
    let hourFormatter = DateFormatter()
    let twelveHourFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let vc = ViewController()
        
        
      
        spreadsheetView.dataSource = self
//        spreadsheetView.delegate = self s! SpreadsheetViewDelegate
        
        spreadsheetView.register(TitleCell.self, forCellWithReuseIdentifier: String(describing: TitleCell.self))
        spreadsheetView.register(ValueCell.self, forCellWithReuseIdentifier: String(describing: ValueCell.self))
        spreadsheetView.register(UINib(nibName: String(describing: SlotCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: SlotCell.self))
        spreadsheetView.register(BlankCell.self, forCellWithReuseIdentifier: String(describing: BlankCell.self))
        
        spreadsheetView.backgroundColor = .white
        
        let hairline = 1 / UIScreen.main.scale
        spreadsheetView.intercellSpacing = CGSize(width: hairline, height: hairline)
        spreadsheetView.gridStyle = .solid(width: hairline, color: .lightGray)
        spreadsheetView.circularScrolling = CircularScrolling.Configuration.none
        print(spreadsheetView.numberOfRows)
        
       
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 2
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 7
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        let width = (((UIScreen.main.bounds.width-32)/2)-4)
        return width
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        var height:CGFloat = 40
        
        if labelValues[row].count > 40{
            height = CGFloat(Double(labelValues[row].count) * 1.2)
        }
        return height
    }
  
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        
        print(indexPath.row)
        
        if indexPath.column == 0 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TitleCell.self), for: indexPath) as! TitleCell
            cell.label.text = labels[indexPath.row]
            cell.gridlines.top = .solid(width: 1, color: .black)
            cell.gridlines.bottom = .solid(width: 1, color: .black)
            cell.gridlines.left = .solid(width: 1, color: .black)
            return cell
        }
        if indexPath.column == 1   {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ValueCell.self), for: indexPath) as! ValueCell
            cell.label.text = labelValues[indexPath.row]
            if labelValues[indexPath.row].count > 28{
                print()
                cell.bounds = CGRect.init(x: 0, y: 0, width: (UIScreen.main.bounds.width-32)/2, height: 100)
            }
            cell.gridlines.top = .solid(width: 1, color: .black)
            cell.gridlines.bottom = .solid(width: 1, color: .black)
            cell.gridlines.left = .solid(width: 1 / UIScreen.main.scale, color: UIColor(white: 0.3, alpha: 1))
            cell.gridlines.right = cell.gridlines.left
            if indexPath.row == 5 {
                link = labelValues[indexPath.row]
                let gestureOpenUrl = UITapGestureRecognizer(target: self, action:  #selector (self.openUrl (_:)))
                cell.addGestureRecognizer(gestureOpenUrl)
                cell.label.textColor = UIColor(hue: 0.5722, saturation: 0.94, brightness: 1, alpha: 1.0)

            }
            return cell
        }
      
        return spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: BlankCell.self), for: indexPath)
    }
    @objc func done() { // remove @objc for Swift 3
        dismiss(animated: true)
    }   
    @IBAction func cancelButtonClick(_ sender: Any) {
        self.done()
    }
    @objc func openUrl(_ sender:UITapGestureRecognizer){
        
        if !link.hasPrefix("http") {
            link = "http://"+link
        }
        if let requestUrl = NSURL(string: link) {
            UIApplication.shared.openURL(requestUrl as URL)
        }
    }
    
    
}

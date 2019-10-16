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
import Localize_Swift
//import SpreadsheetView

protocol DisplayImeiStatusDisplayLogic: class
{
  func displayResult(viewModel: DisplayImeiStatus.ViewModel)
}

class DisplayImeiStatusViewController: UIViewController, DisplayImeiStatusDisplayLogic
{
  var interactor: DisplayImeiStatusBusinessLogic?
  var router: (NSObjectProtocol & DisplayImeiStatusRoutingLogic & DisplayImeiStatusDataPassing)?
  var viewModel: DisplayImeiStatus.ViewModel!
  @IBOutlet weak var cancelBtn: UIButton!
  var resultStatus = [String: [String]]()
  @IBOutlet weak var sceneTitle: UILabel!
  var imeiStatusTitles = [String]()
  @IBOutlet weak var statusTableView: UITableView!
    // MARK: Object lifecycle
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
  {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder)
  {
    super.init(coder: aDecoder)
    setup()
  }
  
  // MARK: Setup
  
  private func setup()
  {
    let viewController = self
    let interactor = DisplayImeiStatusInteractor()
    let presenter = DisplayImeiStatusPresenter()
    let router = DisplayImeiStatusRouter()
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
    setupViews()
    getImeiStatus()
  }

    func setupViews() {
        sceneTitle.text = "Display Status".localized()
        statusTableView?.register(StatusTableViewCell.nib, forCellReuseIdentifier: StatusTableViewCell.identifier)
        statusTableView?.delegate = self
        statusTableView?.dataSource = self
        self.statusTableView.separatorColor = UIColor.clear;
        if UIView.userInterfaceLayoutDirection(
            for: self.view.semanticContentAttribute) == .rightToLeft
        {
            print("tableview is rtl")
            statusTableView.semanticContentAttribute = .forceRightToLeft
        }
    }
    
  
  // MARK: Do something
  
  //@IBOutlet weak var nameTextField: UITextField!
  
  func getImeiStatus()
  {
    let request = DisplayImeiStatus.Request()
    interactor?.getImeiStatus(request: request)
  }
  func displayResult(viewModel: DisplayImeiStatus.ViewModel)
  {
    self.viewModel = viewModel
    statusTableView.reloadData()
  }
    @objc func done() { // remove @objc for Swift 3
        dismiss(animated: true)
    }
    @IBAction func cancelButtonClick(_ sender: Any) {
        self.done()
    }
    
}

extension DisplayImeiStatusViewController: UITableViewDelegate {
    
}

extension DisplayImeiStatusViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: StatusTableViewCell.identifier, for: indexPath) as? StatusTableViewCell {
            
            cell.configureWithItem(item: viewModel.tableViewData[indexPath.item])
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tableViewData.count
    }
}

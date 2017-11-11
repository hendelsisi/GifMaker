//
//  SettingsViewController.swift
//  LoopVideo
//
//  Created by Hend Elsisi on 9/8/16.
//

import UIKit
import StoreKit

import MessageUI
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class SettingsViewController: UIViewController,MFMailComposeViewControllerDelegate {
    
    enum AlertType {
        case goPro
        case rateUs
    }
     var iapProducts : [SKProduct]?
     var currentProduct : SKProduct?
     let iapManager = IAPHelper()
    var alertType:AlertType?
    var counter:Int = 0
   let titles = ["MORE","Go Pro","Rate Us","Share","Feedback","Restore Purchase"]
    @IBOutlet weak var tableViewRight: NSLayoutConstraint!
    @IBOutlet weak var tableViewLeft: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    var enablePurchase : Bool?
    var productsToPurchase : Bool = true
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor.clear
        // Configure the cell...
        cell.textLabel?.text = titles[(indexPath as NSIndexPath).row]
        
        if (indexPath as NSIndexPath).row == 0 {
            if Device.isPad()
            {
            cell.textLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 22)
            }
            else{
            cell.textLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 18)
            }
        }
        else
        {
            if Device.isPad()
            {
                cell.textLabel?.font = UIFont(name: "AppleSDGothicNeo", size: 22)
            }
            else{
                cell.textLabel?.font = UIFont(name: "AppleSDGothicNeo", size: 15)
            }
        }
        
         if (indexPath as NSIndexPath).row == 1
        {
            if self.enablePurchase == true
            {
                cell.textLabel?.textColor = UIColor.white
            }
            else{
                cell.textLabel?.textColor = UIColor.gray
            }
        }
       
        else if (indexPath as NSIndexPath).row == 5
        {
            if self.enablePurchase == true
            {
                cell.textLabel?.textColor = UIColor.gray
            }
            else{
                cell.textLabel?.textColor = UIColor.white
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView!, heightForRowAtIndexPath indexPath: IndexPath!) -> CGFloat {
        if(indexPath.row == 0)
        {
            if(Device.isPad())
            {return 200}
            else if(Device.isPhone())
            {
                if(Device.IS_4_7_INCHES_OR_LARGER()){
                return 140
                }
                else{
                    return 100}
            }
        }
        else
        {if(Device.isPad()){
            return 100}
            else if(Device.isPhone())
        {
            if(Device.IS_4_7_INCHES_OR_LARGER()){
                return 70
                
            }
            else{
            
            return 50}}
    }
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 1 {
            self.alertType = .goPro
            self.showGoProAlert()
        }
        else if (indexPath as NSIndexPath).row == 2 {
            self.alertType = .rateUs
            self.showRateUsAlert()
        }
        else if (indexPath as NSIndexPath).row == 3 {
            let link = URL(string:"http://example.com")
            let vc = UIActivityViewController(activityItems:[link!],applicationActivities: nil )
            if let wPPC = vc.popoverPresentationController {
                wPPC.sourceView = self.view
            }
       
        self.present( vc,animated: true, completion: nil)

        }
        else if (indexPath as NSIndexPath).row == 4 {
            self.feedbackApp()
        }
        else if (indexPath as NSIndexPath).row == 5 {
            self.restore_Operation()
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath) {
        
        //declaring the cell variable again
       let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if(Device.isPad()){
         cell.separatorInset.left = 660
        cell.separatorInset.right = 660
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.initIAPHelper()
        if(Device.isPad()){
        self.tableViewLeft.constant = 160
        self.tableViewRight.constant = 160
        }
        else if Device.IS_4_7_INCHES_OR_LARGER()
        {
            self.tableViewLeft.constant = 40
            self.tableViewRight.constant = 40
        }
    }
    
    
    
    @IBAction func closeButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showGoProAlert(){
        if !(iapManager.isUserPremium())
        {
            let alertView: UIAlertView = UIAlertView()
            alertView.delegate = self
            alertView.title = "GO PRO"
            alertView.message = "Ads suck. Get rid of them! If you have purchased already, please click \"Restore\" button."
            //  alertView
            alertView.addButton(withTitle: "Maybe later")
            alertView.addButton(withTitle: "Restore")
            alertView.addButton(withTitle: "Go Pro | $1.99")
            alertView.show()}
    }
    
    //IAP Operation
    
    func initIAPHelper(){
        self.getIAPProductData()
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.productPurchased(_:)), name: NSNotification.Name(rawValue: Constants.NSNotification.iapHelperProductPurchasedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.iapTransactionFailed(_:)), name: NSNotification.Name(rawValue: Constants.NSNotification.iapHelperTransactionFailNotification), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.uodateTable), name: NSNotification.Name(rawValue: Constants.NSNotification.iapHelperUpdateTable), object: nil)
        }
    
    func purchase_Operation(){
        if self.enablePurchase == true
        {
        if iapProducts != nil && iapProducts?.count > 0 {
            let product = iapProducts![0]
            // check on network
            if Reachability.checkRechabilityAndShowAlertView() {
                self.loading()
                LoopVedioIAPHelper.instance.buyProduct(product)
            }
            }
        }
    }
    
    func uodateTable(){
     self.tableView.reloadData()
    }
    
    func restore_Operation(){
        if Reachability.checkRechabilityAndShowAlertView() {
           self.finishedLoading()
           LoopVedioIAPHelper.instance.restoreCompletedTransactions()
        }
    }
    
    //MARK: - UI Handling
    // MARK: Product Purchased
    func productPurchased(_ notification : Notification)
    {
         self.finishedLoading()
         self.enablePurchase = false
         NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NSNotification.iapHelperUpdateTable), object:nil)
        
    }
    
    // MARK : Fail when buy or when restore
    func iapTransactionFailed(_ notification : Notification)
    {
        let failureMessage = NSLocalizedString("Transaction Faild", comment: "")
        counter += 1
        if counter < 2
        {  let alert = UIAlertView(title: "", message: failureMessage, delegate: nil, cancelButtonTitle: "OK")
            alert.show()}
        self.finishedLoading()
    }
    
    func finishedLoading(){
     UIUtils.instance.hideProgressHud()
    }
    
    func loading(){
         UIUtils.instance.showPorgressHudWithMessage("", view: self.view)
    }
    
    // MARK: Request the IAP product data
    func getIAPProductData()
    {
        if Reachability.checkRechability() {
            self.iapProducts = nil
           
            LoopVedioIAPHelper.instance.requestProductsWithCompletionHandler { (success, products) -> Void in
                if success {
                    self.iapProducts = products as? [SKProduct];
                    self.enablePurchase = true
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NSNotification.iapHelperUpdateTable), object:nil)
                    self.checkPurchasedProducts()
                }
            }
        }else{
            // check the saved product ids in the user default
            self.checkPurchasedProducts()
        }
    }
    
    func checkPurchasedProducts() {
        if let productIdentifier = AppDelegate.sharedAppDelegate().getPremiumProductIdentifier() {
            if  LoopVedioIAPHelper.instance.productPurchased(productIdentifier){
                // disable subscription buttons
                self.enablePurchase = false
             NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NSNotification.iapHelperUpdateTable), object:nil)
            }
           
        }
        
    }
    
    // MARK: Product Purchased
   
     func alertView(_ alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        switch buttonIndex{
        case 0:
            
            if self.alertType == .rateUs
            {
                self.rateUs()
            }
            break
        case 1:
            if self.alertType == .goPro
            { self.restore_Operation()}
            else if self.alertType == .rateUs
            {
                //email
                self.feedbackApp()
            }
           
        case 2:
            if self.alertType == .goPro{
                self.purchase_Operation()}
           
        default:
            print("error")
        }}
    
    func rateUs()
    {
        if Reachability.checkRechabilityAndShowAlertView() {
            UIApplication.shared.openURL(URL(string: AppDelegate.sharedAppDelegate().getAppUrl())!)
        }
    }
    
    func feedbackApp()
    {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func showRateUsAlert(){
        let alertView: UIAlertView = UIAlertView()
        alertView.delegate = self
        alertView.title = "Rate Us"
        alertView.message = "How do you like the app?"
        //  alertView
        alertView.addButton(withTitle: "It's good: Write a review")
        alertView.addButton(withTitle: "It needs work")
        alertView.addButton(withTitle: "Cancel")
        alertView.show()
    }
    
    
    // Compose Mail
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        mailComposerVC.setToRecipients([Constants.FeedbackMailRecipient])
        mailComposerVC.setSubject(getMailSubjectAccordingAppTarget())
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    func getMailSubjectAccordingAppTarget()->String {
        return Constants.FeedbackLoopVideoSubject
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
    }
}

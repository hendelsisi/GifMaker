//
//  IAPHelper.swift
//  MusicPlayer
//
//  Created by Minas Kamel on 9/20/15.
//  Copyright (c) 2015 nWeave LLC. All rights reserved.
//

import Foundation
import StoreKit

class IAPHelper : NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver
{
    let productId = Constants.IAP.productId
    var completionHandler : ((_ success : Bool, _ products : [AnyObject]?) -> Void)!
    var productsRequest : SKProductsRequest!
    var productIdentifiers = Set<String>()
    var purchasedProductIdentifiers : NSMutableSet!
    
    override init() {
        super.init()

        productIdentifiers = Set(arrayLiteral: productId)
        purchasedProductIdentifiers = NSMutableSet()
        
        for productIdentifier in productIdentifiers
        {
            if UserDefaults.standard.bool(forKey: productIdentifier) {
                purchasedProductIdentifiers.add(productIdentifier)
                NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NSNotification.iapHelperProductPurchasedNotification), object: productIdentifier)
                print("Previously purchased: \(productIdentifier)")
            } else {
                print("Not purchased: \(productIdentifier)")
            }
        }
        SKPaymentQueue.default().add(self)
    }
    
    //MARK: - IAP methods
    
    func isUserPremium() -> Bool {
        if LoopVedioIAPHelper.instance.productPurchased(productId) {
            return true
        }
        
        return false
    }
    
    func requestProductsWithCompletionHandler(_ completionHandler : @escaping ((_ success : Bool, _ products : [AnyObject]?) -> Void)) {
        self.completionHandler = completionHandler
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    func buyProduct(_ product : SKProduct) {
        print("Buying: \(product.productIdentifier)")
        let skPayment = SKPayment(product: product)
        SKPaymentQueue.default().add(skPayment)
    }
    
    func restoreCompletedTransactions()
    {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func provideContentForProductIdentifier(_ productIdentifier : String) {
        purchasedProductIdentifiers.add(productIdentifier)
        UserDefaults.standard.set(true, forKey: productIdentifier)
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NSNotification.iapHelperProductPurchasedNotification), object: productIdentifier)
    }
    
    func productPurchased(_ productIdentifier : String) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
    
    //MARK: - Utils
    func getProductPrice(_ product : SKProduct) -> String {
        let priceFormatter = NumberFormatter()
        priceFormatter.formatterBehavior =  NumberFormatter.Behavior.behavior10_4
        priceFormatter.numberStyle = NumberFormatter.Style.currency
        priceFormatter.locale = product.priceLocale
        let iapPrice = priceFormatter.string(from: product.price)!
        return iapPrice
    }
    
    //MARK: - SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        productsRequest = nil
        
        let skProducts = response.products
        for skProduct in skProducts {
            let price = (skProduct.price).floatValue
            print("Found product: \(skProduct.productIdentifier) \(skProduct.localizedTitle) \(price)")
        }
        if skProducts.count != 0{
            
            completionHandler?(true, skProducts)
            completionHandler = nil
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        productsRequest = nil
        completionHandler?(false, nil)
        completionHandler = nil
    }
    
    //MARK: - SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction ).transactionState {
            case .purchased:
                completeTransaction(transaction )
                break
            case .restored:
                restoreTransaction(transaction )
                break
            case .failed:
                failedTransaction(transaction )
                break
            default:
                break
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("failedRestore...")
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NSNotification.iapHelperTransactionFailNotification), object:nil)
    }
    
    func completeTransaction(_ transaction : SKPaymentTransaction) {
        print("completeTransaction...")
        
        provideContentForProductIdentifier(transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func restoreTransaction(_ transaction : SKPaymentTransaction) {
        print("restoreTransaction...")
        
        provideContentForProductIdentifier(transaction.original!.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func failedTransaction(_ transaction : SKPaymentTransaction) {
        print("failedTransaction...")
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NSNotification.iapHelperTransactionFailNotification), object:nil)

        if transaction.error!._code != SKError.paymentCancelled.rawValue {
            print("Transaction error: \(transaction.error!.localizedDescription)")
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
}

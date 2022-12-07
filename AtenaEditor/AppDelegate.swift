//
//  AppDelegate.swift
//  AtenaEditor
//
//  Created by Namikare Gikoha on 2021/11/22.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    weak var vc: ViewController!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    @IBAction func saveKitamuraCSV(_ sender: Any) {
        vc.outputKitamuraCSV(sender)
    }
    
    @IBAction func saveNengaKazokuCSV(_ sender: Any) {
        vc.outputNengaKazokuCSV(sender)
    }

    @IBAction func openAtenaCSV(_ sender: Any) {
        vc.openAtenaCSV()
    }
    
    @IBAction func addToSelection(_ sender: Any) {
        vc.addToSelection()
    }
    
    @IBAction func removeFromSelection(_ sender: Any) {
        vc.removeFromSelection()
    }
    
    @IBAction func showAll(_ sender: Any) {
        vc.showAllButton(sender)
    }
    
    @IBAction func showSelected(_ sender: Any) {
        vc.showSelectOnlyButton(sender)
    }
    
    @IBAction func showPrintMark(_ sender: Any) {
        vc.showPrintOnlyButton(sender)
    }
    
    @IBAction func selectTransLastYear(_ sender: Any) {
        vc.selectTransLastYear()
    }
    @IBAction func selectMochuTransLastYear(_ sender: Any) {
        vc.selectMochuTransLastYear()
    }
    @IBAction func selectReceivedLastYear(_ sender: Any) {
        vc.selectReceivedLastYear()
    }
    
}


//
//  CustomCellView.swift
//  AtenaEditor
//
//  Created by Namikare Gikoha on 2021/11/22.
//

import Cocoa

protocol CatchProtocol {
    func catchSelectButton(row:Int)
    func catchPrintButton(row:Int)
    func catchtyTsPop(row:Int, at: Int)
    func catchtyRcPop(row:Int, at: Int)
    func catchlyTsPop(row:Int, at: Int)
    func catchlyRcPop(row:Int, at: Int)
}

class CustomCellView: NSTableCellView {
    var delegate: CatchProtocol?
    var row: Int=0
    
    @IBOutlet weak var furiNameField: NSTextField!
    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var addrField: NSTextField!
    @IBOutlet weak var addrCodeField: NSTextField!
    @IBOutlet weak var selectButton: NSButton!
    @IBOutlet weak var printButton: NSButton!
    
    @IBOutlet weak var thisYearTextField: NSTextField!
    @IBOutlet weak var lastYearTextField: NSTextField!
    @IBOutlet weak var thisYearTsPopup: NSPopUpButton!
    @IBOutlet weak var thisYearRcPopup: NSPopUpButton!
    @IBOutlet weak var lastYearTsPopup: NSPopUpButton!
    @IBOutlet weak var lastYearRcPopup: NSPopUpButton!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    @IBAction func selectButtonPushed(_ sender: NSButton) {
        delegate?.catchSelectButton(row: self.row)
    }
    @IBAction func printButtonPushed(_ sender: Any) {
        delegate?.catchPrintButton(row: self.row)
    }
    
    @objc func tyTsPopPushed(_ sender: Any) {
        let pos = thisYearTsPopup.indexOfSelectedItem
        delegate?.catchtyTsPop(row: self.row, at: pos)
    }
    @objc func tyRcPopPushed(_ sender: Any) {
        let pos = thisYearRcPopup.indexOfSelectedItem
        delegate?.catchtyRcPop(row: self.row, at: pos)
    }
    @objc func lyTsPopPushed(_ sender: Any) {
        let pos = lastYearTsPopup.indexOfSelectedItem
        delegate?.catchlyTsPop(row: self.row, at: pos)
    }
    @objc func lyRcPopPushed(_ sender: Any) {
        let pos = lastYearRcPopup.indexOfSelectedItem
        delegate?.catchlyRcPop(row: self.row, at: pos)
    }
}

//
//  ViewController.swift
//  AtenaEditor
//
//  Created by Namikare Gikoha on 2021/11/22.
//

import Cocoa
import GRDB
import SwiftCSV

struct AddrList: TableRecord,Codable,FetchableRecord,PersistableRecord  {
    static let databaseTableName = "AddrList"
    var LastName: String
    var FirstName: String
    var furiLastName: String
    var furiFirstName: String
    var AddressCode: String
    var FullAddress: String
    var Suffix: String
    var PhoneItem: String
    var EmailItem: String
    var Memo: String
    var NamesOfFamily1: String
    var Suffix1: String
    var NamesOfFamily2: String
    var Suffix2: String
    var NamesOfFamily3: String
    var Suffix3: String
    var atxBaseYear: Int32?
    var NYCardHistory: String?
    var Selected: Int32?
    var Print: Int32?
    var id: Int32
}


class ViewController: NSViewController,NSTableViewDelegate,NSTableViewDataSource, CatchProtocol {
    
    var alladdr: [AddrList] = []
    var dbpath : String=""
    var dbQueue: DatabaseQueue?
    @IBOutlet weak var myTableView: NSTableView!
    @IBOutlet weak var numOfAddrField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        (NSApplication.shared.delegate as! AppDelegate).vc = self

        let dbpath = Bundle.main.path(forResource: "Atena", ofType: "sqlite")!
        //let res="/Users/gikoha/Atena.sqlite"
        dbQueue = try! DatabaseQueue(path: dbpath)
        self.showAllButton(self)

        //alladdr.sort { $0.furiLastName < $1.furiLastName }


        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return alladdr.count
    }
    
    func getOneHex(str: String, pos: Int) -> Int {
        let c = str[str.index(str.startIndex,offsetBy:pos-1)..<str.index(str.startIndex,offsetBy: pos)]
        
        return Int(c,radix: 16)!
    }

    func calcIndexTransmitted(str: String, pos: Int) -> Int {

        let num = getOneHex(str: str, pos: pos)

        if (num & 8) != 0 {
            return 2 // ??????
        } else if(num & 4) != 0 {
            return 1 // ??????
        }
        return 0
    }
    
    func calcIndexReceived(str: String, pos: Int) -> Int {

        let num = getOneHex(str: str, pos: pos)

        if (num & 2) != 0 {
            return 2 // ??????
        } else if(num & 1) != 0 {
            return 1 // ??????
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MyTableCell"), owner: self) as? CustomCellView
        cell?.furiNameField.stringValue = alladdr[row].furiLastName + " " + alladdr[row].furiFirstName
        cell?.nameField.stringValue = alladdr[row].LastName + " " + alladdr[row].FirstName
        cell?.addrField.stringValue = alladdr[row].FullAddress
        cell?.addrCodeField.stringValue = "???" + alladdr[row].AddressCode

        if let lastYear = alladdr[row].atxBaseYear {
            cell?.lastYearTextField.stringValue = String(lastYear) + "???"
            cell?.thisYearTextField.stringValue = String(lastYear+1) + "???"
            if let s = alladdr[row].NYCardHistory {
                cell?.thisYearTsPopup.selectItem(at: calcIndexTransmitted(str: s, pos: 16))
                cell?.thisYearTsPopup.target = cell!
                cell?.thisYearTsPopup.action = #selector(CustomCellView.tyTsPopPushed(_:))

                cell?.thisYearRcPopup.selectItem(at: calcIndexReceived(str: s, pos: 16))
                cell?.thisYearRcPopup.target = cell!
                cell?.thisYearRcPopup.action = #selector(CustomCellView.tyRcPopPushed(_:))

                cell?.lastYearTsPopup.selectItem(at: calcIndexTransmitted(str: s, pos: 15))
                cell?.lastYearTsPopup.target = cell!
                cell?.lastYearTsPopup.action = #selector(CustomCellView.lyTsPopPushed(_:))

                cell?.lastYearRcPopup.selectItem(at: calcIndexReceived(str: s, pos: 15))
                cell?.lastYearRcPopup.target = cell!
                cell?.lastYearRcPopup.action = #selector(CustomCellView.lyRcPopPushed(_:))
            }
        }

        cell?.selectButton.state = NSControl.StateValue.off
        if let value = alladdr[row].Selected
        {
            if value != 0 {
                cell?.selectButton.state = NSControl.StateValue.on
            }
        }

        cell?.printButton.state = NSControl.StateValue.off
        if let value = alladdr[row].Print
        {
            if value != 0 {
                cell?.printButton.state = NSControl.StateValue.on
            }
        }
        
        cell?.row = row             // you can't set tag because read only
        cell?.delegate = self       // for catchSelect/Print method
        return cell
    }
    
    func catchSelectButton(row: Int)
    {
        // delegate method: clicked Select button in row
        var val = 1
        if alladdr[row].Selected == 1
        {
            val = 0
        }
        let oldrow = alladdr[row].id

        //dbQueue = try! DatabaseQueue(path: dbpath)
        _ = try! dbQueue!.write { db in
            try AddrList.filter(Column("id")==oldrow)
            .updateAll(db,Column("Selected").set(to: val))
        }
    }
    
    func catchPrintButton(row: Int)
    {
        // delegate method: clicked Print button in row
        var val = 1
        if alladdr[row].Print == 1
        {
            val = 0
        }
        let oldrow = alladdr[row].id
        
        //dbQueue = try! DatabaseQueue(path: dbpath)
        _ = try! dbQueue!.write { db in
            try AddrList.filter(Column("id")==oldrow)
                .updateAll(db,Column("Print").set(to: val))
        }

    }
    
    func putOneHex(str: String, pos: Int, to: Int) -> String {
        let range: Range<String.Index> = str.index(str.startIndex, offsetBy: pos-1)..<str.index(str.startIndex, offsetBy: pos)
        return str.replacingCharacters(in: range, with: String(to, radix:16))
    }
    
    func updateNYCardHistory(row: Int, pos: Int, newSelection: Int, send: Bool)
    {
        if let s = alladdr[row].NYCardHistory
        {
            var val = getOneHex(str: s, pos: pos)
            if send
            {
                switch newSelection
                {
                case 1:
                    val &= ~(8|4)
                    val |= 4 // ???
                case 2:
                    val &= ~(8|4)
                    val |= 8 // ???
                default:
                    val &= ~(8|4) // clear 8 and 4 bit  ???
                }
            }
            else
            {
                switch newSelection
                {
                case 1:
                    val &= ~(2|1)
                    val |= 1 // ???
                case 2:
                    val &= ~(2|1)
                    val |= 2 // ???
                default:
                    val &= ~(2|1) // clear 8 and 4 bit  ???
                }

            }
            let u = putOneHex(str: s, pos: pos, to: val)

            alladdr[row].NYCardHistory = u  // modify memory data
            
            // modify disk data
            let oldrow = alladdr[row].id
            _ = try! dbQueue!.write { db in
                try AddrList.filter(Column("id")==oldrow)
                    .updateAll(db,Column("NYCardHistory").set(to: u))
            }
            myTableView.reloadData()
        }
    }
    //             0123456789012345
    // 2022 MoMo = 000090024000000A2006   8+2=10  pos=15
    // 2022 NoNo = 00009002400000002006
    // 2021 MoMo = 00009002400000A02006   8+2=10  pos=14
    // 2021 NoNo = 00009002400000002006
    func catchtyTsPop(row: Int, at: Int)
    {
        updateNYCardHistory(row:row, pos:16, newSelection: at,send: true)
    }
    
    func catchtyRcPop(row: Int, at: Int)
    {
        updateNYCardHistory(row:row, pos:16, newSelection: at,send: false)
    }
    
    func catchlyTsPop(row: Int, at: Int)
    {
        updateNYCardHistory(row:row, pos:15, newSelection: at,send: true)
    }
    
    func catchlyRcPop(row: Int, at: Int)
    {
        updateNYCardHistory(row:row, pos:15, newSelection: at,send: false)
    }

    func addToSelection()
    {
        let indexes = myTableView.selectedRowIndexes
        indexes.forEach { i in
            alladdr[i].Selected = 1
            _ = try! dbQueue!.write { db in
                try AddrList.filter(Column("id")==alladdr[i].id)
                    .updateAll(db,Column("Selected").set(to: 1))
            }
        }
        myTableView.reloadData()
    }
    
    func removeFromSelection()
    {
        let indexes = myTableView.selectedRowIndexes
        indexes.forEach { i in
            alladdr[i].Selected = 0
            _ = try! dbQueue!.write { db in
                try AddrList.filter(Column("id")==alladdr[i].id)
                    .updateAll(db,Column("Selected").set(to: 0))
            }
        }
        myTableView.reloadData()
    }
    
    func selectTransLastYear()
    {
        var index = IndexSet()
        for (row,addr1) in alladdr.enumerated() {
            if let s = addr1.NYCardHistory {
                if(calcIndexTransmitted(str: s, pos: 15) == 1) {
                    index.insert(row)
                }
            }
        }
        myTableView.selectRowIndexes(index, byExtendingSelection: false)
    }
    
    func selectMochuTransLastYear()
    {
        var index = IndexSet()
        for (row,addr1) in alladdr.enumerated() {
            if let s = addr1.NYCardHistory {
                if(calcIndexTransmitted(str: s, pos: 15) == 2) {
                    index.insert(row)
                }
            }
        }
        myTableView.selectRowIndexes(index, byExtendingSelection: false)
    }
    
    func selectReceivedLastYear()
    {
        var index = IndexSet()
        for (row,addr1) in alladdr.enumerated() {
            if let s = addr1.NYCardHistory {
                if(calcIndexReceived(str: s, pos: 15) != 0) {
                    index.insert(row)
                }
            }
        }
        myTableView.selectRowIndexes(index, byExtendingSelection: false)
    }
    
    
    @IBAction func showAllButton(_ sender: Any) {
        // select all
        //dbQueue = try! DatabaseQueue(path: dbpath)
        alladdr = try! dbQueue!.read { db in
            try AddrList.order(sql: "furiLastName").fetchAll(db)
        }
        numOfAddrField.stringValue = String(alladdr.count)
        myTableView.reloadData()
    }
    
    @IBAction func showSelectOnlyButton(_ sender: Any) {
        // select all where Selected!=0
        //dbQueue = try! DatabaseQueue(path: dbpath)
        alladdr = try! dbQueue!.read { db in
            try AddrList.order(sql: "furiLastName").filter(sql: "Selected!=0").fetchAll(db)
        }
        numOfAddrField.stringValue = String(alladdr.count)
        myTableView.reloadData()
    }
    
    @IBAction func showPrintOnlyButton(_ sender: Any) {
        // select all where Print!=0
        //dbQueue = try! DatabaseQueue(path: dbpath)
        alladdr = try! dbQueue!.read { db in
            try AddrList.order(sql: "furiLastName").filter(sql: "Print!=0").fetchAll(db)
        }
        numOfAddrField.stringValue = String(alladdr.count)
        myTableView.reloadData()
    }
    
    func parseCSV(csv: CSV)
    {
        let headvars: [String] = ["LastName","FirstName","furiLastName","furiFirstName","AddressCode",
                                  "FullAddress","Suffix","PhoneItem","EmailItem","Memo",
                                  "NamesOfFamily1","X-Suffix1","NamesOfFamily2","X-Suffix2","NamesOfFamily3",
                                  "X-Suffix3","atxBaseYear","X-NYCardHistory"]
        try! dbQueue!.write { db in
            try db.execute(sql: """
            DROP TABLE IF EXISTS "AddrList";
            """)
            try db.execute(sql: """
            CREATE TABLE "AddrList" ("id" int NOT NULL DEFAULT '0', "LastName" varchar,"FirstName" varchar,"furiLastName" varchar,"furiFirstName" varchar,"AddressCode" varchar,"FullAddress" varchar,"Suffix" varchar,"PhoneItem" varchar,"EmailItem" varchar,"Memo" varchar,"NamesOfFamily1" varchar,"Suffix1" varchar,"NamesOfFamily2" varchar,"Suffix2" varchar,"NamesOfFamily3" varchar,"Suffix3" varchar,"atxBaseYear" int DEFAULT '2021',"NYCardHistory" varchar DEFAULT '00000000000000002006', "Selected" int DEFAULT '0', "Print" int DEFAULT '0');
            """)
            var index = 0
            try csv.enumerateAsDict { row in
                var str = "Insert into AddrList values (" + String(index) + ","
                for h in headvars {
                    if let v = row[h] {
                        str += "'" + v + "',"
                    } else {
                        str += "'',"
                    }
                    
                }
                
                str = String(str.dropLast())
                str += ",0,0)"
                try! db.execute(sql: str)
                index += 1
                
            }
        }
    }
    
    func openAtenaCSV()
    {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.begin { (result) -> Void in
            if result == .OK {
                guard let url = openPanel.url else { return }
                do {
                    let csvFile = try CSV(url: url)
                    self.parseCSV(csv: csvFile)
                    self.showAllButton(self)
                } catch {
                    let alert = NSAlert()
                    alert.messageText = "load error / encoding error / parse error"
                    _ = alert.runModal()
                    return
                }
            }
        }
    }
    
    @IBAction func outputKitamuraCSV(_ sender: Any) {
        let head = "???1,???1,??????1,???2,???2,??????2,???3,???3,??????3,???4,???4,??????4,???5,???5,??????5,???6,???6,??????6,?????????,??????1,??????2,??????3,?????????,??????,??????,??????"
        let headvars: [String] = ["LastName","FirstName","Suffix",
                                "","NamesOfFamily1","Suffix1",
                                "","NamesOfFamily2","Suffix2",
                                "","NamesOfFamily3","Suffix3",
                                "","","",
                                "","","",
                                "AddressCode","FullAddress","","",
                                "","","",""]
        // ??????????????????????????????+CRLF???(?????????(SJIS)+CRLF)xn
        var str = head + "\r\n"
        for addr1 in alladdr
        {
            let addrid = addr1.id
            var str1 = ""
            for (colno,head1) in headvars.enumerated()
            {
                if head1 != ""
                {
                    let str2 = try! dbQueue!.read { db in
                        try AddrList
                            .select(sql:head1)
                            .filter(sql:"id = ?",
                                    arguments: [addrid])
                            .asRequest(of: String.self)
                            .fetchOne(db)
                    }
                    str1 += str2 ?? ""
                    if colno != headvars.count-1
                    {
                        str1 += ","
                    }
                }
                else
                {
                    if colno != headvars.count-1
                    {
                        str1 += ","
                    }
                }
            }
            str += str1 + "\r\n"  // ?????????????????? CRLF ???????????????)
        }

        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.nameFieldStringValue = "atena_kitamura_SJIS.csv"
        savePanel.begin { (result) in
            if result == .OK {
                guard let url = savePanel.url else { return }
                //print(url.absoluteString)
                do {
                    // ?????????????????? SJIS???????????????)
                    try str.write(to: url, atomically: true, encoding: String.Encoding.shiftJIS) // utf8
                } catch {
                    // failed to write file (bad permissions, bad filename etc.)
                }
            }
        }

    }
}


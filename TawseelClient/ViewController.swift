//
//  ViewController.swift
//  TawseelClient
//
//  Created by Mahmoud Amer on 1/31/17.
//  Copyright © 2017 Tawseel. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref: FIRDatabaseReference!
    var currentTripKey = ""
    var currentTripStatus = ""
    var json: JSON = []
    
    // Data model: These strings will be the data for the table view cells
    var locationsArray = [String]()
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var locationsTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Database reference object
        ref = FIRDatabase.database().reference()
        
        //Listen for created trip
        ref.child("trips").queryOrderedByKey().observe(.childAdded, with: { (snapshot) -> Void in
            
            //First, get trip status and if = started (Means currently running), continue
            self.json = JSON(snapshot.value!)
            self.currentTripStatus = self.json["status"].stringValue
            // Listen for locations only if trip status is started
            if (self.currentTripStatus == "started"){
                
                //Empty array and table view
                self.locationsArray.removeAll()
                self.locationsTableView.reloadData()
                //Current trip id (tripID)
                self.currentTripKey = snapshot.key
                
                //Listen for driver movement in this trip
                self.ref.child("trips").child(snapshot.key).child("locations").observe(.childAdded, with: { (snapshot) -> Void in
                    if (snapshot.value != nil){
                        self.locationsArray.append(snapshot.value as! String)
                        self.locationsTableView.reloadData()
                    }
                })
                
                //Listen for changing current trip status to ended
                self.ref.child("trips").child(snapshot.key).child("status").observe(.value, with: { (snapshot) -> Void in
                    print("status changed")
                    print(snapshot.value!)
                    if let statusText = snapshot.value as? String {
                        self.statusLabel.text = statusText
                    }
                })
                
                //Listen for Cost Change for the current trip
                self.ref.child("trips").child(snapshot.key).child("cost").observe(.value, with: { (snapshot) -> Void in
                    print("cost changed")
                    print(snapshot.value!)
                    
                    
                    if let cost = snapshot.value,
                        (cost is NSNumber || cost is String) {
                        
                        self.costLabel.text = "Cost: \(cost) Sar"
                    }
                })
            }            
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TableView Cell identifier
        self.locationsTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        currentTripStatus = ""
        self.locationsArray.removeAll()
        self.locationsTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locationsArray.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.locationsTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        // set the text from the data model
        cell.textLabel?.text = self.locationsArray[indexPath.row]
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}


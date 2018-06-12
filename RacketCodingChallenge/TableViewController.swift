//
//  ViewController.swift
//  RacketCodingChallenge
//
//  Created by Michael Anastasio on 6/7/18.
//  Copyright © 2018 Michael Anastasio. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var newestPostNum: String!
    var storageRef: StorageReference!
    var databaseRef: DatabaseReference!
    @IBOutlet weak var tableView: UITableView!
    var dispatchGroup: DispatchGroup!
    var imageDictionary: [String: UIImage]!
    var descriptionDictionary: [String: String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storageRef = Storage.storage().reference()
        databaseRef = Database.database().reference()
        imageDictionary = [String:UIImage]()
        descriptionDictionary = [String:String]()
        dispatchGroup = DispatchGroup()
        let newestRef = databaseRef.child("newestPost")
        dispatchGroup.enter()
        newestRef.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            self.newestPostNum = snapshot.value as? String
            self.dispatchGroup.leave()
        }) { (error) in
            print(error.localizedDescription)
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        imageDictionary["empty"] = UIImage(named: "EmptyPhoto.jpg")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func refreshButton(_ sender: Any) {
        refreshPage()
    }
    
    func refreshPage(){
        //This is probably not the best way to do this.
        self.viewDidLoad()
        tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostViewCell
        dispatchGroup.notify(queue: .main) {
            let postRef = Int(self.newestPostNum!)! - indexPath.row
            let stringRef = String(postRef)
            if let cellImage = self.imageDictionary[stringRef] {
                cell.postImage.image = cellImage
                if cell.postDescription.text != self.descriptionDictionary[stringRef] {
                    cell.postDescription.text = self.descriptionDictionary[stringRef]
                    }
            }else{
                //cell.postImage.image = UIImage(named: "EmptyPhoto.jpg")
                let group = DispatchGroup()
                cell.group = group
                cell.number = indexPath.row
                cell.hasGottenPost = false
                cell.getPost(postReference: stringRef)
                group.notify(queue: .main, execute: {
                    self.imageDictionary[stringRef] = cell.postImage.image
                    self.descriptionDictionary[stringRef] = cell.postDescription.text
                })
                
            }
        }
        return cell
    }
}

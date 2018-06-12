//
//  PostViewCell.swift
//  RacketCodingChallenge
//
//  Created by Michael Anastasio on 6/9/18.
//  Copyright © 2018 Michael Anastasio. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

class PostViewCell: UITableViewCell {
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postDescription: UILabel!
    var databaseRef: DatabaseReference!
    var storageRef: StorageReference!
    var hasGottenPost: Bool!
    var number: Int!
    var dispatchGroup: DispatchGroup!
    var group: DispatchGroup!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        hasGottenPost = false
        dispatchGroup = DispatchGroup()
        postImage.image = UIImage(named: "EmptyPhoto.jpg")
    }
    func reloadingCell(){
        postImage.image = UIImage(named: "EmptyPhoto.jpg")
        postDescription.text = ""
    }
    
    func getPost(postReference: String){
        let descriptionRef = databaseRef.child("posts").child(postReference).child("description")
        print(String(number!) + " is referencing: " + postReference)
        self.hasGottenPost = true
        group.enter()
        descriptionRef.observeSingleEvent(of: DataEventType.value) { (snapshot) in
            self.postDescription.text = snapshot.value as? String
        }
        let imageRef = storageRef.child("posts/" + postReference + ".jpg")
        imageRef.getData(maxSize: 1*2048*2048) { (data, error) in
            if error == nil {
                self.postImage.image = UIImage(data: data!)
                self.hasGottenPost = true
                self.group.leave()
            }else{
                print(error?.localizedDescription ?? "")
            }
        }
    }
}

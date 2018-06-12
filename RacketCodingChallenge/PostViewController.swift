//
//  PostViewController.swift
//  RacketCodingChallenge
//
//  Created by Michael Anastasio on 6/7/18.
//  Copyright © 2018 Michael Anastasio. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import UIKit


extension UIImage {
    class func scaleImageToSize(img: UIImage, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        img.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

class PostViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var uploadImage: UIImageView!
    @IBOutlet weak var descriptionText: UITextField!
    var dText:String!
    var image:UIImage!
    var databaseRef: DatabaseReference!
    var storageReference: StorageReference!
    var newestPostNum:String!
    var dispatchGroup:DispatchGroup!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference()
        storageReference = Storage.storage().reference()
        dispatchGroup = DispatchGroup()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sharePhoto(_ sender: Any) {
        if(image != nil){
            let newestRef = databaseRef.child("newestPost")
            dispatchGroup.enter()
            newestRef.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                self.newestPostNum = snapshot.value as? String
                self.dispatchGroup.leave()
            }) { (error) in
                print(error.localizedDescription)
            }
            dispatchGroup.notify(queue: .main) {
                var postInt = Int(self.newestPostNum)!
                postInt += 1
                self.newestPostNum = String(postInt)
                newestRef.setValue(self.newestPostNum)
                //post description to firebase
                self.dText = self.descriptionText.text
                //let descriptionRef = self.databaseRef.child("posts/description/" + self.newestPostNum)
                //descriptionRef.setValue(self.dText)
                //post photo to firebase
                let imageReference = self.storageReference.child("posts/" + self.newestPostNum + ".jpg")
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpg"
                //self.image.
                imageReference.putData(UIImageJPEGRepresentation(self.image, 0.3)!, metadata: metadata) { (data, error) in
                    if error == nil {
                        print("upload successful")
                        var imageUrl = URL(fileURLWithPath: "https://firebasestorage.googleapis.com/v0/b/racketcodingchallenge.appspot.com/o/Error.jpg?alt=media&token=2560576a-e36f-4268-b636-9e4356448451")
                        imageReference.downloadURL(completion: { (url, error) in
                            if error == nil {
                                imageUrl = url!
                                let postRef = self.databaseRef.child("posts/" + self.newestPostNum)
                                let post:[String:Any] = ["imageURL":imageUrl.absoluteString, "description":self.dText]
                                postRef.setValue(post)
                                
                            }else{
                                print(error?.localizedDescription ?? "")
                            }
                        })
                    }else{
                        print(error?.localizedDescription ?? "")
                    }
                }
                
                self.dismissVC(self)
            }
        }else{
            print("Theres no photo")
        }
    }
    
    @IBAction func clickCancel(_ sender: Any) {
        dismissVC(self)
    }
    
    @IBAction func dismissVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveView(textField: textField, moveDistance: -40, moveUp: true)
    }
    
    func  textFieldDidEndEditing(_ textField: UITextField) {
        moveView(textField: textField, moveDistance: -40, moveUp: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func moveView(textField: UITextField, moveDistance: Int, moveUp: Bool){
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(moveUp ? moveDistance: -moveDistance)
        UIView.beginAnimations("moveUpAnimation", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    @IBAction func uploadImage(_ sender: Any) {
        CameraHandler.shared.showActionSheet(vc: self)
        CameraHandler.shared.imagePickedBlock = { (photo) in
            //self.image = UIImage.scaleImageToSize(img: photo, size: CGSize(width: 1080, height: 1080))
            self.image = photo
            self.uploadImage.image = self.image
            self.uploadButton.setTitle("", for: .normal)            
        }
        
    }
    
}

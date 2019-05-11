//
//  ViewController.swift
//  Flower Recognition App
//
//  Created by Dennis M on 2019-05-10.
//  Copyright © 2019 Dennis M. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let wikipediaURl = "https://en.wikipedia.org/w/api.php"
    let imagePicker =  UIImagePickerController()

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
    } 

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            guard let ciimage = CIImage(image: image) else {
                fatalError("error converting to ciimage")
            }
            imageView.image = image
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {fatalError("loading coreML model failed")}
        let requst = VNCoreMLRequest(model: model) { (request, error) in
            guard let result = request.results?.first as? VNClassificationObservation else {fatalError("model failed to proccess image")}
            self.navigationItem.title = result.identifier.capitalized
            self.getFlowerData(flowerName: result.identifier)
        }

        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([requst])
        } catch {
            print(error)
        }
    }
    
    func getFlowerData(flowerName: String) {
        let parameters : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts",
            "exintro" : "",
            "explaintext" : "",
            "titles" : flowerName,
            "indexpageids" : "",
            "redirects" : "1",
        ]
        
        Alamofire.request(wikipediaURl, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                print("Got flower's informations")
                print(response)
            } else {
                print("Error: " + String(describing: response.result.error))
            }
        }
    }

}

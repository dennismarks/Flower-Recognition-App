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

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        // vncoremlmodel - comes from the vision framework; allows us to perform an image analysisn request that uses our coreml model to process images
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {fatalError("loading coreML model failed")}
        let requst = VNCoreMLRequest(model: model) { (request, error) in
            guard let result = request.results?.first as? VNClassificationObservation else {fatalError("model failed to proccess image")}
            self.navigationItem.title = result.identifier.capitalized
        }
        
        // perfrom request
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([requst])
        } catch {
            print(error)
        }
    }
}


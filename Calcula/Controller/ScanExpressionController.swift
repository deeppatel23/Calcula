//
//  ScanExpressionController.swift
//  Calcula
//
//  Created by Deep on 14/05/21.
//

import UIKit
import Vision

class ScanExpressionController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextFieldDelegate{
    
    
    @IBOutlet weak var capturedImage: UIImageView!
    @IBOutlet weak var scannedExpression: UITextField!
    let imagePicker = UIImagePickerController()
    var viewAppear = 0
    var callback : ((String)->())?
    
    override func viewDidAppear(_ animated: Bool) {
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        viewAppear += 1
        
        if viewAppear == 1 {
            present(imagePicker, animated: true, completion: nil)
        }
        
        
        self.hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);
    }

//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        imagePicker.delegate = self
//        imagePicker.sourceType = .camera
//        imagePicker.allowsEditing = true
//    }
//
    
    @objc func keyboardWillShow(sender: NSNotification) {
         self.view.frame.origin.y = -150 // Move view 150 points upward
    }

    @objc func keyboardWillHide(sender: NSNotification) {
         self.view.frame.origin.y = 0 // Move view to original position
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
        var image : UIImage!
        if let img = info[.editedImage] as? UIImage {
            image = img
        } else if let img = info[.originalImage] as? UIImage {
            image = img
        }
        picker.dismiss(animated: true,completion: nil)
        capturedImage.image = image
        imageMakeRequest(image: image)
    }
    
    func imageMakeRequest(image: UIImage) {
        
        // Get the CGImage on which to perform requests.
        guard let cgImage = getCGImage(from: image) else {
            fatalError("couldn't convert uiimage to CgImage")
        }

        // Create a new image-request handler.
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)

        // Create a new request to recognize text.
        let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler(request:error:))

        do {
            // Perform the text-recognition request.
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
        
    }
    
    func getCGImage(from uiimg: UIImage) -> CGImage? {
            
            UIGraphicsBeginImageContext(uiimg.size)
            uiimg.draw(in: CGRect(origin: .zero, size: uiimg.size))
            let contextImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return contextImage?.cgImage
            
        }
    
    func recognizeTextHandler(request: VNRequest, error: Error?) {
    
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            return
        }
        let recognizedStrings = observations.compactMap { observation in
            // Return the string of the top VNRecognizedText instance.
            return observation.topCandidates(1).first?.string
        }
        print("Recognized string: \(recognizedStrings)")
    
        var ans = recognizedStrings.first
        var count = 1
        while  count < recognizedStrings.count {
            ans! += "+"
            ans! += recognizedStrings[count]
            count += 1
        }

        ans = ans!.filter("0123456789+-*/()^xX.".contains)
        
        ans = ans!.replacingOccurrences(of: "x", with: "*")
        ans = ans!.replacingOccurrences(of: "X", with: "*")
        ans = ans!.replacingOccurrences(of: "×", with: "*")
        ans = ans!.replacingOccurrences(of: "÷", with: "/")
        
        // Process the recognized strings.
        self.scannedExpression.text = ans
        
    }
    
    
    @IBAction func useExpression(_ sender: UIButton) {
        
        callback?(scannedExpression.text!)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    

    
    @IBAction func cancelAndBack(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}


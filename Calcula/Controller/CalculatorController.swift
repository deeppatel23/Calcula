//
//  ViewController.swift
//  Calcula
//
//  Created by Deep on 08/05/21.
//


import UIKit

class CalculatorController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround() 
    }
        
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var expressionTextField: UITextField!
    
    
    private var calcPressed = false
    private var dotPressed = false
    private var calcEqualPressed = false
    private var errOccured = false
    private var calculatorLogic = CalculatorLogic()
    
    private var displayValue: Double {
        get {
                guard let number = Double(displayLabel.text!) else {
                fatalError("Cannot convert display label text to double.")
                }
                return number
        }
        set {
            displayLabel.text = removeTrailingZero(temp: newValue)
        }
    }
    
    //remove trailing zeroes from double
    func removeTrailingZero(temp: Double) -> String {
        let tempVar = String(format: "%g", temp)
        return tempVar
    }
    

    @IBAction func calcButtonPressed(_ sender: UIButton) {

        if expressionTextField.endEditing(true) {
            calcPressed = false
            calcEqualPressed = false
        }

        if let cM = sender.currentTitle {
            
            if errOccured {
                expressionTextField.text = nil
                return
            }
            if !calcPressed || cM == "AC" || cM == "%" || cM == "+/-" || calcEqualPressed {
                calcPressed = true
                
                if cM == "AC" || cM == "%" || cM == "+/-" {
                    
                    displayValue = calculatorLogic.simpleCalculate(calcMethod: cM, calcNum: displayValue)
                    expressionTextField.text = nil
                    
                } else if cM != "=" {
                    
                    if calcEqualPressed {
                        expressionTextField.text = displayLabel.text
                    }
                    if cM == "×" {
                        expressionTextField.text?.append("*")
                    } else if cM == "÷" {
                        expressionTextField.text?.append("/")
                    } else if cM == "^" {
                        expressionTextField.text?.append("**")
                    } else {
                        expressionTextField.text?.append(cM)
                    }
                    
                    calcEqualPressed = false
    
                    
                } else {
                    
                    if calcEqualPressed {
                        return
                    }
                    
                    calcEqualPressed = true
                    (displayValue, errOccured) = calculatorLogic.calculate(calcMethod: expressionTextField.text!)
                    
                    if errOccured {
                        expressionTextField.text = "ERROR"
                    }
                }
            }
        }
    }
    
    @IBAction func numButtonPressed(_ sender: UIButton) {

        if let numValue = sender.currentTitle {
            
            errOccured = false
            
            //when calculation is over
            if calcPressed {
                displayLabel.text = "0"
                calcPressed = false
                dotPressed = false
                
                if calcEqualPressed {
                    expressionTextField.text = nil
                }
            }
            
            //prevent multiple dots
            if numValue == "."{
                if calcEqualPressed {
                    expressionTextField.text = nil
                    return
                } else if dotPressed {
                    return
                } else {
                    dotPressed = true
                }
            }
            
            //display input
            if displayLabel.text == "0" {
                displayLabel.text = numValue
            } else {
                displayLabel.text?.append(numValue)
            }
            
            //display expression label
            if expressionTextField.text == nil {
                expressionTextField.text = String(numValue)
            } else {
                expressionTextField.text?.append(String(numValue))
            }
        }
    }
    
    
    
    
    @IBAction func scanExpression(_ sender: UIButton) {
        performSegue(withIdentifier: "pickImage", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pickImage" {
            let destinationVC = segue.destination as! ScanExpressionController
            destinationVC.callback = { result in
                print(result)
                self.expressionTextField.text = String(result)
                self.calcEqualPressed = false
                self.calcPressed = false
                self.displayValue = 0
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

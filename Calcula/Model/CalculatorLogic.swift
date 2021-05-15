//
//  CalculatorLogic.swift
//  Calcula
//
//  Created by Deep on 08/05/21.
//

import Foundation
class CalculatorLogic {
    

    func simpleCalculate(calcMethod: String, calcNum: Double) -> Double {
        if calcMethod == "AC" {
            return 0
        } else if calcMethod == "%" {
            return calcNum/100
        } else {
            return calcNum * -1
        }
    }
    
    func calculate (calcMethod : String) -> (Double, Bool) {
        
        var leftB = 0
        var rightB = 0

        for item in calcMethod {
            if item == ")" && leftB <= rightB {
                return (0, true)
            } else if item == "(" {
                leftB += 1
            }
            else if item == ")" {
                rightB += 1
            }
        }


        if leftB != rightB {
            return (0, true)
        }
        
        let exp: NSExpression = NSExpression(format: calcMethod)
        let result: Double = exp.expressionValue(with:nil, context: nil) as! Double
  
        //print(calcMethod)
        
        return (result, false)
            
    }
}


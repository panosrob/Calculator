//
//  ViewController.swift
//  Calculator
//
//  Created by Panagiotis Rompolas on 01/10/2016.
//  Copyright © 2016 Panagiotis Rompolas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var display: UILabel!
    
    @IBOutlet private weak var history: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    
    private var brain  = CalculatorBrain()
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var historyValue: String {
        get {
            return history.text!
        }
        set {
            history.text = newValue
        }
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            updateDisplays()
        }
    }
    
    @IBAction func setVariable() {
        brain.variableValues["M"] = displayValue
        brain.program = brain.program
        updateDisplays()
    }
    
    @IBAction func getVariable() {
        brain.setOperand(variableName: "M")
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        let textInDisplay = display.text!
        if !brain.isPartialResult {
            brain.clear()
            historyValue = " "
        }
        if digit == "." && textInDisplay.range(of: ".") != nil {
            display.text = textInDisplay
        } else {
            if userIsInTheMiddleOfTyping {
                display.text = textInDisplay + digit
            } else {
                display.text = digit
            }
            
            userIsInTheMiddleOfTyping = true
        }
    }
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
        }
        updateDisplays()
    }
    
    func updateDisplays() {
        displayValue = brain.result
        historyValue = brain.history
    }
    
    @IBAction private func clear() {
        brain.clear()
        displayValue = brain.result
        historyValue = brain.history
        userIsInTheMiddleOfTyping = false
    }
}


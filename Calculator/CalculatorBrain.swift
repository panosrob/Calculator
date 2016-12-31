//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Panagiotis Rompolas on 01/10/2016.
//  Copyright © 2016 Panagiotis Rompolas. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private var accumulator = 0.0
    
    private var description = " "
    
    private var previousOperation: Operation = .Equals
    
    private var programItems = [AnyObject]()
    
    var isPartialResult: Bool {
        get {
            return pending != nil || description.isEmpty || description == " "
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
    var history: String {
        get {
            return description
        }
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOperation(sqrt),
        "+/-" : Operation.UnaryOperation({ -$0 }),
        "ln" : Operation.UnaryOperation({ log($0) }),
        "log₁₀" : Operation.UnaryOperation({ log10($0) }),
        "sin" : Operation.UnaryOperation(sin),
        "tan" : Operation.UnaryOperation(tan),
        "1/x" : Operation.UnaryOperation({ 1 / $0 }),
        "x²" : Operation.UnaryOperation({ pow($0, Double(2)) }),
        "x³" : Operation.UnaryOperation({ pow($0, Double(3)) }),
        "xʸ" : Operation.BinaryOperation({ pow($0, $1) }),
        "×" : Operation.BinaryOperation({ $0 * $1 }),
        "÷" : Operation.BinaryOperation({ $0 / $1 }),
        "+" : Operation.BinaryOperation({ $0 + $1 }),
        "−" : Operation.BinaryOperation({ $0 - $1 }),
        "=" : Operation.Equals
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    private func appendToDescription(_ operation:String) {
        description = description + operation
    }
    
    func setOperand(operand: Double) {
        programItems.append(operand as AnyObject)
        accumulator = operand
    }
    
    func performOperation(symbol: String) {
        programItems.append(symbol as AnyObject)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
                previousOperation = operation;
            case .UnaryOperation(let function):
                if isPartialResult {
                    appendToDescription(symbol + "(" + String(accumulator) + ")")
                } else {
                    description = symbol + "(" + description.replacingOccurrences(of: "=", with: "") + ")"
                }
                accumulator = function(accumulator)
                previousOperation = operation;
            case .BinaryOperation(let function):
                if isPartialResult {
                    switch previousOperation {
                        case .BinaryOperation(_):
                            appendToDescription(String(accumulator))
                        case .Equals:
                            appendToDescription(String(accumulator))
                        default:
                            break
                    }
                    
                }
                
                appendToDescription(symbol)
                
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                previousOperation = operation;
            case .Equals:
                if isPartialResult {
                    switch previousOperation {
                        case .BinaryOperation(_):
                            appendToDescription(String(accumulator))
                        case .Equals:
                            appendToDescription(String(accumulator))
                        default:
                            break
                    }
                    executePendingBinaryOperation()
                    previousOperation = operation;
                }
                
            }
        }
    }
    
    private func executePendingBinaryOperation(){
        if isPartialResult {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    func clear()
    {
        accumulator = 0.0
        description = " "
        pending = nil
        previousOperation = .Equals
    }
}

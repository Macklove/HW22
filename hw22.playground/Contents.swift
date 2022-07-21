//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import Foundation

//Chip
import Foundation

public struct Chip {
    public enum ChipType: UInt32 {
        case small = 1
        case medium
        case big
    }
    
    public let chipType: ChipType
    
    public static func make() -> Chip {
        guard let chipType = Chip.ChipType(rawValue: UInt32(arc4random_uniform(3) + 1)) else {
            fatalError("Incorrect random value")
        }
        
        return Chip(chipType: chipType)
    }
    
    public func sodering() {
        let soderingTime = chipType.rawValue
        sleep(UInt32(soderingTime))
    }
}

//Stack
class Stack {

    private var stack = [Chip]()
    private let concurrentQueue = DispatchQueue(label: "concurrent-queue", qos: .utility, attributes: .concurrent)
    var count: Int { stack.count }

    func addChip(_ chip: Chip) {
        concurrentQueue.async(flags: .barrier) { [unowned self] in
            self.stack.append(chip)
            print ("Микросхема размером \(chip.chipType) взята на обработку. Остаток: \(getAllChips())")
        }
    }

    func grabChip() -> Chip? {
        var chip: Chip?
        concurrentQueue.sync { [unowned self] in
            guard let grabbedChip = self.stack.popLast() else { return }
            chip = grabbedChip
            print("Микросхема размером \(grabbedChip.chipType) подготовлена. Остаток: \(getAllChips())")
        }
        return chip
    }

    func getAllChips() -> [UInt32] {
        stack.compactMap { $0.chipType.rawValue }
    }
}

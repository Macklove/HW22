import UIKit
import PlaygroundSupport
import Foundation

//Chip
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

//Thread
class WorkingThread: Thread {
    
    private var stack: Stack
    private let count: Int
    private let interval: Double
    
    init(stack: Stack, count: Int = 10, interval: Double = 2) {
        self.stack = stack
        self.count = count
        self.interval = interval
    }
    
    override func main() {
        for _ in 1...count {
            let chip = createChip()
            stack.addChip(chip)
            Thread.sleep(forTimeInterval: interval)
        }
        cancel()
        print("WorkingThread cancel")
    }
    
    private func createChip() -> Chip {
        let chip = Chip.make()
        print("\nМикросхема размера \(chip.chipType) поступила. Остаток: \(stack.getAllChips())")
        return chip
    }
}

//Solder
class SolderThread: Thread {
    
    private var stack: Stack
    
    init(stack: Stack) { self.stack = stack }
    
    override func main() {
        while stack.count > 0 || !workingThread.isCancelled {
            doWork()
        }
        cancel()
        print("SolderThread cancel")
    }
    
    private func doWork() {
        guard let chip = stack.grabChip() else { return }
        solderChip(chip)
    }
    
    private func solderChip(_ chip: Chip) {
        chip.sodering()
        print ("Микросхема размером \(chip.chipType) припаяна. Остаток: \(stack.getAllChips())")
    }
}

//Work
let stack = Stack()
let workingThread = WorkingThread(stack: stack, interval: 1)
let solderThread = SolderThread(stack: stack)
workingThread.start()
solderThread.start()

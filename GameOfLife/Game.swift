//
//  Game.swift
//  GameOfLife
//
//  Created by Stas Kirichok on 06.04.15.
//  Copyright (c) 2015 Stas Kirichok. All rights reserved.
//

import Foundation

typealias GenerationMatrix = [Index : CellState]

protocol GameDelegate {
    func updateField(newGeneration matrix: GenerationMatrix)
}

class Game {
    
    private let cycleTime: Double = 0.5
    private var currentMatrix: GenerationMatrix!
    private var fieldSize: Int
    private let delegate: GameDelegate
    var isActive = false
    private(set) var generationCount: Int = 0
    
    init(seedMatrix: GenerationMatrix, delegate: GameDelegate) {
        self.currentMatrix = seedMatrix
        self.fieldSize = Int(sqrt(Float(seedMatrix.count)))
        self.delegate = delegate
    }
    
    func changeGameState() {
        self.changeGameState(isActive: !self.isActive)
    }
    
    func changeGameState(isActive state: Bool) {
        self.isActive = state
        if (self.isActive) {
            self.resume()
        }
    }
    
    func reset() {
        self.changeGameState(isActive: false)
        self.generationCount = 0
        for index in self.currentMatrix.keys {
            self.currentMatrix[index] = .Dead
        }
        self.delegate.updateField(newGeneration: self.currentMatrix)
    }
    
    func changeCurrentMatrix(atIndex index: Index, toState state: CellState) {
        self.currentMatrix[index] = state
    }
    
    //MARK: Game cycle
    
    private func resume() {
        if (!self.isActive) {
            return
        }
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(cycleTime * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            if (!self.isActive) {
                return
            }
            self.currentMatrix = self.calculateNextGenMatrix()
            self.generationCount++
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.delegate.updateField(newGeneration: self.currentMatrix)
                self.resume()
            })
        }
    }
    
    private func calculateNextGenMatrix() -> GenerationMatrix {
        var nextGen = GenerationMatrix()
        for (index, state) in self.currentMatrix {
            let aliveNeighBours = self.countAliveNeighbour(index)
            switch(aliveNeighBours) {
                case 0...1 where state == .Alive:
                 println("Died by under-population at index \(index)")
                nextGen[index] = .Dead
                case 2...3 where state == .Alive:
                    println("Still alive at index \(index)")
                    nextGen[index] = .Alive
                case 4...8 where state == .Alive:
                println("Died by overcrowding at index \(index)")
                nextGen[index] = .Dead
            case 3 where state == .Dead:
                println("Cell was born at index \(index)")
                nextGen[index] = .Alive
            default:
               nextGen[index] = .Dead
            }
        }
        
        return nextGen
    }
    
    private func countAliveNeighbour(index: Index) -> Int {
        let lowRow = index.row - 1
        let highRow = index.row + 1
        let lowColumn = index.column - 1
        let highColumn = index.column + 1
        var count = 0
        for row in lowRow...highRow {
            for column in lowColumn...highColumn {
                let currentIndex = Index(row: row, column: column)
                if (index == currentIndex) {
                    continue
                }
                let state = self.currentMatrix[currentIndex]
                if state != nil && state! == .Alive {
                    count++
                }
            }
        }
        
        return count
    }
    
}

struct Index: Hashable, Printable {
    var row: Int
    var column: Int
    
    var hashValue: Int {
        return row.hashValue ^ column.hashValue
    }
    
    var description: String {
       return "row: \(row) column: \(column)"
    }
}

func ==(lhs: Index, rhs: Index) -> Bool {
    return lhs.row == rhs.row && lhs.column == rhs.column
}

//
//  Game.swift
//  GameOfLife
//
//  Created by Stas Kirichok on 06.04.15.
//  Copyright (c) 2015 Stas Kirichok. All rights reserved.
//

import Foundation
import UIKit

typealias GenerationMatrix = [[CellState]]

enum GameOverVariant: String {
    case AllAreDead = "No cells has survived :("
    case AbsoluteStability = "Growth is stopped and nobody is dying now"
    case InfiniteCycle = "Oscillatory mode detected!"
    case ShowMustGoOn = ""
}

protocol GameDelegate {
    func updateField(newGeneration matrix: GenerationMatrix)
    func alarmCollapsedGame(reason: String)
}

class Game {
    
    private let cycleTime: Double = 0.35
    private var currentMatrix: GenerationMatrix!
    private let delegate: GameDelegate
    var isActive = false
    private(set) var generationCount: Int = 0
    private(set) var aliveCount: Int = 0
    
    init(seedMatrix: GenerationMatrix, delegate: GameDelegate) {
        self.currentMatrix = seedMatrix
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
        self.aliveCount = 0
        for row in 0..<self.currentMatrix.count {
            for column in 0..<self.currentMatrix[row].count {
                self.currentMatrix[row][column] = .Dead
            }
        }
        self.delegate.updateField(newGeneration: self.currentMatrix)
    }
    
    func changeCurrentMatrix(atIndex index: Index, toState state: CellState) {
        self.currentMatrix[index.row][index.column] = state
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
            let nextMatrix = self.calculateNextGenMatrix()
            let gameOverState = self.checkGameForCollapse(nextMatrix)
            self.currentMatrix = nextMatrix
            if (gameOverState != .ShowMustGoOn) {
                self.changeGameState()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.delegate.alarmCollapsedGame(gameOverState.rawValue)
                })
                return
            }
            self.generationCount++
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.delegate.updateField(newGeneration: self.currentMatrix)
                self.resume()
            })
        }
    }
    
    private func calculateNextGenMatrix() -> GenerationMatrix {
        var nextGen = GenerationMatrix(count:self.currentMatrix.count, repeatedValue:[CellState](count:self.currentMatrix[0].count, repeatedValue:CellState.Dead))
        self.aliveCount = 0
        for row in 0..<self.currentMatrix.count {
            for column in 0..<self.currentMatrix[row].count {
                let index = Index(row: row, column: column)
                let state = self.currentMatrix[row][column]
                let aliveNeighBours = self.countAliveNeighbour(index)
                switch(aliveNeighBours) {
                case 0...1 where state == .Alive:
                    println("Died by under-population at index \(index)")
                case 2...3 where state == .Alive:
                    println("Still alive at index \(index)")
                    nextGen[index.row][index.column] = .Alive
                    self.aliveCount++
                case 4...8 where state == .Alive:
                    println("Died by overcrowding at index \(index)")
                case 3 where state == .Dead:
                    println("Cell was born at index \(index)")
                    nextGen[index.row][index.column] = .Alive
                    self.aliveCount++
                default:
                    break
                }
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
                if (row < 0 || row >= self.currentMatrix.count || column < 0 || column >= currentMatrix[0].count) {
                    continue
                }
                let state = self.currentMatrix[row][column]
                if state == .Alive {
                    count++
                }
            }
        }
        
        return count
    }
    
    private func checkGameForCollapse(matrix: GenerationMatrix) -> GameOverVariant {
        if (self.aliveCount == 0) {
            return .AllAreDead
        }
        var isEqualToPrevious = true
        for row in 0..<self.currentMatrix.count {
            for column in 0..<self.currentMatrix[row].count {
                if (self.currentMatrix[row][column] != matrix[row][column]) {
                isEqualToPrevious = false
                break
            }
        }
        }
        
        return isEqualToPrevious ? .AbsoluteStability : .ShowMustGoOn
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

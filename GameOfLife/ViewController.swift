//
//  ViewController.swift
//  GameOfLife
//
//  Created by Stas Kirichok on 05.04.15.
//  Copyright (c) 2015 Stas Kirichok. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GameDelegate {
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var gameField: UIView!
    
    private let cellSize: CGFloat = 35
    private var cells: [Index : CellView]!
    private var game: Game!


    //MARK: View lifecycle
   
    override func viewDidLoad() {
        super.viewDidLoad()
       //  Do any additional setup after loading the view, typically from a nib.
        self.gameField.layer.borderWidth = 2
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (self.game == nil) {
            self.placeCellGrid()
            self.startBtn.hidden = false
            self.clearBtn.hidden = false
        }
    }
    
    //MARK: Update UI
    
    private func placeCellGrid() {
       let quantity = floor(self.gameField.bounds.width / cellSize)
       let leftover = self.gameField.bounds.width - quantity * cellSize
        self.cells = Dictionary<Index, CellView>()
        var seed = GenerationMatrix()
        for row in 0...Int(quantity) {
            for column in 0...Int(quantity) {
                let cell = CellView(frame: CGRectMake(leftover / 2 + CGFloat(column) * cellSize, leftover / 2 + CGFloat(row) * cellSize, cellSize, cellSize))
                self.gameField.addSubview(cell)
                let index = Index(row: row, column: column)
                self.cells[index] = cell
                seed[index] = .Dead
            }
        }
        
        let recognizer = UITapGestureRecognizer(target: self, action: Selector("tapField:"))
        self.gameField.addGestureRecognizer(recognizer)
        
        self.game = Game(seedMatrix: seed, delegate: self)
    }
    
    private func updateStartBtn() {
        self.startBtn.setTitle(self.game.isActive ? "Pause" : "Start", forState: UIControlState.Normal)
    }
    
    //MARK: Gesture actions
    
    func tapField(gesture: UIGestureRecognizer) {
       let tappedCell = self.gameField.hitTest(gesture.locationInView(self.gameField), withEvent: nil) as? CellView
        if (tappedCell != nil) {
            tappedCell!.changeCellState()
            let index = allKeysForValue(self.cells, val: tappedCell!).first!
            self.game.changeCurrentMatrix(atIndex: index, toState: tappedCell!.state)
        }
    }
    
    //MARK: Actions
    
    @IBAction func startAction(sender: AnyObject) {
        self.game.changeGameState()
        self.updateStartBtn()
    }

    @IBAction func clearAction(sender: AnyObject) {
        self.game.changeGameState(isActive: false)
        self.updateStartBtn()
        for cell in self.cells.values {
            cell.changeCellState(.Dead)
        }
    }
    
    //MARK: Game delegate
    
    func updateField(newGeneration matrix: GenerationMatrix) {
        for (index, cell) in self.cells {
            cell.changeCellState(matrix[index]!)
            self.game.changeCurrentMatrix(atIndex: index, toState: matrix[index]!)
        }
    }
    
    func allKeysForValue<K, V : Equatable>(dict: [K : V], val: V) -> [K] {
        return map(filter(dict) { $1 == val }) { $0.0 }
    }
}




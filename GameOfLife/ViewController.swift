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
    @IBOutlet weak var generationCounter: UILabel!
    @IBOutlet weak var headerView: UIView!
    
    private let cellSize: CGFloat = 10
    private var cells: [Index : CellView]!
    private var game: Game!


    //MARK: View lifecycle
   
    override func viewDidLoad() {
        super.viewDidLoad()
       //  Do any additional setup after loading the view, typically from a nib.
    
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let gradient = CAGradientLayer()
        gradient.frame = self.headerView.bounds;
        gradient.colors = [UIColor.lightGrayColor().CGColor, UIColor.whiteColor().CGColor]
        gradient.locations = [0.0, 1.0]
        self.headerView.layer.insertSublayer(gradient, atIndex: 0)
        if (self.game == nil) {
            self.placeCellGrid()
            self.startBtn.hidden = false
            self.clearBtn.hidden = false
        }
    }
    
    //MARK: Update UI
    
    private func placeCellGrid() {
       let columns = floor(self.gameField.bounds.width / cellSize)
    let rows = floor(self.gameField.bounds.height / cellSize)
       let xLeftover = self.gameField.bounds.width - columns * cellSize
        let yLeftover = self.gameField.bounds.height - rows * cellSize
        self.cells = Dictionary<Index, CellView>()
        var seed = GenerationMatrix(count:Int(rows), repeatedValue:[CellState](count:Int(columns), repeatedValue:CellState.Dead))
        for row in 0...Int(rows - 1) {
            for column in 0...Int(columns - 1) {
                let cell = CellView(frame: CGRectMake(xLeftover / 2 + CGFloat(column) * cellSize, yLeftover / 2 + CGFloat(row) * cellSize, cellSize, cellSize))
                self.gameField.addSubview(cell)
                let index = Index(row: row, column: column)
                self.cells[index] = cell
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
            tappedCell!.changeCellState(false)
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
        self.game.reset()
        self.updateStartBtn()
    }
    
    //MARK: Game delegate
    
    func updateField(newGeneration matrix: GenerationMatrix) {
        self.generationCounter.text = "Generation: \(self.game.generationCount)"
        for (index, cell) in self.cells {
            cell.changeCellState(matrix[index.row][index.column], animated: true)
            self.game.changeCurrentMatrix(atIndex: index, toState: matrix[index.row][index.column])
        }
    }
    
    func alarmCollapsedGame(reason: String) {
        self.updateStartBtn()
        let alertController = UIAlertController(title: "Game over", message: reason, preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func allKeysForValue<K, V : Equatable>(dict: [K : V], val: V) -> [K] {
        return map(filter(dict) { $1 == val }) { $0.0 }
    }
}




//
//  CellView.swift
//  GameOfLife
//
//  Created by Stas Kirichok on 05.04.15.
//  Copyright (c) 2015 Stas Kirichok. All rights reserved.
//

import Foundation
import UIKit

enum CellState {
    case Alive, Dead
}

class CellView: UIView {
    
    var state = CellState.Dead
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.applyState()
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.masksToBounds = true
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func changeCellState(state: CellState) {
        self.state = state
        self.applyState()
    }
    
    func changeCellState() {
        self.changeCellState(self.state == .Alive ? .Dead : .Alive)
    }
    
    private func applyState() {
        self.backgroundColor = state == .Alive ? UIColor.yellowColor() : UIColor.clearColor()
    }
    
}
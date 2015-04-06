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
    
    private let kAnimationTransition = 0.2
    
    var state = CellState.Dead
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.applyState(true)
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.masksToBounds = true
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeCellState(state: CellState, animated: Bool) {
        self.state = state
        self.applyState(animated)
    }
    
    func changeCellState(animated: Bool) {
        self.changeCellState(self.state == .Alive ? .Dead : .Alive, animated: animated)
    }
    
    private func applyState(animated: Bool) {
        UIView.transitionWithView(self, duration: animated ? kAnimationTransition : 0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.backgroundColor = self.state == .Alive ? UIColor.yellowColor() : UIColor.darkGrayColor()
            }, completion: nil)
    }
    
}
//
//  ViewController.swift
//  OpticScroll
//
//  Created by Shynkarenko Volodymyr on 4/11/19.
//  Copyright © 2019 Shynkarenko Volodymyr. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    lazy var newOptic : MyColorScroll = MyColorScroll()
    lazy var otherOptic : MyColorScroll = MyColorScroll()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let screenSize = self.view.frame.size
        let screenSize1 = CGRect.init(x: 50, y:screenSize.height/4, width: screenSize.width - 100, height: 50)
        self.otherOptic = MyColorScroll(frame: screenSize1)
        self.otherOptic.addTarget(self, action: #selector(changeWidth(_:)), for: .valueChanged)
        self.view.addSubview(otherOptic)
        print("Other: \(self.otherOptic.frame), \(self.otherOptic.layer.frame)")
        let screenSize2 = CGRect.init(x: 0, y: screenSize.height/2, width: screenSize.width, height: 70)
        self.newOptic = MyColorScroll(frame: screenSize2)
        self.newOptic.scrollColors.values = [UIColor.brown, UIColor.red, UIColor.yellow, UIColor.gray]
        self.view.addSubview(newOptic)
        
    }
    
    @objc private func changeWidth (_ sender: Any) {
        self.newOptic.lineWidth  = self.newOptic.frame.height * CGFloat(self.otherOptic.value)
        self.newOptic.redraw()
    }

}


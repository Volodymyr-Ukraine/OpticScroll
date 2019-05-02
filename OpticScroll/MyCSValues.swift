//
//  MyCSValues.swift
//  OpticScroll
//
//  Created by Vladimir on 5/1/19.
//  Copyright © 2019 Vova Abdula. All rights reserved.
//

import UIKit

class MyCSValues<Value> {
    // MARK: This class is for MyColorScroll's needs only. If you don't use MyColorScroll - delete this file from project
    // MARK: -
    // MARK: Properties
    
    public lazy var valueChanged : ()->() = {}
    public var values: [Value] {
        get {
            return self.valuesArray
        }
        set (newValues) {
            
            self.valuesArray = newValues
            self.valueChanged()
        }
    }
    private var valuesArray: [Value] = []
    
    // MARK: -
    // MARK: Initializer
    
    public init (values : [Value], doIfValueChenged toDo: @escaping ()->() ) {
        self.valuesArray = values
        self.valueChanged = toDo
    }
}

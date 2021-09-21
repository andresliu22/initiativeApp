//
//  Preset.swift
//  Initiative
//
//  Created by Andres Liu on 12/14/20.
//

import Foundation

class Preset: NSObject, NSCoding{
    var name: String
    var data: [[Int]]
    
    init(name: String, data: [[Int]]) {
        self.name = name
        self.data = data
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let data = aDecoder.decodeObject(forKey: "data") as! [[Int]]
        self.init(name: name, data: data)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(data, forKey: "data")
    }
}

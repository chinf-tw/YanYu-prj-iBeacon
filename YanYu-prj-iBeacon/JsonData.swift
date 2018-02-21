//
//  JsonData.swift
//  SeachBlueTooth
//
//  Created by 洪權甫 on 2018/1/23.
//  Copyright © 2018年 洪權甫. All rights reserved.
//

import Foundation

class JsonData{
    
    func run(json: Data){
        
        let decoder = JSONDecoder()
        do {
            
            if let product = try decoder.decode([String:Array<String>]?.self, from: json){
                print(product.forEach({ (key,value) in
                    print("\(key) : \(value)")
                })) // Prints "Durian"
            }
        }catch{
            print("Decoder Error")
        }
    }
    
    func getData(json: Data) -> [String : Array<String>]?{
        let decoder = JSONDecoder()
        do {
            if let product = try decoder.decode([String:Array<String>]?.self, from: json){
                return product
            }
        }catch let error{
            print("Decoder Error : \(error)")
        }
        return nil
    }
    
}

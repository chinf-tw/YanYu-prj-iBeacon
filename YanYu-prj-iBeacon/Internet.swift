//
//  Internet.swift
//  YanYu-prj-iBeacon
//
//  Created by 洪權甫 on 2018/2/21.
//  Copyright © 2018年 洪權甫. All rights reserved.
//

import Foundation

class DataTask: NSObject{
    
    
    func requestWithModel(stringURL: String, httpBody: Data, model: Model.HTTP, completion: @escaping (Data) -> Void){
        let url = URL(string: stringURL)!
        var request = URLRequest(url: url)
        
        request.httpBody = httpBody
        request.httpMethod = model.rawValue
        fetchedDataByDataTask(from: request, completion: completion)
    }
    
    
    // https://medium.com/@jerrywang0420/urlsession-教學-swift-3-ios-part-2-a17b2d4cc056
    private func fetchedDataByDataTask(from request: URLRequest, completion: @escaping (Data) -> Void){
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            if error != nil{
                print(error as Any)
            }else{
                guard let data = data else{return}
                completion(data)
            }
        }
        task.resume()
    }
}

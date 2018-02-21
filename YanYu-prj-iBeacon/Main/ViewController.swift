//
//  ViewController.swift
//  YanYu-prj-iBeacon
//
//  Created by 洪權甫 on 2018/2/21.
//  Copyright © 2018年 洪權甫. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var LoginText: UILabel!
    @IBOutlet weak var UserID: UITextField!
    @IBOutlet weak var PassWord: UITextField!
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBAction func LoginClick(_ sender: Any) {
        
        activity.startAnimating()
        
        let username = UserID.text
        let password = PassWord.text
        
        if ((username?.isEmpty)! || (password?.isEmpty)!){
            return
        }
        
        DoLoign(username!, password!)
    }
    let content = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserID.delegate = self
        PassWord.delegate = self
        UserID.returnKeyType = UIReturnKeyType.next
        PassWord.returnKeyType = UIReturnKeyType.send
        
        LoginText.text = content
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func DoLoign (_ user:String,_ pwd:String){
        let url = URL(string: "https://yanyu-chinf.azurewebsites.net/api/login")
        let session = URLSession.shared
        let paramToSend = "UserName=" + user + "&PassWord=" + pwd
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        request.httpBody = paramToSend.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let data:Data = data else {
                print("CHINF : Data is Error.")
                return
            }
            DispatchQueue.main.sync(execute: {
                self.activity.stopAnimating()
            })
            
            
            let response = String(data:data,encoding:String.Encoding.utf8)
            if (response == "Loign-success") {
                
                UserDefaults.standard.set(true, forKey: "session")
                
                DispatchQueue.main.sync(execute: {
                    self.LoginDone()
                })
            }else{
                let alertController = UIAlertController(title:"登入錯誤",message: "帳號或密碼錯誤，請重新試一次。", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController,animated: true, completion: nil)
            }
        }
        task.resume()
    }
    
    func LoginDone(){
        /*
         Segue作法
         self.performSegue(withIdentifier: "showTo", sender: nil)
         print(UserDefaults.standard.bool(forKey: "session"))
         */
        let storyboard = UIStoryboard(name: "List", bundle: nil)
        let viewcontroller = storyboard.instantiateViewController(withIdentifier: "List")
        self.present(viewcontroller, animated: true, completion: nil)
    }

    //鍵盤
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        switch textField {
        case UserID:
            PassWord.becomeFirstResponder()
        case PassWord:
            LoginClick((Any).self)
        default:
            print("textFirld Error")
        }
        return true
    }

}


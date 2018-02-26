//
//  ReportTableViewCell.swift
//  YanYu-prj-iBeacon
//
//  Created by 洪權甫 on 2018/2/26.
//  Copyright © 2018年 洪權甫. All rights reserved.
//

import UIKit

class ReportTableViewCell: UITableViewCell {

    
    @IBOutlet weak var reportImage: UIImageView!
    @IBOutlet weak var ReportTitle: UILabel!
    @IBOutlet weak var reportBody: UILabel!
    @IBOutlet weak var reportLocation: UILabel!
    @IBOutlet weak var status: UIView!
    @IBOutlet weak var reportID: UILabel!
    @IBOutlet weak var cardView: CardView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        status.layer.cornerRadius = status.frame.size.width/2
        status.clipsToBounds = true
        
        reportImage.layer.cornerRadius = reportImage.frame.size.width/2
        reportImage.clipsToBounds = true
    }
    
    func isStatus (_ isbegin: Bool){
        if isbegin {
            status.backgroundColor = UIColor.green
        }else{
            status.backgroundColor = UIColor.red
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

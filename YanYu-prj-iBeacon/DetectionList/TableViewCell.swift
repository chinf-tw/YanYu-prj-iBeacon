//
//  TableViewCell.swift
//  YanYu-prj-iBeacon
//
//  Created by 洪權甫 on 2018/2/21.
//  Copyright © 2018年 洪權甫. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var ID: UILabel!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var Body: UILabel!
    @IBOutlet weak var Location: UILabel!
    @IBOutlet weak var New: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

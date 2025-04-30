//
//  ListCell.swift
//  Shelf
//
//  Created by Sk Jasimuddin on 30/04/25.
//

import UIKit

class ListCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var lblPublisher: UILabel!
    @IBOutlet weak var lblIsbn: UILabel!
    @IBOutlet weak var lblPage: UILabel!
    
    @IBOutlet weak var vwContainer: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        vwContainer.layer.cornerRadius = 12
        vwContainer.layer.borderWidth = 1
        vwContainer.layer.borderColor = UIColor.tintColor.cgColor
        vwContainer.layer.backgroundColor = UIColor.systemBrown.cgColor
     
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepaireCell(_ data:Datum){
        self.title.text = data.title
        self.lblPublisher.text = data.publisher
        self.lblIsbn.text = data.isbn
        self.lblPage.text = "\(data.pages ?? 0)"
    }
    
}

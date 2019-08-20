//
//  NoteTableViewCell.swift
//  Note
//
//  Created by Максим Бачурин on 18/07/2019.
//  Copyright © 2019 Максим Бачурин. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {

    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainTextLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = colorView.backgroundColor
        super.setSelected(selected, animated: animated)
        if selected {
            colorView.backgroundColor = color
        }
        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = colorView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            colorView.backgroundColor = color
        }
    }
    
    func configure(note: Note) {
        colorView.backgroundColor = note.color
        colorView.layer.cornerRadius = colorView.frame.width/2
        titleLabel.text = note.title
        mainTextLabel.text = note.content
    }
    
}

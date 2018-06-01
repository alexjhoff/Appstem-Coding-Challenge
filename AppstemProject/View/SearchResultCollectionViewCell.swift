//
//  SearchResultCollectionViewCell.swift
//  AppstemProject
//
//  Created by Alex Hoff on 5/31/18.
//

import UIKit

class SearchResultCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var resultLabel: UILabel!
    
    var item: ImageSearchViewModelItem? {
        didSet {
            guard let item = item as? SearchResultItem else { return }
            
            if item.wasCorrected {
                resultLabel.text = "Did you mean \(item.term)?"
            } else {
                resultLabel.text = "Search result for \(item.term)"
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}

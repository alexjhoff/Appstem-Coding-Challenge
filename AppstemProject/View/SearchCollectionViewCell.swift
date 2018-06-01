//
//  SearchCollectionViewCell.swift
//  AppstemProject
//
//  Created by Alex Hoff on 5/31/18.
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    weak var viewModel: ImageSearchViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: searchField.frame.height))
        searchField.leftView = paddingView
        searchField.leftViewMode = .always
        searchField.layer.cornerRadius = 5
        searchButton.layer.cornerRadius = 5
    }

    @IBAction func sendTapped(_ sender: Any) {
        guard let text = searchField.text else { return }
        viewModel?.getImagesWithQuery(text, completion: {})
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}

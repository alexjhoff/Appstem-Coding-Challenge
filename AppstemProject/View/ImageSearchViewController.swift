//
//  ViewController.swift
//  AppstemProject
//
//  Created by Alex Hoff on 5/29/18.
//

import UIKit

class ImageSearchViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel: ImageSearchViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
    }

    fileprivate func configureCollectionView() {
        // Assign the dataSource and delegate function responsibility to the view model
        viewModel.delegate = self
        collectionView.dataSource = viewModel
        collectionView.delegate = viewModel
        
        // Register collection view cells
        collectionView.register(ImageCollectionViewCell.nib, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        collectionView.register(SearchCollectionViewCell.nib, forCellWithReuseIdentifier: SearchCollectionViewCell.identifier)
        collectionView.register(SearchResultCollectionViewCell.nib, forCellWithReuseIdentifier: SearchResultCollectionViewCell.identifier)
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ImageModalViewController,
            let image = sender as? UIImage {
            vc.item = image
        }
    }
}

extension ImageSearchViewController: ImageViewProtocol {
    func reloadView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func pushModalViewWithImage(_ image: UIImage) {
//        let modalView = ImageModalViewController()
//        modalView.item = image
//        present(modalView, animated: true, completion: nil)
        
        self.performSegue(withIdentifier: "showModalView", sender: image)
    }
}


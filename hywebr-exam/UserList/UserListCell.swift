//
//  UserListCell.swift
//  hywebr-exam
//
//  Created by Dong on 2023/2/22.
//

import UIKit

class UserListCell: UICollectionViewCell {
    
    //MARK: - Typealias
    typealias FavoriteBtnHandler = ((IndexPath)->())
    
    //MARK: - Variables
    var indexPath: IndexPath?
    var favoriteBtnHandler: FavoriteBtnHandler?
    
    @IBOutlet weak var favoriteBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    //MARK: - Actions
    @IBAction func favoriteBtnPressed(_ sender: Any) {
        if let favoriteBtnHandler, let indexPath {
            favoriteBtnHandler(indexPath)
        }
    }
    
    func setup(_ book: Book, indexPath: IndexPath, favoriteBtnHandler: @escaping FavoriteBtnHandler) {
        self.indexPath = indexPath
        self.favoriteBtnHandler = favoriteBtnHandler
        
        titleLabel.text = book.title
        
        if let urlString = book.coverUrl, let url = URL(string: urlString) {
            ImageCache.shared.image(for: url, handler: {[weak self] image, error in
                guard let self else {return}
                if let image {
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }else if let error {
                    print(error.localizedDescription)
                }
            })
        }
        
        let imageNamed = book.isFavorite ? "icon_heart_fill" : "icon_heart"
        favoriteBtn.setImage(UIImage(named: imageNamed), for: .normal)
    }
}

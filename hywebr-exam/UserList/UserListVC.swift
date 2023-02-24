//
//  UserListVC.swift
//  hywebr-exam
//
//  Created by Dong on 2023/2/22.
//

import UIKit

class UserListVC: UIViewController {

    //MARK: - Variables
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let viewModel = UserListViewModel()
    private let cellIdentifier = "UserListCell"
    private let itemSpacing: CGFloat = 8
    private let numberOfLine: CGFloat = 3
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadData()
    }
    
    //MARK: - Action
    @objc private func backBtnPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    //MARK: - Setup ViewModel
    private func setupViewModel() {
        viewModel.alert = alert(_:)
        viewModel.reloadCollectionView = reloadCollectionView
        viewModel.reloadCollectionViewCell = reloadCollectionViewCell(_:)
    }
    
    //MARK: - Setup Views
    private func setupViews() {
        title = "User List"
        setupNavigationBar()
        setupCollectionView()
        collectionView.isHidden = true
        indicatorView.isHidden = false
    }
    
    private func setupNavigationBar() {
        navigationItem.setHidesBackButton(true, animated: false)
        let backBtn = UIBarButtonItem(image: UIImage(named: "btn_close"), style: .plain, target: self, action: #selector(backBtnPressed))
        backBtn.tintColor = .black
        navigationItem.rightBarButtonItem = backBtn
    }
    
    private func setupCollectionView() {
        collectionView.register(UINib(nibName: "UserListCell", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        
        let layout = UICollectionViewFlowLayout()
        let screenWidth = UIScreen.main.bounds.size.width
        let itemWidth = (screenWidth - itemSpacing * (numberOfLine)) / numberOfLine
        let itemHeight = itemWidth / 110 * 196
        layout.minimumLineSpacing = itemSpacing * 2
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        collectionView.collectionViewLayout = layout
    }
}

//MARK: - UICollectionView Data Source / Delegate
extension UserListVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.count()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? UserListCell,
            let book = viewModel.item(at: indexPath.row)
        else {
            return UICollectionViewCell()
        }
        cell.setup(book, indexPath: indexPath, favoriteBtnHandler: viewModel.favoriteBtnPressed(_:))
        return cell
    }
}

//MARK: - ViewModel Actions
extension UserListVC {
    private func alert(_ text: String) {
        indicatorView.isHidden = true
        let alert = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func reloadCollectionView() {
        collectionView.reloadData()
        collectionView.isHidden = false
        indicatorView.isHidden = true
    }
    
    private func reloadCollectionViewCell(_ indexPath: IndexPath) {
        collectionView.reloadItems(at: [indexPath])
    }
}

//
//  UserListViewModel.swift
//  hywebr-exam
//
//  Created by Dong on 2023/2/22.
//

import Foundation

class UserListViewModel {
    
    //MARK: - Struct
    struct BookCodable: Codable {
        let uuid: Int64?
        let title: String?
        let coverUrl: String?
        let publishDate: String?
        let publisher: String?
        let author: String?
    }
    
    //MARK: - Variables
    var alert: ((String)->())?
    var reloadCollectionView: (()->())?
    var reloadCollectionViewCell: ((IndexPath)->())?
    
    private let dataService = CoreDataService<Book>(entityName: "Book", databaseName: "UserList", sortKey: "uuid")
    
    //MARK: - Action
    func loadData() {
        APIService<[BookCodable]>().get(with: APIURL.user_list, completionHandler: {[weak self] result in
            guard let self else {return}
            if result.errorType == .noError {
                self.save(with: result.data ?? [])
            }else if let errorMessage = result.errorMessage {
                if let alert = self.alert {
                    DispatchQueue.main.async {
                        alert(errorMessage)
                    }
                }
            }
        })
    }
    
    func count() -> Int {
        return dataService.get().count
    }

    func item(at index: Int) -> Book? {
        let books = dataService.get()
        if index < books.count {
            return books[index]
        }else {
            return nil
        }
    }
    
    func favoriteBtnPressed(_ indexPath: IndexPath) {
        guard let book = item(at: indexPath.row), let reloadCollectionViewCell else {return}
        book.isFavorite.toggle()
        dataService.save()
        reloadCollectionViewCell(indexPath)
    }
}

//MARK: - CoreData
extension UserListViewModel {
    private func save(with list: [BookCodable]) {
        list.forEach({renew($0)})
        if let reloadCollectionView {
            DispatchQueue.main.async {
                reloadCollectionView()
            }
        }
    }

    private func renew(_ item: BookCodable) {
        guard let uuid = item.uuid else {return}
        let predicate = NSPredicate(format: "uuid=%d", uuid)
        var book: Book!
        if let savedBook = dataService.get(predicate).first {
            book = savedBook
        }else if let newBook = dataService.new() {
            newBook.uuid = Int64(uuid)
            book = newBook
        }
        guard book != nil else {
            assertionFailure("Fail to save data")
            return
        }
        book.title = item.title
        book.coverUrl = item.coverUrl
        book.publishDate = item.publishDate
        book.publisher = item.publisher
        book.author = item.author
        dataService.save()
    }
}

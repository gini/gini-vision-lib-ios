//
//  AlbumsPickerViewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/26/18.
//

import Foundation

protocol AlbumsPickerViewControllerDelegate: class {
    func albumsPicker(_ viewController: AlbumsPickerViewController,
                      didSelectAlbum album: Album)
}

final class AlbumsPickerViewController: UIViewController {
    
    weak var delegate: AlbumsPickerViewControllerDelegate?
    let galleryManager: GalleryManagerProtocol
    
    lazy var albumsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "GiniAlbumsPickerTableViewCellIdentifier")
        return tableView
    }()
    
    init(galleryManager: GalleryManagerProtocol) {
        self.galleryManager = galleryManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        title = "Albums"
        view.addSubview(albumsTableView)
        Constraints.pin(view: albumsTableView, toSuperView: view)
    }
    
}

// MARK: UITableViewDataSource

extension AlbumsPickerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return galleryManager.albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GiniAlbumsPickerTableViewCellIdentifier")
        cell?.textLabel?.text = galleryManager.albums[indexPath.row].title
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

// MARK: UITableViewDelegate

extension AlbumsPickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.albumsPicker(self, didSelectAlbum: galleryManager.albums[indexPath.row])
    }
}

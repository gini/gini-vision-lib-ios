//
//  AlbumsPickerTableViewCell.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/27/18.
//

import Foundation

final class AlbumsPickerTableViewCell: UITableViewCell {
    
    static let identifier = "AlbumsPickerTableViewCellIdentifier"
    static let height: CGFloat = 90.0
    let padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    lazy var albumAccesoryView: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImageNamedPreferred(named: "disclosureIndicator"), for: .normal)
        return button
    }()
    
    lazy var albumThumbnailView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowRadius = 1
        imageView.layer.shadowOpacity = 0.5
        imageView.layer.shadowOffset = CGSize(width: -2, height: 2)
        
        return imageView
    }()
    
    lazy var albumTitleLabel: UILabel = {
        let albumTitle = UILabel(frame: .zero)
        albumTitle.translatesAutoresizingMaskIntoConstraints = false
        
        return albumTitle
    }()
    
    lazy var albumSubTitleLabel: UILabel = {
        let albumSubTitle = UILabel(frame: .zero)
        albumSubTitle.translatesAutoresizingMaskIntoConstraints = false
        albumSubTitle.textColor = .lightGray
        
        return albumSubTitle
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        addSubview(albumAccesoryView)
        addSubview(albumThumbnailView)
        addSubview(albumTitleLabel)
        addSubview(albumSubTitleLabel)
        addConstraints()
    }
    
    private func addConstraints() {
        // albumThumbnailView
        Constraints.active(item: albumThumbnailView, attr: .leading, relatedBy: .equal, to: self, attr: .leading,
                           constant: padding.left)
        Constraints.active(item: albumThumbnailView, attr: .top, relatedBy: .equal, to: self, attr: .top, constant:
            padding.top)
        Constraints.active(item: albumThumbnailView, attr: .bottom, relatedBy: .equal, to: self, attr: .bottom,
                           constant: -padding.bottom)
        Constraints.active(item: albumThumbnailView, attr: .trailing, relatedBy: .equal, to: albumTitleLabel,
                           attr: .leading, constant: -20)
        Constraints.active(item: albumThumbnailView, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                           constant: 70)
        Constraints.active(item: albumThumbnailView, attr: .width, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                           constant: 70)
        
        // albumAccesoryView
        Constraints.active(item: albumAccesoryView, attr: .leading, relatedBy: .equal, to: albumTitleLabel,
                           attr: .trailing, constant: padding.left, priority: 999)
        Constraints.active(item: albumAccesoryView, attr: .top, relatedBy: .equal, to: self, attr: .top,
                           constant: padding.top)
        Constraints.active(item: albumAccesoryView, attr: .bottom, relatedBy: .equal, to: self, attr: .bottom,
                           constant: -padding.bottom)
        Constraints.active(item: albumAccesoryView, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing,
                           constant: -padding.left)
        
        // albumTitleLabel
        Constraints.active(item: albumTitleLabel, attr: .centerY, relatedBy: .equal, to: self, attr: .centerY,
                           constant: -padding.top)
        Constraints.active(item: albumTitleLabel, attr: .bottom, relatedBy: .equal, to: albumSubTitleLabel,
                           attr: .top, constant: -5)
        
        // albumSubTitleLabel
        Constraints.active(item: albumSubTitleLabel, attr: .bottom, relatedBy: .lessThanOrEqual, to: self,
                           attr: .bottom, constant: 0)
        Constraints.active(item: albumSubTitleLabel, attr: .leading, relatedBy: .equal, to: albumTitleLabel,
                           attr: .leading)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp(with album: Album, giniConfiguration: GiniConfiguration, galleryManager: GalleryManagerProtocol) {
        albumTitleLabel.text = album.title
        albumSubTitleLabel.text = "\(album.count)"
        albumTitleLabel.font = giniConfiguration.customFont.regular.withSize(16)
        albumSubTitleLabel.font = giniConfiguration.customFont.regular.withSize(12)
        
        galleryManager.fetchImage(from: album,
                                  at: album.assets.count - 1,
                                  imageQuality: .thumbnail) {[weak self] image, _ in
            guard let `self` = self else { return }
            self.albumThumbnailView.image = image
        }
    }
}

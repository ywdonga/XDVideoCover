//
//  XDVideoCoverCell.swift
//  XDVideoCover
//
//  Created by dyw on 2023/2/24.
//

import UIKit
import AVFoundation

class XDVideoCoverCell: UICollectionViewCell {
 
    private lazy var imgView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        return v
    }()
    
    private var model: XDCoverModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(asset: AVAsset, model: XDCoverModel) {
        self.model = model
        if let img = self.model?.image {
            imgView.image = img
        } else {
            XDCoverTool.requestImage(from: asset, time: model.requestTime) { [weak self] img, time in
                if self?.model?.requestTime == time {
                    self?.model?.image = img
                    self?.imgView.image = img
                }
            }
        }
    }
    
}

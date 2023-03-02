//
//  XDProgressView.swift
//  XDVideoCover
//
//  Created by dyw on 2023/2/27.
//

import UIKit

class XDProgressView: UIView {
    private lazy var bgView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.borderColor = UIColor.white.cgColor
        v.layer.borderWidth = 2
        v.layer.cornerRadius = 4
        return v
    }()
    
    private lazy var timeLabel: UILabel = {
       let lb = UILabel()
        lb.textColor = .white
        lb.font = .systemFont(ofSize: 14)
        lb.text = "00:00"
        return lb
    }()
    
    private lazy var linView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    
    var seconds: Double = 0 {
        didSet {
            timeLabel.text = seconds.secondMS()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(56)
            make.top.bottom.equalTo(0)
        }
        
        bgView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(bgView.snp.bottom)
            make.height.equalTo(30)
        }
        
        bgView.addSubview(linView)
        linView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(1)
            make.top.bottom.equalTo(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

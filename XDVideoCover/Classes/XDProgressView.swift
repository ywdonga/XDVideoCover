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
        v.backgroundColor = .white.withAlphaComponent(0.5)
        return v
    }()
    
    private lazy var timeLabel: UILabel = {
       let lb = UILabel()
        lb.font = .systemFont(ofSize: 14)
        lb.text = "00:00"
        return lb
    }()
    
    private lazy var linView: UIView = {
        let v = UIView()
        v.backgroundColor = .blue
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
            make.width.equalTo(30)
            make.top.bottom.equalTo(0)
        }
        
        bgView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(bgView.snp.top)
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

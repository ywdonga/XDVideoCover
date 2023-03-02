//
//  XDVideoCoverVC.swift
//  XDVideoCover
//
//  Created by dyw on 2023/2/23.
//

import UIKit
import AVFoundation
import SnapKit
import XDPlayer

public class XDVideoCoverVC: UIViewController {
    
    private var player = XDPlayer()
    private var urlStr: String
    private var dataSourcs = [XDCoverModel]()
    private var lastNavHind: Bool = true
    
    public var snapshotBlock: ((UIImage)->())?
    
    public init(urlStr: String) {
        self.urlStr = urlStr
        super.init(nibName: nil, bundle: nil)
        player.muted = true
        player.playbackLoops = true
        player.autoplay = true
        player.playerDelegate = self
        player.playbackDelegate = self
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        player.willMove(toParent: nil)
        player.view.removeFromSuperview()
        player.removeFromParent()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        lastNavHind = navigationController?.navigationBar.isHidden ?? true
        configUI()
        loadData()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
 
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(lastNavHind, animated: animated)
    }
    
    func configUI() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        navigationController?.navigationBar.isHidden = true
        navView.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.top.bottom.equalTo(0)
            make.left.equalTo(0)
        }

        navView.addSubview(doneBtn)
        doneBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-20)
            make.size.equalTo(CGSize(width: 44, height: 28))
        }
        
        navView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        view.addSubview(navView)
        navView.snp.makeConstraints { make in
            make.top.equalTo(safeInsets().top)
            make.left.right.equalTo(0)
            make.height.equalTo(44)
        }
        
        view.addSubview(player.view)
        player.view.snp.makeConstraints { make in
            make.top.equalTo(navView.snp.bottom)
            make.left.right.equalTo(0)
        }
        addChild(player)
        player.didMove(toParent: self)
        
        view.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { make in
            make.top.equalTo(player.view.snp.bottom)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(36)
        }
        
        view.addSubview(listView)
        listView.snp.makeConstraints { make in
            make.top.equalTo(tipsLabel.snp.bottom)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(56)
            make.bottom.equalTo(-safeInsets().bottom - 10)
        }
        
        view.addSubview(progress)
        progress.snp.makeConstraints { make in
            make.width.equalTo(0)
            make.top.equalTo(listView.snp.top)
            make.bottom.equalTo(listView.snp.bottom)
            make.centerX.equalTo(listView.snp.centerX)
        }
    }
    
    func loadData() {
        player.url = URL(string: urlStr)
        player.playFromCurrentTime()
        
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        player.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func loadCoverList() {
        let duration = player.maximumDuration
        var maxCount = Int(duration * 0.5)
        maxCount = max(maxCount, 4)
        maxCount = min(maxCount, 20)
        dataSourcs.removeAll()
        let spacing = duration / Float64(maxCount)
        var seconds: [Float64] = []
        for i in 0 ..< Int(maxCount) {
            seconds.append(Float64(i) * spacing)
        }
        dataSourcs.append(contentsOf: seconds.compactMap { sec in
            XDCoverModel(requestTime: CMTime(seconds: sec, preferredTimescale: timescale()))
        })
        listView.reloadData()
    }
    
    func timescale() -> CMTimeScale {
        player.asset?.duration.timescale ?? 600
    }
    
    func cellSize() -> CGSize {
        CGSize(width: 80, height: 60)
    }
    
    lazy var navView: UIView = {
        let v = UIView(frame: .zero)
        return v
    }()
    
    lazy var titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "选择封面"
        lb.font = UIFont.boldSystemFont(ofSize: 16)
        lb.textColor = .white
        return lb
    }()
    
    lazy var closeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        btn.setImage(XDCoverTool.getImg(with: "xd_close"), for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        btn.addTarget(self, action: #selector(closeBtnClick), for: .touchUpInside)
        return btn
    }()
    
    lazy var doneBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = UIColor(red: 0, green: 0.73, blue: 0.94, alpha: 1)
        btn.setTitle("保存", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 2
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        return btn
    }()

    lazy var tipsLabel: UILabel = {
        let lb = UILabel()
        lb.backgroundColor = .clear
        lb.text = "左右滑动，从视频中截取封面"
        lb.font = UIFont.systemFont(ofSize: 12)
        lb.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        return lb
    }()
    
    lazy var progress: XDProgressView = {
       let v = XDProgressView()
        return v
    }()
    
    lazy var listView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
        v.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        v.layer.cornerRadius = 2
        v.layer.masksToBounds = true
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        let sw = self.totalWidth()
        v.contentInset = UIEdgeInsets(top: 0, left: sw*0.5, bottom: 0, right: sw*0.5)
        v.register(XDVideoCoverCell.self, forCellWithReuseIdentifier: NSStringFromClass(XDVideoCoverCell.self))
        v.dataSource = self
        v.delegate = self
        return v
    }()
}

extension XDVideoCoverVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSourcs.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(XDVideoCoverCell.self), for: indexPath)
        if let cell = cell as? XDVideoCoverCell, let acc = player.asset {
            cell.setup(asset: acc, model: dataSourcs[indexPath.item])
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard player.playbackState != .playing, player.bufferingState != .unknown else {
            return
        }
        let length = cellSize().width * CGFloat(dataSourcs.count)
        var position = scrollView.contentOffset.x + totalWidth() * 0.5
        if position < 0 {
            progress.snp.updateConstraints { make in
                make.centerX.equalTo(listView.snp.centerX).offset(-position)
            }
        } else if position > length {
            progress.snp.updateConstraints { make in
                make.centerX.equalTo(listView.snp.centerX).offset(length - position)
            }
        }
        position = max(position, 0)
        position = min(position, Double(length))
        let percent = position / Double(length)
        var currentSecond = player.maximumDuration * Double(percent)
        currentSecond = max(currentSecond, 0)
        currentSecond = min(currentSecond, player.maximumDuration)
        let timescale = timescale()
        let currentTime = CMTimeMakeWithSeconds(currentSecond, preferredTimescale: timescale)
        player.seekToTime(to: currentTime, toleranceBefore: CMTimeMakeWithSeconds(0, preferredTimescale: timescale), toleranceAfter: CMTimeMakeWithSeconds(0, preferredTimescale: timescale))
        progress.seconds = currentSecond
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        player.pause()
    }
}

extension XDVideoCoverVC {
    
    @objc func handleTapGestureRecognizer(_ tap: UITapGestureRecognizer) {
        if player.playbackState == .playing {
            player.pause()
        } else if player.playbackState == .paused {
            player.playFromCurrentTime()
        }
    }
    
    @objc func closeBtnClick() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc func doneBtnClick() {
        XDCoverTool.requestImage(from: player.asset, time: CMTime(seconds: player.currentTimeInterval, preferredTimescale: timescale())) { [weak self] image, time in
            if let img = image {
                self?.snapshotBlock?(img)
                self?.navigationController?.popViewController(animated: true)
            } else {
                print("保存错误")
            }
        }
    }
}

// MARK: - PlayerDelegate
extension XDVideoCoverVC: XDPlayerDelegate {
    
    public func playerReady(_ player: XDPlayer) {
        print("\(#function) ready")
        loadCoverList()
    }
    
    public func playerPlaybackStateDidChange(_ player: XDPlayer) {
        print("\(#function) \(player.playbackState.description)")
    }
    
    public func playerBufferingStateDidChange(_ player: XDPlayer) {
        
    }
    
    public func playerBufferTimeDidChange(_ bufferTime: Double) {
        
    }
    
    public func player(_ player: XDPlayer, didFailWithError error: Error?) {
        print("\(#function) error.description")
    }
    
}

// MARK: - PlayerPlaybackDelegate
extension XDVideoCoverVC: XDPlayerPlaybackDelegate {
    
    public func playerCurrentTimeDidChange(_ player: XDPlayer) {
        guard !listView.isTracking, player.playbackState == .playing else { return }
        let fraction = player.currentTime.seconds / player.maximumDuration
        let length = cellSize().width * CGFloat(dataSourcs.count)
        let position = CGFloat(length) * CGFloat(fraction) - totalWidth() * 0.5
        listView.contentOffset = CGPoint(x: position, y: listView.contentOffset.y)
        progress.seconds = player.currentTime.seconds
    }
    
    public func playerPlaybackWillStartFromBeginning(_ player: XDPlayer) {
        
    }
    
    public func playerPlaybackDidEnd(_ player: XDPlayer) {
        
    }
    
    public func playerPlaybackWillLoop(_ player: XDPlayer) {
        
    }

    public func playerPlaybackDidLoop(_ player: XDPlayer) {
        
    }
}


extension XDVideoCoverVC {

    func safeInsets() -> UIEdgeInsets {
        UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
    }
    
    func totalWidth() -> CGFloat {
        return UIScreen.main.bounds.width - 40
    }
}

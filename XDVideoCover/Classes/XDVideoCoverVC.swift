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
        configUI()
        loadData()
    }
 
    func configUI() {
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneBtn)
        
        view.addSubview(player.view)
        player.view.snp.makeConstraints { make in
            make.top.equalTo(safeInsets().top)
            make.left.right.equalTo(0)
        }
        addChild(player)
        player.didMove(toParent: self)
        
        view.addSubview(listView)
        listView.snp.makeConstraints { make in
            make.top.equalTo(player.view.snp.bottom)
            make.left.right.equalTo(0)
            make.height.equalTo(60)
            make.bottom.equalTo(-safeInsets().bottom - 8)
        }
        
        view.addSubview(linView)
        linView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.height.equalTo(1)
            make.bottom.equalTo(listView.snp.top)
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
    
    lazy var doneBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        btn.setTitle("保存", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        btn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        return btn
    }()
    
    lazy var linView: UIView = {
        let v = UIView()
        v.backgroundColor = .lightGray
        return v
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
        v.backgroundColor = .white
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        let sw = UIScreen.main.bounds.width
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
        var position = scrollView.contentOffset.x + UIScreen.main.bounds.size.width * 0.5
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
    
    @objc func doneBtnClick() {
        player.takeSnapshot { [weak self] image, error in
            if let img = image {
                self?.snapshotBlock?(img)
                self?.navigationController?.popViewController(animated: true)
            } else {
                print(error?.localizedDescription ?? "保存错误")
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
        let position = CGFloat(length) * CGFloat(fraction) - UIScreen.main.bounds.size.width * 0.5
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
    
    internal func executeClosureOnMainQueue(withClosure closure: @escaping () -> Void) {
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async(execute: closure)
        }
    }
}

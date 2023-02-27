//
//  ViewController.swift
//  XDVideoCover
//
//  Created by 329720990@qq.com on 02/23/2023.
//  Copyright (c) 2023 329720990@qq.com. All rights reserved.
//

import UIKit
import XDVideoCover
import ZLPhotoBrowser

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func toCoverVC(url: String) {
        let vc = XDVideoCoverVC(urlStr: url)
        vc.snapshotBlock = { [weak self] img in
            self?.imageView.image = img
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func btnClick(_ sender: UIButton) {
        let isLocal = sender.tag == 1
        guard isLocal else {
            toCoverVC(url: "http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4")
            return
        }

        ZLPhotoConfiguration.default()
            .allowSelectVideo(true)
            .allowSelectImage(false)
            .maxSelectCount(1)
        
        let ps = ZLPhotoPreviewSheet()
        ps.selectImageBlock = { [weak self] resut, success in
            guard let asset = resut.first?.asset else {
                return
            }
            ZLVideoManager.exportVideo(for: asset) { [weak self] url, error in
                guard let url = url else { return }
                self?.toCoverVC(url: url.absoluteString)
            }
        }
        ps.showPhotoLibrary(sender: self)
    }
    
}


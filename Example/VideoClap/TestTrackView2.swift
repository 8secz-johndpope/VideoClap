//
//  TestTrackView2.swift
//  VideoClap_Example
//
//  Created by lai001 on 2021/3/1.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import VideoClap
import AVFoundation
//

import UIKit
import AVFoundation
import SnapKit
import Photos
import VideoClap
import SSPlayer
import MobileCoreServices
class TestTrackView2: UIViewController {
    
    var videoDescription: VCVideoDescription {
        return player.videoDescription
    }
    
    var player: VCPlayer {
        return vcplayer
    }
    
    var trackBundle: VCTrackBundle {
        return videoDescription.trackBundle
    }
    
    public lazy var containerView: VCPlayerContainerView = {
        let view = VCPlayerContainerView(player: vcplayer)
        return view
    }()
    
    lazy var vcplayer: VCPlayer = {
        let player = VCPlayer()
        return player
    }()
    
//    var exportVideoClap = VideoClap()
    
    lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0
        //        slider.addTarget(self, action: #selector(durationSliderValueChanged(slider:event:)), for: .valueChanged)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sliderTapped(gestureRecognizer:)))
        slider.addGestureRecognizer(tapGestureRecognizer)
        slider.addTarget(self, action: #selector(durationSliderValueChanged(slider:event:)), for: .valueChanged)
        return slider
    }()
    
    lazy var timelabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.setImage(UIImage(color: .blue, size: CGSize(width: 44, height: 44)), for: .normal)
        button.setImage(UIImage(color: .red, size: CGSize(width: 44, height: 44)), for: .selected)
        button.addTarget(self, action: #selector(playButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    lazy var exportButton: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "export", style: .plain, target: self, action: #selector(exportButtonDidTap))
        return item
    }()
    
    lazy var addButton: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "add", style: .plain, target: self, action: #selector(addButtonDidTap))
        return item
    }()
    
    let ratio: CGFloat = 9.0 / 16.0
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    lazy var scaleView: VCTimeScaleView = {
        let view = VCTimeScaleView(frame: .zero, timeControl: timeControl)
        view.frame.size.height = 30
        view.frame.origin.y = 8
        return view
    }()
    
    lazy var mainTrackView: VCMainTrackView = {
        let view = VCMainTrackView(frame: .zero)
        view.viewDelegate = self
        view.timeControl = self.timeControl
        view.frame.size.height = 120
        view.frame.origin.y = 38
        return view
    }()
    
    var models: [VCImageTrackViewModel] = []
    /*lazy var models: [VCImageTrackViewModel] = {
        var models: [VCImageTrackViewModel] = []
        for index in 0..<8 {
            if Bool.random() {
                let videoTrack = VCVideoTrackDescription()
                videoTrack.mediaURL = resourceURL(filename: "video1.mp4")
                var start: CMTime = .zero
                if (0..<models.count).contains(index - 1) {
                    start = models[index - 1].cellConfig!.targetTimeRange()!.end
                }
                let duration = AVAsset(url: videoTrack.mediaURL.unsafelyUnwrapped).duration
                let source = CMTimeRange(start: 0, end: duration.seconds)
                let target = CMTimeRange(start: start.seconds, duration: source.duration.seconds)
                videoTrack.timeMapping = CMTimeMapping(source: source, target: target)
                let model = VCImageTrackViewModel()
                model.timeControl = self.timeControl
                model.cellConfig = VideoCellConfig(videoTrack: videoTrack)
                model.cellSize = CGSize(width: height, height: height)
                models.append(model)
            } else {
                let videoTrack = VCVideoTrackDescription()
                videoTrack.mediaURL = resourceURL(filename: "video0.mp4")
                var start: CMTime = .zero
                if (0..<models.count).contains(index - 1) {
                    start = models[index - 1].cellConfig!.targetTimeRange()!.end
                }
                let duration = AVAsset(url: videoTrack.mediaURL.unsafelyUnwrapped).duration
                let source = CMTimeRange(start: 0, end: duration.seconds)
                let target = CMTimeRange(start: start.seconds, duration: source.duration.seconds)
                videoTrack.timeMapping = CMTimeMapping(source: source, target: target)
                let model = VCImageTrackViewModel()
                model.timeControl = self.timeControl
                model.cellConfig = VideoCellConfig(videoTrack: videoTrack)
                model.cellSize = CGSize(width: height, height: height)
                models.append(model)
            }
        }
        for index in 0..<2 {
            if Bool.random() {
                let imageTrack = VCImageTrackDescription()
                imageTrack.mediaURL = resourceURL(filename: "4.jpg")
                var start: CMTime = .zero
                if (0..<models.count).contains(index - 1) {
                    start = models[index - 1].cellConfig!.targetTimeRange()!.end
                }
                imageTrack.timeRange = CMTimeRange(start: start.seconds, duration: 3.0)
                let model = VCImageTrackViewModel()
                model.timeControl = self.timeControl
                model.cellConfig = ImageCellConfig(imageTrack: imageTrack)
                model.cellSize = CGSize(width: height, height: height)
                models.append(model)
            } else {
                let imageTrack = VCImageTrackDescription()
                imageTrack.mediaURL = resourceURL(filename: "3.jpg")
                var start: CMTime = .zero
                if (0..<models.count).contains(index - 1) {
                    start = models[index - 1].cellConfig!.targetTimeRange()!.end
                }
                imageTrack.timeRange = CMTimeRange(start: start.seconds, duration: 3.0)
                let model = VCImageTrackViewModel()
                model.timeControl = self.timeControl
                model.cellConfig = ImageCellConfig(imageTrack: imageTrack)
                model.cellSize = CGSize(width: height, height: height)
                models.append(model)
            }
        }
        return models
    }()*/
    
    lazy var pinchGR: UIPinchGestureRecognizer = {
        let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(pinchGRHandler(_:)))
        return pinchGR
    }()
    
    let height: CGFloat = 120
    
    let timeControl: VCTimeControl = VCTimeControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.addSubview(scaleView)
        scrollView.addSubview(mainTrackView)
        scrollView.snp.makeConstraints { (make) in
            make.left.width.bottom.equalToSuperview()
            make.height.equalTo(200)
        }
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        scrollView.contentInset.left = scrollView.bounds.width / 2.0
        scrollView.contentInset.right = scrollView.contentInset.left

        let duration = models.max { (lhs, rhs) -> Bool in
            return (lhs.cellConfig?.targetTimeRange()?.end ?? .zero) < (rhs.cellConfig?.targetTimeRange()?.end ?? .zero)
        }?.cellConfig?.targetTimeRange()?.end ?? .zero
        
        timeControl.setTime(duration: duration)
        timeControl.setScale(1)
        
        view.addGestureRecognizer(pinchGR)
        
        
        mainTrackView.layout.invalidateLayout()
        mainTrackView.collectionView.reloadData()
        
        reloadData(fix: false)
        setupUI()
        videoDescription.fps = 24.0
        videoDescription.renderScale = 1
        videoDescription.renderSize = KResolution720x1280
        
        

    //    mergeClipsRenderDown()
    }
    
    func attemptToRefreshScrollview(){
        let duration = models.max { (lhs, rhs) -> Bool in
            return (lhs.cellConfig?.targetTimeRange()?.end ?? .zero) < (rhs.cellConfig?.targetTimeRange()?.end ?? .zero)
        }?.cellConfig?.targetTimeRange()?.end ?? .zero
        timeControl.setTime(duration: duration)
        timeControl.setScale(1)
        
        
        mainTrackView.layout.invalidateLayout()
        mainTrackView.collectionView.reloadData()
        
        
    }
    
 
    func setupNavBar() {
        navigationItem.rightBarButtonItems = [exportButton, addButton]
    }
    
    func setupUI() {
        setupNavBar()
        edgesForExtendedLayout = []
        view.backgroundColor = .white
        view.addSubview(containerView)
        view.addSubview(slider)
        view.addSubview(playButton)
        view.addSubview(timelabel)
        containerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(2)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(scrollView.snp.top).offset(-44)
        }
        slider.snp.makeConstraints { (make) in
            make.height.equalTo(44)
            make.bottom.equalTo(scrollView.snp.top)
            make.left.right.equalToSuperview().inset(20)
        }
        playButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(scrollView.snp.top)
            make.size.equalTo(44)
            make.left.equalToSuperview()
//            make.right.equalTo(slider.snp.right)
        }
        timelabel.snp.makeConstraints { (make) in
            make.left.equalTo(playButton.snp.right).offset(10)
            make.centerY.equalTo(playButton)
        }
    }
    
    @objc internal func pinchGRHandler(_ sender: UIPinchGestureRecognizer) {
        handle(state: sender.state, scale: sender.scale)
        
        if sender.state == .changed {
            sender.scale = 1.0
        }
    }
    
    public func handle(state: UIGestureRecognizer.State, scale: CGFloat) {
        scrollView.delegate = nil
        defer {
            scrollView.delegate = self
        }
        
        switch state {
        case .began:
            models.forEach({ $0.isStopLoadThumbnail = true })
            
        case .changed:
//            storeScales.append(2.0 - sender.scale)
            timeControl.setScale(scale * timeControl.scale)
            mainTrackView.layout.invalidateLayout()
            reloadData()
        
        case .ended:
            timeControl.setScale(scale * timeControl.scale)
            models.forEach({ $0.isStopLoadThumbnail = false })
            mainTrackView.layout.invalidateLayout()
            reloadData()
            
        default:
            break
        }
    }
    
    func fixPosition() {
        let percentage = timeControl.currentTime.seconds / timeControl.duration.seconds
        let offsetX = CGFloat(percentage) * (scrollView.contentSize.width) - scrollView.contentInset.left
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
    }
    
    public func visibleRect() -> CGRect {
        let rect = CGRect(x: max(0, scrollView.contentOffset.x), y: 0, width: scrollView.bounds.width, height: scrollView.bounds.height)
        return rect
    }
    
    public func reloadData(fix: Bool = true) {
        scrollView.contentSize.width = timeControl.maxLength
        if fix {
            fixPosition()
        }
        guard timeControl.intervalTime.value != 0 else {
            return
        }
        let datasourceCount = Int(timeControl.duration.value / timeControl.intervalTime.value)
        let cellWidth = timeControl.widthPerTimeVale * CGFloat(timeControl.intervalTime.value)
        scaleView.datasourceCount = datasourceCount
        scaleView.cellWidth = cellWidth
        scaleView.reloadData(in: visibleRect())
        
        mainTrackView.frame.size.width = scrollView.contentSize.width
//        mainTrackView.frame.size.height = scrollView.contentSize.height
        
        mainTrackView.reloadData(in: visibleRect())
    }
    
    
    
    func initPlay() {
        vcplayer.reload()
        playButton.isSelected = true
        
        player.observePlayingTime { [weak self] (time: CMTime) in
            guard let self = self else { return }
            self.timer()
        }
        
        player.play()
    }
    
    
    
    @objc func durationSliderValueChanged(slider: UISlider, event: UIEvent) {
        
        struct Scope {
            static var cacheIsPlaying = false
        }
        
        guard let touch = event.allTouches?.first else { return }
        
        switch touch.phase {
        case .began:
            Scope.cacheIsPlaying = player.isPlaying
            player.removePlayingTimeObserver()
            player.pause()
            
        case .ended:
            if Scope.cacheIsPlaying {
                player.observePlayingTime { [weak self] (time: CMTime) in
                    guard let self = self else { return }
                    self.timer()
                }
                player.play()
            }
            
        case .moved:
            let duration = player.currentItem?.asset.duration ?? CMTime(seconds: 1.0)
            let time = CMTime(seconds: duration.seconds * Double(slider.value))
            player.seekSmoothly(to: time) { [weak self] _ in
                guard let self = self else { return }
                self.timer()
            }
            
        default:
            break
        }
    }
    
    @objc func sliderTapped(gestureRecognizer: UIGestureRecognizer) {
        let pointTapped: CGPoint = gestureRecognizer.location(in: self.slider)
        let positionOfSlider: CGPoint = slider.frame.origin
        let widthOfSlider: CGFloat = slider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(slider.maximumValue) / widthOfSlider)
        let cacheIsPlaying = player.isPlaying
        let duration = player.currentItem?.duration.seconds ?? 1
        let time = CMTime(seconds: Double(newValue) * duration)
        
        player.seekSmoothly(to: time) { [weak self] _ in
            guard let self = self else { return }
            self.timer()
            if cacheIsPlaying {
                self.player.play()
            } else {
                self.player.pause()
            }
        }
    }
    
    @objc func timer() {
        let currentTime: CMTime = player.currentItem?.currentTime() ?? .zero
        let duration = player.currentItem?.duration ?? CMTime(seconds: 1.0)
        let value = Float(currentTime.seconds / duration.seconds)
        let isSelected = player.isPlaying
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 2
        nf.minimumFractionDigits = 2
        nf.minimumIntegerDigits = 1
        let timelabelText = nf.string(from: NSNumber(value: currentTime.seconds))! + " / " + nf.string(from: NSNumber(value: duration.seconds))!
        
        if currentTime >= duration {
            player.pause()
            DispatchQueue.main.async {
                self.playButton.isSelected = false
            }
        }
        
        DispatchQueue.main.async {
            self.timelabel.text = timelabelText
            self.playButton.isSelected = isSelected
            self.slider.value = value
        }
    }
    
    @objc func playButtonDidTap(_ sender: UIButton) {
        if player.isPlaying {
            player.pause()
            playButton.isSelected = false
        } else {
            player.play()
            playButton.isSelected = true
            player.observePlayingTime { [weak self] (time: CMTime) in
                guard let self = self else { return }
                self.timer()
            }
        }
    }
    
    @objc func exportButtonDidTap(_ sender: UIBarButtonItem) {
        do {
            // this should be using the videoClap in this vc - not inside vcplayer..... eg.exportVideoClap
            try self.vcplayer.enableManualRenderingMode()
            _ = self.vcplayer.export(size: KResolution720x1280) { (progress) in
                LLog(progress.fractionCompleted)
            } completionHandler: { [weak self] (url, error) in
                guard let self = self else { return }
                self.vcplayer.disableManualRenderingMode()
                if let url = url {
                    PHPhotoLibrary.shared().performChanges {
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                    } completionHandler: { _, _ in
                        LLog("finish ")
                    }
                } else if let error = error {
                    LLog(error)
                }
            }
            playButton.isSelected = false
        } catch let error {
            LLog(error)
        }
    }
    
    @objc func addButtonDidTap(_ sender: UIBarButtonItem) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? []
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
}

extension TestTrackView2: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentSize.width.isZero {
            return
        }
        let percentage = (scrollView.contentOffset.x + scrollView.contentInset.left) / (scrollView.contentSize.width)
        var currentTime = CMTime(seconds: Double(percentage) * timeControl.duration.seconds, preferredTimescale: VCTimeControl.timeBase)
        currentTime = min(max(.zero, currentTime), timeControl.duration)
        timeControl.setTime(currentTime: currentTime)
        
        scaleView.reloadData(in: visibleRect())
        mainTrackView.reloadData(in: visibleRect())
    }
    
}

extension TestTrackView2: VCMainTrackViewDelegate {
    
    func dataSource() -> [VCImageTrackViewModel] {
        return self.models
    }
    
    func didSelectItemAt(_ model: VCImageTrackViewModel, index: Int) {
        
    }
    
    func preReloadModel(_ model: VCImageTrackViewModel, visibleRect: CGRect) {
        
    }
    
    func postReloadModel(_ model: VCImageTrackViewModel, visibleRect: CGRect) {
        
    }
    
}

extension TestTrackView2: (UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if #available(iOS 11.0, *) {
            let type = (info[UIImagePickerController.InfoKey.mediaType] as? String ?? "") as CFString
            switch type {
            case kUTTypeMovie, kUTTypeVideo:
                if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                    let asset = AVAsset(url: url)
                    let tracks = self.trackBundle.imageTracks + self.trackBundle.videoTracks
                    let start = tracks.max { (lhs, rhs) -> Bool in
                        return lhs.timeRange.end < rhs.timeRange.end
                    }?.timeRange.end ?? .zero
                    
                    let videoTrack = VCVideoTrackDescription()
                    videoTrack.id = UUID().uuidString
                    videoTrack.sourceTimeRange = CMTimeRange(start: .zero, duration: asset.duration.seconds)
                    videoTrack.timeRange = CMTimeRange(start: start.seconds, duration: asset.duration.seconds)
                    videoTrack.mediaURL = url
                    self.trackBundle.videoTracks.append(videoTrack)
                    
                    
                    let model = VCImageTrackViewModel()
                    model.timeControl = self.timeControl
                    model.cellConfig = VideoCellConfig(videoTrack: videoTrack)
                    model.cellSize = CGSize(width: height, height: height)
                    models.append(model)
                    
                    reloadData(fix: false)
                    self.vcplayer.reload(time: .zero, closure: nil)
                    attemptToRefreshScrollview()
                }
                
            case kUTTypeImage:
                if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                    let tracks = self.trackBundle.imageTracks + self.trackBundle.videoTracks
                    let start = tracks.max { (lhs, rhs) -> Bool in
                        return lhs.timeRange.end < rhs.timeRange.end
                    }?.timeRange.end ?? .zero
                    
                    let imageTrack = VCImageTrackDescription()
                    imageTrack.id = UUID().uuidString
                    imageTrack.timeRange = CMTimeRange(start: start.seconds, duration: 3.0)
                    imageTrack.mediaURL = url
                    self.trackBundle.imageTracks.append(imageTrack)
                    
                    let model = VCImageTrackViewModel()
                    model.timeControl = self.timeControl
                    model.cellConfig = ImageCellConfig(imageTrack: imageTrack)
                    model.cellSize = CGSize(width: height, height: height)
                    models.append(model)
                    
                    reloadData(fix: false)
                    self.vcplayer.reload(time: .zero, closure: nil)
                    attemptToRefreshScrollview()
                }
                
            default:
                break
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

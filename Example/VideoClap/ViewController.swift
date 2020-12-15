//
//  ViewController.swift
//  VideoClap
//
//  Created by lai001 on 10/24/2020.
//  Copyright (c) 2020 lai001. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit
import Photos
import VideoClap
import SSPlayer

class NavigationController: UINavigationController {
    
}

class ViewController: UIViewController {

    lazy var requestCallbackHandler: VCPreviewRequestCallbackHandler = {
        return VCPreviewRequestCallbackHandler()
    }()
    
    var videoDescription: VCVideoDescription {
        return requestCallbackHandler.videoDescription
    }
    
    lazy var videoClap: VideoClap = {
        let videoClap = VideoClap()
        videoClap.requestCallbackHandler = requestCallbackHandler
        return videoClap
    }()
    
    var player: SSPlayer {
        return requestCallbackHandler.player
    }
    
    var containerView: UIView {
        return requestCallbackHandler.containerView
    }
    
    lazy var queue: DispatchQueue = {
        let queue: DispatchQueue = DispatchQueue(label: "play", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        return queue
    }()
    
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
        let item = UIBarButtonItem(title: "导出", style: .plain, target: self, action: #selector(exportButtonDidTap))
        return item
    }()
    
    let reverseVideo = VCReverseVideo()
    
    let ratio: CGFloat = 9.0 / 16.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        VideoClap.cleanExportFolder()
        
        PHPhotoLibrary.requestAuthorization { (_) in
            
        }
        NotificationCenter.default.addObserver(self, selector: #selector(transitionChange), name: TransitionNotification, object: nil)
        setupUI()
        videoDescription.fps = 24.0
        videoDescription.renderScale = Float(UIScreen.main.scale)
        videoDescription.renderSize = CGSize(width: view.bounds.width * ratio, height: view.bounds.width)
        videoDescription.waterMarkRect = .init(normalizeCenter: CGPoint(x: 0.9, y: 0.1), normalizeWidth: 0.1, normalizeHeight: 0.1)
        videoDescription.waterMarkImageURL = Bundle.main.url(forResource: "test3.jpg", withExtension: nil, subdirectory: "Mat")
        let trackBundle = videoDescription.trackBundle
        
        do {
            let trajectory = VCMovementTrajectory()
            trajectory.movementRatio = 0.1
            let track = VCVideoTrackDescription()
            track.canvasStyle = .image(Bundle.main.url(forResource: "test1.jpg", withExtension: nil, subdirectory: "Mat")!)
            track.trajectory = trajectory
            track.id = "videoTrack"
//            track.speed = 5.0
            let source = CMTimeRange(start: 5.0, end: 100)
            let target = CMTimeRange(start: 5.0, end: 6.0)
            track.timeMapping = CMTimeMapping(source: source, target: target)

            track.isFit = true
            track.mediaURL = Bundle.main.url(forResource: "video0.mp4", withExtension: nil, subdirectory: "Mat")
//            track.mediaClipTimeRange = CMTimeRange(start: 15.0, duration: track.timeRange.duration.seconds)
            track.lutImageURL = Bundle.main.url(forResource: "lut_filter_27", withExtension: "jpg", subdirectory: "Mat")
            trackBundle.videoTracks.append(track)
        }
        
        do {
//            let trajectory = VCMovementTrajectory()
//            trajectory.movementRatio = 0.1
            let track = VCVideoTrackDescription()
//            track.canvasStyle = .image(Bundle.main.url(forResource: "test1.jpg", withExtension: nil, subdirectory: "Mat")!)
//            track.trajectory = trajectory
            track.id = "videoTrack1"
            let source = CMTimeRange(start: 5.0, end: 100)
            let target = CMTimeRange(start: 6, end: 10.0)
            track.timeMapping = CMTimeMapping(source: source, target: target)

            track.isFit = true
            track.mediaURL = Bundle.main.url(forResource: "video0.mp4", withExtension: nil, subdirectory: "Mat")
//            track.mediaClipTimeRange = CMTimeRange(start: 15.0, duration: track.timeRange.duration.seconds)
//            track.lutImageURL = Bundle.main.url(forResource: "lut_filter_27", withExtension: "jpg", subdirectory: "Mat")
            trackBundle.videoTracks.append(track)
        }
        
        do {
            let trajectory = VCMovementTrajectory()
            trajectory.movementRatio = 0.1
            let track = VCImageTrackDescription()
            track.canvasStyle = .image(Bundle.main.url(forResource: "test4.jpg", withExtension: nil, subdirectory: "Mat")!)
            track.trajectory = trajectory
            track.id = "imageTrack"
            track.timeRange = CMTimeRange(start: 0.0, duration: 5.0)
            
            track.mediaURL = Bundle.main.url(forResource: "test3.jpg", withExtension: nil, subdirectory: "Mat")
            track.isFit = true
//            track.cropedRect = CGRect(x: 0.5, y: 0.2, width: 0.5, height: 0.5)
            trackBundle.imageTracks.append(track)
        }
        
        do {
            let track = VCAudioTrackDescription()
            track.id = "audioTrack"
            let timeRange = CMTimeRange(start: 0.0, duration: 6)
            track.timeMapping = CMTimeMapping(source: timeRange, target: timeRange)
            track.mediaURL = Bundle.main.url(forResource: "02.Ellis - Clear My Head (Radio Edit) [NCS]", withExtension: "mp3", subdirectory: "Mat")
            
//            track.mediaClipTimeRange = CMTimeRange(start: 0.0, duration: 3 * 60 + 37)
            if #available(iOS 11.0, *) {
//                track.audioEffectProvider = VCGhostAudioEffectProvider()
            }
            let desc = VCAudioVolumeRampDescription(startVolume: 0.7,
                                                    endVolume: 1.0,
                                                    timeRange: CMTimeRange(start: 0.0, duration: 10.0))
            track.audioVolumeRampDescriptions = [desc]
            trackBundle.audioTracks.append(track)
        }
        
        do {
            let trasition = VCCubeTransition()
            addTransition(trasition)
        }
        
        do {
            let lamination = VCLaminationTrackDescription()
            lamination.id = "laminationTrack"
            lamination.timeRange = CMTimeRange(start: .zero, duration: CMTime(seconds: 10))
            lamination.mediaURL = Bundle.main.url(forResource: "Anniversary1", withExtension: "png", subdirectory: "Mat")
            trackBundle.laminationTracks.append(lamination)
        }
        
        do {
            for index in 0..<2 {
                let animationSticker = VCLottieTrackDescription()
                animationSticker.id = "animationSticker\(index)"
                let size: CGSize = CGSize(width: 0.35 / ratio, height: 0.35)
                animationSticker.rect = VCRect(normalizeCenter: CGPoint(x: CGFloat.random(in: 0.0...1.0), y: CGFloat.random(in: 0.0...1.0)),
                                               normalizeSize: size)
                animationSticker.timeRange = CMTimeRange(start: .zero, duration: CMTime(seconds: 10))
                animationSticker.setAnimationView("Watermelon", subdirectory: "Mat/LottieAnimations")
                trackBundle.lottieTracks.append(animationSticker)
            }
        }
        
        do {
            let textTrack = VCTextTrackDescription()
            textTrack.id = "textTrack"
            textTrack.center = CGPoint(x: 0.5, y: 0.5)
            textTrack.timeRange = CMTimeRange(start: 0.0, end: 10.0)
            textTrack.isTypewriter = true
            textTrack.rotateRadian = .pi * 0.15
            textTrack.text = NSAttributedString(string: "按键或把手把字和符号打印在纸上的机械，有手打和电打两种。\n在大多数办公室，电脑已经取代了打字机。\n她拿起一张纸，把它哗哗啦啦地塞到打字机中。",
                                                attributes: [.foregroundColor : UIColor.red, .font : UIFont.systemFont(ofSize: 30, weight: .bold)])
            trackBundle.textTracks.append(textTrack)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            return
            do {
                self.player.removePlayingTimeObserver()
                self.requestCallbackHandler.stopRenderFlag = true
                self.player.currentItem?.cancelPendingSeeks()
                self.player.cancelPendingPrerolls()
                self.player.pause()
                let track = VCImageTrackDescription()
                track.id = "imageTrack1"
                track.timeRange = CMTimeRange(start: 10.0, duration: 5.0)
                track.mediaURL = Bundle.main.url(forResource: "test4", withExtension: "jpg", subdirectory: "Mat")
                track.isFit = true
                trackBundle.imageTracks.append(track)
                let newPlayerItem = self.videoClap.playerItemForPlay()
                let seekTime = self.requestCallbackHandler.compositionTime
                newPlayerItem.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] (_) in
                    guard let self = self else { return }
                    self.player.replaceCurrentItem(with: newPlayerItem)
                    self.requestCallbackHandler.stopRenderFlag = false
                    self.player.observePlayingTime(queue: self.queue) { (_) in
                        self.timer()
                    }
                }
            }
        }
        
//        reverseVideo.reverse(input: Bundle.main.url(forResource: "video0", withExtension: "mp4", subdirectory: "Mat")!) { (progress: Progress) in
//            LLog(progress.fractionCompleted)
//        } completionCallback: { (url, error) in
//            
//        }

        initPlay()
//        export(fileName: nil) { }
        
//        allCasesExportVideo()
    }
    
    func getTransition(type: TransitionType) -> VCTransitionProtocol {
        let transition: VCTransitionProtocol
        switch type {
        case .Alpha:
            transition = VCAlphaTransition()
        case .BarsSwipe:
            transition = VCBarsSwipeTransition()
        case .Blur:
            transition = VCBlurTransition()
        case .CopyMachine:
            transition = VCCopyMachineTransition()
        case .Dissolve:
            transition = VCDissolveTransition()
        case .Flip:
            transition = VCFlipTransition()
        case .IceMelting:
            transition = VCIceMeltingTransition()
        case .Slide:
            transition = VCSlideTransition()
        case .Swirl:
            transition = VCSwirlTransition()
        case .Vortex:
            let v = VCVortexTransition()
            v.type = .single
            transition = v
        case .Wave:
            transition = VCWaveTransition()
        case .Wipe:
            transition = VCWipeTransition()
        case .Windowslice:
            transition = VCWindowsliceTransition()
        case .PageCurl:
            transition = VCPageCurlWithShadowTransition()
        case .Doorway:
            transition = VCDoorwayTransition()
        case .Squareswire:
            transition = VCSquareswireTransition()
        case .Mod:
            transition = VCModTransition()
        case .Cube:
            transition = VCCubeTransition()
        case .Translation:
            transition = VCTranslationTransition().config(closure: {
                $0.translationType = .left
                $0.translation = self.videoDescription.renderSize.width
            })
        case .Heart:
            transition = VCHeartTransition()
        case .Noise:
            transition = VCNoiseTransition()
        case .Megapolis:
            transition = VCMegapolis2DPatternTransition()
        case .Spread:
            transition = VCSpreadTransition()
        case .Bounce:
            transition = VCBounceTransition()
        }
        return transition
    }
    
    func allCasesExportVideo() {
        DispatchQueue(label: "allCasesExportVideo").async {
            let group = DispatchGroup()
            for type in TransitionType.allCases {
                group.enter()
                let transition: VCTransitionProtocol = self.getTransition(type: type)
                self.addTransition(transition)
                self.export(fileName: type.rawValue + ".mov") {
                    group.leave()
                }
                group.wait()
            }
        }
    }
    
    @objc func transitionChange(_ sender: Notification) {
        let type = sender.userInfo?["transitionType"] as! TransitionType
        let trasition: VCTransitionProtocol = getTransition(type: type)
        addTransition(trasition)
        initPlay()
//        export(fileName: nil) { }
    }
    
    func addTransition(_ trasition: VCTransitionProtocol) {
        trasition.fromId = "imageTrack"
        trasition.toId = "videoTrack"
        trasition.range = VCRange(left: 0.5, right: 0.5)
        videoDescription.transitions = [trasition]
    }
    
    func initPlay() {
        player.currentItem?.cancelPendingSeeks()
        player.pause()
        let item = videoClap.playerItemForPlay()
        player.replaceCurrentItem(with: item)
        playButton.isSelected = true
        
        player.observePlayingTime { (time: CMTime) in
            self.timer()
        }
        
        player.play()
    }
    
    func export(fileName: String?, completion: @escaping () -> Void) {
        videoClap.exportToVideo(fileName: fileName) { (progress) in
            print(progress.fractionCompleted, fileName)
        } completionHandler: { (url, error) in
            if let error = error {
                LLog(error)
            }
            #if targetEnvironment(simulator)
            
            if let url = url {
                do {
                    let folder = "/Users/laimincong/Desktop/Temp/Videos/" // replace your folder path
                    if FileManager.default.fileExists(atPath: folder) == false {
                        try FileManager.default.createDirectory(atPath: folder, withIntermediateDirectories: true, attributes: nil)
                    }
                    let target: String = folder + url.lastPathComponent
                    if FileManager.default.fileExists(atPath: target) {
                        try FileManager.default.removeItem(atPath: target)
                    }
                    try FileManager.default.copyItem(atPath: url.path, toPath: target)
                } catch let error {
                    LLog(error)
                }
            }
            completion()
            #else
            
            if let url = url {
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                } completionHandler: { _, _ in
                    completion()
                }
            } else {
                completion()
            }
            
            #endif
        }
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
                player.observePlayingTime(queue: queue) { (time: CMTime) in
                    self.timer()
                }
                player.play()
            }
            
        case .moved:
            let duration = player.currentItem?.asset.duration ?? CMTime(seconds: 1.0)
            let time = CMTime(seconds: duration.seconds * Double(slider.value))
            player.seekSmoothly(to: time) {
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
        
        player.seekSmoothly(to: time) { [unowned self] in
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
            player.observePlayingTime(queue: queue) { (time: CMTime) in
                self.timer()
            }
        }
    }

    @objc func exportButtonDidTap(_ sender: UIBarButtonItem) {
        player.pause()
        playButton.isSelected = false
        let videoClap = VideoClap()
        videoClap.videoDescription = self.videoDescription.mutableCopy() as! VCVideoDescription
        let scale = CGFloat(videoClap.videoDescription.renderScale)
        videoClap.videoDescription.renderSize = videoClap.videoDescription.renderSize.applying(.init(scaleX: scale, y: scale))
        videoClap.videoDescription.renderScale = 1.0
        videoClap.exportToVideo { (progress) in
            LLog(progress.fractionCompleted)
        } completionHandler: { (url, error) in
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
    }
    
}

extension ViewController {
    
    func setupNavBar() {
        navigationItem.rightBarButtonItem = exportButton
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
            make.height.equalTo(containerView.snp.width)
        }
        slider.snp.makeConstraints { (make) in
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-30)
            make.left.right.equalToSuperview().inset(20)
        }
        playButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(slider.snp.top).offset(-20)
            make.size.equalTo(44)
            make.left.equalToSuperview().offset(20)
        }
        timelabel.snp.makeConstraints { (make) in
            make.left.equalTo(playButton.snp.right).offset(10)
            make.centerY.equalTo(playButton)
        }
    }
    
}

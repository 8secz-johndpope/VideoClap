//
//  VCTimeScaleView.swift
//  VideoClap
//
//  Created by lai001 on 2020/12/13.
//

import Foundation
import AVFoundation
import SnapKit

func format0(time: CMTime) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .none
    formatter.minimumIntegerDigits = 2
    let minute = formatter.string(from: NSNumber(value: Int(time.seconds) / 60)) ?? "00"
    let second = formatter.string(from: NSNumber(value: Int(time.seconds) % 60)) ?? "00"
    let timeStr = "\(minute):\(second)"
    return timeStr
}

public class VCTimeScaleCell: UICollectionViewCell {
    
    private(set) lazy var dotLabel: UILabel = {
        let label = UILabel()
        label.text = "・"
        label.textColor = UIColor.lightText
        label.textAlignment = .center
        return label
    }()
    
    lazy var keyTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightText
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(dotLabel)
        contentView.addSubview(keyTimeLabel)
        dotLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        keyTimeLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView.snp.left)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

public class VCTimeScaleView: UICollectionView {
   
    let timeBase: CMTimeScale = 600
    
    let viewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.scrollDirection = .horizontal
        return layout
    }()
    
    lazy var scale: CGFloat = 1
    
    lazy var duration: CMTime = CMTime(value: CMTimeValue(timeBase * 75), timescale: timeBase)
    
    internal lazy var pinchGR: UIPinchGestureRecognizer = {
        let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(pinchGRHandler(_:)))
        return pinchGR
    }()
    
    lazy var storeScales: [CGFloat] = []
    
    var cellWidth: CGFloat = 0.0
    
    var baseValue: CMTimeValue = 40
    
    var datasourceCount = 0
    
    let range0: Range<CGFloat> = 1..<10
    let range1: Range<CGFloat> = 10..<20
    let range2: Range<CGFloat> = 20..<24
    let range3: Range<CGFloat> = 24..<30
    let range4: Range<CGFloat> = 30..<60
    let range5: Range<CGFloat> = 60..<120
    let range6: Range<CGFloat> = 120..<200
    let range7: Range<CGFloat> = 200..<300
    let range8: ClosedRange<CGFloat> = 300...600
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.sizeToFit()
        return label
    }()
    
    lazy var currentTime: CMTime = CMTime(value: 0, timescale: timeBase)
    
    var isPinching: Bool = false
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    public init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: viewLayout)
        commitInit()
    }
    
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: viewLayout)
        commitInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commitInit() {
        register(VCTimeScaleCell.self, forCellWithReuseIdentifier: VCTimeScaleCell.description())
        delegate = self
        dataSource = self
        addGestureRecognizer(pinchGR)
        makeDataSource()
        self.reloadData()
    }
    
    func makeDataSource() {
        let widthPerTimeValue: CGFloat
        
        switch scale {
        case range0:
            baseValue = 6000
            widthPerTimeValue = scale.map(from: range0, to: 1...2)
            
        case range1:
            baseValue = 3000
            widthPerTimeValue = scale.map(from: range1, to: 1...2)
            
        case range2:
            baseValue = 2400
            widthPerTimeValue = scale.map(from: range2, to: 1...2)
            
        case range3:
            baseValue = 1200
            widthPerTimeValue = scale.map(from: range3, to: 1...2)
            
        case range4:
            baseValue = 600
            widthPerTimeValue = scale.map(from: range4, to: 1...2)
            
        case range5:
            baseValue = 300
            widthPerTimeValue = scale.map(from: range5, to: 1...2)

        case range6:
            baseValue = 100
            widthPerTimeValue = scale.map(from: range6, to: 1...2)
            
        case range7:
            baseValue = 60
            widthPerTimeValue = scale.map(from: range7, to: 1...2)
            
        case range8:
            baseValue = 40
            widthPerTimeValue = scale.map(from: range8, to: 1...2)
            
        default:
            baseValue = 40
            widthPerTimeValue = scale.map(from: range8, to: 1...2)
        }
        
        cellWidth = CGFloat(baseValue) * widthPerTimeValue
        
        cellWidth = cellWidth.map(from: CGFloat(baseValue)...CGFloat(baseValue * 2), to: 80...120)
        
        datasourceCount = Int(duration.value / baseValue)
    }
    
    @objc internal func pinchGRHandler(_ sender: UIPinchGestureRecognizer) {
        let n = 1
        switch sender.state {
        case .began:
            isPinching = true
            storeScales.removeAll()
            
        case .changed:
//            storeScales.append(2.0 - sender.scale)
            storeScales.append(sender.scale)
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(delayChanged), object: nil)
            if storeScales.count % n == 0 {
                delayChanged()
            } else {
                perform(#selector(delayChanged), with: nil, afterDelay: 0.03)
            }
            sender.scale = 1.0
            
        case .ended:
            if storeScales.count % n != 0 {
                delayChanged()
            }
            isPinching = false
            
        default:
            break
        }
    }
    
    @objc func delayChanged() {
        let storeScale = storeScales.reduce(1.0) { (result, scale) in
            return result * scale
        }
        storeScales.removeAll()
        setScale(scale * storeScale)
    }
    
    func setScale(_ v: CGFloat) {
        scale = min(600, max(1 , v))
        makeDataSource()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setCompletionBlock {
            let percentage = self.currentTime.seconds / self.duration.seconds
            
            self.contentOffset.x = CGFloat(percentage) * (self.contentSize.width - self.label.bounds.width / 2.0) - self.contentInset.left
        }
        UIView.performWithoutAnimation {
            self.reloadData()
        }
        CATransaction.commit()
    }
    
}

extension VCTimeScaleView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        contentInset.left = collectionView.bounds.width / 2.0 - label.bounds.width / 2.0
        contentInset.right = collectionView.bounds.width / 2.0
        return datasourceCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VCTimeScaleCell.description(), for: indexPath) as! VCTimeScaleCell
        let time = CMTime(value: baseValue * Int64(indexPath.item), timescale: timeBase)
        
        if time.value % 600 == 0 {
            cell.keyTimeLabel.text = format0(time: time)
        } else {
            let seconds = time.value / 600
            let remaind = time.value - seconds * 600
            cell.keyTimeLabel.text = "\(remaind / 20)f"
        }
 
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: collectionView.bounds.height)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentSize.width.isZero || isPinching {
            return
        }
        let percentage = (scrollView.contentOffset.x + self.contentInset.left) / (scrollView.contentSize.width - label.bounds.width / 2.0)
        currentTime = CMTime(seconds: Double(percentage) * duration.seconds, preferredTimescale: 600)
        currentTime = min(max(.zero, currentTime), duration)
    }
    
}

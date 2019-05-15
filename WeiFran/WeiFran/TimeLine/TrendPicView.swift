//
//  TrendPicView.swift
//  WeiFran
//
//  Created by francis on 2019/5/9.
//  Copyright © 2019 francis. All rights reserved.
//

import UIKit
import SDWebImage

class TrendPicViewModel{
    var picUrls:[String]
    var trendId:Int
    init(picUrls:[String],trendId:Int) {
        self.picUrls = picUrls
        self.trendId = trendId
    }
}
//重载CGPoint比较
func > (left:CGPoint,right:CGPoint)->Bool{
    if left.x > right.x && left.y > right.y {
        return true
    }else{
        return false
    }
}
//图片点击代理方法
protocol TrendPicViewDelegate:NSObjectProtocol {
    func didTapPicView(imageUrl:String,imageFrame:CGRect,indexInSubView:Int)
}
class TrendPicView: UIView {
    @IBOutlet weak var TrendPicViewHeightConstraint:NSLayoutConstraint!
    let imageInterval:CGFloat = 3
    let onePicMaxDimension = CGSize.init(width: 300, height: 300)
    let SDWebImageOption = SDWebImageOptions.progressiveDownload
    weak var picTappedDelegate:TrendPicViewDelegate?
    
    var viewModel:TrendPicViewModel?{
        didSet{
            updateUI()
            tag = viewModel!.trendId
        }
    }
    override func awakeFromNib() {
        //set up uicomponent
        initUI()
    }
    func toInvisiblize(from:Int,to:Int,isHidden:Bool){
        for i in from...to{
            subviews[i].isHidden = isHidden
        }
    }
    @objc func tapPicView(_ sender:UIGestureRecognizer){
        let tapLocation = sender.location(ofTouch: 0, in: self)
        switch viewModel!.picUrls.count {
        case 1:
            picTappedDelegate?.didTapPicView(imageUrl: viewModel!.picUrls[0], imageFrame: subviews[0].frame, indexInSubView: 0)
            break
        case 2:
            if tapLocation.x < subviews[0].frame.origin.x {
                picTappedDelegate?.didTapPicView(imageUrl: viewModel!.picUrls[0], imageFrame: subviews[0].frame, indexInSubView: 0)
            }else if tapLocation.x > subviews[1].frame.origin.x {
                picTappedDelegate?.didTapPicView(imageUrl: viewModel!.picUrls[1], imageFrame: subviews[1].frame, indexInSubView: 1)
            }else{
                print("nothing happens when tapping picView")
            }
            break
        default:
            for subViewIndex in 0...subviews.count-1 {
                let reversed = subviews.count-1-subViewIndex
                if tapLocation > subviews[reversed].frame.origin {
                    picTappedDelegate?.didTapPicView(imageUrl: viewModel!.picUrls[reversed], imageFrame: subviews[reversed].frame, indexInSubView: reversed)
                    return
                }
            }
        }
    }
    
    func initUI(){
        let sideLength = (frame.size.width - 2*imageInterval)/3
        for i in 1...9{
            let row = Int((i-1)/3)+1
            let col = i%3 == 0 ? 3:i%3
            let x = CGFloat(col-1)*(imageInterval+sideLength)
            let y = CGFloat(row-1)*(imageInterval+sideLength)
            let imageView = UIImageView.init(frame: CGRect.init(x: x, y: y, width: sideLength, height: sideLength))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            addSubview(imageView)
        }
        TrendPicViewHeightConstraint.constant = frame.size.width
        //添加手势识别
        let tapGestureRecognizer = UITapGestureRecognizer.init()
        tapGestureRecognizer.addTarget(self, action: #selector(tapPicView))
        isUserInteractionEnabled = true
        addGestureRecognizer(tapGestureRecognizer)
    }
    func updateUI(){
        let defaultSideLength = (frame.size.width - 2*imageInterval)/3
        let defaultRect1 = CGRect.init(origin: .zero, size: .init(width: defaultSideLength, height: defaultSideLength))
        let defaultRect2 = CGRect.init(origin: .init(x: imageInterval+defaultSideLength, y: 0), size: .init(width: defaultSideLength, height: defaultSideLength))
        if viewModel!.picUrls.count == 0 {
            toInvisiblize(from: 0, to: 8, isHidden: true)
            TrendPicViewHeightConstraint.constant = 0
        }else if viewModel!.picUrls.count == 1{
            toInvisiblize(from: 1, to: 8, isHidden: true)
            toInvisiblize(from: 0, to: 0, isHidden: false)
            //默认为SDWebImage缓存，不再次缓存在CacheManager里面了
            //let pic = CacheManager.trendsPicCache[picId]!
            let picKey = SDWebImageManager.shared().cacheKey(for: URL.init(string: viewModel!.picUrls.first!)!)!
            let pic = SDImageCache.shared().imageFromCache(forKey: picKey)!
            //
            let picSize = pic.size
            let resizeRation = min(onePicMaxDimension.height/picSize.height, onePicMaxDimension.width/picSize.width)
            let picImageViewRect = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: picSize.width*resizeRation, height: picSize.height*resizeRation))
            subviews[0].frame = picImageViewRect
            (subviews[0] as! UIImageView).sd_setImage(with: URL.init(string: viewModel!.picUrls[0])!, placeholderImage: UIImage.init(named: "placeholder.png"), options: SDWebImageOption) { (opImage, opError, SDImageCacheType, opUrl) in
                //
            }
            TrendPicViewHeightConstraint.constant = picImageViewRect.height
        }else if viewModel!.picUrls.count == 2{
            toInvisiblize(from: 2, to: 8, isHidden: true)
            toInvisiblize(from: 0, to: 1, isHidden: false)
            let sideLength = (frame.size.width-imageInterval)/2
            let rect1 = CGRect.init(origin: .zero, size: .init(width: sideLength, height: sideLength))
            let rect2 = CGRect.init(origin: .init(x: sideLength+imageInterval, y: 0), size: .init(width: sideLength, height: sideLength))
            subviews[0].frame = rect1
            subviews[1].frame = rect2
            (subviews[0] as! UIImageView).sd_setImage(with: URL.init(string: viewModel!.picUrls[0])!, placeholderImage: UIImage.init(named: "placeholder.png"), options: SDWebImageOption) { (opImage, opError, SDImageCacheType, opUrl) in
                //
            }
            (subviews[1] as! UIImageView).sd_setImage(with: URL.init(string: viewModel!.picUrls[1])!, placeholderImage: UIImage.init(named: "placeholder.png"), options: SDWebImageOption) { (opImage, opError, SDImageCacheType, opUrl) in
                //
            }
            TrendPicViewHeightConstraint.constant = sideLength
        }else{
            //需要恢复九宫格布局
            if subviews[0].frame != defaultRect1 {
                subviews[0].frame = defaultRect1
            }
            if subviews[1].frame != defaultRect2 {
                subviews[1].frame = defaultRect2
            }
            if viewModel!.picUrls.count < 9 {
                toInvisiblize(from: viewModel!.picUrls.count, to: 8, isHidden: true)
                toInvisiblize(from: 0, to: viewModel!.picUrls.count-1, isHidden: false)
            }else{
                toInvisiblize(from: 0, to: 8, isHidden: false)
            }
            for i in 0...min(9, viewModel!.picUrls.count)-1{
                (subviews[i] as! UIImageView).sd_setImage(with: URL.init(string: viewModel!.picUrls[i])!, placeholderImage: UIImage.init(named: "placeholder.png"), options: SDWebImageOption) { (opImage, opError, SDImageCacheType, opUrl) in
                    //
                }
            }
            //
            let totalRow = Int((min(9, viewModel!.picUrls.count)-1)/3)+1
            TrendPicViewHeightConstraint.constant = CGFloat(totalRow)*defaultSideLength+CGFloat(totalRow-1)*imageInterval
        }
    }
    //
    
}

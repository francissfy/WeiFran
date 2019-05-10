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
    var indexPath:IndexPath
    init(picUrls:[String],trendId:Int,index:IndexPath) {
        self.picUrls = picUrls
        self.trendId = trendId
        self.indexPath = index
    }
}

class TrendPicView: UIView {
    @IBOutlet weak var TrendPicViewHeightConstraint:NSLayoutConstraint!
    let imageInterval:CGFloat = 3
    let onePicMaxDimension = CGSize.init(width: 300, height: 300)
    let SDWebImageOption = SDWebImageOptions.progressiveDownload
    
    var viewModel:TrendPicViewModel?{
        didSet{
            print("model setted")
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
            let picId = String(viewModel!.picUrls.first!.split(separator: "/").last!.split(separator: ".").first!)
            let pic = CacheManager.trendsPicCache[picId]!
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

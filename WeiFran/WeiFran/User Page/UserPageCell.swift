//
//  UserPageHeader.swift
//  WeiFran
//
//  Created by francis on 2019/5/14.
//  Copyright © 2019 francis. All rights reserved.
//

import UIKit
import SDWebImage
class UserPageHeaderCell: UITableViewCell {
    @IBOutlet weak var backGroundImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var coverImageHeight: NSLayoutConstraint!
    @IBOutlet weak var coverImageTop: NSLayoutConstraint!
    
    
    var user:NSDictionary!{
        didSet{
            updateUI()
        }
    }
    func updateUI(){
        let coverImageUrl = user["cover_image_phone"] as! String
        let nickName = user["screen_name"] as! String
        let avatarLarge = user["avatar_large"] as! String
        let intro = user["description"] as! String
        let city = user["location"] as! String
        let followingCount = user["friends_count"] as! Int
        let followersCount = user["followers_count"] as! Int
        //
        avatarImageView.sd_setImage(with: URL.init(string: avatarLarge), completed: nil)
        backGroundImageView.sd_setImage(with: URL.init(string: coverImageUrl)!, placeholderImage: UIImage.init(named: "coverPlaceHolder.jpg"), options: .progressiveDownload, completed: nil)
        nickNameLabel.text = nickName
        introductionLabel.text = intro
        followingCountLabel.text = numberAbbr(Num: followingCount)+" following"
        followersCountLabel.text = numberAbbr(Num: followersCount)+" followers"
        cityLabel.text = city
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarImageView.layer.cornerRadius = 10
        self.avatarImageView.layer.masksToBounds = true
        coverImageHeight.constant = frame.width
        coverImageTop.constant = 150
    }
    func modifyCoverImageTopMargin(constant:CGFloat){
        coverImageTop.constant = constant
    }
}

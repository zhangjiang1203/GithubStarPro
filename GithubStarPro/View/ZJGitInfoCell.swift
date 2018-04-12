//
//  ZJGitInfoCell.swift
//  GithubStarPro
//
//  Created by Zj on 2018/3/29.
//  Copyright © 2018年 zhangjiang. All rights reserved.
//

import UIKit
import Kingfisher
class ZJGitInfoCell: UITableViewCell {
    
    
    @IBOutlet weak var userImagView: UIImageView!
    @IBOutlet weak var gitNameLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var starBtn: UIButton!
    @IBOutlet weak var forksBtn: UIButton!
    @IBOutlet weak var followsBtn: UIButton!
    
    var clickBlock:((NSInteger)->Void)?
    
    
    
    var gitModel = ZJGitInfoModel(){
        didSet{
            //设置数据
            userImagView.kf.setImage(with: URL.init(string:gitModel.owner.avatar_url))
            gitNameLabel.text = gitModel.name
            languageLabel.text = gitModel.language
            authorNameLabel.text = "author:"+gitModel.owner.login
            descriptionLabel.text = gitModel.description
            starBtn.setTitle("stars:"+"\(gitModel.stargazers_count)", for: .normal)
            forksBtn.setTitle("forks:"+"\(gitModel.forks_count)", for: .normal)
            followsBtn.setTitle("followers:"+"\(gitModel.watchers_count)", for: .normal)
        }
    }
    
    @IBAction func buttonClickAction(_ sender: UIButton) {
        if let clickBlock = clickBlock {
            clickBlock(sender.tag)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}

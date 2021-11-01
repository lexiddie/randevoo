//
//  InputDescriptionCell.swift
//  randevoo
//
//  Created by Xell on 6/1/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

protocol GetTextViewDelegate {
    func getTextView(text: String)
}

class InputDescriptionCell: UICollectionViewCell {
    
    var delegate: GetTextViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        inputItem.delegate  = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(inputTitle)
        inputTitle.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.lessThanOrEqualTo(self).offset(10)
            make.height.equalTo(18)
        }
        addSubview(inputItem)
        inputItem.snp.makeConstraints { (make) in
            make.top.equalTo(inputTitle.snp.bottom).offset(5)
            make.left.lessThanOrEqualTo(self).offset(10)
            make.right.equalTo(self).inset(10)
            make.bottom.equalTo(self)
            make.width.equalTo(self.frame.width - 20)
        }
    
    }
    
    let inputTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.text = "Description"
        label.textAlignment = .left
        return label
    }()
    
    lazy var inputItem: UITextView = {
        let textView = UITextView()
        let yourText = "Enter your description"
        textView.textAlignment = .left
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.layer.borderColor = UIColor.randevoo.mainLightGray.withAlphaComponent(0.5).cgColor
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let font = UIFont(name: "Quicksand-Regular", size: 15)
        var attributes = [NSAttributedString.Key.paragraphStyle : style, NSAttributedString.Key.font : font]
        textView.attributedText = NSAttributedString(string: yourText, attributes:attributes as [NSAttributedString.Key : Any])
        textView.textColor = UIColor.white
        textView.backgroundColor = UIColor.randevoo.mainColor
        textView.isScrollEnabled = true
        return textView
    }() 
}

extension InputDescriptionCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        } else {
            delegate?.getTextView(text: textView.text)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Enter your description"
            textView.textColor = UIColor.lightGray
        } else {
            delegate?.getTextView(text: textView.text)
        }
    } 
}

//
//  EditPersonalProfileView.swift
//  randevoo
//
//  Created by Alexander on 31/1/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit

class EditPersonalProfileView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(profileView)
        profileView.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaLayoutGuide).inset(10)
            make.left.right.equalTo(self)
            make.height.equalTo(215)
        }
        profileView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { (make) in
            make.top.equalTo(profileView).inset(30)
            make.centerX.equalTo(profileView)
            make.height.width.equalTo(120)
        }
        profileView.addSubview(uploadProfileButton)
        uploadProfileButton.snp.makeConstraints { (make) in
            make.top.equalTo(profileImageView.snp.bottom).offset(15)
            make.centerX.equalTo(profileView)
            make.height.equalTo(40)
        }
        addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.top.equalTo(profileView.snp.bottom).offset(10)
            make.height.equalTo(0.5)
            make.left.right.lessThanOrEqualTo(self)
        }
        addSubview(nameStackView)
        nameStackView.addArrangedSubview(nameLabel)
        nameStackView.addArrangedSubview(nameTextField)
        nameStackView.snp.makeConstraints { (make) in
            make.top.equalTo(lineView.snp.bottom).offset(10)
            make.left.right.lessThanOrEqualTo(self).inset(30)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(nameStackView)
            make.height.equalTo(40)
            make.width.equalTo(100)
        }
        nameTextField.snp.makeConstraints { (make) in
            make.centerY.equalTo(nameStackView)
            make.height.equalTo(40)
            make.width.equalTo(self.frame.width - 160)
        }
        addSubview(nameButton)
        nameButton.snp.makeConstraints { (make) in
            make.top.equalTo(lineView.snp.bottom).offset(10)
            make.left.right.lessThanOrEqualTo(self).inset(30)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
        }
        addSubview(nameLineView)
        nameLineView.snp.makeConstraints { (make) in
            make.top.equalTo(nameStackView.snp.bottom).offset(5)
            make.right.equalTo(self)
            make.height.equalTo(0.5)
            make.width.equalTo(self.frame.width - 130)
        }
        addSubview(usernameStackView)
        usernameStackView.addArrangedSubview(usernameLabel)
        usernameStackView.addArrangedSubview(usernameTextField)
        usernameStackView.snp.makeConstraints { (make) in
            make.top.equalTo(nameLineView.snp.bottom).offset(10)
            make.left.right.lessThanOrEqualTo(self).inset(30)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
        }
        usernameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(usernameStackView)
            make.height.equalTo(40)
            make.width.equalTo(100)
        }
        usernameTextField.snp.makeConstraints { (make) in
            make.centerY.equalTo(usernameStackView)
            make.height.equalTo(40)
            make.width.equalTo(self.frame.width - 160)
        }
        addSubview(usernameButton)
        usernameButton.snp.makeConstraints { (make) in
            make.top.equalTo(nameLineView.snp.bottom).offset(10)
            make.left.right.lessThanOrEqualTo(self).inset(30)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
        }
        addSubview(usernameLineView)
        usernameLineView.snp.makeConstraints { (make) in
            make.top.equalTo(usernameStackView.snp.bottom).offset(5)
            make.right.equalTo(self)
            make.height.equalTo(0.5)
            make.width.equalTo(self.frame.width - 130)
        }
        addSubview(bioStackView)
        bioStackView.addArrangedSubview(bioLabel)
        bioStackView.addArrangedSubview(bioTextField)
        bioStackView.snp.makeConstraints { (make) in
            make.top.equalTo(usernameLineView.snp.bottom).offset(10)
            make.left.right.lessThanOrEqualTo(self).inset(30)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
        }
        bioLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(bioStackView)
            make.height.equalTo(40)
            make.width.equalTo(100)
        }
        bioTextField.snp.makeConstraints { (make) in
            make.centerY.equalTo(bioStackView)
            make.height.equalTo(40)
            make.width.equalTo(self.frame.width - 160)
        }
        addSubview(bioButton)
        bioButton.snp.makeConstraints { (make) in
            make.top.equalTo(usernameLineView.snp.bottom).offset(10)
            make.left.right.lessThanOrEqualTo(self).inset(30)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
        }
        addSubview(bioLineView)
        bioLineView.snp.makeConstraints { (make) in
            make.top.equalTo(bioStackView.snp.bottom).offset(5)
            make.right.equalTo(self)
            make.height.equalTo(0.5)
            make.width.equalTo(self.frame.width - 130)
        }
        addSubview(siteStackView)
        siteStackView.addArrangedSubview(siteLabel)
        siteStackView.addArrangedSubview(siteTextField)
        siteStackView.snp.makeConstraints { (make) in
            make.top.equalTo(bioLineView.snp.bottom).offset(10)
            make.left.right.lessThanOrEqualTo(self).inset(30)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
        }
        siteLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(siteStackView)
            make.height.equalTo(40)
            make.width.equalTo(100)
        }
        siteTextField.snp.makeConstraints { (make) in
            make.centerY.equalTo(siteStackView)
            make.height.equalTo(40)
            make.width.equalTo(self.frame.width - 160)
        }
        addSubview(siteButton)
        siteButton.snp.makeConstraints { (make) in
            make.top.equalTo(bioLineView.snp.bottom).offset(10)
            make.left.right.lessThanOrEqualTo(self).inset(30)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
        }
        addSubview(siteLineView)
        siteLineView.snp.makeConstraints { (make) in
            make.top.equalTo(siteStackView.snp.bottom).offset(5)
            make.right.equalTo(self)
            make.height.equalTo(0.5)
            make.width.equalTo(self.frame.width - 130)
        }
        addSubview(locationStackView)
        locationStackView.addArrangedSubview(locationLabel)
        locationStackView.addArrangedSubview(locationTextField)
        locationStackView.snp.makeConstraints { (make) in
            make.top.equalTo(siteLineView.snp.bottom).offset(10)
            make.left.right.lessThanOrEqualTo(self).inset(30)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
        }
        locationLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(locationStackView)
            make.height.equalTo(40)
            make.width.equalTo(100)
        }
        locationTextField.snp.makeConstraints { (make) in
            make.centerY.equalTo(locationStackView)
            make.height.equalTo(40)
            make.width.equalTo(self.frame.width - 160)
        }
        addSubview(locationButton)
        locationButton.snp.makeConstraints { (make) in
            make.top.equalTo(siteLineView.snp.bottom).offset(10)
            make.left.right.lessThanOrEqualTo(self).inset(30)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
        }
        addSubview(endLineView)
        endLineView.snp.makeConstraints { (make) in
            make.top.equalTo(locationStackView.snp.bottom).offset(10)
            make.height.equalTo(0.5)
            make.left.right.lessThanOrEqualTo(self)
        }
    }
    
    let profileView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
        imageView.layer.cornerRadius = 120/2
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.randevoo.mainWhiteGray.cgColor
        imageView.backgroundColor = UIColor.randevoo.mainWhiteGray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let uploadProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Upload profile photo", for: .normal)
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 17)
        button.setTitleColor(UIColor.randevoo.mainColor, for: .normal)
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action: #selector(EditPersonalProfileController.handleUploadProfile(_:)), for: .touchUpInside)
        return button
    }()
    
    let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        return view
    }()
    
    let nameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.alignment = UIStackView.Alignment.leading
        return stackView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 17)
        label.textAlignment = .left
        return label
    }()
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: "Quicksand-Medium", size: 17)
        textField.textColor = UIColor.randevoo.mainBlack
        textField.textAlignment = .left
        textField.backgroundColor = UIColor.clear
        textField.autocorrectionType = .no
        textField.borderStyle = UITextField.BorderStyle.none
        textField.isEnabled = false
        textField.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        return textField
    }()
    
    let nameLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        return view
    }()
    
    let usernameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.alignment = UIStackView.Alignment.leading
        return stackView
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 17)
        label.textAlignment = .left
        return label
    }()
    
    let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: "Quicksand-Medium", size: 17)
        textField.textColor = UIColor.randevoo.mainBlack
        textField.textAlignment = .left
        textField.backgroundColor = UIColor.clear
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.borderStyle = UITextField.BorderStyle.none
        textField.isEnabled = false
        textField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        return textField
    }()
    
    let usernameLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        return view
    }()
    
    let bioStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.alignment = UIStackView.Alignment.leading
        return stackView
    }()
    
    let bioLabel: UILabel = {
        let label = UILabel()
        label.text = "Bio"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 17)
        label.textAlignment = .left
        return label
    }()
    
    let bioTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: "Quicksand-Medium", size: 17)
        textField.textColor = UIColor.randevoo.mainBlack
        textField.textAlignment = .left
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.backgroundColor = UIColor.clear
        textField.borderStyle = UITextField.BorderStyle.none
        textField.isEnabled = false
        textField.attributedPlaceholder = NSAttributedString(string: "Add a bio to your profile", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        return textField
    }()
    
    let bioLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        return view
    }()
    
    let siteStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.alignment = UIStackView.Alignment.leading
        return stackView
    }()
    
    let siteLabel: UILabel = {
        let label = UILabel()
        label.text = "Website"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 17)
        label.textAlignment = .left
        return label
    }()
    
    let siteTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: "Quicksand-Medium", size: 17)
        textField.textColor = UIColor.randevoo.mainBlack
        textField.textAlignment = .left
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.backgroundColor = UIColor.clear
        textField.borderStyle = UITextField.BorderStyle.none
        textField.isEnabled = false
        textField.attributedPlaceholder = NSAttributedString(string: "Add your website", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        return textField
    }()
    
    let siteLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        return view
    }()
    
    let locationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.alignment = UIStackView.Alignment.leading
        return stackView
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Location"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 17)
        label.textAlignment = .left
        return label
    }()
    
    let locationTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: "Quicksand-Medium", size: 17)
        textField.textColor = UIColor.randevoo.mainBlack
        textField.textAlignment = .left
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.backgroundColor = UIColor.clear
        textField.borderStyle = UITextField.BorderStyle.none
        textField.isEnabled = false
        textField.attributedPlaceholder = NSAttributedString(string: "Add your location", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        return textField
    }()
    
    let endLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        return view
    }()
    
    let nameButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0
        button.layer.backgroundColor = UIColor.clear.cgColor
        button.layer.borderColor = UIColor.clear.cgColor
        button.addTarget(self, action: #selector(EditPersonalProfileController.handleName(_:)), for: .touchUpInside)
        return button
    }()
    
    let usernameButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0
        button.layer.backgroundColor = UIColor.clear.cgColor
        button.layer.borderColor = UIColor.clear.cgColor
        button.addTarget(self, action: #selector(EditPersonalProfileController.handleUsername(_:)), for: .touchUpInside)
        return button
    }()
    
    let bioButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0
        button.layer.backgroundColor = UIColor.clear.cgColor
        button.layer.borderColor = UIColor.clear.cgColor
        button.addTarget(self, action: #selector(EditPersonalProfileController.handleBio(_:)), for: .touchUpInside)
        return button
    }()
    
    let siteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0
        button.layer.backgroundColor = UIColor.clear.cgColor
        button.layer.borderColor = UIColor.clear.cgColor
        button.addTarget(self, action: #selector(EditPersonalProfileController.handleSite(_:)), for: .touchUpInside)
        return button
    }()
    
    let locationButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0
        button.layer.backgroundColor = UIColor.clear.cgColor
        button.layer.borderColor = UIColor.clear.cgColor
        button.addTarget(self, action: #selector(EditPersonalProfileController.handleLocation(_:)), for: .touchUpInside)
        return button
    }()
}

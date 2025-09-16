import UIKit
import SnapKit

final class PantheonGoalsProfileVC: UIViewController {
    
    // MARK: - Properties
    private let avatars = ["avatarOne", "avatarTwo", "avatarThree", "avatarFour", "avatarFive", "avatarSix"]
    private var achievements: [PantheonGoalsAchievement] = []
    private var isShowingAvatarPicker = false
    
    // MARK: - UI Elements
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pahntheonBackground")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let backButton: PantheonGoalsButton = {
        let button = PantheonGoalsButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Profile"
        label.textColor = .white
        label.font = .pantheonGoalsFont(size: 24)
        label.textAlignment = .center
        return label
    }()
    
    private let profileContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .pantheonGoalsBeige.withAlphaComponent(0.9)
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 40
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .pantheonGoalsDarkPurple
        label.font = .pantheonGoalsFont(size: 20)
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let achievementsLabel: UILabel = {
        let label = UILabel()
        label.text = "Achievements"
        label.textColor = .pantheonGoalsDarkPurple
        label.font = .pantheonGoalsFont(size: 24)
        return label
    }()
    
    private let achievementsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private let avatarPickerView: UIView = {
        let view = UIView()
        view.backgroundColor = .pantheonGoalsBeige.withAlphaComponent(0.95)
        view.layer.cornerRadius = 16
        view.isHidden = true
        return view
    }()
    
    private let avatarPickerTitle: UILabel = {
        let label = UILabel()
        label.text = "Choose Avatar"
        label.textColor = .pantheonGoalsDarkPurple
        label.font = .pantheonGoalsFont(size: 20)
        label.textAlignment = .center
        return label
    }()
    
    private let avatarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let avatarPickerCloseButton: PantheonGoalsButton = {
        let button = PantheonGoalsButton()
        button.setTitle("Close", for: .normal)
        button.backgroundColor = .pantheonGoalsGold
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupTableView()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        navigationController?.isNavigationBarHidden = true
        
        view.addSubviews(backgroundImageView, backButton, titleLabel, profileContainer, achievementsTableView, avatarPickerView)
        profileContainer.addSubviews(avatarImageView, nameLabel)
        avatarPickerView.addSubviews(avatarPickerTitle, avatarCollectionView, avatarPickerCloseButton)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.centerX.equalToSuperview()
        }
        
        profileContainer.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        achievementsTableView.snp.makeConstraints { make in
            make.top.equalTo(profileContainer.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        avatarPickerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(200)
        }
        
        avatarPickerTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        avatarCollectionView.snp.makeConstraints { make in
            make.top.equalTo(avatarPickerTitle.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(100)
        }
        
        avatarPickerCloseButton.snp.makeConstraints { make in
            make.top.equalTo(avatarCollectionView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        }
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        avatarPickerCloseButton.addTarget(self, action: #selector(avatarPickerCloseTapped), for: .touchUpInside)
        
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        avatarImageView.addGestureRecognizer(avatarTap)
        
        let nameTap = UITapGestureRecognizer(target: self, action: #selector(nameTapped))
        nameLabel.addGestureRecognizer(nameTap)
    }
    
    private func setupTableView() {
        achievementsTableView.delegate = self
        achievementsTableView.dataSource = self
        achievementsTableView.register(PantheonGoalsAchievementCell.self, forCellReuseIdentifier: "AchievementCell")
        
        avatarCollectionView.delegate = self
        avatarCollectionView.dataSource = self
        avatarCollectionView.register(PantheonGoalsAvatarCell.self, forCellWithReuseIdentifier: "AvatarCell")
    }
    
    private func loadData() {
        nameLabel.text = PantheonGoalsStorageManager.shared.userName
        avatarImageView.image = UIImage(named: PantheonGoalsStorageManager.shared.userAvatar)
        achievements = PantheonGoalsStorageManager.shared.loadAchievements()
        achievementsTableView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        PantheonGoalsFeedbackManager.shared.buttonFeedback()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func avatarTapped() {
        PantheonGoalsFeedbackManager.shared.buttonFeedback()
        showAvatarPicker()
    }
    
    @objc private func avatarPickerCloseTapped() {
        PantheonGoalsFeedbackManager.shared.buttonFeedback()
        hideAvatarPicker()
    }
    
    @objc private func nameTapped() {
        PantheonGoalsFeedbackManager.shared.buttonFeedback()
        showNameAlert()
    }
    
    // MARK: - Helpers
    private func showAvatarPicker() {
        isShowingAvatarPicker = true
        avatarPickerView.isHidden = false
        avatarPickerView.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            self.avatarPickerView.alpha = 1
        }
    }
    
    private func hideAvatarPicker() {
        UIView.animate(withDuration: 0.3) {
            self.avatarPickerView.alpha = 0
        } completion: { _ in
            self.avatarPickerView.isHidden = true
            self.isShowingAvatarPicker = false
        }
    }
    
    private func showNameAlert() {
        let alert = UIAlertController(title: "Change Name", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = PantheonGoalsStorageManager.shared.userName
            textField.placeholder = "Enter your name"
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.dismissKeyboard))
            toolbar.setItems([doneButton], animated: false)
            textField.inputAccessoryView = toolbar
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            if let name = alert.textFields?.first?.text, !name.isEmpty {
                PantheonGoalsStorageManager.shared.userName = name
                self?.nameLabel.text = name
            }
        }
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITableViewDataSource
extension PantheonGoalsProfileVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return achievements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AchievementCell", for: indexPath) as! PantheonGoalsAchievementCell
        cell.configure(with: achievements[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PantheonGoalsProfileVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

// MARK: - Achievement Cell
final class PantheonGoalsAchievementCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .pantheonGoalsBeige.withAlphaComponent(0.9)
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let achievementImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .pantheonGoalsDarkPurple
        label.font = .pantheonGoalsFont(size: 18)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .pantheonGoalsPurple
        label.font = .pantheonGoalsFont(size: 14)
        label.numberOfLines = 2
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubviews(achievementImageView, titleLabel, descriptionLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        achievementImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalTo(achievementImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalTo(achievementImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.lessThanOrEqualToSuperview().offset(-16)
        }
    }
    
    func configure(with achievement: PantheonGoalsAchievement) {
        achievementImageView.image = UIImage(named: achievement.imageName)
        titleLabel.text = achievement.title
        descriptionLabel.text = achievement.description
        containerView.alpha = achievement.isUnlocked ? 1.0 : 0.6
    }
}

// MARK: - UICollectionViewDataSource
extension PantheonGoalsProfileVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return avatars.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvatarCell", for: indexPath) as! PantheonGoalsAvatarCell
        cell.configure(with: avatars[indexPath.item], isSelected: avatars[indexPath.item] == PantheonGoalsStorageManager.shared.userAvatar)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PantheonGoalsProfileVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        PantheonGoalsFeedbackManager.shared.buttonFeedback()
        let selectedAvatar = avatars[indexPath.item]
        PantheonGoalsStorageManager.shared.userAvatar = selectedAvatar
        avatarImageView.image = UIImage(named: selectedAvatar)
        collectionView.reloadData()
        hideAvatarPicker()
    }
}

// MARK: - Avatar Cell
final class PantheonGoalsAvatarCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let selectedOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = .pantheonGoalsGold.withAlphaComponent(0.3)
        view.layer.cornerRadius = 30
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubviews(imageView, selectedOverlay)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        selectedOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(with imageName: String, isSelected: Bool) {
        imageView.image = UIImage(named: imageName)
        selectedOverlay.isHidden = !isSelected
    }
}

import UIKit
import SnapKit

protocol PantheonGoalsAddArtifactDelegate: AnyObject {
    func artifactDidAdd()
}

final class PantheonGoalsAddArtifactVC: UIViewController {
    
    // MARK: - Properties
    private let artifacts = ["copilOne", "copilTwo", "copilThree", "copilFour", "copilFive", "copilSix", "copilSeven"]
    private var selectedImage: String?
    weak var delegate: PantheonGoalsAddArtifactDelegate?
    
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
        label.text = "New Artifact"
        label.textColor = .white
        label.font = .pantheonGoalsFont(size: 24)
        label.textAlignment = .center
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .pantheonGoalsBeige.withAlphaComponent(0.9)
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Artifact Name"
        textField.textColor = .pantheonGoalsDarkPurple
        textField.font = .pantheonGoalsFont(size: 18)
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: nil, action: #selector(dismissKeyboard))
        toolbar.setItems([doneButton], animated: false)
        textField.inputAccessoryView = toolbar
        return textField
    }()
    
    private let targetAmountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Target Amount"
        textField.textColor = .pantheonGoalsDarkPurple
        textField.font = .pantheonGoalsFont(size: 18)
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.keyboardType = .decimalPad
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: nil, action: #selector(dismissKeyboard))
        toolbar.setItems([doneButton], animated: false)
        textField.inputAccessoryView = toolbar
        return textField
    }()
    
    private let deadlineButton: PantheonGoalsButton = {
        let button = PantheonGoalsButton()
        button.setTitle("Set Deadline (Optional)", for: .normal)
        button.backgroundColor = .pantheonGoalsGold
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let deadlineLabel: UILabel = {
        let label = UILabel()
        label.textColor = .pantheonGoalsDarkPurple
        label.font = .pantheonGoalsFont(size: 16)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let imagesLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose Image"
        label.textColor = .pantheonGoalsDarkPurple
        label.font = .pantheonGoalsFont(size: 18)
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let saveButton: PantheonGoalsButton = {
        let button = PantheonGoalsButton()
        button.setTitle("Save", for: .normal)
        button.backgroundColor = .pantheonGoalsGold
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupCollectionView()
    }
    
    // MARK: - Setup
    private func setupUI() {
        navigationController?.isNavigationBarHidden = true
        
        view.addSubviews(backgroundImageView, backButton, titleLabel, containerView, saveButton)
        containerView.addSubviews(nameTextField, targetAmountTextField, deadlineButton, deadlineLabel, imagesLabel, collectionView)
        
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
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        nameTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        targetAmountTextField.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        deadlineButton.snp.makeConstraints { make in
            make.top.equalTo(targetAmountTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        deadlineLabel.snp.makeConstraints { make in
            make.top.equalTo(deadlineButton.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        imagesLabel.snp.makeConstraints { make in
            make.top.equalTo(deadlineLabel.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(imagesLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(100)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-32)
        }
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        deadlineButton.addTarget(self, action: #selector(deadlineButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PantheonGoalsImageCell.self, forCellWithReuseIdentifier: "ImageCell")
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        PantheonGoalsFeedbackManager.shared.buttonFeedback()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func deadlineButtonTapped() {
        PantheonGoalsFeedbackManager.shared.buttonFeedback()
        showDatePicker()
    }
    
    @objc private func saveButtonTapped() {
        PantheonGoalsFeedbackManager.shared.buttonFeedback()
        
        guard let name = nameTextField.text, !name.isEmpty,
              let amountText = targetAmountTextField.text, !amountText.isEmpty,
              let amount = Double(amountText), amount > 0,
              let imageName = selectedImage else {
            showError()
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        var deadline: Date?
        if let dateText = deadlineLabel.text,
           dateText != "No Deadline",
           let date = dateFormatter.date(from: dateText) {
            deadline = date
        }
        
        let artifact = PantheonGoalsArtifact(name: name,
                                           targetAmount: amount,
                                           imageName: imageName,
                                           deadline: deadline)
        
        var artifacts = PantheonGoalsStorageManager.shared.loadArtifacts()
        artifacts.append(artifact)
        PantheonGoalsStorageManager.shared.saveArtifacts(artifacts)
        
        // Check "First Step" achievement
        if artifacts.count == 1 {
            var achievements = PantheonGoalsStorageManager.shared.loadAchievements()
            if let index = achievements.firstIndex(where: { $0.id == "first_step" }) {
                achievements[index].isUnlocked = true
            }
            PantheonGoalsStorageManager.shared.saveAchievements(achievements)
        }
        
        // Check "Collector" achievement
        if artifacts.count == 3 {
            var achievements = PantheonGoalsStorageManager.shared.loadAchievements()
            if let index = achievements.firstIndex(where: { $0.id == "collector" }) {
                achievements[index].isUnlocked = true
            }
            PantheonGoalsStorageManager.shared.saveAchievements(achievements)
        }
        
        delegate?.artifactDidAdd()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Helpers
    private func showDatePicker() {
        let alert = UIAlertController(title: "Select Deadline", message: "\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        datePicker.frame = CGRect(x: 0, y: 20, width: alert.view.frame.size.width, height: 200)
        alert.view.addSubview(datePicker)
        
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            self?.deadlineLabel.text = formatter.string(from: datePicker.date)
            self?.deadlineLabel.isHidden = false
        })
        
        alert.addAction(UIAlertAction(title: "No Deadline", style: .default) { [weak self] _ in
            self?.deadlineLabel.text = "No Deadline"
            self?.deadlineLabel.isHidden = false
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = view
            presenter.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            presenter.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func showError() {
        let alert = UIAlertController(title: "Error",
                                    message: "Please fill in all required fields and select an image",
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension PantheonGoalsAddArtifactVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artifacts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! PantheonGoalsImageCell
        cell.configure(with: artifacts[indexPath.item], isSelected: artifacts[indexPath.item] == selectedImage)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PantheonGoalsAddArtifactVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        PantheonGoalsFeedbackManager.shared.buttonFeedback()
        selectedImage = artifacts[indexPath.item]
        collectionView.reloadData()
    }
}

// MARK: - Image Cell
final class PantheonGoalsImageCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let selectedOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = .pantheonGoalsGold.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
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

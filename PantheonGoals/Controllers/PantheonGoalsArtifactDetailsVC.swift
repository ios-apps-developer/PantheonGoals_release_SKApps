import UIKit
import SnapKit

protocol PantheonGoalsArtifactDetailsDelegate: AnyObject {
    func artifactDidUpdate()
    func artifactDidDelete()
}

final class PantheonGoalsArtifactDetailsVC: UIViewController {
    
    // MARK: - Properties
    private var artifact: PantheonGoalsArtifact
    weak var delegate: PantheonGoalsArtifactDetailsDelegate?
    
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
    
    private let editButton: PantheonGoalsButton = {
        let button = PantheonGoalsButton()
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let deleteButton: PantheonGoalsButton = {
        let button = PantheonGoalsButton()
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
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
    
    private let artifactImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progressTintColor = .pantheonGoalsGold
        progress.trackTintColor = .pantheonGoalsLightBlue
        progress.layer.cornerRadius = 4
        progress.clipsToBounds = true
        return progress
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .pantheonGoalsDarkPurple
        label.font = .pantheonGoalsFont(size: 18)
        label.textAlignment = .center
        return label
    }()
    
    private let deadlineLabel: UILabel = {
        let label = UILabel()
        label.textColor = .pantheonGoalsPurple
        label.font = .pantheonGoalsFont(size: 16)
        label.textAlignment = .center
        return label
    }()
    
    private let completedLabel: UILabel = {
        let label = UILabel()
        label.text = "Completed!"
        label.textColor = .pantheonGoalsGold
        label.font = .pantheonGoalsFont(size: 20)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let addButton: PantheonGoalsButton = {
        let button = PantheonGoalsButton()
        button.setTitle("Add Contribution", for: .normal)
        button.backgroundColor = .pantheonGoalsGold
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    // MARK: - Initialization
    init(artifact: PantheonGoalsArtifact) {
        self.artifact = artifact
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupTableView()
        updateUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        navigationController?.isNavigationBarHidden = true
        
        view.addSubviews(backgroundImageView, backButton, editButton, deleteButton, titleLabel, containerView, addButton, tableView)
        containerView.addSubviews(artifactImageView, progressView, amountLabel, deadlineLabel, completedLabel)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }
        
        editButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(deleteButton.snp.leading).offset(-8)
            make.width.height.equalTo(44)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(44)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.centerX.equalToSuperview()
            make.leading.equalTo(backButton.snp.trailing).offset(8)
            make.trailing.equalTo(editButton.snp.leading).offset(-8)
        }
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        artifactImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(artifactImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(8)
        }
        
        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        deadlineLabel.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        completedLabel.snp.makeConstraints { make in
            make.top.equalTo(deadlineLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        addButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(50)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(addButton.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PantheonGoalsContributionCell.self, forCellReuseIdentifier: "ContributionCell")
    }
    
    private func updateUI() {
        titleLabel.text = artifact.name
        artifactImageView.image = UIImage(named: artifact.imageName)
        progressView.progress = Float(artifact.progress)
        amountLabel.text = String(format: "%.2f / %.2f", artifact.currentAmount, artifact.targetAmount)
        
        if let deadline = artifact.deadline {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            deadlineLabel.text = "Deadline: \(formatter.string(from: deadline))"
        } else {
            deadlineLabel.text = nil
        }
        
        completedLabel.isHidden = !artifact.isCompleted
        addButton.isEnabled = !artifact.isCompleted
        addButton.alpha = artifact.isCompleted ? 0.5 : 1.0
        
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        PantheonGoalsFeedbackManager.shared.buttonFeedback()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func editButtonTapped() {
        PantheonGoalsFeedbackManager.shared.buttonFeedback()
        let editVC = PantheonGoalsEditArtifactVC(artifact: artifact)
        editVC.delegate = self
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    @objc private func deleteButtonTapped() {
        PantheonGoalsFeedbackManager.shared.buttonFeedback()
        
        let alert = UIAlertController(title: "Delete Artifact",
                                    message: "Are you sure you want to delete this artifact?",
                                    preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteArtifact()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func addButtonTapped() {
        PantheonGoalsFeedbackManager.shared.buttonFeedback()
        
        let alert = UIAlertController(title: "Add Contribution",
                                    message: "Enter amount and optional comment",
                                    preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Amount"
            textField.keyboardType = .decimalPad
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.dismissKeyboard))
            toolbar.setItems([doneButton], animated: false)
            textField.inputAccessoryView = toolbar
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Comment (optional)"
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.dismissKeyboard))
            toolbar.setItems([doneButton], animated: false)
            textField.inputAccessoryView = toolbar
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let amountText = alert.textFields?[0].text,
                  let amount = Double(amountText),
                  amount > 0 else {
                return
            }
            
            let comment = alert.textFields?[1].text
            self?.addContribution(amount: amount, comment: comment)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Data Management
    private func addContribution(amount: Double, comment: String?) {
        let contribution = PantheonGoalsContribution(amount: amount, comment: comment)
        artifact.contributions.append(contribution)
        artifact.currentAmount += amount
        artifact.isCompleted = artifact.currentAmount >= artifact.targetAmount
        
        if artifact.isCompleted {
            checkAchievements()
        }
        
        saveArtifact()
        updateUI()
    }
    
    private func deleteContribution(at indexPath: IndexPath) {
        let contribution = artifact.contributions[indexPath.row]
        artifact.currentAmount -= contribution.amount
        artifact.contributions.remove(at: indexPath.row)
        artifact.isCompleted = artifact.currentAmount >= artifact.targetAmount
        
        tableView.performBatchUpdates({
            tableView.deleteRows(at: [indexPath], with: .fade)
        }, completion: { _ in
            self.saveArtifact()
            self.updateUI()
        })
    }
    
    private func deleteArtifact() {
        var artifacts = PantheonGoalsStorageManager.shared.loadArtifacts()
        artifacts.removeAll { $0.id == artifact.id }
        PantheonGoalsStorageManager.shared.saveArtifacts(artifacts)
        delegate?.artifactDidDelete()
        navigationController?.popViewController(animated: true)
    }
    
    private func saveArtifact() {
        var artifacts = PantheonGoalsStorageManager.shared.loadArtifacts()
        if let index = artifacts.firstIndex(where: { $0.id == artifact.id }) {
            artifacts[index] = artifact
            PantheonGoalsStorageManager.shared.saveArtifacts(artifacts)
            delegate?.artifactDidUpdate()
        }
    }
    
    private func checkAchievements() {
        var achievements = PantheonGoalsStorageManager.shared.loadAchievements()
        
        // Check "Completed Artifact" achievement
        if let index = achievements.firstIndex(where: { $0.id == "completed_artifact" }) {
            achievements[index].isUnlocked = true
        }
        
        // Check "On Time" achievement
        if let deadline = artifact.deadline,
           Calendar.current.isDate(Date(), inSameDayAs: deadline) {
            if let index = achievements.firstIndex(where: { $0.id == "on_time" }) {
                achievements[index].isUnlocked = true
            }
        }
        
        // Check "Strength of Athena" achievement
        let allUnlocked = achievements.allSatisfy { $0.id == "strength_of_athena" || $0.isUnlocked }
        if allUnlocked {
            if let index = achievements.firstIndex(where: { $0.id == "strength_of_athena" }) {
                achievements[index].isUnlocked = true
            }
        }
        
        PantheonGoalsStorageManager.shared.saveAchievements(achievements)
    }
}

// MARK: - UITableViewDataSource
extension PantheonGoalsArtifactDetailsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artifact.contributions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContributionCell", for: indexPath) as! PantheonGoalsContributionCell
        cell.configure(with: artifact.contributions[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PantheonGoalsArtifactDetailsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.deleteContribution(at: indexPath)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - Contribution Cell
final class PantheonGoalsContributionCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .pantheonGoalsBeige.withAlphaComponent(0.9)
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .pantheonGoalsDarkPurple
        label.font = .pantheonGoalsFont(size: 18)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .pantheonGoalsPurple
        label.font = .pantheonGoalsFont(size: 14)
        return label
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .pantheonGoalsPurple
        label.font = .pantheonGoalsFont(size: 14)
        label.numberOfLines = 0
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
        containerView.addSubviews(amountLabel, dateLabel, commentLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        amountLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        commentLabel.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    func configure(with contribution: PantheonGoalsContribution) {
        amountLabel.text = String(format: "+%.2f", contribution.amount)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateLabel.text = dateFormatter.string(from: contribution.date)
        
        commentLabel.text = contribution.comment
        commentLabel.isHidden = contribution.comment == nil
    }
}

// MARK: - PantheonGoalsEditArtifactDelegate
extension PantheonGoalsArtifactDetailsVC: PantheonGoalsEditArtifactDelegate {
    func artifactDidUpdate() {
        // Reload artifact data
        let artifacts = PantheonGoalsStorageManager.shared.loadArtifacts()
        if let updatedArtifact = artifacts.first(where: { $0.id == artifact.id }) {
            artifact = updatedArtifact
            updateUI()
            delegate?.artifactDidUpdate()
        }
    }
}

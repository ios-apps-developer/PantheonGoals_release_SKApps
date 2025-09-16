import UIKit
import SnapKit

final class PantheonGoalsMainVC: UIViewController {
    // MARK: - Properties
    private var artifacts: [PantheonGoalsArtifact] = [] {
        didSet {
            emptyLabel.isHidden = !artifacts.isEmpty
            artifactsCollectionView.reloadData()
        }
    }
    
    // MARK: - UI Elements
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pahntheonBackground")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let transitionView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pahntheonBackground")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let profileButton: PantheonGoalsButton = {
        let button = PantheonGoalsButton()
        button.setImage(UIImage(systemName: "person.circle"), for: .normal)
        button.tintColor = .white
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        return button
    }()
    
    private let settingsButton: PantheonGoalsButton = {
        let button = PantheonGoalsButton()
        button.setImage(UIImage(systemName: "gearshape"), for: .normal)
        button.tintColor = .white
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        return button
    }()
    
    private let infoButton: PantheonGoalsButton = {
        let button = PantheonGoalsButton()
        button.setImage(UIImage(systemName: "info.circle"), for: .normal)
        button.tintColor = .white
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        return button
    }()
    
    private let artifactsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(PantheonGoalsArtifactCell.self, forCellWithReuseIdentifier: PantheonGoalsArtifactCell.reuseIdentifier)
        return collectionView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No artifacts yet"
        label.textColor = .white
        label.font = .pantheonGoalsFont(size: 24)
        label.textAlignment = .center
        return label
    }()
    
    private let addButton: PantheonGoalsButton = {
        let button = PantheonGoalsButton()
        button.setTitle("Add Artifact", for: .normal)
        button.backgroundColor = .pantheonGoalsGold
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        loadArtifacts()
        
        // Start transition animation
        animateTransition()
        
        // Check if it's first launch
        checkFirstLaunch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadArtifacts()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubviews(backgroundImageView, profileButton, settingsButton, infoButton, artifactsCollectionView, emptyLabel, addButton, transitionView)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        profileButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(33)
        }
        
        infoButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(settingsButton.snp.leading).offset(-16)
            make.width.height.equalTo(33)
        }
        
        settingsButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(33)
        }
        
        artifactsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(profileButton.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(addButton.snp.top).offset(-16)
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        addButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-32)
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().offset(-32)
            make.height.equalTo(50)
        }
        
        transitionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Setup collection view
        artifactsCollectionView.delegate = self
        artifactsCollectionView.dataSource = self
    }
    
    private func setupActions() {
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Animations
    private func animateTransition() {
        UIView.animate(withDuration: 0.5) {
            self.transitionView.alpha = 0
        }
    }
    
    // MARK: - Actions
    @objc private func profileButtonTapped() {
        PantheonGoalsFeedbackManager.shared.buttonFeedback()
        let profileVC = PantheonGoalsProfileVC()
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @objc private func settingsButtonTapped() {
        PantheonGoalsFeedbackManager.shared.buttonFeedback()
        let settingsVC = PantheonGoalsSettingsVC()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @objc private func addButtonTapped() {
        PantheonGoalsFeedbackManager.shared.buttonFeedback()
        let addVC = PantheonGoalsAddArtifactVC()
        addVC.delegate = self
        navigationController?.pushViewController(addVC, animated: true)
    }
    
    // MARK: - First Launch
    private func checkFirstLaunch() {
        if PantheonGoalsStorageManager.shared.isFirstLaunch {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.showOnboarding()
            }
            PantheonGoalsStorageManager.shared.isFirstLaunch = false
        }
    }
    
    // MARK: - Navigation
    private func showOnboarding() {
        let onboardingVC = PantheonGoalsOnboardingVC()
        navigationController?.pushViewController(onboardingVC, animated: true)
    }
    
    @objc private func infoButtonTapped() {
        PantheonGoalsFeedbackManager.shared.buttonFeedback()
        showOnboarding()
    }
    
    // MARK: - Data Management
    private func loadArtifacts() {
        artifacts = PantheonGoalsStorageManager.shared.loadArtifacts()
    }
}

// MARK: - UICollectionViewDataSource
extension PantheonGoalsMainVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artifacts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PantheonGoalsArtifactCell.reuseIdentifier, for: indexPath) as? PantheonGoalsArtifactCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: artifacts[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PantheonGoalsMainVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height: CGFloat = 400
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        PantheonGoalsFeedbackManager.shared.buttonFeedback()
        let detailsVC = PantheonGoalsArtifactDetailsVC(artifact: artifacts[indexPath.item])
        detailsVC.delegate = self
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}

// MARK: - PantheonGoalsArtifactDetailsDelegate
extension PantheonGoalsMainVC: PantheonGoalsArtifactDetailsDelegate {
    func artifactDidUpdate() {
        loadArtifacts()
    }
    
    func artifactDidDelete() {
        loadArtifacts()
    }
}

// MARK: - PantheonGoalsAddArtifactDelegate
extension PantheonGoalsMainVC: PantheonGoalsAddArtifactDelegate {
    func artifactDidAdd() {
        loadArtifacts()
    }
}


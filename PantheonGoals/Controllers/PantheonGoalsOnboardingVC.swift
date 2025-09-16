import UIKit
import SnapKit

final class PantheonGoalsOnboardingVC: UIViewController {
    
    // MARK: - Properties
    private let pages = [
        "Collect artifacts and achieve your goals.",
        "Customize your profile.",
        "Track progress and earn achievements."
    ]
    
    private var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
            updateButtons()
        }
    }
    
    // MARK: - UI Elements
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pahntheonBackground")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let closeButton: PantheonGoalsButton = {
        let button = PantheonGoalsButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .pantheonGoalsGold
        pageControl.pageIndicatorTintColor = .pantheonGoalsBeige
        return pageControl
    }()
    
    private let nextButton: PantheonGoalsButton = {
        let button = PantheonGoalsButton()
        button.setTitle("Next", for: .normal)
        button.backgroundColor = .pantheonGoalsGold
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupUI() {
        navigationController?.isNavigationBarHidden = true
        
        view.addSubviews(backgroundImageView, closeButton, collectionView, pageControl, nextButton)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(44)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(pageControl.snp.top).offset(-32)
        }
        
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(nextButton.snp.top).offset(-32)
            make.centerX.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-32)
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().offset(-32)
            make.height.equalTo(50)
        }
        
        pageControl.numberOfPages = pages.count
        updateButtons()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PantheonGoalsOnboardingCell.self, forCellWithReuseIdentifier: "OnboardingCell")
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    private func updateButtons() {
        let isLastPage = currentPage == pages.count - 1
        nextButton.setTitle(isLastPage ? "Get Started" : "Next", for: .normal)
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        PantheonGoalsFeedbackManager.shared.buttonFeedback()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func nextButtonTapped() {
        PantheonGoalsFeedbackManager.shared.buttonFeedback()
        
        if currentPage < pages.count - 1 {
            currentPage += 1
            collectionView.scrollToItem(at: IndexPath(item: currentPage, section: 0),
                                      at: .centeredHorizontally,
                                      animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension PantheonGoalsOnboardingVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCell", for: indexPath) as! PantheonGoalsOnboardingCell
        cell.configure(with: pages[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PantheonGoalsOnboardingVC: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        currentPage = page
    }
}

// MARK: - Onboarding Cell
final class PantheonGoalsOnboardingCell: UICollectionViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .pantheonGoalsBeige.withAlphaComponent(0.9)
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .pantheonGoalsDarkPurple
        label.font = .pantheonGoalsFont(size: 24)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(200)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(24)
        }
    }
    
    func configure(with text: String) {
        titleLabel.text = text
    }
}

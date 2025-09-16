import UIKit
import SnapKit

final class PantheonGoalsArtifactCell: UICollectionViewCell {
    static let reuseIdentifier = "PantheonGoalsArtifactCell"
    
    // MARK: - UI Elements
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .pantheonGoalsBeige.withAlphaComponent(0.9)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .pantheonGoalsDarkPurple
        label.font = .pantheonGoalsFont(size: 28)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
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
        label.font = .pantheonGoalsFont(size: 16)
        label.textAlignment = .center
        return label
    }()
    
    private let completedLabel: UILabel = {
        let label = UILabel()
        label.text = "Completed!"
        label.textColor = .pantheonGoalsGold
        label.font = .pantheonGoalsFont(size: 18)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let deadlineLabel: UILabel = {
        let label = UILabel()
        label.textColor = .pantheonGoalsPurple
        label.font = .pantheonGoalsFont(size: 14)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubviews(nameLabel, artifactImageView, progressView, amountLabel, completedLabel, deadlineLabel)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.top.equalToSuperview().inset(28)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        artifactImageView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(140)
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
        
        completedLabel.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        deadlineLabel.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    // MARK: - Configuration
    func configure(with artifact: PantheonGoalsArtifact) {
        artifactImageView.image = UIImage(named: artifact.imageName)
        nameLabel.text = artifact.name
        amountLabel.text = String(format: "%.0f / %.0f", artifact.currentAmount, artifact.targetAmount)
        progressView.progress = Float(artifact.progress)
        
        if artifact.isCompleted {
            completedLabel.isHidden = false
            deadlineLabel.isHidden = true
        } else {
            completedLabel.isHidden = true
            if let deadline = artifact.deadline {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                deadlineLabel.text = "Deadline: \(formatter.string(from: deadline))"
            } else {
                deadlineLabel.text = "No deadline"
            }
            deadlineLabel.isHidden = false
        }
    }
}

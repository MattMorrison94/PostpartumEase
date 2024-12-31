import SwiftUI
import PhotosUI
import SwiftData
import CloudKit

enum OnboardingStep {
    case welcome
    case profile
    case delivery
    case completion
}

@MainActor
class OnboardingViewModel: ObservableObject {
    // Parent Information
    @Published var currentStep: OnboardingStep = .welcome
    @Published var name: String = ""
    @Published var birthDate: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    @Published var deliveryDate: Date = Date()
    @Published var deliveryType: DeliveryType = .vaginal
    @Published var imageSelection: PhotosPickerItem? {
        didSet { Task { await loadImage() } }
    }
    @Published var profileImage: UIImage?
    
    // Baby Information
    @Published var isBabyBorn = false
    @Published var babyName: String = ""
    @Published var babyBirthDate: Date = Date()
    @Published var babyGender: Gender = .male
    @Published var babyBirthWeight: String = ""
    @Published var babyBirthLength: String = ""
    
    // State
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isCompleted = false
    
    private var modelContext: ModelContext?
    private let cloudKitContainer: CKContainer?
    
    var isProfileValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        birthDate < Date()
    }
    
    var isDeliveryValid: Bool {
        if isBabyBorn {
            let nameValid = !babyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            let birthDateValid = babyBirthDate <= Date()
            let weightValid = babyBirthWeight.isEmpty || (Double(babyBirthWeight) ?? 0) > 0
            let lengthValid = babyBirthLength.isEmpty || (Double(babyBirthLength) ?? 0) > 0
            
            return nameValid && birthDateValid && weightValid && lengthValid
        } else {
            // If baby isn't born yet, just validate the due date is in the future
            return deliveryDate > Date()
        }
    }
    
    init() {
        // Initialize CloudKit container if available
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            self.cloudKitContainer = CKContainer(identifier: "iCloud.\(bundleIdentifier)")
        } else {
            self.cloudKitContainer = nil
        }
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func nextStep() {
        switch currentStep {
        case .welcome:
            currentStep = .profile
        case .profile:
            currentStep = .delivery
        case .delivery:
            currentStep = .completion
        case .completion:
            completeOnboarding()
        }
    }
    
    func skipOnboarding() {
        currentStep = .completion
    }
    
    func completeOnboarding() {
        guard let modelContext = modelContext else {
            print("ModelContext not set")
            return
        }
        
        Task {
            do {
                isLoading = true
                
                // Create local user with conditional delivery information
                let user = User(
                    name: name,
                    birthDate: birthDate,
                    deliveryDate: isBabyBorn ? babyBirthDate : deliveryDate,
                    deliveryType: isBabyBorn ? deliveryType : nil,
                    profileImage: profileImage?.jpegData(compressionQuality: 0.7)
                )
                
                // Create baby if information is provided
                if isBabyBorn {
                    let baby = Baby(
                        name: babyName,
                        birthDate: babyBirthDate,
                        birthWeight: Double(babyBirthWeight),
                        birthLength: Double(babyBirthLength),
                        gender: babyGender
                    )
                    modelContext.insert(baby)
                }
                
                // Save to SwiftData
                modelContext.insert(user)
                try modelContext.save()
                
                // Try to save to CloudKit if available
                if let container = cloudKitContainer {
                    do {
                        try await saveToCloudKit(user, container: container)
                    } catch {
                        print("CloudKit save failed (continuing anyway): \(error.localizedDescription)")
                    }
                }
                
                await MainActor.run {
                    // Update UserDefaults
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    self.isCompleted = true
                    
                    // Post notification
                    NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
                    
                    self.isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
                print("Error completing onboarding: \(error)")
            }
        }
    }
    
    private func loadImage() async {
        guard let imageSelection else { return }
        
        do {
            let data = try await imageSelection.loadTransferable(type: Data.self)
            guard let data, let image = UIImage(data: data) else { return }
            
            await MainActor.run {
                self.profileImage = image
            }
        } catch {
            print("Error loading image: \(error)")
        }
    }
    
    private func saveToCloudKit(_ user: User, container: CKContainer) async throws {
        // Check iCloud status first
        try await checkCloudKitAvailability(container)
        
        let record = CKRecord(recordType: "User")
        record["name"] = user.name
        record["birthDate"] = user.birthDate
        record["deliveryDate"] = user.deliveryDate
        if let deliveryType = user.deliveryType {
            record["deliveryType"] = deliveryType.rawValue
        }
        
        if let imageData = user.profileImage {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try imageData.write(to: url)
            let asset = CKAsset(fileURL: url)
            record["profileImage"] = asset
            
            defer {
                try? FileManager.default.removeItem(at: url)
            }
            
            try await container.privateCloudDatabase.save(record)
        } else {
            try await container.privateCloudDatabase.save(record)
        }
    }
    
    private func checkCloudKitAvailability(_ container: CKContainer) async throws {
        let status = try await container.accountStatus()
        guard status == .available else {
            throw NSError(
                domain: "PostpartumEase",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "iCloud account not available. Some features may be limited."]
            )
        }
    }
}

extension Notification.Name {
    static let onboardingCompleted = Notification.Name("onboardingCompleted")
} 

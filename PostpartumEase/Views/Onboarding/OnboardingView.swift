import SwiftUI
import PhotosUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        NavigationStack {
            TabView(selection: $viewModel.currentStep) {
                welcomeStep
                    .tag(OnboardingStep.welcome)
                
                profileStep
                    .tag(OnboardingStep.profile)
                
                deliveryStep
                    .tag(OnboardingStep.delivery)
                
                completionStep
                    .tag(OnboardingStep.completion)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: viewModel.currentStep)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.currentStep != .completion {
                        Button("Skip") {
                            viewModel.skipOnboarding()
                        }
                        .foregroundStyle(.secondary)
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .interactiveDismissDisabled()
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
        .onChange(of: viewModel.isCompleted) { completed in
            if completed {
                hasCompletedOnboarding = true
            }
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }
    
    private var welcomeStep: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "heart.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundStyle(.pink)
            
            Text("Welcome to PostpartumEase")
                .font(.title)
                .bold()
            
            Text("Your personal companion for postpartum recovery and wellness.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: { viewModel.nextStep() }) {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.pink)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    private var profileStep: some View {
        VStack(spacing: 20) {
            Text("Create Your Profile")
                .font(.title2)
                .bold()
            
            PhotosPicker(selection: $viewModel.imageSelection,
                        matching: .images,
                        photoLibrary: .shared()) {
                Group {
                    if let profileImage = viewModel.profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(.secondary, lineWidth: 2))
                    } else {
                        Circle()
                            .fill(.secondary.opacity(0.2))
                            .frame(width: 100, height: 100)
                            .overlay {
                                Image(systemName: "camera.fill")
                                    .foregroundStyle(.secondary)
                            }
                    }
                }
            }
            
            TextField("Your Name", text: $viewModel.name)
                .textFieldStyle(.roundedBorder)
            
            DatePicker("Your Birth Date",
                      selection: $viewModel.birthDate,
                      displayedComponents: .date)
            
            Spacer()
            
            Button(action: { viewModel.nextStep() }) {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isProfileValid ? .pink : .gray)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!viewModel.isProfileValid)
        }
        .padding()
    }
    
    private var deliveryStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Baby Information")
                    .font(.title2)
                    .bold()
                
                Toggle("Baby is already born", isOn: $viewModel.isBabyBorn)
                    .padding(.bottom)
                
                if viewModel.isBabyBorn {
                    Group {
                        TextField("Baby's Name", text: $viewModel.babyName)
                            .textFieldStyle(.roundedBorder)
                        
                        DatePicker("Birth Date",
                                  selection: $viewModel.babyBirthDate,
                                  in: ...Date(),
                                  displayedComponents: .date)
                        
                        Picker("Delivery Type", selection: $viewModel.deliveryType) {
                            ForEach(DeliveryType.allCases, id: \.self) { type in
                                Text(type.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        Picker("Gender", selection: $viewModel.babyGender) {
                            ForEach(Gender.allCases, id: \.self) { gender in
                                Text(gender.rawValue).tag(gender)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        HStack {
                            TextField("Weight (kg)", text: $viewModel.babyBirthWeight)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                            
                            TextField("Length (cm)", text: $viewModel.babyBirthLength)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        Text("Expected Due Date")
                            .font(.headline)
                        
                        DatePicker("Due Date",
                                  selection: $viewModel.deliveryDate,
                                  in: Date()...,
                                  displayedComponents: .date)
                        
                        Text("You can add more details after your baby is born.")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
                
                Spacer(minLength: 20)
                
                Button(action: { viewModel.nextStep() }) {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isDeliveryValid ? .pink : .gray)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!viewModel.isDeliveryValid)
            }
            .padding()
        }
    }
    
    private var completionStep: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundStyle(.green)
            
            Text("You're All Set!")
                .font(.title)
                .bold()
            
            Text("Your profile has been created. Let's start your wellness journey together.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: viewModel.completeOnboarding) {
                Text("Begin Journey")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.pink)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.isLoading)
            .padding(.horizontal)
        }
        .padding()
    }
} 
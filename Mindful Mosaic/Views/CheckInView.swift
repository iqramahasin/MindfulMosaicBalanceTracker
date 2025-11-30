import SwiftUI
import Combine

struct CheckInView: View {
    @StateObject private var viewModel = CheckInViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text("How are you feeling today?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top)
                    
                    EmotionSelectionView(selectedEmotion: $viewModel.selectedEmotion)
                    
                    Text("What did you do today?")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    ActivitySelectionView(selectedActivities: $viewModel.selectedActivities)
                    
                    Text("Add a note (optional)")
                        .font(.headline)
                    
                    TextField("Your thoughts...", text: $viewModel.note)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    Button(action: {
                        viewModel.saveCheckIn()
                    }) {
                        Text("Save Check-In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.selectedEmotion != nil ? Color.purple : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(viewModel.selectedEmotion == nil)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .alert("Check-In Saved", isPresented: $viewModel.showSuccessAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("Your check-in has been saved successfully!")
                    }
                }
            }
            .navigationTitle("Daily Check-In")
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
}

struct EmotionSelectionView: View {
    @Binding var selectedEmotion: String?
    
    let emotions = ["Joy", "Calm", "Anxiety", "Pride", "Tiredness", "Inspiration", "Sadness", "Excitement", "Gratitude", "Confusion"]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
            ForEach(emotions, id: \.self) { emotion in
                Button(action: {
                    selectedEmotion = emotion
                }) {
                    Text(emotion)
                        .font(.subheadline)
                        .foregroundColor(selectedEmotion == emotion ? .white : .primary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedEmotion == emotion ? Color.purple : Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct ActivitySelectionView: View {
    @Binding var selectedActivities: Set<String>
    
    let activities = ["Exercise", "Meditation", "Walk", "Hobby", "Social", "Work", "Reading", "Music"]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
            ForEach(activities, id: \.self) { activity in
                Button(action: {
                    if selectedActivities.contains(activity) {
                        selectedActivities.remove(activity)
                    } else {
                        selectedActivities.insert(activity)
                    }
                }) {
                    Text(activity)
                        .font(.subheadline)
                        .foregroundColor(selectedActivities.contains(activity) ? .white : .primary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedActivities.contains(activity) ? Color.blue : Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal)
    }
}

class CheckInViewModel: ObservableObject {
    @Published var selectedEmotion: String?
    @Published var selectedActivities: Set<String> = []
    @Published var note: String = ""
    @Published var showSuccessAlert = false
    
    private let checkInService = CheckInService.shared
    
    func saveCheckIn() {
        guard let emotion = selectedEmotion else {
            return
        }
        
        let checkIn = CheckInData(
            emotion: emotion,
            activities: Array(selectedActivities),
            note: note
        )
        
        checkInService.saveCheckIn(checkIn)
        
        selectedEmotion = nil
        selectedActivities = []
        note = ""
        showSuccessAlert = true
    }
}


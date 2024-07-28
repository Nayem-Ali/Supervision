
# Supervison


## Features

- **Group Creation**: Students or teachers can create a group. When other team members want to join they need a group unique ID to join the group. Each group gets some sub-features such as File Sharing, Task Assigning, Discussion Room and Attendacne both automated and manual. 

- **Schedule**: Teachers can create supervisory meeting schedule with their assigned team. Student can finds their slot by searching their supervisor intial.  


## Tech Stack

- **Flutter**: Used to build the user interface (UI) and ensure a consistent experience across Android and iOS platforms.
- **Firebase**: Provides backend services including Firestore for real-time database operations and Firebase Authentication for user authentication.
- **TensorFlow Lite**: Integrated for implementing the FaceNet model on mobile devices, enabling real-time face recognition.
- **Deep Learning**: FaceNet is used as the deep learning model for face recognition, facilitating accurate attendance tracking.

## Screenshorts
![Homepage & Group Setup](https://drive.google.com/file/d/1cWvJ736R1q-LUMwENZP6DPcSi7_RYXOM/view?usp=drive_link)

## Getting Started

To get started with the project, follow these steps:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/your-repository.git
   cd your-repository
   ```

2. **Set up Firebase**:
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/).
   - Add your Firebase configuration details to the Flutter project.

3. **Run the Flutter app**:
   - Connect a device or emulator.
   - Run the app using Flutter CLI:
     ```bash
     flutter run
     ```

4. **Explore the functionalities**:
   - Navigate through the app to explore attendance management, file sharing, chat features, task assignments, and scheduling.


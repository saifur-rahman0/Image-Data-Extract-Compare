# Image Information Extractor

A Flutter application designed to extract text and other information from images. This app utilizes Google's ML Kit for powerful text recognition capabilities.

## Features

*   **Image Picking**: Select images from your gallery or capture them using the camera.
*   **Text Recognition**: Extracts text from the selected images using Google ML Kit Text Recognition.
*   **State Management**: Built with GetX for efficient state management.
*   **(Potential) API Interaction**: Includes `http` package for potential future integration with web services.

## Dependencies

This project uses the following key dependencies:

*   `flutter`
*   `get`: For state management, navigation, and dependency injection.
*   `image_picker`: To pick images from the gallery or camera.
*   `google_mlkit_text_recognition`: For on-device text recognition from images.
*   `http`: For making HTTP requests.
*   `cupertino_icons`: For iOS style icons.

## Getting Started

This project is a starting point for a Flutter application.

To get started with this project:

1.  Ensure you have Flutter installed. For help, view the [online documentation](https://docs.flutter.dev/).
2.  Clone the repository:
    ```bash
    git clone <your-repository-url>
    ```
3.  Navigate to the project directory:
    ```bash
    cd Image-Information-Extractor
    ```
4.  Install dependencies:
    ```bash
    flutter pub get
    ```
5.  Run the app:
    ```bash
    flutter run
    ```


## Project Structure

The project follows a standard Flutter structure, with GetX modules for organizing features:

*   `lib/app/modules/`: Contains different modules of the application (e.g., home, result).
*   `lib/app/routes/`: Defines application routes and pages.
*   `lib/app/services/`: For services like API communication.
*   `lib/main.dart`: The main entry point of the application.

## Usage

1.  Launch the application.
2.  Use the image picker to select an image from your device's gallery or take a new photo.
3.  The application will process the image and display the extracted text.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m '''Add some AmazingFeature'''`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request


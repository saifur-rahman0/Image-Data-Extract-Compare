#  Image Data Extract & Compare (Flutter Project)

##  Project Overview
This is a simple mobile app built with **Flutter** for the interview task.  
It allows users to:
1. **Upload or capture an image**
2. **Extract text** from the image using **Google ML Kit OCR**
3. **Detect important entities** (temperature or product names)
    - If text contains **temperature (e.g., 28°C / 28 Celcius)** → compare with **OpenWeather API**
    - If text contains **product names** → detect using **Hugging Face NER model (`dslim/bert-base-NER`)**
4. **Compare results** with online APIs and highlight matches/differences.

---

##  Features
-  Capture or upload image from gallery
-  OCR (Optical Character Recognition) using **Google ML Kit**
-  Temperature detection with regex (`°C`, `Celcius`)
-  Compare extracted temperature with **OpenWeather API** (real city data)
-  Product name detection with **Hugging Face Inference API**
-  Display OCR result and API result side by side
-  Highlight match or mismatch in the UI
-  Clean, minimal UI built with **Flutter Widgets**
-  Extendable architecture (easy to add new entity types later)

---

##  Tech Stack
- **Frontend:** Flutter (Dart)
- **OCR:** Google ML Kit (on-device, free)
- **Weather API:** [OpenWeather](https://openweathermap.org/api)
- **NER API (Product Detection):** [Hugging Face Inference API](https://huggingface.co/models/dslim/bert-base-NER)
- **State Management:** GetX (or setState if minimal)
- **HTTP Client:** `http` package

---


import torch
import os
from services.model import get_model

DISEASES = [
    'Atelectasis', 
    'Cardiomegaly', 
    'Consolidation', 
    'Edema',
    'Effusion', 
    'Emphysema', 
    'Fibrosis', 
    'Hernia',
    'Infiltration', 
    'Mass', 
    'No Finding', 
    'Nodule',
    'Pleural_Thickening', 
    'Pneumonia', 
    'Pneumothorax'
]

NUM_CLASSES = len(DISEASES)

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL_PATH = os.path.join(BASE_DIR, "models", "best_model.pth")

# Load model
model = get_model(NUM_CLASSES)
model.load_state_dict(torch.load(MODEL_PATH, map_location=torch.device('cpu')))
model.eval()


def run_inference(image):
    with torch.no_grad():
        outputs = model(image)

        probs = torch.sigmoid(outputs).squeeze().tolist()

        results = []
        for i, prob in enumerate(probs):
            results.append({
                "disease": DISEASES[i],
                "confidence": float(prob)
            })

        # Sort by confidence (highest first)
        results = sorted(results, key=lambda x: x['confidence'], reverse=True)

        top = results[0]

        # 🧠 Smart prediction logic
        prediction = "Normal" if top["disease"] == "No Finding" else "Abnormal"

        return {
            "prediction": prediction,
            "details": results
        }
from flask import Blueprint, request, jsonify
from services.model_service import run_inference
from services.preprocessing import preprocess_image

predict_bp = Blueprint("predict", __name__)

@predict_bp.route("/predict", methods=["POST"])
def predict():
    if 'image' not in request.files:
        return jsonify({"error": "No image provided"}), 400

    file = request.files['image']

    try:
        # Preprocess image
        image = preprocess_image(file)

        # Run model inference
        result = run_inference(image)
        return jsonify(result)

    except Exception as e:
        return jsonify({"error": str(e)}), 500
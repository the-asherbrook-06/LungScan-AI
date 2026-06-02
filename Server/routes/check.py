from flask import Blueprint

check_bp = Blueprint("check", __name__)

@check_bp.route("/check", methods=["GET"])
def predict():
    return "SERVER STATUS: ✅ Server is alive and well"
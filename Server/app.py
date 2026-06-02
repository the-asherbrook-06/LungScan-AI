from flask import Flask
from routes.predict import predict_bp
from routes.check import check_bp

app = Flask(__name__)

app.register_blueprint(predict_bp, url_prefix="/api")
app.register_blueprint(check_bp, url_prefix="/api")

if __name__ == "__main__":
    app.run(debug=True)
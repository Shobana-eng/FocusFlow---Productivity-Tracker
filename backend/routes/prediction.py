from flask import Blueprint, request, jsonify

prediction = Blueprint("prediction", __name__)


@prediction.route("/predict", methods=["POST"])
def predict():

    try:
        data = request.get_json()

        study_hours = float(data.get("study_hours", 0))
        sleep_hours = float(data.get("sleep_hours", 0))
        screen_time = float(data.get("screen_time", 0))

        # Keep values within reasonable ranges
        study_hours = max(0, min(study_hours, 12))
        sleep_hours = max(0, min(sleep_hours, 12))
        screen_time = max(0, min(screen_time, 16))

        # Productivity scoring
        study_score = min(study_hours / 6 * 100, 100)

        if 7 <= sleep_hours <= 9:
            sleep_score = 100
        elif 6 <= sleep_hours < 7 or 9 < sleep_hours <= 10:
            sleep_score = 80
        elif 5 <= sleep_hours < 6 or 10 < sleep_hours <= 11:
            sleep_score = 60
        else:
            sleep_score = 40

        screen_score = max(0, 100 - (screen_time / 12 * 100))

        productivity_score = (
            (study_score * 0.50)
            + (sleep_score * 0.30)
            + (screen_score * 0.20)
        )

        productivity_score = round(
            max(0, min(productivity_score, 100)), 2
        )

        # Productivity level
        if productivity_score >= 80:
            level = "Excellent"
        elif productivity_score >= 60:
            level = "Good"
        elif productivity_score >= 40:
            level = "Average"
        else:
            level = "Low"

        # Recommendations
        recommendations = []

        if study_hours < 2:
            recommendations.append(
                "Increase your focused study time gradually."
            )

        if sleep_hours < 7:
            recommendations.append(
                "Try to get at least 7 hours of sleep."
            )

        if sleep_hours > 9:
            recommendations.append(
                "Maintain a consistent sleep schedule."
            )

        if screen_time > 5:
            recommendations.append(
                "Reduce unnecessary screen time during study hours."
            )

        if not recommendations:
            recommendations.append(
                "Great job! Maintain your current productivity habits."
            )

        return jsonify({
            "success": True,
            "productivity_score": productivity_score,
            "level": level,
            "recommendations": recommendations,
            "inputs": {
                "study_hours": study_hours,
                "sleep_hours": sleep_hours,
                "screen_time": screen_time
            }
        })

    except Exception as e:

        return jsonify({
            "success": False,
            "error": str(e)
        }), 400
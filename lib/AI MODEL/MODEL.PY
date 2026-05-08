from flask import Flask, jsonify, request
from flask_cors import CORS
import firebase_admin
from firebase_admin import credentials, firestore
import google.generativeai as genai
import json
import time

print("🚀 PlanNova Server Starting...")

# =========================
# 🔐 Firebase Setup
# =========================

cred = credentials.Certificate(
    r"C:\Users\mk\first_project\plannova\lib\AI MODEL\serviceAccountKey (1).json"
)

firebase_admin.initialize_app(cred)

db = firestore.client()

# =========================
# 🤖 Gemini Setup
# =========================

genai.configure(
    api_key="AIzaSyDPUry8RKDs1vImPXb1e3R6QaCTKbhtxzw"
)

model = genai.GenerativeModel(
    "gemini-flash-latest"
)

# =========================
# 🌐 Flask Setup
# =========================

app = Flask(__name__)
CORS(app)

# =========================
# 🧠 SYSTEM PROMPT
# =========================

SYSTEM_PROMPT = """
You are PlanNova AI, a productivity and scheduling expert.

You must generate a weekly schedule in JSON format.

IMPORTANT TIME RULE:
- All durations are in MINUTES.
- 60 minutes = 1 hour only for understanding.
- Never assume hours automatically.

SCHEDULING RULES:
- If duration is invalid → use 60 minutes.
- Respect canSplit:
    - true → task may be divided.
    - false → task must stay continuous.
- Respect flexible:
    - false → strict timing.
- Deep tasks should be scheduled in high-focus periods.
- Balance workload across days.
- Avoid overloading one day.
- Add proper breaks between heavy tasks.

OUTPUT RULE:
Return ONLY valid JSON array.

Each task MUST contain:
[
  {
    "title": "",
    "category": "",
    "type": "",
    "priority": "",
    "duration": 0,
    "day": "",
    "startTime": "",
    "endTime": "",
    "status": "pending",
    "completed": false,
    "progress": 0,
    "flexible": true,
    "canSplit": false
  }
]

No markdown.
No explanations.
No extra text.
"""

# =========================
# 📥 Get Firestore Data
# =========================

def get_input_data(plan_id):
    doc = db.collection("plans").document(plan_id).get()

    if not doc.exists:
        return None

    return doc.to_dict()

# =========================
# 🧠 Build Prompt
# =========================

def build_prompt(data):

    energy = data.get("energy", "Normal")
    plan_type = data.get("planType", "Balanced")

    text = f"""
User Energy Level: {energy}
Preferred Plan Type: {plan_type}

Available Days:
"""

    # الأيام المتاحة
    days = data.get("days", {})

    active_days = []

    for day, active in days.items():
        if active:
            active_days.append(day)

    text += ", ".join(active_days)

    # التاسكات
    text += "\n\nTasks:\n\n"

    for task in data.get("tasks", []):

        title = task.get("title", "")
        duration = task.get("duration", 60)
        task_type = task.get("type", "General")
        category = task.get("category", "General")
        priority = task.get("priority", "Medium")
        flexible = task.get("flexible", True)
        can_split = task.get("canSplit", False)

        if duration == 0:
            duration = 60

        text += f"""
Task:
Title: {title}
Duration: {duration} minutes
Type: {task_type}
Category: {category}
Priority: {priority}
Flexible: {flexible}
Can Split: {can_split}

"""

    return text

# =========================
# 🚀 Generate API
# =========================

@app.route("/generate", methods=["POST"])
def generate():

    try:

        data = request.json

        # Validation
        if not data or "plan_id" not in data:
            return jsonify({
                "status": "error",
                "message": "plan_id is required"
            }), 400

        plan_id = data["plan_id"]

        print(f"📌 Plan ID: {plan_id}")

        # Get plan from Firestore
        raw_data = get_input_data(plan_id)

        if not raw_data:
            return jsonify({
                "status": "error",
                "message": "Plan not found"
            }), 404

        # Build prompt
        prompt = build_prompt(raw_data)

        print("📤 Sending request to Gemini...")

        # Retry logic
        response = None

        for i in range(3):

            try:

                response = model.generate_content(
                    SYSTEM_PROMPT + "\n\n" + prompt
                )

                break

            except Exception as e:

                print(f"⚠️ Retry {i+1}: {e}")

                time.sleep(2)

        if response is None:
            return jsonify({
                "status": "error",
                "message": "Gemini failed"
            }), 500

        print("📥 Gemini Response:")
        print(response.text)

        # تنظيف الـ markdown
        clean_text = response.text.strip()

        if clean_text.startswith("```json"):
            clean_text = clean_text.replace("```json", "")
            clean_text = clean_text.replace("```", "")

        clean_text = clean_text.strip()

        # تحويل JSON
        plan_json = json.loads(clean_text)

        # حفظ البلان
        db.collection("plans").document(plan_id).update({
            "generatedPlan": plan_json,
            "status": "completed",
            "generatedAt": firestore.SERVER_TIMESTAMP
        })

        print("✅ Plan Generated Successfully")

        return jsonify({
            "status": "success",
            "data": plan_json
        })

    except Exception as e:

        print("🔥 ERROR:", e)

        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

# =========================
# ▶️ Run Server
# =========================

if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True
    )
from flask import Flask, request, jsonify # type: ignore
import psycopg2 # type: ignore
from werkzeug.security import generate_password_hash, check_password_hash # type: ignore

app = Flask(__name__)

# Configuración de conexión a la base de datos
def get_db_connection():
    return psycopg2.connect(
        dbname="postgres",
        user="postgres",
        password="root",
        host="localhost"
    )

# Ruta de registro
@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data['username']
    # password = generate_password_hash(data['password'], method='pbkdf2:sha256')
    password = data['password']

    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("INSERT INTO usuarios (username, password) VALUES (%s, %s)", (username, password))
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"message": "Usuario registrado con éxito"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400

# Ruta de login
@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data['username']
    password = data['password']

    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT password FROM usuarios WHERE username = %s", (username,))
    user = cur.fetchone()
    cur.close()
    conn.close()

    # if user and check_password_hash(user[0], password):
    if user:
        return jsonify(success=True), 200
    else:
        return jsonify(success=False), 401

if __name__ == '__main__':
    app.run(host='0.0.0.0',port="5001", debug=True)

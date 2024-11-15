# from flask import Flask, request, jsonify # type: ignore
# import psycopg2 # type: ignore
# from werkzeug.security import generate_password_hash, check_password_hash # type: ignore

# app = Flask(__name__)

# # Configuración de conexión a la base de datos
# def get_db_connection():
#     return psycopg2.connect(
#         dbname="postgres",
#         user="postgres",
#         password="root",
#         host="localhost"
#     )

# # Ruta de registro
# @app.route('/register', methods=['POST'])
# def register():
#     data = request.get_json()
#     username = data['username']
#     # password = generate_password_hash(data['password'], method='pbkdf2:sha256')
#     password = data['password']

#     try:
#         conn = get_db_connection()
#         cur = conn.cursor()
#         cur.execute("INSERT INTO usuarios (username, password) VALUES (%s, %s)", (username, password))
#         conn.commit()
#         cur.close()
#         conn.close()
#         # return jsonify({"message": "Usuario registrado con éxito"}), 201
#         return jsonify({"success": True, "message": "Usuario registrado con éxito"}), 201
#     except Exception as e:
#         # return jsonify({"error": str(e)}), 400
#         return jsonify({"success": False, "error": str(e)}), 400



# @app.route('/login', methods=['POST'])
# def login():
#     data = request.get_json()
#     username = data['username']
#     password = data['password']

#     conn = get_db_connection()
#     cur = conn.cursor()
#     cur.execute("SELECT password FROM usuarios WHERE username = %s", (username,))
#     user = cur.fetchone()
#     cur.close()
#     conn.close()

#     # if user and check_password_hash(user[0], password):
#     if user:
#         return jsonify(success=True), 200
#     else:
#         return jsonify(success=False), 401

# if __name__ == '__main__':
#     app.run(host='0.0.0.0',port="5001", debug=True)


from flask import Flask, request, jsonify
import firebase_admin
from firebase_admin import credentials, firestore
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)

# Inicializar Firebase
cred = credentials.Certificate("/Users/kevinjapa/Desktop/Materia/Computacion Paralela/proyectoInterciclo/app-social-media-552ea-firebase-adminsdk-jc51c-746b9b24f5.json")  # Asegúrate de colocar tu archivo de clave JSON aquí
firebase_admin.initialize_app(cred)
db = firestore.client()

# Ruta de registro
@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data['username']
    password = generate_password_hash(data['password'], method='pbkdf2:sha256')  # Cifrado de contraseña

    try:
        # Verificar si el usuario ya existe
        users_ref = db.collection('users').where('username', '==', username).get()
        if users_ref:
            return jsonify({"success": False, "message": "Usuario ya existe"}), 400

        # Crear nuevo usuario en Firestore
        db.collection('users').add({
            "username": username,
            "password": password  # Almacenar contraseña cifrada
        })
        return jsonify({"success": True, "message": "Usuario registrado con éxito"}), 201
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400

# Ruta de inicio de sesión
@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data['username']
    password = data['password']

    try:
        # Buscar usuario en Firestore
        users_ref = db.collection('users').where('username', '==', username).get()
        if not users_ref:
            return jsonify({"success": False, "message": "Usuario no encontrado"}), 401

        # Comparar contraseñas
        user = users_ref[0].to_dict()
        if check_password_hash(user['password'], password):
            return jsonify({"success": True, "message": "Inicio de sesión exitoso"}), 200
        else:
            return jsonify({"success": False, "message": "Contraseña incorrecta"}), 401
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port="5001", debug=True)
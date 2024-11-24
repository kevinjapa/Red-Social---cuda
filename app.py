from flask import Flask, request, jsonify
import firebase_admin
from firebase_admin import credentials, firestore, storage, initialize_app
from werkzeug.security import generate_password_hash, check_password_hash
import os
# import pycuda.driver as drv
# from pycuda.compiler import SourceModule
from PIL import Image
import io
import time
import numpy as np
from werkzeug.utils import secure_filename
from flask import send_from_directory
from flask_cors import CORS
import random


app = Flask(__name__)
CORS(app)
# Inicializar Firebase
cred = credentials.Certificate("/Users/kevinjapa/Desktop/Materia/Computacion Paralela/proyectoInterciclo/app-social-media-552ea-firebase-adminsdk-jc51c-746b9b24f5.json")
# firebase_admin.initialize_app(cred)
initialize_app(cred, {
    'storageBucket': 'app-social-media-552ea.firebasestorage.app'
})
db = firestore.client()

# Ruta de registro
@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data['username']
    password = generate_password_hash(data['password'], method='pbkdf2:sha256')  
    nombre = data['nombre']
    apellido = data['apellido']
    try:
        # Verificar si el usuario ya existe
        users_ref = db.collection('users').where('username', '==', username).get()
        if users_ref:
            return jsonify({"success": False, "message": "Usuario ya existe"}), 400

        # Crear nuevo usuario en Firestore
        db.collection('users').add({
            "username": username,
            "password": password,  # Almacenar contraseña cifrada
            "nombre": nombre,
            "apellido": apellido
        })
        return jsonify({"success": True, "message": "Usuario registrado con éxito"}), 201
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data['username']
    password = data['password']

    try:
        users_ref = db.collection('users').where('username', '==', username).get()
        if not users_ref:
            return jsonify({"success": False, "message": "Usuario no encontrado"}), 401

        user = users_ref[0].to_dict()
        if check_password_hash(user['password'], password):
            return jsonify({"success": True, "message": "Inicio de sesión exitoso"}), 200
        else:
            return jsonify({"success": False, "message": "Contraseña incorrecta"}), 401
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400

@app.route('/user/<username>', methods=['GET'])
def get_user(username):
    try:
        users_ref = db.collection('users').where('username', '==', username).get()
        if not users_ref:
            return jsonify({"success": False, "message": "Usuario no encontrado"}), 404

        user = users_ref[0].to_dict()
        return jsonify({
            "username": user['username'],
            "nombre": user['nombre'],
            "apellido": user['apellido']
        }), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400

@app.route('/update-password', methods=['POST'])
def update_password():
    data = request.get_json()
    username = data['username']
    new_password = generate_password_hash(data['new_password'], method='pbkdf2:sha256')

    try:
        users_ref = db.collection('users').where('username', '==', username).get()
        if not users_ref:
            return jsonify({"success": False, "message": "Usuario no encontrado"}), 404

        user_id = users_ref[0].id
        db.collection('users').document(user_id).update({"password": new_password})
        return jsonify({"success": True, "message": "Contraseña actualizada"}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400
    
UPLOAD_FOLDER = 'static/uploads/'
PROCESSED_FOLDER = 'static/processed/'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['PROCESSED_FOLDER'] = PROCESSED_FOLDER

os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(PROCESSED_FOLDER, exist_ok=True)

@app.route('/upload-image', methods=['POST'])
def upload_image():
    try:
        username = request.form.get('username')  # Asegúrate de que Flutter envía el nombre de usuario
        if not username:
            return jsonify({"success": False, "message": "Falta el nombre de usuario"}), 400

        if 'file' not in request.files:
            return jsonify({"success": False, "message": "No se encontró el archivo"}), 400

        file = request.files['file']

        if file.filename == '':
            return jsonify({"success": False, "message": "No se seleccionó un archivo"}), 400

        # Crear carpeta para el usuario si no existe
        user_folder = os.path.join(app.config['UPLOAD_FOLDER'], username)
        os.makedirs(user_folder, exist_ok=True)

        # Generar un nombre único para la imagen
        # filename = f"{secure_filename(file.filename)}{int(time.time())}.jpg"
        filename = f"{secure_filename(file.filename).split('.')[0]}_{int(time.time())}.jpg"
        file_path = os.path.join(user_folder, filename)
        file.save(file_path)

        # Construir la URL de la imagen
        image_url = f"http://{request.host}/static/uploads/{username}/{filename}"
        

        # Guardar en Firestore
        db.collection('posts').add({
            "username": username,
            "imageUrl": filename,  # Guarda solo el nombre del archivo
            "likes": [],  # Lista vacía inicialmente
            "comments": [],  # Lista vacía inicialmente
        })

        return jsonify({
            "success": True,
            "message": "Imagen subida con éxito",
            "file_path": file_path,
            "image_url": image_url
        }), 200

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/user-images/<username>', methods=['GET'])
def get_user_images(username):
    try:
        # Aquí suponemos que los nombres de los archivos subidos incluyen información del usuario
        user_folder = os.path.join(app.config['UPLOAD_FOLDER'], username)
        if not os.path.exists(user_folder):
            return jsonify({"success": False, "message": "No hay imágenes para este usuario"}), 404

        # Listar todos los archivos en la carpeta del usuario
        images = os.listdir(user_folder)
        image_urls = [f"/static/uploads/{username}/{img}" for img in images]

        return jsonify({"success": True, "images": image_urls}), 200

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/static/uploads/<path:filename>')
def serve_image(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

@app.route('/feed', methods=['GET'])
def get_feed():
    try:
        # Ruta base de uploads
        uploads_path = app.config['UPLOAD_FOLDER']
        if not os.path.exists(uploads_path):
            return jsonify({"success": False, "message": "No se encontró el directorio de uploads"}), 404

        # Recolectar imágenes de todos los usuarios
        all_images = []

        # Buscar carpetas de usuarios en 'static/uploads'
        for username_folder in os.listdir(uploads_path):
            user_folder = os.path.join(uploads_path, username_folder)
            if os.path.isdir(user_folder):
                # Buscar información del usuario en Firestore
                users_ref = db.collection('users').where('username', '==', username_folder).get()
                if not users_ref:
                    continue  # Ignorar carpetas sin usuario válido

                user_data = users_ref[0].to_dict()

                # Listar todas las imágenes del usuario
                user_images = []
                for img in os.listdir(user_folder):
                    img_path = os.path.join(user_folder, img)
                    if os.path.isfile(img_path):
                        # Obtener la fecha de modificación de la imagen
                        creation_time = os.path.getmtime(img_path)

                        # Buscar publicación correspondiente en Firestore
                        post_ref = db.collection('posts').where('imageUrl', '==', img).get()
                        if post_ref:
                            post_data = post_ref[0].to_dict()
                            likes = post_data.get('likes', [])
                            comments = post_data.get('comments', [])
                        else:
                            likes = []  # Si no hay likes registrados, asignar lista vacía
                            comments = []

                        user_images.append({

                            
                            "username": user_data['username'],
                            # "username": f"{user_data['nombre']} {user_data['apellido']}",
                            "nombre": user_data['nombre'],
                            "apellido": user_data['apellido'],
                            "imageUrl": f"/static/uploads/{username_folder}/{img}",
                            "description": f"Publicación de {user_data['nombre']} {user_data['apellido']}",
                            # "description": f"Publicación de {user_data['username']}",
                            "timestamp": creation_time,  # Timestamp para ordenarlas después
                            "likes": likes,  # Incluir los likes en la respuesta
                            "comments": comments
                        })

                user_images.sort(key=lambda x: x['timestamp'], reverse=True)

                if user_images:
                    all_images.append(user_images[0])  # Agregar la última publicación primero

                if len(user_images) > 1:
                    remaining_images = user_images[1:]
                    random.shuffle(remaining_images)
                    all_images.extend(remaining_images)

        # Ordenar la lista final por fecha (las más recientes primero)
        all_images.sort(key=lambda x: x['timestamp'], reverse=True)

        return jsonify({"success": True, "posts": all_images}), 200

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/like-post', methods=['POST'])
def like_post():
    try:
        # Obtener los datos de la solicitud
        data = request.get_json()
        image_url = data.get('imageUrl')
        username = data.get('username')

        if not image_url or not username:
            return jsonify({"success": False, "message": "Datos incompletos"}), 400

        # Extraer el nombre del archivo base del imageUrl
        image_filename = os.path.basename(image_url)
        print(f"Procesando like para imageFilename: {image_filename} por usuario: {username}")

        # Buscar la publicación en Firestore
        post_ref = db.collection('posts').where('imageUrl', '==', image_filename).get()

        if not post_ref:
            print("No se encontró la publicación con el imageUrl proporcionado.")
            return jsonify({"success": False, "message": "Publicación no encontrada"}), 404

        post_id = post_ref[0].id
        post_data = post_ref[0].to_dict()

        # Verificar o inicializar el campo likes como lista
        likes = post_data.get('likes', [])
        print(f"Estado actual de likes antes de actualizar: {likes}")

        if not isinstance(likes, list):
            likes = []  # Inicializar como lista vacía si no lo es

        # Verificar si el usuario ya dio like
        if username in likes:
            print(f"El usuario {username} ya dio like.")
        else:
            likes.append(username)  # Agregar el usuario a la lista de likes
            print(f"Agregando usuario {username} a likes.")

            # Actualizar el campo likes en Firestore
            try:
                db.collection('posts').document(post_id).update({'likes': likes})
                print(f"Likes actualizados en Firestore: {likes}")
            except Exception as e:
                print(f"Error al actualizar Firestore: {e}")
                return jsonify({"success": False, "message": "Error al actualizar Firestore"}), 500

        # Devolver la lista completa de likes
        return jsonify({"success": True, "likes": likes}), 200
    except Exception as e:
        print(f"Error en el servidor: {e}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/comment-post', methods=['POST'])
def comment_post():
    try:
        # Validar los datos de entrada
        data = request.get_json()
        if not data or 'username' not in data or 'imageUrl' not in data or 'comment' not in data:
            return jsonify({"success": False, "message": "Faltan datos en la solicitud"}), 400

        username = data['username'].strip()
        image_url = data['imageUrl'].strip()
        comment = data['comment'].strip()

        image_filename = image_url.split("/")[-1]

        if not username or not image_url or not comment:
            return jsonify({"success": False, "message": "Datos incompletos o inválidos"}), 400

        # Obtener la publicación correspondiente
        post_ref = db.collection('posts').where('imageUrl', '==', image_filename).get()
        if not post_ref:
            return jsonify({"success": False, "message": "Publicación no encontrada"}), 404

        post_id = post_ref[0].id
        post_data = post_ref[0].to_dict()

        # Agregar el comentario
        comments = post_data.get('comments', [])
        comments.append({
            'username': username,
            'comment': comment,
            'timestamp': time.time()
        })

        # Actualizar Firestore con los nuevos comentarios
        db.collection('posts').document(post_id).update({'comments': comments})

        return jsonify({"success": True, "comments": comments}), 200

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/upload-profile-image', methods=['POST'])
def upload_profile_image():
    try:
        username = request.form.get('username')
        file = request.files['file']

        if not username or not file:
            return jsonify({"success": False, "message": "Faltan datos"}), 400

        # Nombre único para la imagen
        filename = f"profile_{username}.jpg"

        # Accede al bucket configurado
        bucket = storage.bucket()
        blob = bucket.blob(f"profile_pictures/{filename}")
        blob.upload_from_file(file, content_type=file.content_type)

        # Obtener URL pública
        blob.make_public()
        image_url = blob.public_url

        # Actualizar Firestore con la nueva URL
        users_ref = db.collection('users').where('username', '==', username).get()
        if not users_ref:
            return jsonify({"success": False, "message": "Usuario no encontrado"}), 404

        user_id = users_ref[0].id
        db.collection('users').document(user_id).update({"profileImage": image_url})

        return jsonify({"success": True, "imageUrl": image_url}), 200
    except Exception as e:
        print(f"Error desconocido: {e}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/profile-image/<username>', methods=['GET'])
def get_profile_image(username):
    try:
        users_ref = db.collection('users').where('username', '==', username).get()
        if not users_ref:
            return jsonify({"success": False, "message": "Usuario no encontrado"}), 404

        user_data = users_ref[0].to_dict()
        image_url = user_data.get("profileImage", "")

        return jsonify({"success": True, "imageUrl": image_url}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500



# Codigo para implementar lo de cuda 

# # drv.init()
# # device = drv.Device(0)
# # context = device.make_context()

# # mod = SourceModule("""
# #     __global__ void applyConvolutionGPU(unsigned char* d_image, double* d_kernel, double* d_result, int width, int height, int kernel_size) {
# #         int x = blockIdx.x * blockDim.x + threadIdx.x;
# #         int y = blockIdx.y * blockDim.y + threadIdx.y;
# #         int half_kernel = kernel_size / 2;

# #         if (x < width && y < height) {
# #             if (x >= half_kernel && x < width - half_kernel && y >= half_kernel && y < height - half_kernel) {
# #                 double sum = 0.0;
# #                 for (int ky = -half_kernel; ky <= half_kernel; ++ky) {
# #                     for (int kx = -half_kernel; kx <= half_kernel; ++kx) {
# #                         int pixel_value = d_image[(y + ky) * width + (x + kx)];
# #                         sum += pixel_value * d_kernel[(ky + half_kernel) * kernel_size + (kx + half_kernel)];
# #                     }
# #                 }
# #                 d_result[y * width + x] = sum;
# #             } else {
# #                 d_result[y * width + x] = 0;
# #             }
# #         }
# #     }
# # """)

# def create_emboss_kernel(kernel_size):
#     kernel = np.zeros(kernel_size * kernel_size, dtype=np.float64)
#     half_size = kernel_size // 2
#     for y in range(kernel_size):
#         for x in range(kernel_size):
#             if x < half_size and y < half_size:
#                 kernel[y * kernel_size + x] = -1
#             elif x > half_size and y > half_size:
#                 kernel[y * kernel_size + x] = 1
#             elif x == half_size and y == half_size:
#                 kernel[y * kernel_size + x] = 1
#     return kernel

# def create_gabor_kernel(kernel_size, sigma, theta, lambda_, gamma, psi):
#     kernel = np.zeros((kernel_size, kernel_size), dtype=np.float64)
#     half_size = kernel_size // 2
#     for y in range(-half_size, half_size + 1):
#         for x in range(-half_size, half_size + 1):
#             x_theta = x * np.cos(theta) + y * np.sin(theta)
#             y_theta = -x * np.sin(theta) + y * np.cos(theta)
#             gauss = np.exp(-(x_theta**2 + gamma**2 * y_theta**2) / (2 * sigma**2))
#             sinusoid = np.cos(2 * np.pi * x_theta / lambda_ + psi)
#             kernel[y + half_size, x + half_size] = gauss * sinusoid
#     return kernel.flatten()

# def create_high_boost_kernel(kernel_size, A):
#     kernel = -np.ones(kernel_size * kernel_size, dtype=np.float64)
#     half_size = kernel_size // 2
#     kernel[half_size * kernel_size + half_size] = A + (kernel_size * kernel_size) - 1
#     return kernel

# def apply_filter(image, kernel, width, height, kernel_size, hilos):
#     dest = np.zeros_like(image, dtype=np.float64)
#     block_dim = int(np.sqrt(hilos))
#     block_size = (block_dim, block_dim, 1)
#     grid_size = (int(np.ceil(width / block_size[0])), int(np.ceil(height / block_size[1])), 1)

    # context.push()
    # try:
    #     applyConvolutionGPU = mod.get_function("applyConvolutionGPU")
    #     start_time = time.time()
    #     applyConvolutionGPU(
    #         drv.In(image), drv.In(kernel), drv.Out(dest),
    #         np.int32(width), np.int32(height), np.int32(kernel_size),
    #         block=block_size, grid=grid_size
    #     )
    #     context.synchronize()
    #     gpu_time = time.time() - start_time
    # finally:
    #     context.pop()

    # min_val, max_val = np.min(dest), np.max(dest)
    # normalized_image = ((dest - min_val) / (max_val - min_val) * 255).astype(np.uint8)

    # return {
    #     "filtered_image": normalized_image,
    #     "gpu_time": gpu_time
    # }


# @app.route('/')
# def index():
#     return jsonify({"message": "Welcome to the image filter API!"})

# @app.route('/upload', methods=['POST'])
# def upload_file():
#     if 'file' not in request.files:
#         return jsonify({"error": "No file part in the request"})

#     file = request.files['file']
#     if file.filename == '':
#         return jsonify({"error": "No file selected for uploading"})

#     filepath = os.path.join(app.config['UPLOAD_FOLDER'], file.filename)
#     file.save(filepath)

#     filter_type = request.form.get('filter_type')
#     kernel_size = int(request.form.get('kernel_size', 5))
#     hilos = int(request.form.get('hilos', 1024))

#     gray_image, width, height = load_image(filepath)

#     if filter_type == 'emboss':
#         kernel = create_emboss_kernel(kernel_size)
#     elif filter_type == 'gabor':
#         kernel = create_gabor_kernel(kernel_size, 4.0, 0, 10.0, 0.5, 0)
#     elif filter_type == 'high_boost':
#         kernel = create_high_boost_kernel(kernel_size, 10.0)
#     else:
#         return jsonify({"error": "Unsupported filter type"})

#     result_data = apply_filter(gray_image, kernel, width, height, kernel_size, hilos)

#     processed_filepath = os.path.join(app.config['PROCESSED_FOLDER'], 'processed_' + file.filename)
#     save_image(result_data["filtered_image"], width, height, processed_filepath)

#     return jsonify({
#         "original_image": filepath,
#         "processed_image": processed_filepath,
#         "gpu_time": result_data["gpu_time"]
#     })

# @app.route('/download/<filename>', methods=['GET'])
# def download_file(filename):
#     filepath = os.path.join(app.config['PROCESSED_FOLDER'], filename)
#     if os.path.exists(filepath):
#         return send_file(filepath, as_attachment=True)
#     else:
#         return jsonify({"error": "File not found"}), 404

# def load_image(filepath):
#     image = Image.open(filepath).convert('L')
#     gray_image = np.array(image, dtype=np.uint8)
#     width, height = image.size
#     return gray_image, width, height

# def save_image(image, width, height, filepath):
#     result_image = Image.fromarray(image)
#     result_image.save(filepath)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port="5001", debug=True)
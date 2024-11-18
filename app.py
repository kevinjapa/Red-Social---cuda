from flask import Flask, request, jsonify
import firebase_admin
from firebase_admin import credentials, firestore, storage
from werkzeug.security import generate_password_hash, check_password_hash
import os
# import pycuda.driver as drv
# from pycuda.compiler import SourceModule
from PIL import Image
import io
import time
import numpy as np
from werkzeug.utils import secure_filename


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

#  devolver datos de ususario

# Ruta para obtener datos del usuario
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
    
# cambiar contrasena
# Ruta para actualizar la contraseña
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

# Ruta para subir una imagen
# @app.route('/upload-image', methods=['POST'])
# def upload_image():
#     if 'file' not in request.files:
#         return jsonify({"success": False, "message": "No se encontró el archivo"}), 400

#     file = request.files['file']

#     if file.filename == '':
#         return jsonify({"success": False, "message": "No se seleccionó un archivo"}), 400

#     # Guardar el archivo
#     try:
#         filename = secure_filename(file.filename)
#         file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
#         file.save(file_path)

#         return jsonify({
#             "success": True,
#             "message": "Imagen subida con éxito",
#             "file_path": file_path
#         }), 200
#     except Exception as e:
#         return jsonify({"success": False, "error": str(e)}), 500

@app.route('/upload-image', methods=['POST'])
def upload_image():
    try:
        # Verificar si hay un archivo en la solicitud
        if 'file' not in request.files:
            return jsonify({"success": False, "message": "No se encontró el archivo"}), 400

        file = request.files['file']

        # Validar el nombre del archivo
        if file.filename == '':
            return jsonify({"success": False, "message": "No se seleccionó un archivo"}), 400

        # Guardar el archivo de manera segura
        filename = secure_filename(file.filename)
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(file_path)

        return jsonify({
            "success": True,
            "message": "Imagen subida con éxito",
            "file_path": file_path
        }), 200

    except Exception as e:
        # Captura cualquier error
        return jsonify({"success": False, "error": str(e)}), 500

# drv.init()
# device = drv.Device(0)
# context = device.make_context()

# mod = SourceModule("""
#     __global__ void applyConvolutionGPU(unsigned char* d_image, double* d_kernel, double* d_result, int width, int height, int kernel_size) {
#         int x = blockIdx.x * blockDim.x + threadIdx.x;
#         int y = blockIdx.y * blockDim.y + threadIdx.y;
#         int half_kernel = kernel_size / 2;

#         if (x < width && y < height) {
#             if (x >= half_kernel && x < width - half_kernel && y >= half_kernel && y < height - half_kernel) {
#                 double sum = 0.0;
#                 for (int ky = -half_kernel; ky <= half_kernel; ++ky) {
#                     for (int kx = -half_kernel; kx <= half_kernel; ++kx) {
#                         int pixel_value = d_image[(y + ky) * width + (x + kx)];
#                         sum += pixel_value * d_kernel[(ky + half_kernel) * kernel_size + (kx + half_kernel)];
#                     }
#                 }
#                 d_result[y * width + x] = sum;
#             } else {
#                 d_result[y * width + x] = 0;
#             }
#         }
#     }
# """)

def create_emboss_kernel(kernel_size):
    kernel = np.zeros(kernel_size * kernel_size, dtype=np.float64)
    half_size = kernel_size // 2
    for y in range(kernel_size):
        for x in range(kernel_size):
            if x < half_size and y < half_size:
                kernel[y * kernel_size + x] = -1
            elif x > half_size and y > half_size:
                kernel[y * kernel_size + x] = 1
            elif x == half_size and y == half_size:
                kernel[y * kernel_size + x] = 1
    return kernel

def create_gabor_kernel(kernel_size, sigma, theta, lambda_, gamma, psi):
    kernel = np.zeros((kernel_size, kernel_size), dtype=np.float64)
    half_size = kernel_size // 2
    for y in range(-half_size, half_size + 1):
        for x in range(-half_size, half_size + 1):
            x_theta = x * np.cos(theta) + y * np.sin(theta)
            y_theta = -x * np.sin(theta) + y * np.cos(theta)
            gauss = np.exp(-(x_theta**2 + gamma**2 * y_theta**2) / (2 * sigma**2))
            sinusoid = np.cos(2 * np.pi * x_theta / lambda_ + psi)
            kernel[y + half_size, x + half_size] = gauss * sinusoid
    return kernel.flatten()

def create_high_boost_kernel(kernel_size, A):
    kernel = -np.ones(kernel_size * kernel_size, dtype=np.float64)
    half_size = kernel_size // 2
    kernel[half_size * kernel_size + half_size] = A + (kernel_size * kernel_size) - 1
    return kernel

def apply_filter(image, kernel, width, height, kernel_size, hilos):
    dest = np.zeros_like(image, dtype=np.float64)
    block_dim = int(np.sqrt(hilos))
    block_size = (block_dim, block_dim, 1)
    grid_size = (int(np.ceil(width / block_size[0])), int(np.ceil(height / block_size[1])), 1)

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

@app.route('/')
def index():
    return jsonify({"message": "Welcome to the image filter API!"})

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({"error": "No file part in the request"})

    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No file selected for uploading"})

    filepath = os.path.join(app.config['UPLOAD_FOLDER'], file.filename)
    file.save(filepath)

    filter_type = request.form.get('filter_type')
    kernel_size = int(request.form.get('kernel_size', 5))
    hilos = int(request.form.get('hilos', 1024))

    gray_image, width, height = load_image(filepath)

    if filter_type == 'emboss':
        kernel = create_emboss_kernel(kernel_size)
    elif filter_type == 'gabor':
        kernel = create_gabor_kernel(kernel_size, 4.0, 0, 10.0, 0.5, 0)
    elif filter_type == 'high_boost':
        kernel = create_high_boost_kernel(kernel_size, 10.0)
    else:
        return jsonify({"error": "Unsupported filter type"})

    result_data = apply_filter(gray_image, kernel, width, height, kernel_size, hilos)

    processed_filepath = os.path.join(app.config['PROCESSED_FOLDER'], 'processed_' + file.filename)
    save_image(result_data["filtered_image"], width, height, processed_filepath)

    return jsonify({
        "original_image": filepath,
        "processed_image": processed_filepath,
        "gpu_time": result_data["gpu_time"]
    })

@app.route('/download/<filename>', methods=['GET'])
def download_file(filename):
    filepath = os.path.join(app.config['PROCESSED_FOLDER'], filename)
    if os.path.exists(filepath):
        return send_file(filepath, as_attachment=True)
    else:
        return jsonify({"error": "File not found"}), 404

def load_image(filepath):
    image = Image.open(filepath).convert('L')
    gray_image = np.array(image, dtype=np.uint8)
    width, height = image.size
    return gray_image, width, height

def save_image(image, width, height, filepath):
    result_image = Image.fromarray(image)
    result_image.save(filepath)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port="5001", debug=True)
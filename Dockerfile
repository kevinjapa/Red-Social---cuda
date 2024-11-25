# Imagen base de CUDA y cuDNN
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

# Instalación de dependencias del sistema
RUN apt-get -qq update && \
    apt-get -qq install -y build-essential python3 python3-pip python3-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalación de dependencias de Python
COPY requirements.txt /app/requirements.txt
WORKDIR /app
RUN pip3 install --no-cache-dir -r requirements.txt

# Copia de los archivos de la aplicación
COPY . .

# Crear directorios necesarios
RUN mkdir -p static/uploads static/processed

# Exponer el puerto del servidor Flask
EXPOSE 5001

# Comando para ejecutar la aplicación
CMD ["python3", "app.py"]

![logo](https://github.com/user-attachments/assets/74b4cf78-ea96-43bd-ac3e-09a9e1688745)
# Manual tecnico
## Universidad Politecnica Salesiana
## Integrantes: Jorge Sayago, Pedro Orellana , Kevin Japa
## Carrera: Computacion
## Materia: Computacion Paralela

# Introduccion
Este manual tecnico ofrece una detallada guía para aquellos involucrados en la implementación, configuración y mantenimiento de esta  Aplicacion tanto para su servidor como para la aplicacion movil diseñada para ofrecer una experiencia social enriquecida y personalizada. La aplicación está orientada a usuarios que deseen compartir contenido visual de manera intuitiva, interactuar con otros a través de "likes" y comentarios, y aplicar filtros avanzados a sus imágenes mediante el uso de Pycuda antes de publicarlas.

El documento está orientado a desarrolladores y administradores que buscan implementar esta solución tecnológica en diferentes entornos. A lo largo del manual, se cubren aspectos clave como la arquitectura de la aplicación, los procedimientos de instalación y configuración, las funcionalidades principales y el proceso para generar el archivo APK. Esto permitirá a los lectores comprender y gestionar tanto los aspectos técnicos como operativos de la aplicación.

# Proposito 
El propósito de este proyecto es desarrollar una aplicación móvil innovadora que combine las características sociales de una red tipo Instagram con herramientas avanzadas de procesamiento de imágenes y una experiencia de usuario mejorada. La aplicación busca superar las limitaciones comunes de otras plataformas sociales mediante:

- Un feed cronológico transparente que prioriza el contenido reciente, eliminando algoritmos opacos.
- Funcionalidades de interacción intuitivas, como "likes" que se actualizan automáticamente y un sistema de comentarios fácil de gestionar.
- Capacidades creativas avanzadas, como la aplicación de filtros de imágenes utilizando aceleración por GPU.
- Flexibilidad técnica para adaptarse a diferentes entornos de desarrollo a través de la configuración de URLs de la API.
- Una experiencia sin publicidad intrusiva, centrada en el contenido auténtico generado por los usuarios.

# Alcance 
La aplicación móvil está diseñada para proporcionar a los usuarios una experiencia social completa y enriquecida, basada en funcionalidades avanzadas y una interfaz intuitiva. Este proyecto tiene como alcance:
- **Gestión de Usuarios:** Permitir a los usuarios registrarse, iniciar sesión y gestionar su perfil de manera segura y sencilla.
- **Interacciones Sociales:** Incorporar funcionalidades esenciales como dar "likes" a publicaciones, que se actualizan en tiempo real, y una sección de comentarios interactiva para fomentar la comunicación entre los usuarios.
- **Publicación de Imágenes:** Facilitar la carga de imágenes desde dispositivos móviles, con la posibilidad de aplicar filtros de procesamiento avanzados antes de compartirlas.
- **Visualización del Feed:** Ofrecer un feed cronológico que prioriza las publicaciones más recientes, garantizando que los usuarios tengan acceso al contenido más actualizado.
- **Flexibilidad Técnica: Adaptar** la aplicación a diferentes entornos de desarrollo mediante la configuración dinámica de la URL de la API, asegurando su funcionalidad tanto en entornos de desarrollo como de producción.
- **Distribución del APK: Generar** un archivo APK optimizado para su instalación en dispositivos Android, permitiendo la distribución directa de la aplicación a los usuarios finales.

# Requerimientos

## Requerimientos de Hardware para el Servidor

| **Componente**            | **Requerimiento**                                              |
|---------------------------|----------------------------------------------------------------|
| **Procesador (CPU)**      | Procesador con soporte para virtualización, mínimo 4 núcleos.  |
| **Tarjeta Gráfica (GPU)** | GPU NVIDIA compatible con CUDA 12.4 y cuDNN.                   |
| **Memoria RAM**           | 16 GB recomendados (mínimo 8 GB).                              |
| **Almacenamiento**        | 50 GB disponibles para Docker, imágenes y datos.               |
| **Red**                   | Conexión a Internet estable.                                   |

## Requerimientos de Software para el Servidor

| **Componente**        | **Requerimiento**                                                                       |
|-----------------------|-----------------------------------------------------------------------------------------|
| **Sistema Operativo** | Ubuntu 22.04 LTS, Windows 11 (o cualquier distribución compatible con Docker y NVIDIA). |
| **Software Principal**| Docker (versión 20.10 o superior) y NVIDIA Container Toolkit.                           |
| **Librerías**         | PyCUDA, Flask, Firebase Admin SDK, Pillow.                                              |
| **Otros**             | Git (para gestión de repositorios).                                                     |

## Requerimientos de Hardware para la Aplicación en el Celular

| **Componente**       | **Requerimiento**                                      |
|-----------------------|-------------------------------------------------------|
| **Procesador (CPU)**  | Procesador de 8 núcleos, 2 GHz o superior.            |
| **Memoria RAM**       | Mínimo 4 GB (recomendado 6 GB).                       |
| **Almacenamiento**    | 200 MB disponibles para instalación y datos locales.  |
| **Pantalla**          | Resolución mínima de 1280x720.                        |
| **Red**               | Conexión a Internet estable.                         |

## Requerimientos de Software para la Aplicación en el Celular

| **Componente**            | **Requerimiento**                                                                 |
|---------------------------|-----------------------------------------------------------------------------------|
| **Sistema Operativo**     | Android 9.0 (Pie) o superior.                                                     |
| **Software Principal**    | APK generado a partir del código en Flutter.                                      |
| **Permisos**              | Acceso a la cámara, almacenamiento y red.                                         |
| **Servicios Adicionales** | Aplicación de Google Play Services (para garantizar compatibilidad completa).     |

# Instalacion y Despliegue 

## **Prerrequisitos**

Antes de comenzar, asegúrate de tener instalados los siguientes componentes en tu sistema Windows:

1. **Git**: Para clonar el repositorio del proyecto.
   - Descárgalo desde [Git para Windows](https://git-scm.com/download/win) e instálalo.

2. **Docker Desktop**: Para contenerizar y desplegar el backend.
   - Descárgalo desde [Docker Desktop](https://www.docker.com/products/docker-desktop) e instálalo.
   - Habilita la integración con WSL 2 durante la instalación y configura Docker para que use la GPU NVIDIA (si es necesario).

3. **NVIDIA Container Toolkit**: Para ejecutar PyCUDA con soporte de GPU dentro de Docker.
   - Sigue las instrucciones oficiales: [Instalar NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html).

4. **Flutter**: Para desarrollar y compilar la aplicación móvil.
   - Descarga Flutter desde [Flutter para Windows](https://flutter.dev/docs/get-started/install/windows) y configura la variable de entorno `PATH` para incluir la carpeta `flutter/bin`.
   - Ejecuta el siguiente comando para verificar la instalación:
     ```cmd
     flutter doctor
     ```

5. **Python 3.10+ y pip**: Para manejar dependencias locales si deseas probar sin Docker.
   - Descarga Python desde [Python.org](https://www.python.org/downloads/).
   - Asegúrate de seleccionar "Add Python to PATH" durante la instalación.

---

## **Configuración del Proyecto**

### **1. Clonar el Repositorio**
Clona el repositorio del proyecto en tu máquina local utilizando Git:
```cmd
git clone https://github.com/kevinjapa/Red-Social---cuda
```
Asegúrate de tener un archivo requirements.txt con las siguientes dependencias:
```cmd
firebase-admin
flask
flask-cors
numpy
pillow
pycuda
werkzeug
```
## Consideraciones y Recomendaciones

### **Consideraciones**
1. **Compatibilidad del Sistema**:
   - Asegúrate de que la máquina donde se ejecuta el backend tenga una GPU NVIDIA compatible con CUDA 12.4 y cuDNN.
   - Verifica que Docker Desktop esté configurado correctamente para utilizar GPU en sistemas Windows.

2. **Configuración de la Red**:
   - Para entornos locales, asegúrate de que el backend y el frontend estén en la misma red para facilitar la comunicación.
   - En entornos de producción, utiliza un proxy inverso como NGINX para manejar las solicitudes de forma segura.

3. **Seguridad**:
   - No compartas las credenciales del archivo de configuración de Firebase. Utiliza variables de entorno en lugar de incluirlas directamente en el código.
   - Asegúrate de habilitar HTTPS en producción para proteger la comunicación entre la aplicación móvil y el backend.

4. **Desempeño**:
   - La calidad del procesamiento de imágenes depende en gran medida del hardware disponible. En entornos con GPU de baja capacidad, el rendimiento podría ser limitado.
   - Configura el backend para manejar múltiples solicitudes concurrentes utilizando herramientas como Gunicorn o Uvicorn con workers adicionales.

---

### **Recomendaciones**
1. **Pruebas en Diferentes Entornos**:
   - Realiza pruebas exhaustivas en un entorno local antes de desplegar en producción.
   - Configura entornos separados para desarrollo, pruebas y producción para evitar interferencias.

2. **Mantenimiento del Código**:
   - Utiliza Git para gestionar cambios en el código y colabora de manera eficiente con tu equipo.
   - Documenta cualquier actualización o cambio significativo en el código fuente para facilitar el mantenimiento.

3. **Optimización de la Aplicación Móvil**:
   - Prueba el APK en dispositivos Android con diferentes versiones del sistema operativo (9.0 en adelante) para garantizar compatibilidad.
   - Realiza optimizaciones en la interfaz de usuario para mejorar la experiencia en dispositivos con pantallas pequeñas o de baja resolución.

4. **Monitoreo en Producción**:
   - Implementa herramientas de monitoreo como Grafana o Prometheus para rastrear el rendimiento del backend.
   - Configura alertas para detectar posibles problemas en el sistema, como errores en la API o tiempos de respuesta elevados.

5. **Escalabilidad**:
   - Utiliza servicios en la nube como AWS o Google Cloud para desplegar el backend con soporte para escalado automático.
   - Considera el uso de un sistema de almacenamiento distribuido para manejar un volumen creciente de datos generados por los usuarios.
.




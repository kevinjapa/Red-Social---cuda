# Universidad Politecnica Salesiana
## Manual tecnico
## Integrantes: Jorge Sayago, Pedro Orellana , Kevin Japa
## Materia Computacion Paralela

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

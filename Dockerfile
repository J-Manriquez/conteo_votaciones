# Usa una imagen base de Flutter
FROM cirrusci/flutter:latest

# Establece el directorio de trabajo
WORKDIR /app

# Copia el archivo pubspec.yaml y pubspec.lock
COPY pubspec.yaml pubspec.lock ./

# Instala las dependencias de Flutter
RUN flutter pub get

# Copia el resto del código de la aplicación
COPY . .

# Construye la aplicación Flutter para web
RUN flutter build web

# Expone el puerto en el que la aplicación se ejecutará
EXPOSE 8080

# Comando para ejecutar el servidor web
CMD ["flutter", "run", "--web-port", "8080", "--web-hostname", "0.0.0.0"]


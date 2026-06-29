## Comandos de Ejecución

A continuación se detallan los comandos necesarios para preparar y ejecutar la aplicación en los distintos lenguajes. 
**Nota:** Todos los servicios están configurados para ejecutarse en el puerto `8000`.

| Lenguaje | Instalación / Preparación | Comando de Ejecución | Puerto |
| :--- | :--- | :--- | :--- |
| **C++** | `g++ main.cpp -o app -lcurl -lws2_32 -lcrypt32` | `./app.exe` | `8000` |
| **C#** | `dotnet build` | `dotnet run` | `8000` |
| **Go** | `go mod init app` | `go run main.go` | `8000` |
| **Java** | N/A *(JDK 11+)* | `java NombreArchivo.java` | `8000` |
| **Node.js**| N/A | `node server.js` | `8000` |
| **Perl** | `cpanm Mojolicious` | `perl script.pl` | `8000` |
| **Ruby** | `gem install sinatra savon` | `ruby script.rb` | `8000` |
| **Rust** | `cargo build` | `cargo run` | `8000` |

### Gestión de Dependencias
* **Perl / Ruby:** Requieren la instalación previa de los frameworks (Mojolicious / Sinatra) vía consola utilizando sus respectivos gestores de paquetes (`cpanm` / `gem`).

### Ejecución y Pruebas
1. Para probar cualquier lenguaje, abre la consola o terminal.
2. Navega a la carpeta de tu proyecto (por ejemplo: `cd C:\ruta\proyecto`).
3. Ejecuta el **Comando de Ejecución** correspondiente mostrado en la tabla superior.
4. **Prueba de ejecución:** Abre tu navegador y accede a: `http://localhost:8000/?n=21`. Si el servidor responde con el texto solicitado, el despliegue es exitoso.

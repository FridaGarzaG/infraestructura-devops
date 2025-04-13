import os
import subprocess

def run(cmd):
    print(f"Ejecutando: {cmd}")
    subprocess.run(cmd, shell=True, check=True)

def instalar_apache():
    # Detectar distro para usar el gestor correcto
    if os.path.exists("/etc/debian_version"):
        run("sudo apt update")
        run("sudo apt install -y apache2")
        run("sudo systemctl start apache2")
        run("sudo systemctl enable apache2")

    elif os.path.exists("/etc/redhat-release"):
        run("sudo yum install -y httpd")
        run("sudo systemctl start httpd")
        run("sudo systemctl enable httpd")
    else:
        print("Distro no soportada")

def crear_pagina():
    html = """

    <!DOCTYPE html>
    <html lang="es">
        <head>
            <meta charset="UTF-8">
            <title>DevOps - Act3</title>
        </head>

        <body>
            <h1 style="text-align: center">¡Hola, bienvenido al primer Web Server de Linux!</h1>
            <h3 style="text-align: center">Justo ahora te encuentras en la página web de Linux Web Server 1</h3>

            <p style="text-align: center"> Frida Garza | Actividad 3 - DevOps | Primer Web Server</p>
        </body>
    </html>
    """

    with open("/tmp/index.html", "w", encoding="utf-8") as f:
        f.write(html)
    run("sudo mv /tmp/index.html /var/www/html/index.html")

if __name__ == "__main__":
    instalar_apache()
    crear_pagina()
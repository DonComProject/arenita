# arenita dns_ldap_veyon.sh
## Explicación del Script de Configuración de Servidores 😊

#### Parte Fácil 🌟

1. **Actualizar el sistema**: El script primero verifica si hay actualizaciones disponibles para el sistema operativo y las instala para asegurarse de que todo esté al día. Esto es como asegurarse de tener las últimas funciones en tu teléfono.

2. **Instalar el servidor DNS**: Instala una herramienta llamada "servidor DNS" que ayuda a traducir nombres de sitios web (como google.com) en direcciones IP. Es como tener un libro de direcciones para encontrar lugares en internet.

3. **Configurar el DNS**: Configura el servidor DNS para que pueda entender y ayudar a encontrar las direcciones de los sitios web en nuestro propio sistema.

4. **Instalar el servidor LDAP**: Instala otro tipo de servidor llamado "servidor LDAP", que ayuda a organizar y almacenar información sobre usuarios y contraseñas de una manera segura. Es como tener un archivador gigante para guardar información importante.

5. **Configurar el servidor LDAP**: Configura el servidor LDAP para que sepa cómo manejar y proteger la información que guardará. Es como ponerle cerraduras a las carpetas de un archivador para que nadie más pueda ver lo que hay dentro.

6. **Instalar herramientas de red**: Instala una herramienta llamada "Nmap" que ayuda a escanear y encontrar otros dispositivos conectados a nuestra red. Es como buscar otros teléfonos conectados a la misma red Wi-Fi que el tuyo.

7. **Instalar y configurar Veyon**: Instala y configura una herramienta llamada "Veyon" que ayuda a monitorear y administrar otros dispositivos en la red. Es como tener un control remoto para ver lo que hacen otros en sus computadoras.

#### Parte Técnica 🔧

1. **Variables**: Define variables con información importante, como contraseñas y direcciones IP, que se utilizarán en todo el script.

2. **Actualizar y configurar BIND**: Instala y configura el servidor DNS BIND para que funcione con nuestro dominio LDAP.

3. **Instalar y configurar OpenLDAP**: Instala y configura el servidor LDAP OpenLDAP con las opciones necesarias y establece la contraseña del administrador.

4. **Crear estructura base LDAP**: Crea la estructura base del directorio LDAP si aún no existe, incluidos usuarios, grupos y computadoras.

5. **Instalar Nmap y escanear la red**: Instala la herramienta Nmap y la utiliza para realizar un escaneo de la red en busca de dispositivos activos.

6. **Crear archivo de configuración JSON de Veyon**: Crea un archivo de configuración JSON para Veyon basado en los dispositivos encontrados durante el escaneo de red.

7. **Instalar y configurar Veyon**: Instala Veyon y configura la clave maestra para acceder y administrar los dispositivos de la red.

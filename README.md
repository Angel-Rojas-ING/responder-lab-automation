# 🎩 Responder-Hash-Capture-Lab

![Version](https://img.shields.io/badge/version-1.0-blue.svg)
![Platform](https://img.shields.io/badge/platform-Kali_Linux-orange.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Bash](https://img.shields.io/badge/shell-bash-yellowgreen.svg)

**Script automatizado para el Lab 1.1: Active Online Attack usando Responder y John the Ripper**

Herramienta educativa diseñada para automatizar la captura de hashes NTLMv2 mediante Responder y su posterior cracking con John the Ripper en entornos de laboratorio controlados.

---

## 🚀 Características

- ✅ **Instalación automática** de dependencias (Responder, John the Ripper, rockyou.txt)
- ✅ **Verificación inteligente** de interfaces de red
- ✅ **Captura automatizada** de hashes NTLMv2 via SMB
- ✅ **Selección interactiva** de hashes para crackear
- ✅ **Interfaz amigable** con colores y emojis
- ✅ **Guía paso a paso** para máquinas Windows
- ✅ **Sección de ayuda** con soluciones a problemas comunes
- ✅ **Manejo robusto** de errores y timeouts

---

## 🎯 ¿Qué hace este script?

1. **Verifica dependencias** y las instala automáticamente si faltan
2. **Ejecuta Responder** para crear servicios falsos (SMB, HTTP, etc.)
3. **Te guía** para hacer que Windows se conecte a `\\test`
4. **Captura hashes NTLMv2** cuando Windows intenta autenticarse
5. **Te permite elegir** qué hash crackear con John the Ripper
6. **Muestra los resultados** de las contraseñas encontradas

---

## 📋 Requisitos

- **SO**: Kali Linux (recomendado) o cualquier distribución basada en Debian/Ubuntu
- **Permisos**: sudo/root
- **Red**: Máquina Windows en la misma red local
- **Python**: 3.x (incluido por defecto en Kali)

---

## 🛠 Instalación

### Opción 1: Descarga directa
```bash
# Clonar el repositorio
https://github.com/Angel-Rojas-ING/responder-lab-automation.git

# Entrar al directorio
cd responder-lab-automation

# Dar permisos de ejecución
chmod +x responder_lab_automation.sh
```

### Opción 2: Descarga del script únicamente
```bash
# Descargar solo el script
wget https://raw.githubusercontent.com/tu-usuario/Responder-Hash-Capture-Lab/main/responder_lab_automation.sh

# Dar permisos
chmod +x responder_lab_automation.sh
```

---

## 🎮 Uso

### Ejecución básica
```bash
# Ejecutar con sudo (requerido para Responder)
sudo ./responder_lab_automation.sh
```

### Configuración personalizada
Si necesitas cambiar la interfaz de red, edita la variable en el script:
```bash
# Abrir con tu editor favorito
nano responder_lab_automation.sh

# Cambiar esta línea por tu interfaz (eth0, wlan0, etc.)
INTERFACE="eth0"
```

---

## 📚 Flujo de trabajo

### Fase 1: Verificación automática
El script verifica e instala automáticamente:
- `git`
- `responder` (o clona desde GitHub si falla)
- `john` (John the Ripper)
- `rockyou.txt` (descomprime si está en .gz)

### Fase 2: Configuración de red
- Verifica que la interfaz de red existe
- Muestra interfaces disponibles si hay error

### Fase 3: Captura de hashes
- Inicia Responder en segundo plano
- Espera a que esté completamente listo
- Te muestra **instrucciones claras** para Windows:

```
1. Abre el Explorador de Archivos (Win + E) 🗂️
2. Escribe exactamente: \\test
3. Presiona Enter
4. Usa credenciales falsas si se solicitan
```

### Fase 4: Selección y cracking
- Lista todos los hashes capturados
- Te permite elegir cuál crackear
- Opción para intentar capturar más hashes
- Ejecuta John the Ripper con rockyou.txt

---

## 🔧 Solución de problemas

### No se capturan hashes
```bash
# Verificar conectividad de red
ping <IP_de_Windows>

# Verificar interfaz
ip a

# Verificar que Windows está en la misma red
nmap -sn 192.168.1.0/24
```

### Responder no se instala
```bash
# Instalación manual
sudo apt update
sudo apt install responder

# O clonar desde GitHub
sudo git clone https://github.com/SpiderLabs/Responder.git /opt/Responder
```

### John no crackea el hash
```bash
# Probar con reglas adicionales
sudo john --format=netntlmv2 --wordlist=/usr/share/wordlists/rockyou.txt --rules hash_file.txt

# Usar Hashcat como alternativa
hashcat -m 5600 hash_file.txt /usr/share/wordlists/rockyou.txt
```

---

## ⚖️ Consideraciones éticas y legales

⚠️ **IMPORTANTE**: Este script es únicamente para propósitos educativos y de laboratorio.

### ✅ Uso permitido:
- Laboratorios de ciberseguridad personales
- Entornos de práctica con permiso explícito
- Cursos y certificaciones de seguridad
- Pentesting autorizado por contrato

### ❌ Uso prohibido:
- Redes sin autorización
- Sistemas de terceros sin permiso
- Actividades maliciosas o ilegales
- Violación de términos de servicio

**El autor no se hace responsable del uso indebido de esta herramienta.**

---

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Si tienes ideas para mejorar el script:

1. Haz fork del repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Añadir nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

---

## 📝 Changelog

### v1.0 (2025-06-02)
- ✅ Lanzamiento inicial
- ✅ Instalación automática de dependencias
- ✅ Interfaz interactiva con colores
- ✅ Selección manual de hashes
- ✅ Guía paso a paso para Windows
- ✅ Manejo robusto de errores

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

---

## 👨‍💻 Autor

**The-White-Hat** 🎩

- GitHub: [@tu-usuario](https://github.com/tu-usuario)
- Propósito: Educación en ciberseguridad

---

## 🙏 Agradecimientos

- **Laurent Gaffié** - Creador de Responder
- **John the Ripper Team** - Herramienta de cracking
- **Offensive Security** - Kali Linux
- **Comunidad de InfoSec** - Por compartir conocimiento

---

## ⭐ ¿Te gustó el proyecto?

Si este script te ayudó en tus laboratorios de seguridad, ¡dale una estrella! ⭐

```bash
# Sígueme para más herramientas de ciberseguridad
git clone https://github.com/tu-usuario/Responder-Hash-Capture-Lab.git
```

---

*Desarrollado con ❤️ para la comunidad de ciberseguridad*

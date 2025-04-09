#!/bin/sh

_replaceFrontendEnvVars() {
    # Wait for the build directory to be ready
    echo "Waiting for build directory..."
    for i in $(seq 1 30); do
        if [ -d "/usr/src/app/build" ]; then
            break
        fi
        sleep 1
    done

    if [ ! -d "/usr/src/app/build" ]; then
        echo "Build directory not found"
        exit 1
    fi

    echo "Procurando arquivos contendo variáveis a serem substituídas...."

    # Encontra todos os arquivos que contêm as variáveis ou URLs específicas
    FILES=$(find /usr/src/app/build -type f -exec grep -l "hours_ticket_close_auto\|https://api.example.com" {} \;)

    if [ -z "$FILES" ]; then
        echo "Nenhum arquivo contendo as ocorrências especificas encontrado"
        echo "Criando arquivo de ambiente..."
        mkdir -p /usr/src/app/build
        echo "REACT_APP_BACKEND_URL=$REACT_APP_BACKEND_URL" > /usr/src/app/build/env-config.js
        echo "REACT_APP_HOURS_CLOSE_TICKETS_AUTO=$REACT_APP_HOURS_CLOSE_TICKETS_AUTO" >> /usr/src/app/build/env-config.js
        exit 0
    fi

    for FILE in $FILES; do
        echo "Modificando $FILE..."

        # Escapar caracteres especiais nas variáveis de ambiente
        ESCAPED_REACT_APP_HOURS_CLOSE_TICKETS_AUTO=$(printf '%s\n' "$REACT_APP_HOURS_CLOSE_TICKETS_AUTO" | sed 's:[\\/&]:\\&:g')
        ESCAPED_REACT_APP_BACKEND_URL=$(printf '%s\n' "$REACT_APP_BACKEND_URL" | sed 's:[\\/&]:\\&:g')

        # Substituir as variáveis e URLs nos arquivos
        sed -i "s/hours_ticket_close_auto/${ESCAPED_REACT_APP_HOURS_CLOSE_TICKETS_AUTO}/g" "$FILE"
        sed -i "s|https://api.example.com|${ESCAPED_REACT_APP_BACKEND_URL}|g" "$FILE"

        echo "$FILE modificado com sucesso."
    done
}

_replaceFrontendEnvVars

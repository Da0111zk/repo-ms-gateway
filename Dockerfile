# --- ETAPA 1: Compilación ---
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app

COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# --- ETAPA 2: Ejecución ---
FROM eclipse-temurin:21-jre
WORKDIR /app

USER root
RUN mkdir -p /app/wallet

COPY --from=build /app/target/*.jar app.jar

# Creación del script usando Heredoc (Evita errores de escape de caracteres)
RUN cat <<-'EOF' > /app/entrypoint.sh
#!/bin/sh
echo "[INIT] Inicializando entorno para Oracle Wallet..."

if [ ! -z "$WALLET_BASE64" ]; then
    echo "$WALLET_BASE64" | base64 -d > /app/wallet/cwallet.sso
    echo "[INIT] cwallet.sso generado con éxito."
fi

if [ ! -z "$ORACLE_TNSNAMES" ]; then
    echo "$ORACLE_TNSNAMES" > /app/wallet/tnsnames.ora
    echo "[INIT] tnsnames.ora generado con éxito."
fi

if [ ! -z "$ORACLE_SQLNET" ]; then
    echo "$ORACLE_SQLNET" > /app/wallet/sqlnet.ora
    echo "[INIT] sqlnet.ora generado con éxito."
fi

exec java $JAVA_OPTS -jar app.jar
EOF

RUN chmod +x /app/entrypoint.sh
EXPOSE 8080
ENTRYPOINT ["/app/entrypoint.sh"]

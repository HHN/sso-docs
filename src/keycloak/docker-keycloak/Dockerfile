# We pin a specific version here, so needs to be changed if Keycloak is updated
FROM quay.io/keycloak/keycloak:22.0.3 as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=mariadb

WORKDIR /opt/keycloak

COPY hhn-ad-ca-cert.pem /hhn-ad-ca-cert.pem
COPY hhn-ad-lb-cert.pem /hhn-ad-lb-cert.pem
COPY hhn-galera-ca-cert.pem /hhn-galera-ca-cert.pem

# Copy custom infinispan configuration to build container (encrypted traffic)
COPY hhn-infinispan-config.xml /opt/keycloak/conf/hhn-infinispan-config.xml

# Update certificate store with CA certs for HHN RZ Active Directory and HHN RZ Galera Cluster
USER root
# Import CA Certificate of HHN RZ Active Directory
RUN keytool -import -keystore /etc/pki/java/cacerts -alias hhn-ad-ca-cert -file /hhn-ad-ca-cert.pem -noprompt -storepass changeit
# Import CA Certificate of HHN RZ Active Directory Proxy Loadbalancer
RUN keytool -import -keystore /etc/pki/java/cacerts -alias hhn-ad-lb-cert -file /hhn-ad-lb-cert.pem -noprompt -storepass changeit
# Import CA Certificate of HHN RZ Galera Cluster
RUN keytool -import -keystore /etc/pki/java/cacerts -alias hhn-galera-ca-cert -file /hhn-galera-ca-cert.pem -noprompt -storepass changeit

# Switch back to the build user
USER keycloak

# Add hhn theme
COPY hhn-theme.jar /opt/keycloak/providers/hhn.jar
# Build keycloak with preview features required for HHN Auth
RUN ls -la /opt/keycloak && /opt/keycloak/bin/kc.sh build \
--features=declarative-user-profile,admin-fine-grained-authz,recovery-codes \
--transaction-xa-enabled=false \
--spi-theme-welcome-theme=hhn \
--cache=ispn \
--cache-config-file=hhn-infinispan-config.xml \
--spi-x509cert-lookup-provider=haproxy

# Copy TLS/SSL server certificate & key
COPY hhn-keycloak-server-cert.pem /opt/keycloak/conf/server.crt.pem
COPY hhn-keycloak-server-key.pem /opt/keycloak/conf/server.key.pem

# Create custom server.jks keystore to encrypt infinispan traffic
COPY server.jks /opt/keycloak/conf/server.jks

# Copy deny lists to related location on Keycloak
COPY hhn-pw-deny-list.txt /opt/keycloak/data/password-blacklists/hhn-pw-deny-list.txt

FROM quay.io/keycloak/keycloak:22.0.3

COPY --from=builder /opt/keycloak/ /opt/keycloak/
COPY --from=builder /etc/pki/java/cacerts /etc/pki/java/cacerts

# Configuration to reach Galera4 Cluster via SSL/TLS
ENV KC_DB_URL=jdbc:mariadb:loadbalance://keydb01.rz.hs-heilbronn.de,keydb02.rz.hs-heilbronn.de,keydb03.rz.hs-heilbronn.de/keycloak?useSSL=true&sslMode=verify-full
ENV KC_DB_USERNAME=<user>
ENV KC_DB_PASSWORD=<password>
ENV KC_HOSTNAME=login.hs-heilbronn.de
ENV KC_HTTPS_CERTIFICATE_FILE=/opt/keycloak/conf/server.crt.pem
ENV KC_HTTPS_CERTIFICATE_KEY_FILE=/opt/keycloak/conf/server.key.pem
ENV KC_METRICS_ENABLED=true

# Special Quarkus properties to enhance connection pool validation
ENV QUARKUS_DATASOURCE_JDBC_VALIDATION_QUERY_SQL="SELECT 1"
ENV QUARKUS_DATASOURCE_JDBC_BACKGROUND_VALIDATION_INTERVAL=30s

ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start", "--optimized", "--hostname=login.hs-heilbronn.de", "--proxy=reencrypt", "--log-level=INFO,org.keycloak.events:debug", "--spi-x509cert-lookup-haproxy-ssl-client-cert=SSL_CLIENT_CERT", "--spi-x509cert-lookup-haproxy-ssl-cert-chain-prefix=CERT_CHAIN", "--spi-x509cert-lookup-haproxy-certificate-chain-length=0"]

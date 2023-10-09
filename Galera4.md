# Installation Datenbankcluster (am Beispiel von Ubuntu 22.04 LTS)

## Installation MariaDB und Galera

### Firewall

Für die Kommunikation innerhalb des Subnetzes sind folgende Ports für Galera und MySQL notwendig.

- Zwischen den Datenbank-Knoten: 3306, 4444, 4567, 4568
- Zugriff von den KeyCloak-Knoten: 3306

### Installation von MariaDB und Galera4 aus dedizierter Paketquelle 

```
apt-get install apt-transport-https curl
curl -o /etc/apt/trusted.gpg.d/mariadb_release_signing_key.asc 'https://mariadb.org/mariadb_release_signing_key.asc'
sh -c "echo 'deb https://mirror1.hs-esslingen.de/pub/Mirrors/mariadb/repo/10.10/ubuntu jammy main' >>/etc/apt/sources.list"
apt update
apt-get install mariadb-server mariadb-client galera-4
mysql_secure_installation
cd /etc/apparmor.d/disable/
ln -s /etc/apparmor.d/usr.sbin.mariadbd
systemctl restart apparmor
# Configure the galera cluster in /etc/mysql/mariadb.conf.d/60-galera.cnf (see below)
service mariadb stop
``` 

### Anlegen der Cluster Konfiguration und Erst-Einrichtung

Verzeichnis: `/etc/mysql/mariadb.conf.d/60-galera.cnf`

```bash
#
# * Galera-related settings
#
# See the examples of server wsrep.cnf files in /usr/share/mysql
# and read more at https://mariadb.com/kb/en/galera-cluster/


[sst]
tkey = /etc/my.cnf.d/certificates/client-key.pem
tcert = /etc/my.cnf.d/certificates/client-cert.pem

[galera]
# Mandatory settings
wsrep_on                 = ON
wsrep_provider           = /usr/lib/galera/libgalera_smm.so
wsrep_cluster_name       = "HHN RZ KeyCloak Galera Cluster"
# CAVE: We use gcom:// on the first initial node. Other nodes need the full address string
#wsrep_cluster_address    = gcomm://IP1,IP2,IP3,IP4,IP5
wsrep_cluster_address    = gcomm://
binlog_format            = row
default_storage_engine   = InnoDB
innodb_autoinc_lock_mode = 2
innodb_doublewrite       = 1
# Allow server to accept connections on all interfaces.
bind-address = 0.0.0.0

# Optional settings
wsrep_slave_threads = 4
wsrep_sst_method = rsync
innodb_flush_log_at_trx_commit = 0
log_error = /var/log/mysql/error.log

# Node specific configuration - needs to be adjusted on every node!
wsrep_node_name = keydb01
wsrep_node_address = "<IP1>"

# TLS/SSL Confguration
ssl_cert = /etc/my.cnf.d/certificates/server-cert.pem
ssl_key = /etc/my.cnf.d/certificates/server-key.pem
ssl_ca = /etc/my.cnf.d/certificates/ca.pem
wsrep_provider_options="socket.ssl_cert=/etc/my.cnf.d/certificates/server-cert.pem;socket.ssl_key=/etc/my.cnf.d/certificates/server-key.pem;socket.ssl_ca=/etc/my.cnf.d/certificates/ca.pem"
``` 

- **Achtung:** Auf dem ersten Knoten unterscheidet sich die `wsrep_cluster_address` zu den übrigen Knoten, siehe Kommentar in der Konfiguration.

##### TLS / SSL

- Zertifikate erzeugen (wie unter [CA](CA.md) beschrieben)
- Galera benötigt re-hashing der Zertifikate (auf jedem Cluster Mitglied):

```
openssl rehash /etc/my.cnf.d/certificates
```
#### Erst-Einrichtung

- Auf dem ersten Knoten

```bash
galera_new_cluster
```

- Auf allen anderen Knoten
```bash
service mariadb start
```

#### Prüfen des Cluster-Zustands:

```
mysql -u root -e "SHOW STATUS LIKE 'wsrep_cluster_size'"
```

## Verwaltung von Datenbanken

### Verbinden mit Cluster

Auf einem der Cluster-Knoten

```bash
mysql -u root 
```

### Erstellen einer Datenbank

```
create database keycloak;
```

### Liste der DBs

```
show databases;
```

### Erstellen eines Nutzers
```
create user 'keycloak'@'%' identified by 'SomePassword';
```

### Zuweisen von Rechten auf der Datenbank für einen spezifischen Nutzer
```
grant all privileges on keycloak.* to 'keycloak'@'%';
```

# Update Datenbankcluster

Die Pakete sind mit `apt-get mark hold` fixiert. Ein Update muss manuell gemäß offizieller Dokumentation erfolgen.
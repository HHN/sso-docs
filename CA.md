# Eigene Certificate Authority (CA) für interne Kommunikation

## Anlegen einer eigenen CA

```bash
openssl genrsa 2048 > ca-key.pem
openssl req -new -x509 -nodes -days 365000 -key ca-key.pem -out ca.pem
```

## Erstellen eines Zertifikats inkl. SANs (Subject Alternative Names, d.h. weiteren DNS-Namen)

Hier am Beispiel für ein "client-cert":

1. Anpassen der [san.cnf-Datei](src/ca/san.cnf), sodass sie alle gewünschten SANs beinhaltet (ganz unten in der Datei)
2. `openssl req -newkey rsa:2048 -days 365000 -nodes -keyout client-key.pem -config san.cnf -out client-req.pem`
3. `openssl rsa -in client-key.pem -out client-key.pem`
4. `openssl x509 -req -in client-req.pem -days 365000 -CA ca.pem -CAkey ca-key.pem -set_serial 100 -extfile san.cnf -extensions v3_req -out client-cert.pem`

**Wichtig:** Die Seriennummer sollte für jedes ausgestellte Zertifikat unterschiedlich sein.

## Übersicht über die internen Zertifikate

### Galera Cluster
- `Server-Zertifikat` für Port 3306 (d.h. nach außen und für die Incremental State Transfers (ISTs).
- `Client-Zertifikat` für SSTs = Snapshot State Transfers
- jeweils ein Zertifikat für jeden Datenbankknoten

### KeyCloak
- `Server-Zertifikat` für HTTPS über Port 8443 (sodass Verbindung zwischen KeyCloak-Knoten und HAProxy geschützt sind)
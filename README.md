# Single-Sign-On (SSO) an der Hochschule Heilbronn

Dieses Repository bietet eine Einführung in unsere auf [KeyCloak](https://www.keycloak.org/) basierende SSO-Lösung an der [Hochschule Heilbronn](https://www.hs-heilbronn.de). Das Gesamtsystem befindet sich seit Anfang 2023 im produktiven Einsatz für über 8.000 Studierende und 800 Beschäftigte.

## Motivation

Aufgrund eines Cyberangriffs mussten wir große Teile unserer IT-Infrastruktur neu aufbauen und in diesem Zuge auch die Passwörter aller Hochschulangehörigen zurücksetzen. Wir haben neue Domänencontroller installiert, Konten für alle Hochschulangehörigen (Studierende und Mitarbeiter) eingerichtet und Initialpasswörter vergeben. Die Initialpasswörter bestanden aus einer zufälligen Zeichenfolge, gefolgt vom Geburtsdatum der Person. Das Active Directory ist das führende System für die Verwaltung der Konten und die Passwörter werden nur dort gespeichert (keine Repliken auf LDAP-Servern o. ä.).

### Warum KeyCloak?

Als "Frontend" dafür haben wir uns für die Identity und Access Management Lösung [KeyCloak](https://www.keycloak.org/) entschieden. Dafür gab es mehrere Gründe:

* KeyCloak ist Open Source.
* KeyCloak kann Active Directory als Datenquelle nutzen.
* KeyCloak bietet ein webbasiertes Account Management. Über dieses Self-Service-Portal können Nutzer z. B. ihr Passwort ändern, ihre Zweitfaktoren verwalten oder aktive Sessions einsehen.
* KeyCloak ermöglicht Multi-Faktor-Authentifizierung (MFA) über zeitbasierte Einmal-Token (TOTP) oder FIDO2 (Hardware-Keys, Passkeys, etc.).
* KeyCloak unterstützt moderne Authentifizierungsverfahren wie OpenID Connect (OIDC) oder SAML 2.0, mit denen ein Single Sign-On für *alle* webbasierten Dienste realisiert werden kann. Über [eduVPN](https://www.eduvpn.org) werden auch VPN-Logins per Single Sign-On realisiert und per MFA geschützt.
* KeyCloak erleichtert das "Onboarding" beim Passwort-Rollout.
* KeyCloak kann dem Shibboleth Identity Provider (IDP) transparent "vorgeschaltet" werden. Damit ist auch der Zugriff auf föderierte Dienste (bwIDM) per Single Sign-On möglich und automatisch per MFA geschützt, ohne dass der IDP dafür aufwändig angepasst werden muss.

### Warum Single Sign-On?

Mit Single Sign-On werden Zugangsdaten künftig nur noch an einer zentralen Stelle in unserem KeyCloak-basierten "Login-Portal" eingegeben. Daraus ergeben sich mehrere Vorteile:

* Die einzelnen Anwendungen erhalten nicht mehr die Klartext-Passwörter der Nutzer, sondern nur noch einen temporären Login-Token, der vom Login-Portal ausgegeben wird. Dadurch sinkt das Risiko der Kompromittierung von Hochschulzugangsdaten gegenüber z. B. LDAP-basierten Verfahren.
* Am Login-Portal kann eine starke Authentifizierung über zwei Faktoren erzwungen werden.
* Am Login-Portal kann ein Monitoring aller Anmeldevorgänge erfolgen, um zukünftige identitätsbasierte Angriffe schneller erkennen und verfolgen zu können.
* Am Login-Portal kann an zentraler Stelle ein Brute-Force-Schutz implementiert werden (z.B. Throttling und ggf. IP-Blocking).
* Das Risiko von Phishing-Angriffen sinkt, da Nutzer zukünftig dazu angehalten werden können, ihre Zugangsdaten nur noch im offiziellen Login-Portal einzugeben. Durch geeignete Zweitfaktoren (FIDO2) kann das Phishing-Risiko eliminiert werden.
* Gleichzeitig steigt der Komfort für Nutzer, da sie sich nur noch einmal am Login-Portal stark authentifizieren müssen und dann ohne weitere Anmeldungen auf die dort angebundenen Anwendungen zugreifen können (Single Sign-On).

### Warum dieses Projekt?

Auf diesen Seiten stellen wir alle Informationen zu unserer KeyCloak-Installation zur Verfügung. Unser Ziel ist es, anderen Hochschulen die Möglichkeit zu geben, dieses Setup zu evaluieren und ggf. zu implementieren.

Neben Architekturbeschreibungen und Anleitungen stellen wir auch Docker- und Konfigurationsdateien zur Verfügung. Diese beinhalten z. B. das Setup von KeyCloak selbst, aber auch Konfigurationsdateien für einen hochverfügbaren Clusterbetrieb oder zusätzliche Sicherheitsmaßnahmen wie einen Brute-Force-Schutz und den Schutz durch eine Web Application Firewall. Darüber hinaus beschreiben wir, wie KeyCloak in Verbindung mit Shibboleth IDP (bwIDM) betrieben werden kann.

Darüber hinaus stellen wir den Quellcode von zwei eigenentwickelten Anwendungen als Open Source zur Verfügung:

* **Onboarding**: Die Onboarding-Anwendung hilft bei der Ersteinrichtung neuer Konten. Nutzer werden zunächst aufgefordert, sich mit ihrem Initialpasswort anzumelden. Anschließend werden sie von einem Assistenten durch die Aktivierung ihres neuen Hochschulkontos geführt. Dabei wird unter anderem ein neues sicheres Passwort konfiguriert, Notfallwiederherstellungscodes generiert und ein zweiter Faktor (TOTP oder FIDO2) registriert. Im Hintergrund kommuniziert die Anwendung mit der KeyCloak API. Diese Anwendung haben wir bei unserem Passwort-Rollout eingesetzt und setzen sie auch heute noch für neue Mitarbeitende und Studierende ein. Mittlerweile haben über 10.000 Personen ihr neues Hochschulkonto darüber in Betrieb genommen. Die Welcome- bzw. Onboarding-Anwendung ist über https://login.hs-heilbronn.de öffentlich erreichbar.

* **Helpdesk**: Die Helpdesk-Anwendung unterstützt das Zurücksetzen von Passwörtern in Helpdesk-Situationen. Dazu werden Passwort-Reset-Briefe mit zufälligen Passwörtern vorgeneriert, ausgedruckt und kuvertiert am Helpdesk bereitgestellt. Im Sichtfenster befindet sich ein QR-Code mit einer fortlaufenden Nummer. Nach erfolgter Identitätsfeststellung (Ausweisprüfung) wird über die Helpdesk-Anwendung das betroffene Nutzerkonto ausgewählt und der QR-Code gescannt. In diesem Moment wird das Konto auf das im Brief enthaltene Passwort zurückgesetzt. Im Hintergrund kommuniziert die Anwendung mit der KeyCloak API. Über alle Aktivitäten wird ein Audit-Log erstellt, so dass am Ende des Tages die Unterschriftenlisten im Helpdesk mit dem Audit-Log über die dokumentierten Passwort-Resets abgeglichen werden können.

## Gesamtüberblick

Active Directory ist das führende System zur Speicherung von Account-Informationen. KeyCloak ist das "Frontend" dazu und bietet eine webbasierte Account-Verwaltung, Multi-Faktor-Authentifizierung, Single Sign-On und eine umfassende API, die u. a. von den Onboarding/Helpdesk-Anwendungen genutzt wird.

[SCHAUBILD HIER]

Daneben gibt es noch einige andere Authentifizierungssysteme:

* LDAP-Server: Einige Legacy-Anwendungen benötigen noch eine Anmeldung über LDAP. Solche Anwendungen unterstützen bisher weder OIDC noch SAML2.0. Für eine Übergangszeit erlauben wir die Nutzung, verlangen aber von den Systemverantwortlichen ein Sicherheitskonzept. Die LDAP-Server replizieren keine Passwörter und sind direkt mit dem Active Directory verbunden.

* RADIUS-Server: [eduroam](https://eduroam.org) nutzt IEEE 802.1X zur Authentifizierung von WiFi-Clients auf Basis von RADIUS. Dazu betreiben wir derzeit RADIUS-Server basierend auf OpenRADIUS, die das Active Directory als Quelle nutzen. Perspektivisch wollen wir auf [easyroam](https://doku.tid.dfn.de/de:eduroam:easyroam) umsteigen und die Anmeldevorgänge dann auch über das Login-Portal abwickeln.



## Customizing
Für den initialen Rollout sowie eine verbesserte Benutzerfreundlichkeit wurden einige Anpassungen an einer Standardinstallation von Keycloak vorgenommen:

1. Theming gemäß den Richtlinien der Hochschule
2. Entwicklung eines Einrichtungsassistenten zur Einrichtung des Passworts und eines zweiten Faktors. Source-Code: [hier](https://github.com/hhn/sso-helpdesk).

Die nachfolgenden Videos zeigen den Erst-Anmelde Prozess für Studierende sowie für Beschäftigte.

### Erst-Anmeldung für Studierende

- https://youtu.be/XtUYZPxLRg8

### Erst-Anmeldung für Beschäftigte

- https://youtu.be/yK5jxKleMaE

Hinweis: Die Hochschulleitung hat sich in Rücksprache mit unserem Informationssicherheitsbeauftragten sowie nach zahlreichen technischen Tests für die Ausgabe von
[Yubikeys](https://www.yubico.com/) an Beschäftigte als zweiter Faktor entschieden.

### Zurücksetzen eines Passworts bzw. eines zweiten Faktors

Keycloak selbst bietet keine schnelle und einfache Möglichkeit Passwörter sowie vorhandene zweite Faktoren zurückzusetzen.
Hierzu sind stets Administratoren-Rechte erforderlich.

*bla bla zu HelpDesk und den Prozess aus @aykay's Folien*

- [Beispiel Brief zum Download](src/demo-brief-helpdesk.pdf)

## Technische Architektur

- [Keycloak](Keycloak.md)
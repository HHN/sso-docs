# Single-Sign-On (SSO) an der Hochschule Heilbronn

Dieses Repository bietet eine Einführung in unsere auf [KeyCloak](https://www.keycloak.org/) basierende SSO-Lösung an der [Hochschule Heilbronn](https://www.hs-heilbronn.de). Das Gesamtsystem befindet sich seit Anfang 2023 im produktiven Einsatz für über 8.000 Studierende und 800 Beschäftigte.

## Motivation

In Folge eines Cyberangriffs mussten wir weite Teile unserer IT-Infrastruktur neu aufbauen und in diesem Zuge auch die Passwörter aller Hochschulangehörigen zurücksetzen. Wir haben neue Domänencontroller installiert, Konten für alle Hochschulangehörige angelegt (Studierende und Beschäftigte) und Initialpasswörter vergeben. Die Initialpasswörter bestanden aus einer zufälligen Zeichenkette gefolgt vom Geburtsdatum der Person. Das Active Directory ist das führende System im Hinblick auf die Verwaltung von Konten und Passwörter werden nur an dieser Stelle gespeichert (keine Replica auf LDAP-Servern o. ä.).

### Warum KeyCloak?

Als "Frontend" dafür haben wir uns für die Identity- und Access-Management-Lösung [KeyCloak](https://www.keycloak.org/) entschieden. Die Gründe dafür waren vielfältig:

* KeyCloak ist Open Source.
* KeyCloak kann Active Directory als Datenquelle werden.
* KeyCloak bietet eine webbasierte Accountverwaltung. Über dieses Self-Service-Portal können Nutzer bspw. ihr Passwort ändern, ihre zweite Faktoren verwalten oder aktive Sitzungen einsehen.
* KeyCloak ermöglicht eine Multi-Faktor-Authentifizierung (MFA) via zeitbasierter Einmaltoken (TOTP) oder FIDO2 (Hardware-Schlüssel, Passkeys, etc.).
* KeyCloak unterstützt moderne Authentifzierungsverfahren wie OpenID Connect (OIDC) oder SAML 2.0. Darüber lässt sich ein Single Sign-On für *alle* webbasierten Dienste realisieren. Über [eduVPN](https://www.eduvpn.org) sind auch Anmeldungen am VPN per Single Sign-On realisiert und per MFA geschützt.
* KeyCloak erleichtert das "Onboarding" beim Passwort-Rollout.
* KeyCloak kann transparent "vor" den Shibboleth Identity Provider (IDP) geschaltet werden. Dadurch sind auch Zugriffe auf föderierte Dienste (bwIDM) via Single Sign-On möglich und automatisch per MFA geschützt, ohne den IDP dafür aufwändig anpassen zu müssen.

### Warum Single Sign-On?

Per Single Sign-On werden Zugangsdaten zukünftig nur noch an zentraler Stelle in unserem KeyCloak-basierten "Login-Portal" eingegeben. Daraus ergeben sich verschiedene Vorteile:

* Einzelne Anwendungen erhalten nicht mehr die Klartext-Passwörter der Nutzer, sondern nur noch einen vom Login-Portal ausgestellten, zeitlich befristeten Anmeldetoken. Dadurch sinkt das Risiko der Kompromittierung von Hochschulzugangsdaten via bspw. bei LDAP-basierten Verfahren.
* Am Login-Portal kann eine starke Authentifizierung über zwei Faktoren erzwungen werden.
* Am Login-Portal kann ein Monitoring der Anmeldevorgänge erfolgen, um zukünftige Identitätsbasierte Angriffe schneller zu erkennen und nachverfolgen zu können.
* Am Login-Portal kann an zentraler Stelle ein Brute-Force-Schutz implementiert werden (bspw. Throttling und ggf. IP Blocking).
* Das Risiko für Phishing-Angriffe sinkt, weil Nutzer zukünftig dazu angehalten werden können, ihre Zugangsdaten nur noch in das offizielle Login-Portal einzugeben. Über geeignete zweite Faktoren (FIDO2) kann das Phishing-Risiko eliminiert werden.
* Gleichzeitig steigt der Komfort für Nutzer, weil sie sich nur noch einmal am Login-Portal stark authentisieren müssen und anschließend ohne weitere Anmeldungen auf die daran angebunden Anwendungen zugreifen können (Single Sign-On).




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
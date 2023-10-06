# Single-Sign-On (SSO) Architektur an der Hochschule Heilbronn

Dieses Repository bietet eine Einführung in unsere auf [Keycloak](https://www.keycloak.org/)-basierende SSO-Lösung an der [Hochschule Heilbronn](https://www.hs-heilbronn.de).
Das Gesamtsystem befindet sich seit dem XX.XX.2023 im produktiven Einsatz für XX Studierende und XX Mitarbeitende.

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
cp 10-million-password-list-top-1000000.txt 10-million-password-list-top-1000000.txt.bak;
(sed 's/.*/\L&/g' < 10-million-password-list-top-1000000.txt) > hhn-pw-deny-list.txt;

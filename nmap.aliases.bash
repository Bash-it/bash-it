cite 'about-alias'
about-alias 'Nmap scanner'

###############################
# Usa Nmap0 para leer el menu #
# Use Nmap0 for read info     #
###############################

alias Nmap0='echo -e "Nmap1 Geografico/Geographical Scan";echo -e "Nmap2 Versines/Versions";echo -e "Nmap3 Paranoico/Paranoic";echo -e "Nmap4 Furtivo/Sneaky";echo -e "Nmap5 Cortes/Polite";echo -e "Nmap6 Normal";echo -e "Nmap 7 Agresivo/Agresive";echo -e "Nmap8 Insano/Insane";echo -e "Nmap9 WEB (vulscan)";'
alias Nmap1='echo "geografico/GeoGrafic"; sudo nmap --script=asn-query,whois,ip-geolocation-maxmind'
alias Nmap2='echo "script"; sudo nmap -sV -sC' 
alias Nmap3='echo "Paranoico/Paranoid (Lento/slow) "; sudo nmap -sSV -sC -p- -T0 '
alias Nmap4='echo "Furtivo/Sneaky (Lento/slow)"; sudo nmap -sSV -sC -p- -T1'
alias Nmap5='echo "Cortes/Polite (lento/slow)"; sudo nmap -sSV -sC -p- -T2'
alias Nmap6='echo "Normal (Normal)"; sudo nmap -sSV -sC -p- -T3'
alias Nmap7='echo "Agresivo/Agresive (Rapidito/Quick)"; sudo nmap -sSV -sC -p- -T4'
alias Nmap8='echo "Insano/insane (Rapidito/Quick)"; sudo nmap -sSV -sC -p- -T5'
alias Nmap9='echo "WEB(vulscan)": sudo nmap -sV --script=vulscan/vulscan.nse'

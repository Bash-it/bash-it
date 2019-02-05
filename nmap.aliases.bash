cite 'about-alias'
about-alias 'Nmap scanner'

###############################
# Use Nmap0 for read info     #
###############################

alias Nmap0='echo -e "Nmap1 Geographical Scan";echo -e "Nmap2 Versions";echo -e "Nmap3 Paranoic";echo -e "Nmap4 Sneaky";echo -e "Nmap5 Polite";echo -e "Nmap6 Normal";echo -e "Nmap 7 Agresive";echo -e "Nmap8 Insane";echo -e "Nmap9 WEB (vulscan)";'
alias Nmap1='echo "GeoGrafic"; sudo nmap --script=asn-query,whois,ip-geolocation-maxmind'
alias Nmap2='echo "script"; sudo nmap -sV -sC' 
alias Nmap3='echo "Paranoid slow"; sudo nmap -sSV -sC -p- -T0 '
alias Nmap4='echo "Sneaky slow"; sudo nmap -sSV -sC -p- -T1'
alias Nmap5='echo "Polite slow"; sudo nmap -sSV -sC -p- -T2'
alias Nmap6='echo "Normal"; sudo nmap -sSV -sC -p- -T3'
alias Nmap7='echo "Agresive Quick"; sudo nmap -sSV -sC -p- -T4'
alias Nmap8='echo "insane Quick"; sudo nmap -sSV -sC -p- -T5'
alias Nmap9='echo "WEB(vulscan)": sudo nmap -sV --script=vulscan/vulscan.nse'

#Niil78
#2019
cite 'about-alias'
about-alias 'Nmap scanner'

alias Nmap0='echo "Escaner normal"; sudo nmap' #Escaner Basico
alias Nmap1='echo "Escaner geografico"; sudo nmap --script=asn-query,whois,ip-geolocation-maxmind' #Informacion Geografica.
alias Nmap2='echo "Escaner con script"; sudo nmap -sV -sC' #Informacion basica de versiones 
alias Nmap3='echo "Escaner Total Paranoico(Lento) "; sudo nmap -sSV -sC -p- -T0 '
alias Nmap4='echo "Escaner Total Sniky(Lento)"; sudo nmap -sSV -sC -p- -T1'
alias Nmap5='echo "Escaner Total Polite(lento)"; sudo nmap -sSV -sC -p- -T2'
alias Nmap6='echo "Escaner Total Normal(Normal)"; sudo nmap -sSV -sC -p- -T3'
alias Nmap7='echo "Escaner Total Agresivo(Rapidito)"; sudo nmap -sSV -sC -p- -T4'
alias Nmap8='echo "Escaner Total Insano(Rapidito)"; sudo nmap -sSV -sC -p- -T5'
alias Nmap9='echo "Escaner web(vulscan)": sudo nmap -sV --script=vulscan/vulscan.nse'

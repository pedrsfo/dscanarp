#!/bin/bash

# Nome: DScanARP - Detector de Scanner ARP

# Autor: Pedro Otávio
# Email: pedr_ofs@hotmail.com
# Atualziado: 04/03/2022

# Este simples script tem por objetivo realizar o monitoramento de Scanners ARP em uma determinada rede.

# O DscanARP é um sistema de detecção de Sanners ARP em uma rede. Semelhante a um IDS, o DScanARP opera melhor com algumas
# exigências:

#	1º - Possuir acesso root!
#	2º - Habilitar o modo promíscuo da interface a ser monitorada.
#	3º - Espelhar todo o trafego da rede para a porta do "IDS de borda", o DScanARP.
#	4º - Possuir a ferramenta Tcpdump instalada.

# Verifica se o primeiro argumento foi passado.
if [ "$1" == "" ];
then
	echo -e "Modo de uso: sudo $0 [INTERFACE]\nEx: sudo $0 enp0s3"
else

# Verifica se o diretório dslogs existe.
	if [ -d dslogs ];
	then
		true
	else
		mkdir dslogs
	fi

	# Torna o script contínuo.
	while true;
	do

		# Pula uma linha
		echo -e ""

		# Captura 5 pacotes ARP Request.
		## O número de pacotes capturados poderá ser alterado dependendo do tamanho de tráfego ARP da rede.
		tcpdump -venw scan-arp.pcap -c 5 -i $1 arp and arp[6:2] == 1

		# Verifica se a quantidade de linhas do arquivo está correta.
		## Caso modifique o número de pacotes, não se esqueça de  modificar aqui também o seu valor!
		if [ "$(tcpdump -venr scan-arp.pcap | wc -l)" == "5" ];
		then

			# Atribui a hora do registro a um arquivo temporário unificando as linhas iguais.
			tcpdump -venr scan-arp.pcap | cut -d " " -f 1 | cut -d "." -f 1 | sort -u > tempo

			# Atribui o do endereço IP do registro a um arquivo temporário unificando as linhas iguais.
			tcpdump -venr scan-arp.pcap | cut -d " " -f 20 | sed 's/,//g' | sort -u > atacante

			# Quantifica em linhas o tempo e os endereços IPs, caso seja igual a 1:
			if [ "$(cat tempo | wc -l)" == "1" ] && [ "$(cat atacante | wc -l)" == "1" ];
			then
				# Configura um Scan ARP.

				### ENTRE COM O COMANDO DE ALERTA DO ADMIM AQUI! ###
				echo -e "\nALERTA!!!\nSCAN ARP DETECTADO!!!\n\nProveniente do IP: $(cat atacante)\n Horario: $(cat tempo)\n"

				# Cria arquivo de log.
				echo -e "\nALERTA DE SCAN ARP NA REDE!!!\n" >> dslogs/dslogs.log
				echo -e "Proveniente do IP: $(cat atacante)" >> dslogs/dslogs.log
				echo -e "Hora: $(cat tempo)\n-------------------------------" >> dslogs/dslogs.log
			fi

		fi
			# Verifica se os arquivos temporários existem. Se sim, os apaga.
			test -f scan-arp.pcap && rm scan-arp.pcap
			test -f tempo && rm tempo
			test -f atacante && rm atacante

			# Agurda um segundo.
			sleep 1
	done
fi

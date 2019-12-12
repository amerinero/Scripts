#!/bin/bash
#DOMINIOS="espaciodespachos.es lefebvre.es"
DOMINIOS=`cat all-domains-20191012.txt`
EXP_AXARNET="axarnet"
TEST_PREFIXES="www"
OUT_CSV="check-domains.csv"
SOA=""


function get_SOA () {
	SOA=`dig +noall +answer -t SOA -q $1 | awk '{print $5,$6,$7}'`
	if [[ -z $SOA ]]
	then 
		SOA="SOA No encontrado"
	fi
	echo "  $1 SOA = ${SOA}"
	CSV_LINE=${CSV_LINE}${SOA}";"
}

function resolver () {
	DIRECCION=`dig +noall +answer -t A -q $1 | head -1 | awk '{print $5}'`
	echo "  $1 --> ${DIRECCION}"
	if [[ -z $DIRECCION ]]
	then
		DIRECCION="NO resuelve"
	fi
	CSV_LINE=${CSV_LINE}${DIRECCION}";"
}

function is_axarnet () {
	curl --silent $1 2>&1 | grep -q -i axarnet
	RESP=$?
	if [ $RESP -eq "0" ]
	then
		echo "  Respuesta automatica de Axarnet"
		CSV_LINE=${CSV_LINE}"Respuesta automatica de Axarnet;"
	else
		echo "  WEB REAL!!!"
		CSV_LINE=${CSV_LINE}"WEB REAL!!!;"
	fi
}

function is_axarnet_ssl () {
	curl -k --silent https://$1 2>&1 | grep -q -i axarnet
	RESP=$?
	if [ $RESP -eq "0" ]
	then
		echo "  Respuesta automatica de Axarnet"
		CSV_LINE=${CSV_LINE}"Respuesta automatica de Axarnet SSL;"
	else
		echo "  WEB REAL!!!"
		CSV_LINE=${CSV_LINE}"WEB REAL SSL!!!;"
	fi
}

function https_ping () {
	httping -l -t 5 -c 2 $1 > /dev/null 2>&1
	RESP=$?
	if [ $RESP -eq "0" ]
	then
		echo "  httping SSL $1 OK"
		is_axarnet_ssl $1
	else
		echo "  httping SSL $1 No OK"
		CSV_LINE=${CSV_LINE}"NO HTTP;"
	fi	
}

function http_ping () {
	httping -t 5 -c 2 $1 > /dev/null 2>&1
	RESP=$?
	if [ $RESP -eq "0" ]
	then
		echo "  httping $1 OK"
		is_axarnet $1
	else
		echo "  httping $1 No OK"
		https_ping $1
	fi
}



for dom in ${DOMINIOS}
do
	CSV_LINE="${dom};"
	echo "Testeando ${dom}..."
	get_SOA ${dom}
	resolver ${dom}
	http_ping ${dom}
	echo "$CSV_LINE" >> $OUT_CSV
	for PREFIX in ${TEST_PREFIXES}
	do
		CSV_LINE="${PREFIX}.${dom};${SOA};"
		resolver ${PREFIX}.${dom}
		http_ping ${PREFIX}.${dom}
		echo "$CSV_LINE" >> $OUT_CSV
	done
	echo ""
done


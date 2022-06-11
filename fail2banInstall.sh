#!/bin/bash
#
# Script de instalação e modificação do Fail2Ban no sistema CentOS 7
#
# Autor Ricardo Souza 16/07/2022
#
# Versão 1.0
###############################################################################################

echo "################################################################"
echo "Atualização de pacotes e a instalação do Fail2Ban no CentOs 7"
echo "################################################################"
echo "################################################################"
sudo yum install fail2ban -y

echo "################################################################"
echo "Auto Configuração em processamento"
echo "################################################################"
echo "-- Escrevendo o arquivo /etc/fail2ban/filter.d/asterisk.conf"
	touch /etc/fail2ban/filter.d/asterisk.conf
	cp /etc/fail2ban/filter.d/asterisk.conf /etc/fail2ban/filter.d/asterisk.bak

################################# ESCREVENDO ARQUIVOS EM ASTERISK.CONF #################

echo "
# Configuração de arquivos Fail2Ban

[INCLUDES]

# Read common prefixes. If any customizations available -- read them from
# common.local
before = common.conf

[Definition]

# Option:  failregex
# Notes.:  regex to match the password failures messages in the logfile.
# Values:  TEXT
#
log_prefix= \[\]\s*(?:NOTICE|SECURITY)%(__pid_re)s:?(?:\[\S+\d*\])? \S+:\d*

failregex = ^%(log_prefix)s Registration from '[^']*' failed for '<HOST>(:\d+)?' - Wrong password$
            ^%(log_prefix)s Registration from '[^']*' failed for '<HOST>(:\d+)?' - No matching peer found$
            ^%(log_prefix)s Registration from '[^']*' failed for '<HOST>(:\d+)?' - Username/auth name mismatch$
            ^%(log_prefix)s Registration from '[^']*' failed for '<HOST>(:\d+)?' - Device does not match ACL$
            ^%(log_prefix)s Registration from '[^']*' failed for '<HOST>(:\d+)?' - Peer is not supposed to register$
            ^%(log_prefix)s Registration from '[^']*' failed for '<HOST>(:\d+)?' - ACL error \(permit/deny\)$
            ^%(log_prefix)s Registration from '[^']*' failed for '<HOST>(:\d+)?' - Not a local domain$
            ^%(log_prefix)s Call from '[^']*' \(<HOST>:\d+\) to extension '\d+' rejected because extension not found in context 'default'\.$
            ^%(log_prefix)s Host <HOST> failed to authenticate as '[^']*'$
            ^%(log_prefix)s No registration for peer '[^']*' \(from <HOST>\)$
            ^%(log_prefix)s Host <HOST> failed MD5 authentication for '[^']*' \([^)]+\)$
            ^%(log_prefix)s Failed to authenticate (user|device) [^@]+@<HOST>\S*$
            ^%(log_prefix)s (?:handle_request_subscribe: )?Sending fake auth rejection for (device|user) \d*<sip:[^@]+@<HOST>>;tag=\w+\S*$
            ^%(log_prefix)s SecurityEvent="\""(FailedACL|InvalidAccountID|ChallengeResponseFailed|InvalidPassword)"\"",EventTV="\""[\d-]+"\"",Severity="\""[\w]+"\"",Service="\""[\w]+"\"",EventVersion="\""\d+"\"",AccountID="\""\d+"\"",SessionID="\""0x[\da-f]+"\"",LocalAddress="\""IPV[46]/(UD|TC)P/[\da-fA-F:.]+/\d+"\"",RemoteAddress="\""IPV[46]/(UD|TC)P/<HOST>/\d+"\""(,Challenge="\""\w+"\"",ReceivedChallenge="\""\w+"\"")?(,ReceivedHash="\""[\da-f]+"\"")?$

# Option:  ignoreregex
# Notes.:  regex to ignore. If this regex matches, the line is ignored.
# Values:  TEXT
#
ignoreregex =" > /etc/fail2ban/filter.d/asterisk.conf

################################# FINALIZANDO EM ASTERISK.CONF ##################

echo "-- Modificando o arquivo /etc/fail2ban/jail.conf"

################################# Escrevendo o JAIL.CONF ####################

cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.bkp

echo "
[INCLUDES]
before = paths-fedora.conf

[DEFAULT]
bantime  = 100
maxretry = 3
ignoreip = 127.0.0.1/8 ::1

[asterisk-iptables]

enabled  = true
filter   = asterisk
action   = iptables-allports[name=ASTERISK, protocol=all]
           sendmail-whois[name=ASTERISK, dest=$EMAIL, sender=seuemail@seuprovedor.com.br]
logpath  = /var/log/asterisk/messages
maxretry = 4
bantime = 86400

[sshd]
enabled = true
filter = sshd
logpath = %(sshd_log)s" > /etc/fail2ban/jail.conf

################################## CRIANDO ARQUIVO jail.local ################################
echo "CRIANDO O ARQUIVO jail.local"
touch /etc/fail2ban/jail.local
echo " "
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

################################# CONCLUIDO A FINALIZACAO DO JAIL.CONF ######################

echo "-- Modificando o arquivo /etc/asterisk/logger.conf"

################################# ESCREVENDO O ARQUIVO LOGGER.CONF ##################
mv /etc/asterisk/logger.conf /etc/asterisk/logger.bak

touch /etc/asterisk/logger.conf

echo "
[general]
dateformat=%F %T

[logfiles]
notice => notice
debug => debug
trace => trace
security => security
console => error,dtmf,debug,verbose
;console => notice,warning,error,debug
messages => notice,warning,error,security
;full => notice,warning,error,debug,verbose,dtmf,fax
" >> /etc/asterisk/logger.conf

################################# TERMINANDO A CONFIGURAÇÃO DO LOGGER.CONF #####################

echo "######### Recarregando o Asterisk Logger #############"
asterisk -rx "logger reload"
echo " "
echo " "
echo "#################################################################"
echo " Reload no modulo do Logger so asterisk OK!!!!"
echo "################################################################"
echo "Configuração Finalizada com Sucesso"


systemctl restart fail2ban

echo "################################################################"
echo "Fail2Ban para Asterisk finalizado com sucesso"
echo "###############################################################"
echo " "
echo "Vá tomar seu cafezinho!!!!"



echo " "

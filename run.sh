#!/bin/bash

##修改Config.py配置
#sed -i "s/localhost/$HOSTNAME/"                 /app/shadowsocks/Config.py
#sed -i "s/ssuser/$USERNAME/"                    /app/shadowsocks/Config.py
#sed -i "s/yourDBPassword/$PASSWORD/"            /app/shadowsocks/Config.py
#sed -i "s/shadowsocks/$DATABASE/"               /app/shadowsocks/Config.py 
##添加server.py的执行路径/app/shadowsocks
#sed -i "s%##sed add##%import os \\nos.chdir(\"/app/shadowsocks\")%"   /app/shadowsocks/server.py

if [ "${AUTHORIZED_KEYS}" != "**None**" ]; then
    echo "=> Found authorized keys"
    mkdir -p /root/.ssh
    chmod 700 /root/.ssh
    touch /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    IFS=$'\n'
    arr=$(echo ${AUTHORIZED_KEYS} | tr "," "\n")
    for x in $arr
    do
        x=$(echo $x |sed -e 's/^ *//' -e 's/ *$//')
        cat /root/.ssh/authorized_keys | grep "$x" >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "=> Adding public key to /root/.ssh/authorized_keys: $x"
            echo "$x" >> /root/.ssh/authorized_keys
        fi
    done
fi

if [ ! -f /.root_pw_set ]; then
	/set_root_pw.sh
fi

apache2-foreground &

exec /usr/sbin/sshd -D

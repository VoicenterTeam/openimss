#!/bin/bash
set -e

#run captagent pre-config:
#/usr/bin/mo /tmp/hepCfg.mustache > /usr/local/captagent/etc/captagent/transport_hep.xml
#/usr/local/captagent/sbin/captagent -f  /usr/local/captagent/etc/captagent/captagent.xml -d
#/usr/bin/heplify -i any -t af_packet -m SIPRTCP -hs $hepIP:$hepPort -hi $hepID &
#

if [ "$1" = 'asterisk' ]; then
  shift

  while :; do
    case $1 in
    --http-port)
      if [ -n "$2" ]; then
        sed -i -e "s/bindport=[[:digit:]]\+/bindport=$2/g" /etc/asterisk/http.conf
      fi
      ;;

    --http-address)
      if [ -n "$2" ]; then
        sed -i -e "s/bindaddr=.*\"/bindaddr=$2\"/g" /etc/asterisk/http.conf
      fi
      ;;

    --ari-user)
      if [ -n "$2" ]; then
        sed -i -e "s!^\[asterisk\]![$2]!g" /etc/asterisk/ari.conf
      fi
      ;;

    --ari-password)
      if [ -n "$2" ]; then
        sed -i -e "s!^password = asterisk!password = $2!g" /etc/asterisk/ari.conf
      fi
      ;;

    --sip-address)
    if [ -n "$2" ]; then
      sed -i -e "s!^bind=0.0.0.0:5060!bind=$2!g" /etc/asterisk/pjsip.conf
    fi
    ;;

    --)
      shift
      break
      ;;

    *)
      break
    esac

    shift 2

  done
  echo
  exec asterisk -f $@
fi

exec "$@"

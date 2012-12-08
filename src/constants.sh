#!/bin/sh
#
# This file generates any necessary constant for a given platform.
#

# Name of package

name=$1
srcdir=$2
fname=$3
CC="$4"

# List of constants we need to know

constants="TCP_NODELAY AF_INET AF_UNIX SOCK_STREAM SOCK_DGRAM EINTR EAGAIN"
constants="${constants} EWOULDBLOCK EINPROGRESS EALREADY EISCONN"
constants="${constants} ECONNREFUSED FNDELAY FASYNC-FIOASYNC F_GETFL F_SETFL"
constants="${constants} F_SETOWN-FIOSSAIOOWN SO_RCVBUF SO_REUSEADDR"
constants="${constants} SO_REUSEPORT"
constants="${constants} SOL_SOCKET SIGTERM SIGKILL O_RDONLY O_WRONLY"
constants="${constants} O_RDWR HOST_NOT_FOUND TRY_AGAIN NO_RECOVERY"
constants="${constants} NO_DATA NO_ADDRESS POLLIN POLLPRI POLLOUT POLLERR"
constants="${constants} POLLHUP POLLNVAL I_SETSIG S_RDNORM S_WRNORM"
constants="${constants} IPPROTO_IP IP_ADD_MEMBERSHIP IP_MULTICAST_LOOP"
constants="${constants} IP_MULTICAST_TTL IP_DROP_MEMBERSHIP"
constants="${constants} O_NONBLOCK MSG_PEEK FIONBIO FIONREAD SO_SNDBUF"
constants="${constants} SOL_TCP SO_KEEPALIVE TCP_KEEPCNT TCP_KEEPIDLE TCP_KEEPINTVL"
# ipv6
constants="${constants} AF_INET6"
# Constants for protocol independent nodename-address translations
constants="${constants} AI_ADDRCONFIG  AI_ALL         AI_CANONNAME"
constants="${constants} AI_DEFAULT     AI_MASK        AI_NUMERICHOST"
constants="${constants} AI_PASSIVE     AI_V4MAPPED    AI_V4MAPPED_CFG"
constants="${constants} NI_DGRAM       NI_MAXHOST     NI_MAXSERV"
constants="${constants} NI_NAMEREQD    NI_NOFQDN      NI_NUMERICHOST"
constants="${constants} NI_NUMERICSERV NI_WITHSCOPEID"
# setsockopt
constants="${constants} IPPROTO_IPV6"
constants="${constants} IPV6_UNICAST_HOPS   IPV6_MULTICAST_IF"
constants="${constants} IPV6_MULTICAST_HOPS IPV6_MULTICAST_LOOP"
constants="${constants} IPV6_JOIN_GROUP     IPV6_LEAVE_GROUP"

# Debug

debug=$1

# Look for any header file found

tmpe=./tmpe$$
trap "rm -f ${tmpe}" 0 1 2 3 15

# Header of generated file

cat > ${fname} << EOF
--  This package has been generated automatically on:
EOF
./split "`uname -a`" >> ${fname}
echo "--  Generation date: `date`" >> ${fname}
cat >> ${fname} << EOF
--  Any change you make here is likely to be lost !
package ${name} is
EOF

# For each constant, try to output its value or -1 if undefined

for c in ${constants}; do
    case ${c} in
	*-*)
            OIFS=${IFS}; IFS="-"; set ${c}; IFS=${OIFS}; \
	    echo "Checking value of $1 (or $2 as a substitute)"; \
            (${CC} -DCONSTANT_NAME=$1 -I. -o ${tmpe} ${srcdir}/constants.c \
	            2>/dev/null &&
	            ${tmpe} $1 >> ${fname}) ||
            (${CC} -DCONSTANT_NAME=$2 -I. -o ${tmpe} ${srcdir}/constants.c \
	            2>/dev/null &&
	            ${tmpe} $1 >> ${fname}) ||
            ./constants_nodef $1 >> ${fname}
    ;;
	*)
	    echo "Checking value of $c"; \
            (${CC} -DCONSTANT_NAME=${c} -I. -o ${tmpe} ${srcdir}/constants.c \
	            2>/dev/null && \
	            ${tmpe} ${c} >> ${fname}) || \
             ./constants_nodef ${c} >> ${fname}
    ;;
    esac
done

# Trailer of generated file

cat >> ${fname} << EOF
end ${name};
EOF

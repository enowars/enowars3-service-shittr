all: run

run:
	socat OPENSSL-LISTEN:31337,fork,reuseaddr,pktinfo,cert=./static/ssl.crt,key=./static/ssl.key,verify=0 EXEC:./shittr
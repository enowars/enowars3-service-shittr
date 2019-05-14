all: run6

run6:
	socat OPENSSL-LISTEN:31337,fork,reuseaddr,pktinfo,cert=./static/ssl.crt,key=./static/ssl.key,verify=0,pf=ip6 EXEC:./shittr 

run4:
	socat OPENSSL-LISTEN:31337,fork,reuseaddr,pktinfo,cert=./static/ssl.crt,key=./static/ssl.key,verify=0,pf=ip4 EXEC:./shittr 
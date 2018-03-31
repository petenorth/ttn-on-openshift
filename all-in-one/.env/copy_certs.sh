cat discovery/server.cert > router/ca.cert
cat discovery/server.cert > broker/ca.cert
cp networkserver/server.cert broker/networkserver.cert
cat discovery/server.cert > handler/ca.cert

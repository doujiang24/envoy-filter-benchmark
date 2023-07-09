upstream_ip=127.0.0.1
envoy=envoy

run:
	sed "s#/path-to-lua-file#$$PWD/passthrough.lua#g" envoy.yaml | sed "s#upstream_ip#${upstream_ip}#g" > envoy-run.yaml
	nohup ${envoy} -c envoy-run.yaml &

test:
	curl -s -I 'http://localhost:10000/'
	curl -s -I 'http://localhost:10000/' -H 'Authorization: Basic Zm9vbmFtZTp2YWxpZHBhc3N3b3Jk'

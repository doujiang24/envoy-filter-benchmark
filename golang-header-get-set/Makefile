
go120=go
go121=go
go122=go
envoy=envoy

upstream_ip=127.0.0.1

build:
	${go120} build -v -o lib120.so -buildmode=c-shared .
	${go121} build -v -o lib121.so -buildmode=c-shared .
	${go122} build -v -o lib122.so -buildmode=c-shared .

run-120:
	sed "s#/path-to-golang.so#$$PWD/lib120.so#g" envoy.yaml | sed "s#upstream_ip#${upstream_ip}#g" > envoy-run.yaml
	GODEBUG=cgocheck=0,gctrace=1 nohup ${envoy} -c envoy-run.yaml &

run-121:
	sed "s#/path-to-golang.so#$$PWD/lib121.so#g" envoy.yaml | sed "s#upstream_ip#${upstream_ip}#g" > envoy-run.yaml
	GODEBUG=cgocheck=0,gctrace=1 nohup ${envoy} -c envoy-run.yaml &

run-122:
	sed "s#/path-to-golang.so#$$PWD/lib122.so#g" envoy.yaml | sed "s#upstream_ip#${upstream_ip}#g" > envoy-run.yaml
	GODEBUG=cgocheck=0,gctrace=1 nohup ${envoy} -c envoy-run.yaml &

test:
	curl -s -I 'http://localhost:10000/'
	curl -s -I 'http://localhost:10000/' -H 'Authorization: Basic Zm9vbmFtZTp2YWxpZHBhc3N3b3Jk'

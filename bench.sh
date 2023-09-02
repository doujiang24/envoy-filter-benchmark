#!/bin/bash

upstream_ip="172.26.222.91"
local_ip="172.26.222.90"

go120=~/work/go1.20/bin/go
go121=~/work/go1.21/bin/go
go122=~/work/go-src/bin/go

envoy=~/work/envoy/envoy-opt-wasm

set -o errexit

kill_envoy() {
    count=`ps aux | grep envoy | grep -v grep | wc -l`
    if [ $count -ne 0 ]; then
        ps aux | grep envoy | grep -v grep | awk '{print $2}' | xargs kill
        sleep 1.5
    fi
    count=`ps aux | grep envoy | grep -v grep | wc -l`
    if [ $count -ne 0 ]; then
        echo "kill envoy failed"
        exit 1
    fi
}

bench() {
    ssh root@$upstream_ip "wrk -d 30 -t 4 -c 100 http://$local_ip:10000 -H 'Authorization: Basic Zm9vbmFtZTp2YWxpZHBhc3N3b3Jk'"

    kill_envoy
}

set +x

echo "=== envoy base ==="

cd envoy-base

make run upstream_ip=$upstream_ip envoy=$envoy
bench

cd ..

echo "=== passthrough: golang compiling ==="

cd golang-passthrough
make build go120=$go120 go121=$go121

echo "=== passthrough: golang 1.20 running ==="

make run-120 upstream_ip=$upstream_ip envoy=$envoy
bench

echo "=== passthrough: golang 1.21 running ==="

make run-121 upstream_ip=$upstream_ip envoy=$envoy
bench

cd ..

cd lua-passthrough

echo "=== passthrough: lua running ==="

make run upstream_ip=$upstream_ip envoy=$envoy
bench

cd ..

echo "=== passthrough: wasm running ==="

cd wasm-tinygo-passthrough

make build
make run upstream_ip=$upstream_ip envoy=$envoy
bench

cd ..

echo "=== basic auth: golang compiling ==="

cd golang-basic-auth
make build go120=$go120 go121=$go121

echo "=== basic auth: golang 1.20 running ==="

make run-120 upstream_ip=$upstream_ip envoy=$envoy
bench

echo "=== basic auth: golang 1.21 running ==="

make run-121 upstream_ip=$upstream_ip envoy=$envoy
bench

cd ..

cd lua-basic-auth

echo "=== basic auth: lua running ==="

make run-lua upstream_ip=$upstream_ip envoy=$envoy
bench

echo "=== basic auth: luajit running ==="

make run-luajit upstream_ip=$upstream_ip envoy=$envoy
bench

cd ..

echo "=== basic-auth: wasm ==="

cd wasm-tinygo-basic-auth

make build
make run upstream_ip=$upstream_ip envoy=$envoy
bench

cd ..

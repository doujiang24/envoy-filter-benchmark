#!/bin/bash

upstream_ip="172.26.222.90"
local_ip="172.26.222.89"

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
    ssh root@$upstream_ip "wrk -d 300 -t 4 -c 100 http://$local_ip:10000 -H 'Authorization: Basic Zm9vbmFtZTp2YWxpZHBhc3N3b3Jk'"

    kill_envoy

    tail -n 1000 nohup.out | grep 'gc ' | tail -n 2
}

set +x

echo "=== header-get-set: golang compiling ==="

cd golang-header-get-set
make build go120=$go120 go121=$go121 go122=$go122

echo "=== header-get-set: golang 1.20 running ==="

make run-120 upstream_ip=$upstream_ip envoy=$envoy
bench

echo "=== header-get-set: golang 1.21 running ==="

make run-121 upstream_ip=$upstream_ip envoy=$envoy
bench

echo "=== header-get-set: golang 1.22 running ==="

make run-122 upstream_ip=$upstream_ip envoy=$envoy
bench

cd ..

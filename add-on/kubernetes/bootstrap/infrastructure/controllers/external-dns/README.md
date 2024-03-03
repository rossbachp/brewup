# External DNS

* https://github.com/kubernetes-sigs/external-dns
* https://coredns.io
* https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/coredns.md
* https://github.com/bitnami/charts/blob/main/bitnami/external-dns/values.yaml
* https://www.diomedet.com/posts/kubernetes-external-dns-pihole-and-a-custom-domain/

## Preparation

* Setup of the coredns + etcd
* Choose right domain

## Install

```shell
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update bitnami
k create namespace external-dns
k ns external-dns
kubectl apply -f external-dns-config.yaml
kubectl apply -f external-dns.yaml

kubectl --namespace=external-dns get pods -l "app.kubernetes.io/name=external-dns,app.kubernetes.io/instance=external-dns"
```

## Check

```shell
k create namespace whoami
k ns whoami
k apply -f test/whoami.yaml

# check with dig
dig @172.20.0.249 -p 30053 whoami.yp.chicken.lan
; <<>> DiG 9.10.6 <<>> @192.168.176.4 -p 30053 whoami.yp.chicken.lan
; (1 server found)
;; global options: +cmd
;; Got answer:
;; WARNING: .local is reserved for Multicast DNS
;; You are currently testing what happens when an mDNS query is leaked to DNS
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 62462
;; flags: qr aa rd; QUERY: 1, ANSWER: 3, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;whoami.yp.chicken.lan. IN A

;; ANSWER SECTION:
whoami.yp.chicken.lan. 30 IN A     172.20.0.248

;; Query time: 2 msec
;; SERVER: 172.20.0.249#30053(172.20.0.249)
;; WHEN: Fri Feb 05 10:01:03 CET 2024
;; MSG SIZE  rcvd: 213

# teardown
k delete namespace whoami

```

## Todos

* Check the requirements of mhs
* Setup etcd with TLS
* Metrics Support
* Install ca-bundle as ClusterIssuer and check that certificate can install at cluster level
  * https://cert-manager.io/docs/usage/ingress/

Regards,
[`|-o-|` The pathfinder - Peter](mailto://peter.rossbach@bee42.com)

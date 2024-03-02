# Setup Core DNS

* https://www.diomedet.com/posts/kubernetes-external-dns-pihole-and-a-custom-domain/
* https://artifacthub.io/packages/helm/coredns/coredns
  
```shell
k create namespace coredns
k ns coredns
# We will add this repo to our helm infrastructure. Then we do not need a separate
# deployment.yaml in our own project. We will use the helm template from the external repo
helm repo add coredns https://coredns.github.io/helm
# create your configuration
k apply -f etcd
k apply -f coredns-config.yaml
k apply -f coredns.yaml
k get nodes -o wide
dig @172.22.5.104 -p 30053 google.com

; <<>> DiG 9.10.6 <<>> @192.168.176.4 -p 30053 google.com
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 898
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;google.com.                    IN      A

;; ANSWER SECTION:
google.com.             30      IN      A       172.217.16.206

;; Query time: 17 msec
;; SERVER: 192.168.176.4#30053(192.168.176.4)
;; WHEN: Fri Feb 02 10:14:11 CET 2024
;; MSG SIZE  rcvd: 65

```

TODO:

* Image version etcd expected
* Helm Chart etcd
* Kustomize etcd or use ectd operator
* Other Option to make etcd avaiable
* Documentation of DNS Integrations...

Regards,
[`|-o-|` The pathfinder - Peter](mailto://peter.rossbach@bee42.com)

# tschrock52.com

## Architecture Image
![Site Architecture](/html/images/architecture_site.png)

### Architecture Explanation
#### Public Traffic Flow
##### Client -> Firewall Edge
 - Public traffic resolves the DNS name tschrock52.com to my public IP address.
 - Once traffic flows into my pfSense firewall on port 443, it hits an HAProxy frontend.
 - The HAPRoxy frontend uses a wildcard certificate from LetsEncrypt to provide secure SSL encryption.
 - HAProxy has a backend tied to this frontend and custom configuration options defined.

###### HAProxy's Http check version:
```
HTTP/1.1\r\nHost:\ www.tschrock52.com\r\nAccept:\ */*
```
###### HAProxy's Backend pass thru:
```
http-request set-header Host www.tschrock52.com
```
##### MetalLB / kube-proxy / ingress -> Service
 - HAProxy’s backend forwards decrypted HTTP traffic to the MetalLB-assigned LoadBalancer IP (10.1.0.x) for the ingress-nginx-controller Service.
   - Note: This external IP is configured and working due to MetalLB's controller pod configuring an external IP for the ingress-nginx-controller.
 - kube-proxy on the node receives traffic for the external Load Balancer IP on a port (say 80 or 443).
 - kube-proxy uses iptables/ipvs rules to forward the traffic to one of the ingress-nginx-controller Pods based on the Service definition.
 - The ingress-nginx-controller pod processes the HTTP/HTTPS request based on configured Ingress rules.
 - The ingress-nginx-controller uses the NGINX web server to process the request and route it to the correct service in the cluster (tschrock52-service).
   - Note: The NGINX web server is configured with a custom configMap that sets up a default backend for 404 errors.
##### Service -> Site Pods -> Client
 - The tschrock52-service forwards the request to the correct pod (tschrock52-site-aaaaaaaaaa-bbbbb/schrock52-site-xxxxxxxxxx-yyyyy).
 - The pod processes the request and returns a response to the client.

### Code
### deployment.yaml
```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tschrock52-site
  namespace: tschrock52
spec:
  replicas: 2
  selector:
    matchLabels:
      app: tschrock52-site
  template:
    metadata:
      labels:
        app: tschrock52-site
    spec:
      containers:
      - name: nginx
        image: tschrock52/tschrock52-html-site:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: tschrock52-service
  namespace: tschrock52
spec:
  type: ClusterIP
  selector:
    app: tschrock52-site
  ports:
  - port: 80
    targetPort: 80
```
### metallb-config.yaml
```YAML
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  namespace: metallb-system
  name: tschrock52-pool
spec:
  addresses:
  - 10.1.0.175-10.1.0.185
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  namespace: metallb-system
  name: l2-adv
```
### tschrock52-ingress.yaml
```YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tschrock52-ingress
  namespace: tschrock52
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: www.tschrock52.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: tschrock52-service
            port:
              number: 80
```

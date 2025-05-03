#!/bin/bash
cd /var/www/html
docker build -t tschrock52-html-site /var/www/html
docker tag tschrock52-html-site tschrock52/tschrock52-html-site
docker push tschrock52/tschrock52-html-site
sleep 5
kubectl rollout restart deployment tschrock52-site -n tschrock52

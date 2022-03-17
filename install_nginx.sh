#! /bin/bash
sudo yum update
sudo amazon-linux-extras install -y nginx1
echo "charset utf-8;" | sudo tee /etc/nginx/conf.d/http.conf
sudo systemctl start nginx
echo "<!DOCTYPE html><html><head><meta http-equiv=”Content-Type” content=”text/html; charset=utf-8″><title>Schub terraform challenge</title></head><body><h1>Deployment date: $(date -u)</h1><h1>Test for Schub Cloud</h1><h1>João Victor Oliveira Santos</h1></body></html>" | sudo tee /usr/share/nginx/html/index.html
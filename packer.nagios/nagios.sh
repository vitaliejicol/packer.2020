#!/bin/bash        
        


cd /tmp
sudo yum install wget -y
wget https://assets.nagios.com/downloads/nagiosxi/xi-latest.tar.gz
tar xzf xi-latest.tar.gz
cd nagiosxi
sudo ./fullinstall -y
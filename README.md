# Database_Queries
Hear you can get Oracle, Sql Server, MySql,PostGres database queries.
HI,

Useful Commands:-

sudo sed -i 's/8080/5000/g' app.py; python3 app.py #to change the port in a file directly change from 8080 to 5000

sudo sed -i 's/0.0.0.0/127.0.0.1/g;s/8080/5000/g' /opt/simple-webapp-flask/app.py;
cd /opt/simple-webapp-flask/; nohup python3 app.py &
sudo sed -i 's/172.16.239.30/0.0.0.0/g' /opt/simple-webapp-flask/app.py; sudo pkill python3; cd /opt/simple-webapp-flask/; nohup python3 app.py &
curl app01:5000 ; curl 172.16.239.30:5000



grep "2025/01/31" error.log-20250102 | grep "Worker_connections are not enough" | wc -l #gives the count of event what we provided
112341 
zgrep "31/Jan/2024" access* | wc -l #give the count of all connections
1232133

zgrep "31/Jan/2024" access* | cut -f9 -d" " | sort | uniq -c #gives the count of connection list based on error code
32123213 200
54       302
6856     400
654      404

zgrep "31/Jan/2024" access* | cut -f1 -d" " | cut -f2 -d" " | sort | uniq -c #gives count based on incoming ip address
54757534  192.168.0.1
56476     192.168.0.8
765       192.168.6.7


jq .scripts /opt/the-example-app.nodejs/package.json #to find which is not a script for the nodejs app?

sudo npm dist-tag pm2  #to find the latest version pm2

sudo npm install pm2@latest -g ## pm2 start app.js ## pm2 delete app.js ## pm2 start app.js -i 4 #with 4 forks

ip addr show ## 

sudo sed -i 's/8080/9090/g' apache-tomcat-8.5.53/conf/server.xml  

thor@host01 ~$ sudo ./apache-tomcat-8.5.53/bin/startup.sh




example to create ssl
sudo openssl req -new -newkey rsa:2048 -nodes -keyout app01.key -out app01.csr
openssl req  -noout -text -in app01.csr

/etc/httpd/csr/app01.csr (key name should be app01.key). Below are the required details which should be used while creating CSR.


a. Country Name = SG

b. State or Province Name = Capital Tower

c. Locality Name = CT

d. Organization Name = KodeKloud

e. Organizational Unit Name = Education

f. Common Name = app01.com

g. Email Address = admin@kodekloud.com

h. Keep challenge password blank.

i. Keep optional company name blank.



cd into /etc/httpd/certs directory and run command sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout app01.key -out app01.crt and then pass in the details given above.

a. Country Name = SG

b. State or Province Name = Capital Tower

c. Locality Name = CT

d. Organization Name = KodeKloud

e. Organizational Unit Name = Education

f. Common Name = app01.com

g. Email Address = admin@kodekloud.com

git log --graph --decorate

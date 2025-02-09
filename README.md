# Database_Queries
Hear you can get Oracle, Sql Server, MySql,PostGres database queries.
HI,

Useful Commands:-

sudo sed -i 's/8080/5000/g' app.py; python3 app.py #to change the port in a file directly change from 8080 to 5000

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



jq .scripts /opt/the-example-app.nodejs/package.json #to find which is not a script for the nodejs app?


54757534  192.168.0.1
56476     192.168.0.8
765       192.168.6.7

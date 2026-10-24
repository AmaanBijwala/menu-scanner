#!/usr/bin/env bash
# Read-only diagnostics for "port 8080 not reachable". Run remotely:
#   ssh -i key.pem ubuntu@<ip> "bash -s" < check.sh

section() { echo; echo "===== $1 ====="; }

section "Host"
hostname; uptime
echo "Public IP (metadata): $(TOKEN=$(curl -s -m 2 -X PUT http://169.254.169.254/latest/api/token -H 'X-aws-ec2-metadata-token-ttl-seconds: 60'); curl -s -m 2 -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)"

section "Listening TCP ports"
sudo ss -tlnp

section "Port 8080 listener"
sudo ss -tlnp | grep ':8080 ' || echo "NOTHING is listening on 8080"

section "Java / Tomcat processes"
ps -eo pid,user,etime,cmd | grep -Ei 'java|catalina|tomcat' | grep -v grep || echo "No java/tomcat process running"

section "Java installed?"
java -version 2>&1 || echo "java not found on PATH"

section "Tomcat systemd units"
systemctl list-unit-files --no-pager | grep -i tomcat || echo "No tomcat unit file found"
for u in tomcat tomcat10 tomcat9; do
  if systemctl list-unit-files --no-pager | grep -q "^$u.service"; then
    echo "--- systemctl status $u ---"
    sudo systemctl status "$u" --no-pager -l | head -30
    echo "--- journalctl -u $u (last 30) ---"
    sudo journalctl -u "$u" --no-pager -n 30
  fi
done

section "Tomcat install dirs"
for d in /opt/tomcat /usr/share/tomcat10 /var/lib/tomcat10; do
  [ -d "$d" ] && { echo "--- $d ---"; ls -la "$d"; }
done
ls -la /opt/tomcat/webapps 2>/dev/null

section "Tomcat connector config (port)"
for f in /opt/tomcat/conf/server.xml /etc/tomcat10/server.xml; do
  [ -f "$f" ] && { echo "--- $f ---"; grep -n '<Connector' -A3 "$f"; }
done

section "Latest Tomcat logs"
for dir in /opt/tomcat/logs /var/log/tomcat10; do
  if [ -d "$dir" ]; then
    sudo ls -lt "$dir" | head -8
    for f in $(sudo ls -t "$dir" 2>/dev/null | grep -E 'catalina|localhost' | head -2); do
      echo "--- tail $dir/$f ---"
      sudo tail -40 "$dir/$f"
    done
  fi
done

section "curl localhost:8080"
curl -sS -m 5 -o /dev/null -w "HTTP %{http_code}\n" http://localhost:8080/ || true
curl -sS -m 5 -o /dev/null -w "HTTP %{http_code} (/menu-scanner/)\n" http://localhost:8080/menu-scanner/ || true

section "Host firewall"
sudo ufw status verbose 2>/dev/null || echo "ufw not available"
sudo iptables -S 2>/dev/null | head -20

section "Postgres / Redis / Nginx"
for s in postgresql redis-server nginx; do
  printf "%-14s %s\n" "$s" "$(systemctl is-active $s 2>/dev/null)"
done

section "Resources"
free -h; df -h /

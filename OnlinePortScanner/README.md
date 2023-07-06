
<center>
<img src="https://arsscriptum.github.io/assets/img/posts/scanner/main.jpg" alt="scanner" />
</center>


# Leveraging Online Port Scanners using PowerShell

Firewall Testing is the only way to accurately confirm whether the firewall is working as expected. Complicated firewall rules, poor management interfaces, and other factors often make it difficult to determine the status of a firewall. By using an external port scanner it is possible to accurately determine the firewall status. Personally, I needed a way to detect unauthorized changes in my config. Also, this is usefull when troubleshoting network access problems or detecting potential mishaps before they become a security castatrophe.

This type of firewall test attempts to make connections to external-facing services from the same perspective as an attacker. An unprotected open service (listening port) can be a major security weakness in poor firewall or router configurations.


### Why ? 

Here are some reasons you may want to use this script with an ***online port scanner***

1) Test Firewall Logging and IDS
2) Find Open Ports
3) Detect Unauthorized Firewall Changes
4) Troubleshoot Network Services

---------------------------------------------------------------------------------------------------------

### How ?

Pretty Straighforward. It uses an ***online port scanner*** , in this case [https://www.speedguide.net/portscan.php](https://www.speedguide.net/portscan.php) parses the replies using [HtmlAgilityPack](https://html-agility-pack.net/) . 

For your convienience, a function to install [HtmlAgilityPack](https://html-agility-pack.net/) is provided in [Install-HtmlAgilityPack.ps1](Install-HtmlAgilityPack.ps1). You can also checkout my [Install-NugetPackage.ps1](https://github.com/arsscriptum/PowerShell.Public.Sandbox/tree/master/InstallNugetPackage) script.  


### Possible States for Ports


|             **STATE**            |                                                                                                                                                                       **DESCRIPTION**                                                                                                                                                                       |
|:--------------------------------:|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
|            ** open **            | _Open ports offer services that are potentialy vulnerable to attacks! All ports should be closed or filtered, unless you specifically require some open (and know exactly what they are)._                                                                                                                                                                  |
|           ** closed **           | _Ports in this category respond to our scan, however appear to be closed. This state offers medium security. It still reveals that your system is up, and might provide some additional fingerprinting information to potential intruders._                                                                                                                 |
|          ** filtered **          | _Filtered ports do not respond to a portscan at all, they don't appear to exist. This is the best security level for your ports, as it provides no information about your system or its existence (a.k.a. black hole)._                                                                                                                                     |
| ** filtered?   open\|filtered ** | _Filtered UDP ports that do not respond to the scan. Note that the UDP protocol is not lossless, and does not respond to all requests by definition. Therefore, the lack of response does not guarantee that a port is being filtered. We have send a few requests without response, and it is reasonable to believe the ports in this state are filtered._ |


### Usage

Super easy, you provide port and the protocol. You can pass ```BOTH``` as protocol. In which case, you receive 2 results objects in the *Port* property.

```
    # Checking port 80 on TCP
    Test-FirewallPort -Port 80 -Protocol TCP

    Start-Sleep 5  # Server limits request rate

    # Checking port 1194 on TCP and UDP
    Test-FirewallPort -Port 1194 -Protocol BOTH 

    # Port 64 on UDP
    Test-FirewallPort -Port 64 -Protocol UDP
```

### Returned Results Format

You get a PsCustomObject. Here's a JSON representation to give you an idea.

```
    {
      "Total_scanned_ports": 1,
      "Open_ports": 0,
      "Closed_ports": 0,
      "Filtered_ports": 1,
      "Ports": [
        {
          "Port": "8088",
          "Protocol": "tcp",
          "Status": "filtered",
          "Service": "radan-http",
          "Description": "A port sometimes used for testing HTTP SERVERs"
        }
      ]
    }
```


### Important note

Upon getting an error in the request, you may have been rate-limited by the server. Try again later.

---------------------------------------------------------------------------------------------------------



<center>
<img src="https://arsscriptum.github.io/assets/img/posts/scanner/scanner.jpg" alt="scanner" />
</center>


### Other Online Port Scanners

 - [nmap online](https://nmap.online/) : an online version of the nmap utility. You can query any website or IP address but only a small number of nmap features are available. You may need to create a free account. The port scan looks at TCP ports FTP(21), SSH(22), SMTP(25), HTTP(80), POP(110), IMAP(143), HTTPS(443) and SMB(445). The Fast scan option scans the most popular 100 ports.
 - [can you see me](https://canyouseeme.org/) : will only test your public IP address (your router). It tests one port at a time and will test any port. It says nothing about TCP vs. UDP, so probably only uses TCP.
 - [grc.com](https://www.grc.com/x/portprobe=1801)
 - [whatsmyip](https://www.whatsmyip.org/port-scanner/) : can scan a single port or four different groups of common ports. They don't say if the scans are TCP, UDP or both. A port that does not respond is said to time out. This does not differentiate between closed and stealthed ports, making it relatively useless.
 - [ipvoid](https://www.ipvoid.com/port-scan/) : scans any public IP address. If you opt for common ports, it scans: 21, 22, 23, 25, 53, 80, 110, 111, 135, 139, 143, 389, 443, 445, 587, 1025, 1080, 1433, 3306, 3389, 5900, 6001, 6379 and 8080.
 - [ipfingerprints](https://www.ipfingerprints.com/portscan.php) : ipfingerprints.com lets you test an arbitrary range of ports, both for TCP and UDP
 - [shodan](https://routersecurity.org/shodan.php)
 - [hackertarget nmap tool](https://hackertarget.com/nmap-online-port-scanner/)
 - [hackertarget fw test](https://hackertarget.com/firewall-test/)


## Get the code 

[OnlinePortScanner on GitHub](https://github.com/arsscriptum/PowerShell.Public.Sandbox/tree/master/OnlinePortScanner)

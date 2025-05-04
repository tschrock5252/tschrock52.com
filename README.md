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

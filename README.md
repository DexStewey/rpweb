# Raspberry Pi Web Server Setup Script

This script automates the setup of a web server on a Raspberry Pi. It includes the installation and configuration of Apache, MySQL (MariaDB), PHP, Python, Django, Samba for file sharing, Webmin for server management, and Shell In A Box for web-based terminal access. Additionally, it creates a self-signed SSL certificate to enable HTTPS for secure connections.

## Features
- **LAMP Stack:** Installs Apache, MySQL (MariaDB), and PHP for a full web server setup.
- **Django Environment:** Sets up Python, `virtualenv`, and installs Django for web application development.
- **File Sharing:** Configures Samba to share the web server's directory over the network for easy file management.
- **Webmin:** Provides a web-based interface for server administration.
- **Shell In A Box:** Allows terminal access to the Raspberry Pi via a web browser.
- **Self-Signed SSL Certificate:** Configures Apache to use HTTPS with a self-signed certificate for secure access.
- **Automatic Service Start:** Ensures all services are configured to start on boot.

## Requirements
- Raspberry Pi running Raspberry Pi OS.
- Internet connection to download required packages.
- Administrator (sudo) access on the Raspberry Pi.

## Installation

### Step 1: Clone the Repository
On your Raspberry Pi, open a terminal and run:

```bash
git clone https://github.com/DexStewey/rpweb.git
cd rpweb
```

### Step 2: Make the Script Executable
Run the following command to make the script executable:

```bash
chmod +x setup_server.sh
```

### Step 3: Run the Script
Run the script with superuser privileges:

```bash
sudo ./setup_server.sh
```

### Step 4: Post-Installation
- **Access the Web Server:** Open a web browser and navigate to `http://<raspberry_pi_ip_address>/` or `https://<raspberry_pi_ip_address>/` for the secure version.
- **Access Webmin:** Use `https://<raspberry_pi_ip_address>:10000/`.
- **Access Shell In A Box:** Use `https://<raspberry_pi_ip_address>:4200/`.
- **Access PHPMyAdmin:** Use `http://<raspberry_pi_ip_address>/phpmyadmin`.
- **Access Shared Web Folder:** Use the network path `\\<raspberry_pi_ip_address>\web` on your local network.

## Customizing the Script
- **Samba User:** Replace `'pi'` in the script with your desired Samba username.
- **MySQL Root Password:** Replace `"your_secure_password"` in the script with a secure password for the MySQL root user.
- **SSL Certificate:** By default, the script creates a self-signed SSL certificate. You can replace it with a certificate from a Certificate Authority (CA) if needed.

## Troubleshooting
- **Permission Denied:** Ensure you run the script with `sudo`.
- **SSL Warnings:** Since a self-signed certificate is used, browsers will show a warning. To prevent this, add the generated certificate (`/etc/ssl/certs/myserver.crt`) to your browser's trusted certificate store.
- **Slow or No Boot After BIOS Update:** If your laptop exhibits booting issues after BIOS updates, you may need to clear CMOS settings or verify BIOS configurations.

## License
This project is licensed under the MIT License - see the `LICENSE` file.

## Contributions
No contributions are accepted at this time.

## Author
Created by _**ShadesOfAnime**_

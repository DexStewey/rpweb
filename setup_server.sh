#!/bin/bash

# Update and upgrade the system
echo "Updating the system..."
sudo apt update && sudo apt upgrade -y

# Install Apache, MySQL (MariaDB), PHP, Python, and other necessary packages
echo "Installing Apache, MySQL (MariaDB), PHP, Python, Pip, and Expect..."
sudo apt install apache2 mariadb-server php libapache2-mod-php php-mysql python3 python3-pip expect -y

# Install PHPMyAdmin
echo "Installing PHPMyAdmin..."
sudo apt install phpmyadmin -y

# Link PHPMyAdmin to the Apache web directory
echo "Linking PHPMyAdmin to the web directory..."
sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# Install Samba for network file sharing
echo "Installing Samba..."
sudo apt install samba samba-common-bin -y

# Create a new Samba user
echo "Creating a Samba user..."
sudo smbpasswd -a pi  # Replace 'pi' with the desired username
echo "Please enter a password for the new Samba user."

# Configure Samba to share the /var/www/html directory securely
echo "Configuring Samba..."
sudo tee -a /etc/samba/smb.conf > /dev/null <<EOL

[web]
path = /var/www/html
browseable = yes
writeable = yes
only guest = no
create mask = 0755
directory mask = 0755
public = no
valid users = pi  # Replace 'pi' with the username you created
EOL

# Restart Samba to apply changes
echo "Restarting Samba..."
sudo systemctl restart smbd

# Install Webmin
echo "Installing Webmin..."
wget http://www.webmin.com/jcameron-key.asc
sudo apt-key add jcameron-key.asc
echo "deb http://download.webmin.com/download/repository sarge contrib" | sudo tee /etc/apt/sources.list.d/webmin.list
sudo apt update
sudo apt install webmin -y

# Secure MySQL Installation
echo "Securing MySQL installation..."
SECURE_MYSQL=$(expect -c "

set timeout 10
spawn sudo mysql_secure_installation

expect \"Enter current password for root (enter for none):\"
send \"\r\"

expect \"Set root password?\"
send \"y\r\"

expect \"New password:\"
send \"your_secure_password\r\"

expect \"Re-enter new password:\"
send \"your_secure_password\r\"

expect \"Remove anonymous users?\"
send \"y\r\"

expect \"Disallow root login remotely?\"
send \"y\r\"

expect \"Remove test database and access to it?\"
send \"y\r\"

expect \"Reload privilege tables now?\"
send \"y\r\"

expect eof
")

echo "$SECURE_MYSQL"

# Install Shell In A Box
echo "Installing Shell In A Box..."
sudo apt install shellinabox -y

# Change Shell In A Box to use port 4200 and allow any IP to connect
echo "Configuring Shell In A Box..."
sudo sed -i 's/--localhost-only/--no-beep/' /etc/default/shellinabox
sudo sed -i 's/4200/-p 4200/' /etc/default/shellinabox

# Restart Shell In A Box to apply changes
echo "Restarting Shell In A Box..."
sudo systemctl restart shellinabox

# Install Python virtualenv and Django dependencies
echo "Installing Python virtualenv and Django..."
sudo pip3 install virtualenv

# Set up Django project directory and virtual environment
echo "Setting up Django project..."
cd /var/www/html
virtualenv django_env
source django_env/bin/activate

# Install Django within the virtual environment
pip install django

# Create a new Django project
django-admin startproject myproject

# Install mod_wsgi for serving Django with Apache
echo "Installing mod_wsgi..."
sudo apt install libapache2-mod-wsgi-py3 -y

# Configure Apache for the Django project
echo "Configuring Apache for Django..."
sudo tee /etc/apache2/sites-available/django_project.conf > /dev/null <<EOL
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/myproject

    Alias /static /var/www/html/myproject/static
    <Directory /var/www/html/myproject/static>
        Require all granted
    </Directory>

    <Directory /var/www/html/myproject/myproject>
        <Files wsgi.py>
            Require all granted
        </Files>
    </Directory>

    WSGIDaemonProcess myproject python-path=/var/www/html/myproject python-home=/var/www/html/django_env
    WSGIProcessGroup myproject
    WSGIScriptAlias / /var/www/html/myproject/myproject/wsgi.py
</VirtualHost>
EOL

# Enable the new Apache site
sudo a2ensite django_project.conf

# Create a self-signed SSL certificate
echo "Creating a self-signed SSL certificate..."
sudo mkdir -p /etc/ssl/private
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/myserver.key -out /etc/ssl/certs/myserver.crt -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=localhost"

# Enable SSL module in Apache
echo "Enabling SSL module in Apache..."
sudo a2enmod ssl

# Create a new Apache configuration for HTTPS
echo "Configuring Apache for HTTPS..."
sudo tee /etc/apache2/sites-available/django_project_ssl.conf > /dev/null <<EOL
<VirtualHost *:443>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/myproject

    Alias /static /var/www/html/myproject/static
    <Directory /var/www/html/myproject/static>
        Require all granted
    </Directory>

    <Directory /var/www/html/myproject/myproject>
        <Files wsgi.py>
            Require all granted
        </Files>
    </Directory>

    WSGIDaemonProcess myproject python-path=/var/www/html/myproject python-home=/var/www/html/django_env
    WSGIProcessGroup myproject
    WSGIScriptAlias / /var/www/html/myproject/myproject/wsgi.py

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/myserver.crt
    SSLCertificateKeyFile /etc/ssl/private/myserver.key

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL

# Enable the new SSL site
sudo a2ensite django_project_ssl.conf

# Restart Apache to apply changes
echo "Restarting Apache..."
sudo systemctl restart apache2

# Collect static files for Django
echo "Collecting static files for Django..."
cd /var/www/html/myproject
python manage.py collectstatic --noinput

# Ensure all services are enabled to start on boot
echo "Enabling services to start on boot..."
sudo systemctl enable apache2
sudo systemctl enable mariadb
sudo systemctl enable smbd
sudo systemctl enable webmin
sudo systemctl enable shellinabox

# Provide information on how to access the services
ip_address=$(hostname -I | awk '{print $1}')
echo "Setup complete!"
echo "You can now access your server at: http://$ip_address/"
echo "Access your server securely at: https://$ip_address/"
echo "Access PHPMyAdmin at: http://$ip_address/phpmyadmin"
echo "Access Webmin at: https://$ip_address:10000/"
echo "Access Shell In A Box at: https://$ip_address:4200/"
echo "The web folder can be accessed on the network at: \\\\$ip_address\\web"

echo "MySQL installation has been secured."
echo "Django project setup is complete."
echo "Self-signed SSL certificate has been created and configured for HTTPS."

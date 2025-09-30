# Linux Server Setup & MERN App Deployment
These are the steps to setup an Ubuntu server from scratch and deploy a MERN app with the PM2 process manager and Nginx. We are using Linode, but you could just as well use a different cloud provider or your own machine or VM.

Create an account at [Linode](https://linode.com/traversy)

Click on **Create Linode**

Choose your server options (OS, region, etc)

### SSH Keys
You will see on the setup page an area to **add an SSH key**. 

There are a few ways that you can log into your server. You can use passwords, however, if you want to be more secure, I would suggest setting up SSH keys and then disabling passwords. That way you can only log in to your server from a PC that has the correct keys setup.

I am going to show you how to setup authentication with SSH, but if you want to just use a password, you can skip most of this stuff.

You need to generate an SSH key on your local machine to login to your server remotely. Open your terminal and type

```bash
ssh-keygen
```

By default, it will create your public and private key files in the **.ssh** directory on your local machine and name them **id_rsa** and **id_rsa.pub**. You can change this if you want, just make sure when it asks, you put the entire path to the key as well as the filename. I am using **id_rsa_linode**

Once you do that, you need to copy the public key. You can use the `cat` command and then copy the key

```bash
cat ~/.ssh/id_rsa_linode.pub
```
Copy the key. It will look something like this:
```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDEwMkP0KHX19q2dM/9pB9dpB2B/FwdeP4egXCgdEOraJuqGvaylKgbu7XDFinP6ByqJQg/w8vRV0CsFXrnr+Lh51fKv8ZPvV/yRIMjxKzNn/0+asatkjrkOwT3f3ipbzfS0bsqfWTHivZ7UNMrOHaaSezxvJpPGbW3aoTCFSA/sUUUSiWZ65v7I/tFkXE0XH+kSDFbLUDDNS1EzofWZFRcdSFbC3zrGsQHN3jcit6ba7bACQYixxFCgVB0mZO9SOgFHC64PEnZh5hJ8h8AqIjf5hDF9qFdz2jFEe/4aQmKQAD3xAPKTXDLLngV/2yFF0iWpnJ9MZ/mJoLVzhY2pfkKgnt/SUe/Hn1+jhX4wrz7wTDV4xAe35pmnajFjDppJApty+JOzKf3ifr4lNeZ5A99t9Pu0294BhYxm7/mKXiWPsevX9oSZxSJmQUtqWWz/KBVoVjlTRgAgLYbKCNBzmw7+qdRxoxxscQCQrCpJMlat56vxK8cjqiESvduUu78HHE= trave@ASUS
```
Now paste that into the Linode.com textarea and name it (eg.My PC)

At some point, you will be asked to enter a root password for your server as well.

### Connecting as Root
Finish the setup and then you will be taken to your dashboard. The status will probably say **Provisioning**. Wait until it says **Running** and then open your local machine's terminal and connect as root. Of course you want to use your own server's IP address

```bash
ssh root@69.164.222.31
```
At this point, passwords are enabled, so you will be asked for your root password.

If you authenticate and login, you should see a welcome message and your prompt should now say root@localhost:~#. This is your remote server

I usually suggest updating and upgrading your packages

```
sudo apt update
sudo apt upgrade
```
### Create a new user
Right now you are logged in as root and it is a good idea to create a new account. Using the root account can be a security risk.

You can check your current user with the command:

```bash
whoami
```

It will say **root** right noe.

Let's add a new user. I am going to call my user **brad**
```bash
adduser brad
```
Just hit enter through all the questions. You will be asked for a use password as well.

You can use the following command to see the user info including the groups it belongs to
```bash
id brad
```
Now, let's add this user to the "sudo" group, which will give them root privileges.
```bash
usermod -aG sudo brad
```

Now if you run the following command, you should see **sudo**
```bash
id brad
```

### Add SSH keys for new account
If you are using SSH, you will want to setup SSH keys for the new account. We do this by adding it to a file called **authorized_keys** in the users directory.

Go to the new users home directory
```bash
cd /home/brad
```
Create a **.ssh** directory and go into it
```bash
mkdir .ssh
cd .ssh
```

Create a new file called **authorized_keys**
```bash
touch authorized_keys
```
Now you want to put your public key in that file. You can open it with a simpl text editor called **nano**

```bash
sudo nano authorized_keys
```
Now you can paste your key in here. Just repeat the step above where we ran **cat** and then the location of your public key.
**IMPORTANT**: Make sure you open a new terminal for this that is not logged into your server.

Now paste the key in the file and hi `ctrl` or `cmd+X` then hit `Y` to save and hit `enter` again

### Disabling passwords
This is an extra security step. Like I said earlier, we can disable passwords so that only your local machine with the correct SSH keys can login.

Open the following file on your server
```bash
sudo nano /etc/ssh/sshd_config
```

Look for where it says
```
PasswordAuthentication Yes
```
Remove the # if there is one and change the Yes to No

If you want to disable root login all together you could change **permitRootLogin** to no as well. Be sure to remove the # sign becayse that comments the line out.

Save the file by exiting (ctrl+x) and hit Y to save.

Now you need to reset the sshd service
```bash
sudo systemctl restart sshd
```

Now you can logout by just typing `logout`

Try logging back in with your user (Use your username and server's IP)
```bash
ssh brad@69.164.222.31
```

If you get a message that says "Publick key denied" or something like that, run the following commands:
```bash
eval `ssh-agent -s`
ssh-add ~/.ssh/id_rsa_linode     # replace this with whatever you called your key file
```
try logging in again and you should see the welcome message and not have to type in any password.

### Node.js setup
Now that we have provisioned our server and we have a user setup with SSH keys, it's time to start setting up our app environment. Let's start by installing Node.js

We can install Node.js with curl using the following commands

```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Check to see if node was installed
node --version
npm --version
```

### Get files on the server
We want to get our application files onto the server. We will use **Git** for this. I am using the goal setter app from my MERN stack series on [YouTube](https://www.youtube.com/watch?v=-0exw-9YJBo)

On your SERVER, go to where you want the app to live and clone the repo you want to deply from GitHub (or where ever else)

Here is the repo I will be using. Feel free to deploy the same app:
https://github.com/bradtraversy/mern-tutorial

```bash
mkdir sites
cd sites
git clone https://github.com/bradtraversy/mern-tutorial.git
```

Now I should have a folder called **mern-tutorial** with all of my files and folders.

### App setup
There are a few things that we need to do including setting up the .ENV file, installing dependencies and building our static assets for React.

#### .env file
With this particular application, I create a .envexample file because I did not want to push the actual .env file to GitHub. So you need to first rename that .envexample:
```bash
mv .envexample .env

# To check
ls -a
```

Now we need to edit that file
```bash
sudo nano .env
```

Change the NODE_ENV to "production" and change the MONGO_URI to your own. You can create a mongodb Atlas database [here](https://mongodb.com)

Exit with saving.

#### Dependencies & Build
We need to install the server dependencies. This should be run from the root of the mern-tutorial folder. NOT the backend folder.
```bash
npm install
```

Install frontend deps:
```
cd frontend
npm install
```

We need to build our static assets as well. Do this from the `frontend` folder
```bash
npm run build
```

### Run the app
Now we should be able to run the app like we do on our local machine. Go into the root and run
```bash
npm start
```

If you go to your ip and port 5000, you should see your app. In my case, I would go to
```
http://69.164.222.31:5000
```

Even though we see our app running, we are not done. We don't want to leave a terminal open with npm start. We also don't want to have to go to port 5000. So let's fix that.

Stop the app from running with `ctrl+C`

### PM2 Setup

PM2 is a production process manager fro Node.js. It allows us to keep Node apps running without having to have terminal open with npm start, etc like we do for development.

Let's first install PM2 globally with NPM
```bash
sudo npm install -g pm2
```
Run with PM2
```bash
pm2 start backend/server.js   # or whatever your entry file is
```
Now if you go back to your server IP and port 5000, you will see it running. You could even close your terminal and it will still be running

There are other pm2 commands for various tasks as well that are pretty self explanatory:

- pm2 show app
- pm2 status
- pm2 restart app
- pm2 stop app
- pm2 logs (Show log stream)
- pm2 flush (Clear logs)

### Firewall Setup
Obviously we don't want users to have to enter a port of 5000 or anything else. We are going to solve that by using a server called NGINX. Before we set that up, lets setup a firewall so that people can not directly access any port except ports for ssh, http and https

The firewall we are using is called UFW. Let's enable it.

```bash
  sudo ufw enable
```

You will notice now if you go to the site using :5000, it will not work. That is because we setup a firewall to block all ports.

You can check the status of the firewall with 
```bash
sudo ufw status
```

Now let's open the ports that we need which are 22, 80 and 443
```bash
sudo ufw allow ssh (Port 22)
sudo ufw allow http (Port 80)
sudo ufw allow https (Port 443)
```

### Setup NGINX
Now we need to install NGINX to serve our app on port 80, which is the http port

```bash
sudo apt install nginx
```
If you visit your IP address with no port number, you will see a **Welcome to nginx!** page.

Now we need to configure a proxy for our MERN app.

Open the following config file
```bash
sudo nano /etc/nginx/sites-available/default
```

Find the **location /** area and replace with this
```
location / {
        proxy_pass http://localhost:5000;    # or which other port your app runs on
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
```

Above that, you can also put the domain that you plan on using:
```
server_name yourdomain.com www.yourdomain.com;
```
Save and close the file

You can check your nginx configuration with the following command
```bash
sudo nginx -t
```

Now restart the NGINX service:
```bash
sudo service nginx restart
```

Now you should see your app when you go to your IP address in the browser.

### Domain Name
You probably don't want to use your IP address to access your app in the browser. So let's go over setting your domain with a Linode.

You need to register your domain. It doesn't matter who you use for a registrar. I use **Namecheap**, but you could use Godaddy, Google Domains or anyone else.

You need to change the nameservers with your Domain registrar. The process can vary depending on who you use. With Namecheap, the option is right on the details page.

You want to add the following nameservers:

- ns1.linode.com
- ns2.linode.com
- ns3.linode.com
- ns4.linode.com
- ns5.linode.com

Technically this could take up to 48 hours, but it almost never takes that long. In my own experience, it is usually 30 - 90 minutes.

#### Set your domain in Linode

Go to your dashboard and select **Domains** and then **Create Domain**

Add in your domain name and link to the Linode with your app, then submit the form.

Now you will see some info like **SOA Record**, **NS Record**, **MX Record**, etc. There are A records already added that link to your IP address, so you don't have to worry about that. If you wanted to add a subdomain, you could create an A record here for that.

Like I said, it may take a few hours, but you should be all set. You have now deployed your application.

if you want to make changes to your app, just push to github and run a **git pull** on your server. There are other tools to help automate your deployments, but I will go over that another time.

### Set Up SSL

You can purchase an SSL and set it with your domain registrar or you can use Let's Encrypt and set one up for free using the following commands:

```bash
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install python-certbot-nginx
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Only valid for 90 days, test the renewal process with
certbot renew --dry-run
```



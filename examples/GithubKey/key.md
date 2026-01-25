ssh-keygen -t ed25519 -C "your_email@example.com"   

ssh-copy-id username@server_ip   

ssh username@server_ip   

To enable passwordless SSH on Linux, follow these steps:

Generate an SSH key pair
On your local machine, run:

ssh-keygen -t ed25519 -C "your_email@example.com"

Press Enter to accept defaults. Leave the passphrase empty for fully passwordless access. 

Copy the public key to the remote server
Use ssh-copy-id to automate the process:

ssh-copy-id username@server_ip

You’ll be prompted for the user’s password once. This copies your public key to the server’s ~/.ssh/authorized_keys file. 

Test passwordless login
Now connect without a password:

ssh username@server_ip

If successful, you’re logged in instantly. 

Disable password authentication (recommended for security)
On the server, edit /etc/ssh/sshd_config:

sudo nano /etc/ssh/sshd_config

Set these lines:

PasswordAuthentication no
PubkeyAuthentication yes
UsePAM no

Save and restart SSH:

sudo systemctl restart ssh

⚠️ Important: Ensure you can still log in via SSH key before disabling passwords to avoid locking yourself out. 

Ensure the remote server's SSH service is configured to allow public key authentication. Check:

Permissions on the server:
~/.ssh directory must be 700
~/.ssh/authorized_keys must be 600
Run:
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

SSH config on server (/etc/ssh/sshd_config):
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
SELinux/AppArmor (if enabled) may block access. Temporarily disable to test.
Verify key was copied correctly:
Manually append your public key:
cat ~/.ssh/id_ed25519.pub | ssh user@server "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

Test with verbose output:
ssh -v user@server

This shows where the authentication fails.

To disable remote SSH login for a specific user (USERNAME_HERE), edit the SSH daemon configuration:

Edit the SSH config file
sudo nano /etc/ssh/sshd_config

Add the user to DenyUsers
Add this line at the end of the file:
DenyUsers USERNAME_HERE

Restart the SSH service
sudo systemctl restart ssh

After this, the specified user will be unable to log in via SSH. 

Disable SSH Root Access
The same way described above can be used to disable login to a root user. However to disable complete root access, i.e., to disable access to all root users, follow the steps given below.

Open the file ‘/etc/ssh/sshd_config’ in any text editor and search for the string ‘PermitRootLogin’. Uncomment the line and if it has any other value, set the value to ‘no’.

PermitRootLogin  no
Disable SSH Root Login
Disable SSH Root Login
Save and exit the file. Restart SSH with:

$ sudo systemctl restart sshd

To resolve the error USERNAME_HERE is not in the sudoers file, you need to grant sudo privileges to the user. Here are the standard methods:

Add User to the Sudo Group (Recommended)
If you have access to a user with sudo or root privileges, run:

sudo usermod -aG sudo USERNAME_HERE

On CentOS/RHEL systems, use the wheel group instead:

sudo usermod -aG wheel USERNAME_HERE

Add User Directly to the Sudoers File
Edit the sudoers configuration safely using visudo:

sudo visudo

Add this line at the end:

USERNAME_HERE ALL=(ALL:ALL) ALL

Save and exit.


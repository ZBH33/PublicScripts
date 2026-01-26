
cat ~/.ssh/Workstation@windows.pub | ssh user@server "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
# NEED TO RUN TWICE ONCE FOR ROOT USER AND ONE FOR NEW USER


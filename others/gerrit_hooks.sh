#!/bin/bash

name="gerrit"

export PATH=$PATH:/srv/cloudlabs/scripts

echo $(hostname) > /tmp/hname

# Getting the doc and styles
wget -q -N --timeout=2 https://raw.githubusercontent.com/terminalcloud/apps/master/docs/"$name".md
wget -q -N --timeout=2 https://raw.githubusercontent.com/terminalcloud/apps/master/docs/termlib.css && mv termlib.css /root/

# Making the file...
cat > /root/info.html << EOF
<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" type="text/css" href="termlib.css" />
<p id="exlink"><a id="exlink" target="_blank" href="https://$(hostname)-8081.terminal.com"><b>Go to your Gerrit installation here!</b></a></p>
</head>
<body>
EOF

# Converting markdown file
markdown "$name.md" >> /root/info.html

# Closing file
cat >> /root/info.html << EOF
</body>
</html>
EOF

# Convert links to external links
sed -i 's/a\ href/a\ target\=\"\_blank\"\ href/g' /root/info.html 

# Update server URL in keys [user may regenerate them]
sed -i "s/terminalservername/$(hostname)/g" /home/gerrit5/gerrit/etc/ssh_host_dsa_key.pub
sed -i "s/terminalservername/$(hostname)/g" /home/gerrit5/gerrit/etc/ssh_host_rsa_key.pub

# Showing up
cat | /srv/cloudlabs/scripts/run_in_term.js	 << EOF
sed -i "s/terminalservername/$(hostname)/g" /home/gerrit5/gerrit/etc/gerrit.config
/etc/init.d/gerrit restart
/srv/cloudlabs/scripts/display.sh /root/info.html
EOF
# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    apples.sh                                          :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: gfielder <marvin@42.fr>                    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2019/05/09 22:34:33 by gfielder          #+#    #+#              #
#    Updated: 2019/05/10 01:43:50 by gfielder         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

YEL="\x1B[1;33m"
GRN="\x1B[32m"
RED="\x1B[1;31m"
RST="\x1B[0m"

APPLES_ROOT=$(pwd)

if [ $# -ne 1 ]
then
	echo "usage: sh $0 <host_port>"
fi
HOST_PORT="$1"

# make sure the port number is valid
if [ -n "$HOST_PORT" ] && [ "$HOST_PORT" -eq "$HOST_PORT" ] ; then # is numeric
	if [ $HOST_PORT -gt 1024 ] ; then # valid port number
		echo $GRN"HOST_PORT will be $HOST_PORT"$RST
	else
		echo $RED"$HOST_PORT: host_port must be greater than 1024"$RST
		exit -1
	fi
else
	echo $RED"$HOST_PORT: host_port must be numeric"$RST
	exit -1
fi

# Shut down the VM if it is running
(VBoxManage controlvm gitserver-vm poweroff 2>/dev/null && echo $YEL"VM Shutting down..."$RST && sleep 3) || (echo "" > /dev/null)

# Add the port forwarding rule
echo $YEL"Configuring port forwarding..."$RST
VBoxManage modifyvm "gitserver-vm" --natpf1 "gitserver-ssh-$HOST_PORT,tcp,,$HOST_PORT,,22"

echo $YEL"VM Starting up..."$RST
VBoxManage startvm gitserver-vm
echo $YEL"Waiting for VM bootup process..."$RST
sleep 20

# Make a new RSA SSH keypair in the current directory
rm -f id_rsa
rm -f id_rsa.pub
ssh-keygen -f id_rsa -P "" -q
# Copy the new id to gitserver
echo ""
echo $YEL"Enter the password provided by your system administrator. For first time setup, the default password is:"$RST
echo $GRN"    \`git\`"$RST
echo $YEL"This is the only time we'll need to use a password"$RST
echo ""
ssh-copy-id -f -p $HOST_PORT -i id_rsa git@localhost

echo $YEL"Installing gitserver interface..."$RST
# Check if we already installed a server using this script previously
# If not, add to the SSH configuration so that git will recognize gitserver
PREV_SETTINGS=$(grep -c "HERCULES-APPLES-$HOST_PORT" ~/.ssh/config)
if [[ $PREV_SETTINGS -eq 0 ]]
then
	echo "" >> ~/.ssh/config
	echo "# [HERCULES-APPLES-$HOST_PORT]" >> ~/.ssh/config
	echo "# Added by Hercules, the Apples of Hesperides script apples.sh" >> ~/.ssh/config
	echo "Host gitserver" >> ~/.ssh/config
	echo "\tHostname localhost" >> ~/.ssh/config
	echo "\tUser git" >> ~/.ssh/config
	echo "\tIdentityFile $APPLES_ROOT/id_rsa" >> ~/.ssh/config
	echo "\tPort $HOST_PORT" >> ~/.ssh/config
	echo "# End Hercules" >> ~/.ssh/config
fi

# Adds a new function to the parent shell, `gitserver`
source gitserver-commands.sh
export -f gitserver

echo ""
echo $YEL"gitserver is running! Directions:"$RST
echo "To create a new remote respository, run:"
echo $GRN"    gitserver new  repo_name"$RST
echo "to see a list of remote repos, run:"
echo $GRN"    gitserver ls"$RST
echo "to clone a gitserver repo, run:"
echo $GRN"    git clone gitserver:/repos/repo-name  [local-path]"$RST
echo "For remote administration, run:"
echo $GRN"    ssh gitserver"$RST

echo ""
echo $YEL"Would you like to open a repo for this project on the VM? y/n"$RST
read RESPONSE
if [ "$RESPONSE" = "y" ]
then
	echo $YEL"Ok, but we'll do it the hard way because vogssphere and gitserver aren't talking to each other right now."$RST
	mv .git tmp
	echo "tmp/" >> .gitignore
	echo "id_rsa*" >> .gitignore
	ssh gitserver rm -rf /repos/apples
	gitserver new apples
	git init .
	git remote add origin gitserver:/repos/apples
	git add .
	git commit -m "initial commit"
	git push --set-upstream origin master
	rm -rf .git
	mv tmp .git
	echo $YEL"Repo cloned. You may clone the duplicate using git clone gitserver:/repos/apples"$RST
fi
RESPONSE="n"


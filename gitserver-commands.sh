# [HERCULES-APPLES]
# Added by Hercules, the Apples of Hesperides script apples.sh
function gitserver()
{
	if [ $# -lt 1 ] ; then
		echo "usage: gitserver new repo-name"
		echo "       gitserver ls"
		exit -1
	fi
	if [ "$1" = "new" ] ; then
		if [ $# -ne 2 ] ; then
			echo "usage: gitserver new repo-name"
			exit -1
		fi
		ssh gitserver "mkdir /repos/$2 && git init --bare /repos/$2" && \
		echo "Remote repository created. Clone this repo using:\n" \
		"    git clone gitserver:/repos/$2 [local directory]"
	elif [ "$1" = "ls" ] ; then
		ssh gitserver ls -1 /repos
	else
		echo "gitserver: $1: command not recognized"
	fi
}
# End Hercules

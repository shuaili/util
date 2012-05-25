TAG_USER=`whoami`
let N_HOSTS=0

while getopts ":u:n:h" optname; do
    case "$optname" in
        "u")
        	TAG_USER=$OPTARG
        	;;
      	"n")
        	TAG_HOST[$N_HOSTS]=$OPTARG
        	let N_HOSTS=N_HOSTS+1
        	;;
      	"h")
        	echo "./ssh_authen.sh -u user -n hostname" 
        	exit
        	;;
      	"?")
        	echo "Unknown option $OPTARG"
        	exit 1
        	;;
      	":")
        	echo "No argument value for option $OPTARG"
        	exit 1
        	;;
      	*)
        	echo "Unknown error while processing options"
        	exit
       	 	;;
	esac
done

pushd ~
mkdir -p .ssh
chmod 700 .ssh
if (!(test -f ".ssh/id_rsa") || !(test -f ".ssh/id_rsa.pub")); then
   	ssh-keygen -f id_rsa -t rsa -N ""
   	cp -fr id_rsa.pub ~/.ssh/
   	cp -fr id_rsa ~/.ssh/
fi
TAG_GROUP=`groups $TAG_USER|awk '{print $3}'`
chown $TAG_USER:$TAG_GROUP ~/.ssh/id_rsa.pub
chown $TAG_USER:$TAG_GROUP ~/.ssh/id_rsa
touch .ssh/authorized_keys
chmod -R 600 .ssh/*
popd

let j=0
while [ $j -lt $N_HOSTS ]; do
	echo "processding ${TAG_HOST[$j]}..."
	KEY=`cat ~/.ssh/id_rsa.pub`
	DIR_EXIST=`ssh $TAG_USER@${TAG_HOST[$j]} "mkdir -p ~/.ssh; chmod 700 ~/.ssh; touch ~/.ssh/authorized_keys; chmod -R 600 ~/.ssh/*; grep \"$KEY\" ~/.ssh/authorized_keys > /dev/null 2>&1; echo \\\$?"`

	if [ "$DIR_EXIST" != "0" ]; then
  		ssh $TAG_USER@${TAG_HOST[$j]} "mkdir -p ~/.ssh && echo \"$KEY\" >> ~/.ssh/authorized_keys"
	fi
	let j=j+1
done
echo "well done."



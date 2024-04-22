# python3 -m pip install --user ansible

DIR=$(pwd)

cd $DIR/ansible

if [ -z "$1" ]; then
    echo "Usage: ./ansible.sh <playbook>"
else
    ANSIBLE_CONFIG=$(pwd)/ansible.cfg ansible-playbook play/$1.yml --ask-vault-pass
fi
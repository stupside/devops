# python3 -m pip install --user ansible

DIR=$(pwd)

cd $DIR/ansible

ANSIBLE_CONFIG=$(pwd)/ansible.cfg ansible-playbook play/$1.yml
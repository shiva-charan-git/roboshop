source common.sh

roboshop_app_password=$1

if [ -z "${1}" ]; then
  echo -e "\e[31mMissing Roboshop App User passowrd argument\e[om"
  exit 1
fi

component=payment
python


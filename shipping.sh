source common.sh

mysql_root_password=$1

if [ -z "${mysql_root_password}" ]; then
   echo -e "\e[31mMissing MySql Root passowrd argument\e[om"
  exit 1
fi


component=shipping
Scheme_Type="mysql"
java
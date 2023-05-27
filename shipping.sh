source common.sh

mysql_root_password=$1

if [ "${mysql_root_password}" == "mysql" ]; then
   echo -e "\e[31mMissing MySql Root passowrd argument\e[om"
  exit 1
fi

component=shipping
scheme_type="mysql"
java
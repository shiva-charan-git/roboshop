source common.sh

mysql_root_password=$1

if [ -z "${1}" ]; then
  echo -e "\e[31mMissing MySql Root passowrd argument\e[om"
  exit 1
fi

print_head "disabling mysql 8 version"
yum module disable mysql -y  &>>${log_file}
status_check $?


print_head "installing MySQL server"
yum install mysql-community-server -y &>>${log_file}
status_check $?

print_head "enabling MySQL service"
systemctl enable mysqld &>>${log_file}
status_check $?

print_head "start MySQL service"
systemctl start mysqld   &>>${log_file}
status_check $?

print_head "Set Password"
mysql_secure_installation --set-root-pass ${mysql_root_password} &>>${log_file}
status_check $?
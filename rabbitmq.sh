source common.sh

roboshop_app_password=$1

if [ -z "${1}" ]; then
  echo -e "\e[31mMissing Roboshop App User passowrd argument\e[om"
  exit 1
fi

print_head "setup Erlang repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>${log_file}
status_check $?

print_head "Setup RabbitMQ Repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>${log_file}
status_check $?

print_head "Install Erlang & RabbitMQ"
yum install rabbitmq-server rlang -y  &>>${log_file}
status_check $?

print_head "Enable RabbitMQ Service"
systemctl enable rabbitmq-server  &>>${log_file}
status_check $?

print_head "Start RabbitMQ Service"
systemctl start rabbitmq-server  &>>${log_file}
status_check $?

print_head "Add Application User"
rabbitmqctl list_users | grep roboshop &>>${log_file}
if [ $? -ne 0 ]; then
 rabbitmqctl add_user roboshop ${roboshop_app_password} &>>${log_file}
fi
status_check $?

## roboshop123 password --------

print_head "Configuration Permission for App User"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>>${log_file}
status_check $?
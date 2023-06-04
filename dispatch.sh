source common.sh


print_head "installing go lang"
yum install golang -y &>>${log_file}
status_check $?


print_head "user add roboshop"
useradd roboshop &>>${log_file}
status_check $?


print_head "createing app directry"
mkdir /app &>>${log_file}
status_check $?


print_head "downloading the software to node"
curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch.zip  &>>${log_file}
status_check $?


print_head "unzip the zip file"
cd /app &>>${log_file}
unzip /tmp/dispatch.zip &>>${log_file}
status_check $?


print_head "mod iinit disptach"
cd /app &>>${log_file}
go mod init dispatch &>>${log_file}
status_check $?


b
print_head "get && Build"
go get &>>${log_file}
go build &>>${log_file}
status_check $?



print_head "Copyingg configuration file"
cp ${code_dir}configs/dispatch.service /etc/systemd/system/dispatch.service &>>${log_file}
status_check $?


print_head "enabling dispatch service"
systemctl enable dispatch  &>>${log_file}
status_check $?


print_head "starting dispatch service"
systemctl start dispatch &>>${log_file}
status_check $?


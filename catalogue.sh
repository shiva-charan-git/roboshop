source common.sh

print_head "configure  nodejs repo"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log_file}
status_check $?

print_head "nodejs installation"
yum install nodejs -y  &>>${log_file}
status_check $?

print_head "create user roboshop"
id roboshop  &>>${log_file}
if [ $? -ne 0 ]; then
  useradd roboshop  &>>${log_file}
fi
status_check $?

print_head "Create Appliaction Dir"
if [ ! -d /app ]; then
  mkdir /app  &>>${log_file}
fi
status_check $?

print_head "Delete old content"
rm -rf /app/*  &>>${log_file}
status_check $?
 
print_head "download app content"
curl  -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip  &>>${log_file}
cd /app   
status_check $?

print_head "Extracting app content"
unzip /tmp/catalogue.zip  &>>${log_file}
status_check $?

print_head "Installing Nodejs Dependency"
npm install   &>>${log_file}
status_check $?


print_head "Copying system File"
cp ${code_dir}/configs/catalogue.service  /etc/systemd/system/catalogue.service  &>>${log_file}
status_check $?

print_head "reload systemd"
systemctl daemon-reloadb  &>>${log_file}
status_check $?

print_head "ebnabling catalogue service"
systemctl enable catalogue &>>${log_file}
status_check $?

print_head "starting catalogue service"
systemctl restart catalogue  &>>${log_file}
status_check $?

print_head "Copy mongodb repo file"
cp ${code_dir}/configs/mongodb.repo /etc/yum.repos.d/mongo.repo  &>>${log_file}
status_check $?

print_head "install mongo clinet"
yum install mongodb-org-shell -y  &>>${log_file}
status_check $?

print_head "load schema"
mongo --host mongodb-dev.devsig90.online </app/schema/catalogue.js  &>>${log_file}
status_check $?

source common.sh

print_head "configure  nodejs repo"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log_file}

print_head "nodejs installation"
yum install nodejs -y  &>>${log_file}


print_head "create user roboshop"
useradd roboshop  &>>${log_file}

print_head "Create Appliaction Dir"
mkdir /app  &>>${log_file}


print_head "Delete old content"
rm -rf /app/*  &>>${log_file}
 
print_head "download app content"
curl  -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip  &>>${log_file}
cd /app   

print_head "Extracting app content"
unzip /tmp/catalogue.zip  &>>${log_file}

print_head "Installing Nodejs Dependency"
npm install   &>>${log_file}


print_head "Copying system File"
cp ${code_dir}/configs/catalogue.service  /etc/systemd/system/catalogue.service  &>>${log_file}

print_head "reload systemd"
systemctl daemon-reloadb  &>>${log_file}

print_head "ebnabling catalogue service"
systemctl enable catalogue &>>${log_file}

print_head "starting catalogue service"
systemctl restart catalogue  &>>${log_file}

print_head "Copy mongodb repo file"
cp ${code_dir}/configs/mongodb.repo /etc/yum.repos.d/mongo.repo  &>>${log_file}

print_head "install mongo clinet"
yum install mongodb-org-shell -y  &>>${log_file}

print_head "load schema"
mongo --host mongodb-dev.devsig90.online </app/schema/catalogue.js  &>>${log_file}
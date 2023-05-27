code_dir=$(pwd)
log_file=/tmp/roboshop.log
rm -f ${log_file}

print_head() {
    echo -e "\e[36m$1\e[0m"
}

status_check() {
if [ $1 -eq 0 ]; then
  echo SUCCESS
else
  echo FAILURE
  echo "Read the log file ${log_file} for more information aboutb the error"
  exit 1
fi
}

systemd_setup() {

 print_head "Copying system File"
 cp ${code_dir}/configs/${component}.service  /etc/systemd/system/${component}.service  &>>${log_file}
 status_check $?

 print_head "reload systemd"
 systemctl daemon-reload  &>>${log_file}
 status_check $?

 print_head "ebnabling ${component} service"
 systemctl enable ${component} &>>${log_file}
 status_check $?

 print_head "starting ${component} service"
 systemctl restart ${component}  &>>${log_file}
 status_check $?
}

schema_setup() {
  if [ "${schema_type}" == "mongo" ]; then
    print_head "Copy mongodb repo file"
    cp ${code_dir}/configs/mongodb.repo /etc/yum.repos.d/mongo.repo  &>>${log_file}
    status_check $?

    print_head "install mongo clinet"
    yum install mongodb-org-shell -y  &>>${log_file}
    status_check $?

    print_head "load schema"
    mongo --host mongodb-dev.devsig90.online </app/schema/${component}.js  &>>${log_file}
    status_check $?
  elif [ "${schema_type}" == "mysql" ]; then
    print_head "install MySQL Client"
    yum install mysql -y b
    status_check $?

    print_head "load schema"
    mysql -h mysql-dev.devsig90.online -uroot -p${mysql_root_password} < /app/schema/shipping.sql 
    status_check $?
}

app_prereq_setup() {

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
curl  -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip  &>>${log_file}
cd /app   
status_check $?

print_head "Extracting app content"
unzip /tmp/${component}.zip  &>>${log_file}
status_check $?

}

nodejs() {
  print_head "configure  nodejs repo"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log_file}
status_check $?

print_head "nodejs installation"
yum install nodejs -y  &>>${log_file}
status_check $?

app_prereq_setup

print_head "Installing Nodejs Dependency"
npm install   &>>${log_file}
status_check $?

schema_setup

systemd_setup


}

java() {

  print_head "install maven"
  yum install maven -y  &>>${log_file}
  status_check $?
  
  app_prereq_setup
  
  print_head "download bdependency & packages"
  mvn clean package   &>>${log_file}
  mv target/${component}-1.0.jar ${component}.jar  &>>${log_file}
  status_check $?
  

  # schema setup function
  schema_setup
  
  #b systemd function
  systemd_setup

}
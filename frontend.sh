source common.sh

print_head "installing Nginx"
yum install nginx -y  &>>${log_file}
if [ $? -eq 0 ]; then
  echo SUCCESS
else
  echo FAILURE
fi


print_head "Removing old content"
rm -rf /usr/share/nginx/html/* &>>${log_file}
echo $?

print_head "downloading frontend content"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip  &>>${log_file}
echo $?

print_head "Extracting downloaded content"
cd /usr/share/nginx/html  &>>${log_file}
unzip /tmp/frontend.zip  &>>${log_file}
echo $?

print_head "copying Nginx config for roboshop"
cp ${code_dir}/configs/nginx-roboshop.conf /etc/nginx/default.d/roboshop.conf &>>${log_file}
echo $?

print_head "Enabling nginx"
systemctl enable nginx  &>>${log_file}
echo $?

print_head "Starting Nginx"
systemctl restart nginx   &>>${log_file}
echo $?
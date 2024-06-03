call c:\tools\cmder\vendor\init.bat

cd /d c:\Users\Vagrant

git clone https://github.com/daxgames/cmder cmderdev

cd cmderdev

git remote add upstream  https://github.com/cmderdev/cmder

git pull upstream master

copy C:\Tools\Cmder\Cmder.exe .\

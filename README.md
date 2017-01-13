# CycriptLearn
cd CycriptLearn

#chose one method to connect device
#1 : connect iPhone from ip
ssh root@iPhoneIp
scp -P 2222 -r ./xdc root@iPhoneIp:/usr/lib/cycript0.9/com/

#2 : connect iPhone from usb
itnl --iport 22 --lport 2222
scp -P 2222 -r ./xdc root@localhost:/usr/lib/cycript0.9/com/
ssh -p 2222 root@localhost

# ==> open and use ps command find process you hook
# ps -e | grep /var
cycript -p theProcessYouHook /usr/lib/cycript0.9/com/xdc/gxmain.cy
cycript -p theProcessYouHook

# use the gx_function

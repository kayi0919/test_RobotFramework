@echo off
cd /d C:\docker0814\test_RobotFramework\
python tests\execute.py
robot --outputdir ./ --output email.html --log email.xml --report email.html .\tests\email.robot
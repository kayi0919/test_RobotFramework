import time
from robot import run

#單筆
#run('tests/report_098_MED.robot')

#多筆
files = [
    'tests/report_098_MED.robot',
   'tests/report_100_MED.robot'
]

run(*files)

# 休息3秒
time.sleep(3)
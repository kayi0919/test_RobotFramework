import time
from robot import run

#單筆
#run('tests/report_098_MED.robot')

#多筆
files = [
    'tests/login_and_search.robot',
    'tests/report_simple_MED.robot',
    'tests/report_006_MED.robot',
    'tests/report_010_MED.robot',
    'tests/report_19CVS_MED.robot',
    'tests/report_044_MED.robot',
    'tests/report_061_MED.robot',
    'tests/report_090_MED.robot',
    'tests/report_098_MED.robot',
   'tests/report_100_MED.robot'
]

run(*files)

# 休息3秒
time.sleep(3)
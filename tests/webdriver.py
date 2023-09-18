from selenium import webdriver  #從library中引入webdriver

# 定義全局變數來保存瀏覽器實例
global browser

def open_browser_in_py():
    global browser
    browser = webdriver.Chrome()    #開啟chrome browser
    browser.get("https://localhost:44395/login") # 前往這個網址
    
    
def close_browser_in_py():
    global browser
    browser.close() # 關閉視窗
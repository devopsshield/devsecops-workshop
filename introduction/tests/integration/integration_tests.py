from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from time import sleep
 
def test_login_page_loads():
    options = Options()
    options.add_argument('--headless')
    chrome_driver = webdriver.Chrome(options=options)
    
    chrome_driver.get('http://pygoat.cnepho.com/login')
 
    chrome_driver.find_element_by_xpath("//div[@class='btn btn-primary' and text()='Register']").click()
 
    title = "Pygoat"
    assert title == chrome_driver.title
    
    sleep(2)
    chrome_driver.close()
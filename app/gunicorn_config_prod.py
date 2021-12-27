pythonpath = './'

workers = 1

worker_class = 'uvicorn.workers.UvicornWorker'

bind = '172.16.30.40:8000'

pidfile = 'prod.pid'

raw_env = ['MODE=PROD']

daemon = True

errorlog = './logs/error_log.txt'

proc_name = 'home_kit'

accesslog = './logs/access_log.txt'

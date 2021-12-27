start:
	gunicorn -c gunicorn_config_prod.py main:app

kill:
	curl http://172.16.30.40:8000/this/destroy
	kill `cat prod.pid`

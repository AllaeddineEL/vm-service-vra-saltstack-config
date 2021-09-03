import pprint
import json
from sseapiclient.tornado import SyncClient
file_contents = '''
install_redis:
  pkg.installed:
    - name: redis

start_redis:
  service.running:
    - name: redis
'''
client = SyncClient.connect(
    'https://localhost', 'root', 'salt', ssl_validate_cert=False)
f = client.api.fs.file_exists(saltenv='demo', path='/redis/init.sls')
if f.ret == True:
    apps = client.api.fs.update_file(
        saltenv='demo',
        path='/redis/init.sls',
        contents=file_contents
    )
else:
    apps = client.api.fs.save_file(
        saltenv='demo',
        path='/redis/init.sls',
        contents=file_contents
    )

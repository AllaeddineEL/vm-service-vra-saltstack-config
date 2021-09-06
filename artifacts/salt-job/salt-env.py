from sseapiclient import APIClient
from pathlib import Path

host = 'https://localhost'
user = 'root'
password = 'salt'

base_path = Path(__file__).parent
file_path = (base_path / "init.sls").resolve()

with open(file_path) as f:
    file_contents = f.read()

client = APIClient(host, user, password, ssl_validate_cert=False)

f = client.api.fs.file_exists(saltenv='demo', path='/nginx/init.sls')

if f.ret == True:
    apps = client.api.fs.update_file(saltenv='demo',
                                     path='/nginx/init.sls',
                                     contents=file_contents)
else:
    apps = client.api.fs.save_file(saltenv='demo',
                                   path='/nginx/init.sls',
                                   contents=file_contents)
j = client.api.job.get_jobs(name="Demo Nginx for VM Services")

if j.ret['count'] == 0:

    client.api.job.save_job(
        name="Demo Nginx for VM Services",
        desc="Deploy an example Nginx",
        cmd="local",
        fun="state.apply",
        arg={
            "arg": ["saltenv=demo"],
            "kwarg": {
                "mods": "nginx"
            }
        },
    )

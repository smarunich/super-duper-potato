#!/usr/bin/python
import sys
import redis
import threading
import urllib3

urllib3.disable_warnings()
from avi.sdk.avi_api import ApiSession


def get_tag(r, tag=None):
    try:
        for name in r.smembers('names'):
            if 'jumpbox' in name:
                return r.hget(name, tag)
    except Exception:
        return None


def clean_up(ctrl, user, passwd):
    print "Cleaning Controller IP: %s" % ctrl
    no_access = {'vtype': 'CLOUD_NONE'}
    api = ApiSession.get_session(ctrl, user, passwd, tenant="admin", timeout=600)
    for i in api.get('virtualservice').json()['results']:
        print "%s:Deleting VS: %s" % (ctrl, i['name'])
        api.delete_by_name('virtualservice', i['name'])
    for i in api.get('serviceengine').json()['results']:
        print "%s:Deleting SE: %s" % (ctrl, i['name'])
        api.delete_by_name('serviceengine', i['name'])
    for i in api.get('cloud').json()['results']:
        print "%s:Forcing garbage collection on cloud: %s" % (ctrl, i['name'])
        no_access['name'] = i['name']
        for j in range(5):
            api.put('cloud/%s/gc' % i['uuid'], params={'force': True})
        print "%s:Setting NO_ACCESS on cloud: %s" % (ctrl, i['name'])
        api.put('cloud/%s' % i['uuid'], data=no_access)


r = redis.StrictRedis(host='localhost', port=6379, db=0)
threads = []
ctrls = r.sscan('controllers')[1]

for ctrl in ctrls:
    username = get_tag(r, tag='Lab_avi_backup_admin_username')
    password = get_tag(r, tag='Lab_avi_backup_admin_password')
    t = threading.Thread(target=clean_up, args=(ctrl, username, password))
    threads.append(t)
    t.start()

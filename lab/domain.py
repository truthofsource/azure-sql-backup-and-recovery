import copy
from .fixtures import SNAPSHOT,REQUEST
from .readiness import validate,ReadinessError
def demo():
    checks=[];record=validate(copy.deepcopy(SNAPSHOT),copy.deepcopy(REQUEST))
    checks.append({'name':'Fictional readiness passes without submitting a restore','passed':record['status']=='prepared-not-submitted' and not record['productionAuthorization'],'detail':'A prepared receipt is not authorization or Azure acceptance'})
    for name,change in [('Source overwrite rejected',{'targetName':'workforce-example'}),('Wrong source identity rejected',{'sourceId':'/wrong/source'}),('Too-old restore point rejected',{'restorePointUtc':'2026-10-01T00:00:00Z'}),('Future restore point rejected',{'restorePointUtc':'2026-11-07T00:00:00Z'}),('Unsupported target-server change rejected',{'targetServerId':'/wrong/server'}),('Unreviewed method rejected',{'method':'geo-restore'})]:
        request=copy.deepcopy(REQUEST);request.update(change)
        try:validate(SNAPSHOT,request);blocked=False
        except ReadinessError:blocked=True
        checks.append({'name':name,'passed':blocked,'detail':'Expected local preparation guard; no provider operation'})
    return {'checks':checks,'metrics':[{'label':'PITR retention','value':'14 days','detail':'Source production policy'},{'label':'Backup redundancy','value':'Geo','detail':'Backups, not a running secondary'},{'label':'Live restores','value':'0','detail':'Prepared procedure only'},{'label':'Azure calls','value':'0','detail':'Local fictional inputs'}],'records':[['Production profile','S0 / Geo / 14 days','Terraform source and dated ownership receipt'],['Local request',record['status'],record['receiptSha256'][:16]],['Restore availability','Unverified','Azure must validate the selected point'],['Cloud recovery','Not executed','No live SQL or data access']]}

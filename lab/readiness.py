"""Pure preparation checks. No Azure SDK, HTTP client, subprocess or restore action."""
import copy,datetime as dt,hashlib,json,re
class ReadinessError(ValueError): pass
def require(value,code):
    if not value: raise ReadinessError(code)
def utc(value):
    require(isinstance(value,str) and value.endswith('Z'),'utc_timestamp_required')
    try: parsed=dt.datetime.fromisoformat(value.replace('Z','+00:00'))
    except ValueError: raise ReadinessError('invalid_timestamp') from None
    return parsed
def validate(snapshot,request):
    require(set(request)=={'sourceId','targetName','targetServerId','restorePointUtc','method','runId'},'unexpected_request_fields')
    require(request['sourceId']==snapshot['sourceId'],'source_identity_mismatch')
    require(request['method']=='same-server-pitr','method_requires_separate_plan')
    require(request['targetServerId']==snapshot['sourceServerId'],'pitr_target_server_mismatch')
    require(re.fullmatch(r'restore-drill-[a-z0-9-]{1,40}',request['targetName']) and request['targetName']!=snapshot['sourceName'],'owned_separate_target_required')
    require(request['targetName'] not in snapshot['existingDatabases'],'target_already_exists')
    require(re.fullmatch(r'[a-z0-9-]{1,50}',request['runId']),'run_identity_required')
    observed=utc(snapshot['observedAtUtc']);point=utc(request['restorePointUtc']);earliest=utc(snapshot['earliestRestoreDateUtc'])
    require(earliest<=point<=observed,'restore_point_outside_observed_window')
    require(snapshot['retentionDays']==14 and snapshot['backupRedundancy']=='Geo' and snapshot['sku']=='S0','production_backup_profile_mismatch')
    require(snapshot['serverPublicNetworkAccess']=='Disabled' and snapshot['entraOnly'] is True,'private_identity_boundary_missing')
    for flag in ['custodianOnlyReviewed','containedUsersReviewed','privateCallerPathReviewed','sendersAndWorkersIsolated','sourceBindingsPreserved','targetCostAndExpiryReviewed']:
        require(snapshot['readiness'].get(flag) is True,'hold_'+flag)
    canonical=json.dumps({'snapshot':snapshot,'request':request},sort_keys=True,separators=(',',':')).encode()
    return {'status':'prepared-not-submitted','receiptSha256':hashlib.sha256(canonical).hexdigest(),'restorePointUtc':request['restorePointUtc'],'sourceBindingsChanged':False,'azureOperations':0,'productionAuthorization':False,'availabilityStillRequiresAzureValidation':True,'fixtureObservationLagSeconds':int((observed-point).total_seconds())}

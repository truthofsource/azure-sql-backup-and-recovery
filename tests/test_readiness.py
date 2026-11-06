import copy,unittest
from lab.fixtures import SNAPSHOT,REQUEST
from lab.readiness import validate,ReadinessError
from lab.demo import report
class ReadinessTests(unittest.TestCase):
    def setUp(self):self.snapshot=copy.deepcopy(SNAPSHOT);self.request=copy.deepcopy(REQUEST)
    def rejected(self):
        with self.assertRaises(ReadinessError):validate(self.snapshot,self.request)
    def test_prepared_is_not_authorized_or_submitted(self):
        receipt=validate(self.snapshot,self.request);self.assertFalse(receipt['productionAuthorization']);self.assertEqual(receipt['azureOperations'],0);self.assertTrue(receipt['availabilityStillRequiresAzureValidation'])
    def test_deterministic_receipt_and_no_input_mutation(self):
        before=copy.deepcopy((self.snapshot,self.request));self.assertEqual(validate(*before),validate(self.snapshot,self.request));self.assertEqual(before,(self.snapshot,self.request))
    def test_source_mismatch(self):self.request['sourceId']='wrong';self.rejected()
    def test_source_overwrite(self):self.request['targetName']=self.snapshot['sourceName'];self.rejected()
    def test_existing_target(self):self.snapshot['existingDatabases'].append(self.request['targetName']);self.rejected()
    def test_unowned_target(self):self.request['targetName']='other-target';self.rejected()
    def test_timestamp_without_utc(self):self.request['restorePointUtc']='2026-11-05T18:00:00';self.rejected()
    def test_future_point(self):self.request['restorePointUtc']='2026-11-07T18:00:00Z';self.rejected()
    def test_old_point(self):self.request['restorePointUtc']='2026-10-01T18:00:00Z';self.rejected()
    def test_cross_server_is_not_silently_pitr(self):self.request['targetServerId']='different';self.rejected()
    def test_geo_restore_requires_separate_plan(self):self.request['method']='geo-restore';self.rejected()
    def test_untrusted_approval_field(self):self.request['approved']=True;self.rejected()
    def test_missing_readiness_and_string_true_fail(self):
        for key in self.snapshot['readiness']:
            for value in [False,'true',None]:
                snapshot=copy.deepcopy(self.snapshot);snapshot['readiness'][key]=value
                with self.assertRaises(ReadinessError):validate(snapshot,self.request)
    def test_public_access_denied(self):self.snapshot['serverPublicNetworkAccess']='Enabled';self.rejected()
    def test_wrong_backup_policy(self):self.snapshot['retentionDays']=7;self.rejected()
    def test_demo_has_seven_explicitly_local_checks(self):
        result=report();self.assertEqual(len(result['checks']),7);self.assertTrue(all(c['passed'] for c in result['checks']));self.assertIn('fictional',result['boundary'])

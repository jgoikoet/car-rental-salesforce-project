@isTest
public with sharing class VRT_CLS_LWC_SearchVehicles_Test {
    public VRT_CLS_LWC_SearchVehicles_Test() {

    }

    @testSetup
    static void setup(){

        List<VRT_Vehicle__c> testVehics = new List<VRT_Vehicle__c>();
        
        for(Integer i=0;i < 10; i++) {
            VRT_Vehicle__c veh = new VRT_Vehicle__c (
                VRT_TXT_ExternalId__c = 'TestVeh'+i,  
                VRT_TXT_LicensePlate__c = 'TST000'+i,
                VRT_TXT_Brand__c = 'Opel', 
                VRT_TXT_Model__c = 'Maravilla ' + i,
                VRT_SEL_VehicleType__c = 'Coche', 
                VRT_SEL_Status__c = 'Listo',  
                VRT_SEL_EnergyType__c = 'Diesel', 
                VRT_NUM_Passengers__c = 5,
                VRT_FLG_Available__c = true
            );
			testVehics.add(veh);
        }
        insert testVehics;

    }

    @isTest
    static void searchVehiclesTest(){

        Test.startTest();

        List<VRT_Vehicle__c> vehList = VRT_CLS_LWC_SearchVehicles.searchVehicles('Ope');
        System.assertEquals(10, vehList.size(), 'El numero de registros devueltos debe ser 10');

        vehList = VRT_CLS_LWC_SearchVehicles.searchVehicles('001');
        System.assertEquals(1, vehList.size(), 'El numero de registros devueltos debe ser 1');

        vehList = VRT_CLS_LWC_SearchVehicles.searchVehicles('xxx');
        System.assertEquals(null, vehList, 'Debe devolver null');

        Test.stopTest();

    }

    @isTest
    static void searchVehicleTest(){

        VRT_Vehicle__c veh =[SELECT Id FROM VRT_Vehicle__c WHERE VRT_TXT_Model__c = 'Maravilla 3' LIMIT 1];

        Test.startTest();
        
        VRT_Vehicle__c returnedVeh = VRT_CLS_LWC_SearchVehicles.searchVehicle(veh.Id);
        System.assertEquals(veh.Id, returnedVeh.Id, 'Los dos Id-s deben ser iguales');
        System.assertEquals('Maravilla 3', returnedVeh.VRT_TXT_Model__c, 'EL modelo tiene que ser Maravilla 3');

        Test.stopTest();

    }

}
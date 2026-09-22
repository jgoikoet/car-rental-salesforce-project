@isTest
public with sharing class VRT_CLS_LWC_GetRentFullData_Test {
    public VRT_CLS_LWC_GetRentFullData_Test() {

    }

    @TestSetup
    static void setup(){

        Account testAcc = new Account(Name = 'Bacalao de Bilbao');
        insert testAcc;

        VRT_Vehicle__c testVeh = new VRT_Vehicle__c (
            VRT_TXT_ExternalId__c = 'TestVeh1',  
            VRT_TXT_LicensePlate__c = 'TST0001',
            VRT_TXT_Brand__c = 'Opel', 
            VRT_TXT_Model__c = 'Maravilla',
            VRT_SEL_VehicleType__c = 'Coche', 
            VRT_SEL_Status__c = 'Listo',  
            VRT_SEL_EnergyType__c = 'Diesel', 
            VRT_NUM_Passengers__c = 5,
            VRT_FLG_Available__c = true
        );
        insert testVeh;

        VRT_Rental__c testRental= new VRT_Rental__c();
        testRental.VRT_LKP_Account__c = testAcc.Id;
        testRental.VRT_LKP_Vehicle__c = testVeh.Id;
        testRental.VRT_DAT_InitialDate__c = Date.Today();
        testRental.VRT_DAT_FinalDate__c = Date.Today()+5;
        testRental.VRT_SEL_Status__c = 'Reservado';
        insert testRental;
    }

    @isTest 
    static void getRentDataTest(){

        VRT_Rental__c testRental = [SELECT Name FROM VRT_Rental__c LIMIT 1];
    
        Test.startTest();

        VRT_Rental__c checkedRent = VRT_CLS_LWC_GetRentFullData.getRentFullData(testRental.Name);
        Assert.areEqual(testRental.Name, checkedRent.Name, 'Debe devolver el alquiler del mismo nombre');

        Test.stopTest();

    }

    @isTest 
    static void getVehicleDataTest(){

        VRT_Vehicle__c testVeh = [SELECT Id FROM VRT_Vehicle__c LIMIT 1];
    
        Test.startTest();

        VRT_Vehicle__c checkedVh = VRT_CLS_LWC_GetRentFullData.getVehicleData(testVeh.Id);
        Assert.areEqual(testVeh.Id, checkedVh.Id, 'Debe devolver el mismo Id');

        Test.stopTest();

    }

    @isTest 
    static void getAccountDataTest(){

        Account testAcc = [SELECT Id FROM Account LIMIT 1];
    
        Test.startTest();

        Account checkedAcc = VRT_CLS_LWC_GetRentFullData.getAccountData(testAcc.Id);
        Assert.areEqual(testAcc.Id, checkedAcc.Id, 'Debe devolver el mismo Id');

        Test.stopTest();

    }



}
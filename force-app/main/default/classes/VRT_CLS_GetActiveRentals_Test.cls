@isTest
public with sharing class VRT_CLS_GetActiveRentals_Test {
    public VRT_CLS_GetActiveRentals_Test() {

    }

    @testSetup
    static void setup() {
        
        List<VRT_Vehicle__c> testVehics = new List<VRT_Vehicle__c>();
        List<VRT_Rental__c> testRentals = new List<VRT_Rental__c>();

        //*p* creamos una cuenta para test
        Account testAcc = new Account(Name = 'Bacalao de Bilbao');
        insert testAcc;

        //*p* creamos 2 vehiculos (coches) para los tests
        for(Integer i=0;i < 2; i++) {
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
        
        //*p* Creamos 2  alquileres para test uno activo(reservado) y otro inactivo (cancelado)
        List<VRT_Vehicle__c> insertedVehics = [SELECT Id FROM VRT_Vehicle__c];

        VRT_Rental__c newRental= new VRT_Rental__c();
        newRental.VRT_LKP_Account__c = testAcc.Id;
        newRental.VRT_LKP_Vehicle__c = insertedVehics[0].Id;
        newRental.VRT_DAT_InitialDate__c = Date.Today();
        newRental.VRT_DAT_FinalDate__c = Date.Today()+5;
        newRental.VRT_SEL_Status__c = 'Reservado';
        testRentals.add(newRental);

        VRT_Rental__c newRentalB= new VRT_Rental__c();
        newRental.VRT_LKP_Account__c = testAcc.Id;
        newRentalB.VRT_LKP_Vehicle__c = insertedVehics[1].Id;
        newRentalB.VRT_DAT_InitialDate__c = Date.Today()+3;
        newRentalB.VRT_DAT_FinalDate__c = Date.Today()+10;
        newRentalB.VRT_SEL_Status__c = 'Cancelado';
        testRentals.add(newRentalB);

        insert testRentals;
    }


    @isTest
    static void checkActive(){
       
        List<VRT_Rental__c> activeRentals = new List<VRT_Rental__c>();
        Account testAcc = [SELECT ID FROM Account LIMIT 1];

        Test.startTest();

        //*p* Deberia de haber un alquiler activo para la cuenta testAcc
        activeRentals = VRT_CLS_GetActiveRentals.getAlquileresActivos(testAcc.Id);
        System.assertEquals(1, activeRentals.size(), 'Deberia de haber una alquiler activo para esta cuenta');

        Test.stopTest();

    }
}
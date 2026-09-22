@isTest
public with sharing class VRT_CLS_checkVehDisponibilityForLWC_Test {
    
    public VRT_CLS_checkVehDisponibilityForLWC_Test() {

    }

    @testSetup
    static void setup() {
        
        List<VRT_Vehicle__c> testVehics = new List<VRT_Vehicle__c>();
        List<VRT_Rental__c> testRentals = new List<VRT_Rental__c>();

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
        
        //*p* Creamos 2  alquileres para test parcialmente solapados con vehiculos diferentes
        List<VRT_Vehicle__c> insertedVehics = [SELECT Id FROM VRT_Vehicle__c];

        VRT_Rental__c newRental= new VRT_Rental__c();
        newRental.VRT_LKP_Vehicle__c = insertedVehics[0].Id;
        newRental.VRT_DAT_InitialDate__c = Date.Today();
        newRental.VRT_DAT_FinalDate__c = Date.Today()+5;
        newRental.VRT_SEL_Status__c = 'Reservado';
        testRentals.add(newRental);

        VRT_Rental__c newRentalB= new VRT_Rental__c();
        newRentalB.VRT_LKP_Vehicle__c = insertedVehics[1].Id;
        newRentalB.VRT_DAT_InitialDate__c = Date.Today()+3;
        newRentalB.VRT_DAT_FinalDate__c = Date.Today()+10;
        newRentalB.VRT_SEL_Status__c = 'Reservado';
        testRentals.add(newRentalB);

        insert testRentals;
    }


    @isTest
    static void checkDisponibility(){

        //List<VRT_Vehicle__c> insertedVehics = [SELECT Id FROM VRT_Vehicle__c];
        
        List<VRT_Vehicle__c> availableVehics = new List<VRT_Vehicle__c>();

        //*p/ Creamos 2 alquileres, uno con coche disponible y otro ocupado 


        Test.startTest();

        //*p* Deberia de haber un vehiculo disponible
        availableVehics = VRT_CLS_checkVeicleDisponibilityForLWC.getDisponibleVehicles(Date.Today(), Date.Today()+2);
        System.assertEquals(1, availableVehics.size(), 'Deberia de haber 1 vehiculo disponible');

        //*p* Deberia de haber dos vehiculos disponibles
        availableVehics = VRT_CLS_checkVeicleDisponibilityForLWC.getDisponibleVehicles(Date.Today()+15, Date.Today()+18);
        System.assertEquals(2, availableVehics.size(), 'Deberia de haber 2 vehiculos disponibles');

        //*p* No deberia de haber ningun vehiculo disponible
        availableVehics = VRT_CLS_checkVeicleDisponibilityForLWC.getDisponibleVehicles(Date.Today(), Date.Today()+6);
        System.assertEquals(0, availableVehics.size(), 'No deberia de haber ningun vehiculo disponible');

        Test.stopTest();

    }
}
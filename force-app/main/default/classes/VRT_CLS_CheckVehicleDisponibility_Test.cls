
@isTest
public  class VRT_CLS_CheckVehicleDisponibility_Test {
    
    static Integer vehiclesNumber = 10;
    //static Integer accountsNumber = 2;

    @testSetup
    static void setup() {

        List<VRT_Vehicle__c> testVehics = new List<VRT_Vehicle__c>();
        //List<Account> testAccounts = new List<Account>();

        //*p* creamos vehiculos para los tests
        for(Integer i=0;i < vehiclesNumber; i++) {
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

        //*p* creamos cuentas para los tests
        // for(Integer i=0;i < accountsNumber; i++) {
        //     Account acc = new Account (Name = 'Obleas P.Tinto ' + i);

		// 	testAccounts.add(acc);
        // }
        // insert testAccounts;

    }

    @isTest
    static void createRentals(){

        List<VRT_Vehicle__c> testVehics = [SELECT Id, Name FROM VRT_Vehicle__c];
        List<VRT_Rental__c> testRentals = new List<VRT_Rental__c>();

        //*p* creamos x alquileres con los x vehiculos creados anteriormente
        for (VRT_Vehicle__c veh : testVehics){

            //system.debug(veh.Id + ' ' + veh.NAme);
            
            VRT_Rental__c newRental= new VRT_Rental__c();
            newRental.VRT_LKP_Vehicle__c = veh.Id;
            newRental.VRT_DAT_InitialDate__c = Date.Today();
            newRental.VRT_DAT_FinalDate__c = Date.Today()+3;
            newRental.VRT_SEL_Status__c = 'Reservado';
            testRentals.add(newRental);

        }

        //*p* creamos varios alquileres con vehiculos repetidos y distintos precios
        
        for (Integer i = 0; i < 5; i++){

            VRT_Rental__c newRental= new VRT_Rental__c();
            newRental.VRT_LKP_Vehicle__c = testVehics[0].Id;
            newRental.VRT_DAT_InitialDate__c = Date.Today();
            newRental.VRT_DAT_FinalDate__c = Date.Today()+i+1;
            newRental.VRT_SEL_Status__c = 'Reservado';
            testRentals.add(newRental);
        }
        for (Integer i = 0; i < 3; i++){

            VRT_Rental__c newRental= new VRT_Rental__c();
            newRental.VRT_LKP_Vehicle__c = testVehics[1].Id;
            newRental.VRT_DAT_InitialDate__c = Date.Today();
            newRental.VRT_DAT_FinalDate__c = Date.Today()+i+1;
            newRental.VRT_SEL_Status__c = 'Reservado';
            testRentals.add(newRental);
        }

        
        //*p* un alquiler no solapado con vehiculo repetido
        VRT_Rental__c newRental= new VRT_Rental__c();
        newRental.VRT_LKP_Vehicle__c = testVehics[1].Id;
        newRental.VRT_DAT_InitialDate__c = Date.Today() + 100;
        newRental.VRT_DAT_FinalDate__c = Date.Today()+102;
        newRental.VRT_SEL_Status__c = 'Reservado';
        testRentals.add(newRental);

        Test.startTest();
        insert testRentals;
        Test.stopTest();

        List<VRT_Rental__c> insertedRentals = [SELECT id, VRT_LKP_Vehicle__r.Name FROM VRT_Rental__c];

        system.debug('Buenas tarde');

        // for(VRT_Rental__c rental : insertedRentals){
        //     system.debug(rental.Id + ' ' + rental.VRT_LKP_Vehicle__r.Name);
        // }
        System.assertEquals(vehiclesNumber, insertedRentals.size(), 'Deberia haber '+ vehiclesNumber +' registros');
    }

}
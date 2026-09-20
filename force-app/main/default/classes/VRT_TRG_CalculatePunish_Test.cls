
@isTest
private class VRT_TRG_CalculatePunish_Test {
    public VRT_TRG_CalculatePunish_Test() {

    }

    @testSetup
    static void setup() {

        List<VRT_Vehicle__c> testVehicles = new  List<VRT_Vehicle__c>();
        List<VRT_Rental__c> testRentals = new List<VRT_Rental__c>();

        Account testAcc = new Account(Name = 'Bacalao de Bilbao',
            VRT_TXT_Email__c = 'josebagoikol@gmail.com');
        insert testAcc;

        VRT_Vehicle__c testCoche = new VRT_Vehicle__c(
            VRT_TXT_ExternalId__c = 'TestVeh', 
            VRT_TXT_LicensePlate__c = 'TST0001',
            VRT_TXT_Brand__c = 'Opel', 
            VRT_SEL_VehicleType__c = 'Coche', 
            VRT_SEL_Status__c = 'Listo',  
            VRT_SEL_EnergyType__c = 'Diesel', 
            VRT_NUM_Passengers__c = 5,
            VRT_FLG_Available__c = true,
            VRT_NUM_Mileage__c = 100,
            VRT_DAT_ManufacturedYear__c = System.today().addYears(-1)
        ); 
        testVehicles.add(testCoche);

        VRT_Vehicle__c testMoto = new VRT_Vehicle__c(
            VRT_TXT_ExternalId__c = 'TestVeh', 
            VRT_TXT_LicensePlate__c = 'TST0002',
            VRT_TXT_Brand__c = 'Derby', 
            VRT_SEL_VehicleType__c = 'Moto', 
            VRT_SEL_Status__c = 'Listo',  
            VRT_SEL_EnergyType__c = 'Diesel', 
            VRT_NUM_Passengers__c = 2,
            VRT_FLG_Available__c = true,
            VRT_NUM_Mileage__c = 100,
            VRT_DAT_ManufacturedYear__c = System.today().addYears(-1)
        ); 
        testVehicles.add(testMoto);

        insert testVehicles;

        // Coche en temporada alta
        VRT_Rental__c newRental= new VRT_Rental__c();
        newRental.VRT_LKP_Account__c = testAcc.Id;
        newRental.VRT_LKP_Vehicle__c = testCoche.Id;
        newRental.VRT_DAT_InitialDate__c = Date.newInstance(Date.today().year() - 1, 1, 1);
        newRental.VRT_DAT_FinalDate__c = Date.newInstance(Date.today().year() - 1, 1, 2);
        newRental.VRT_SEL_Status__c = 'En curso';
        newRental.VRT_SEL_PaymentStatus__c = 'Pagado';
        testRentals.add(newRental);

        // Moto en temporada alta
        VRT_Rental__c newRentalB= new VRT_Rental__c();
        newRentalB.VRT_LKP_Account__c = testAcc.Id;
        newRentalB.VRT_LKP_Vehicle__c = testMoto.Id;
        newRentalB.VRT_DAT_InitialDate__c = Date.newInstance(Date.today().year() - 1, 1, 1);
        newRentalB.VRT_DAT_FinalDate__c = Date.newInstance(Date.today().year() - 1, 1, 2);
        newRentalB.VRT_SEL_Status__c = 'En curso';
        newRentalB.VRT_SEL_PaymentStatus__c = 'Pagado';
        testRentals.add(newRentalB);

        // Coche en temporada media
        VRT_Rental__c newRentalC= new VRT_Rental__c();
        newRentalC.VRT_LKP_Account__c = testAcc.Id;
        newRentalC.VRT_LKP_Vehicle__c = testCoche.Id;
        newRentalC.VRT_DAT_InitialDate__c = Date.newInstance(Date.today().year() - 1, 2, 1);
        newRentalC.VRT_DAT_FinalDate__c = Date.newInstance(Date.today().year() - 1, 2, 2);
        newRentalC.VRT_SEL_Status__c = 'En curso';
        newRentalC.VRT_SEL_PaymentStatus__c = 'Pagado';
        testRentals.add(newRentalC);

        // Moto en temporada media
        VRT_Rental__c newRentalD= new VRT_Rental__c();
        newRentalD.VRT_LKP_Account__c = testAcc.Id;
        newRentalD.VRT_LKP_Vehicle__c = testMoto.Id;
        newRentalD.VRT_DAT_InitialDate__c = Date.newInstance(Date.today().year() - 1,2, 1);
        newRentalD.VRT_DAT_FinalDate__c = Date.newInstance(Date.today().year() - 1, 2, 2);
        newRentalD.VRT_SEL_Status__c = 'En curso';
        newRentalD.VRT_SEL_PaymentStatus__c = 'Pagado';
        testRentals.add(newRentalD);

        // Coche en temporada baja
        VRT_Rental__c newRentalE= new VRT_Rental__c();
        newRentalE.VRT_LKP_Account__c = testAcc.Id;
        newRentalE.VRT_LKP_Vehicle__c = testCoche.Id;
        newRentalE.VRT_DAT_InitialDate__c = Date.newInstance(Date.today().year() - 1, 3, 1);
        newRentalE.VRT_DAT_FinalDate__c = Date.newInstance(Date.today().year() - 1, 3, 2);
        newRentalE.VRT_SEL_Status__c = 'En curso';
        newRentalE.VRT_SEL_PaymentStatus__c = 'Pagado';
        testRentals.add(newRentalE);

        // Moto en temporada media
        VRT_Rental__c newRentalF= new VRT_Rental__c();
        newRentalF.VRT_LKP_Account__c = testAcc.Id;
        newRentalF.VRT_LKP_Vehicle__c = testMoto.Id;
        newRentalF.VRT_DAT_InitialDate__c = Date.newInstance(Date.today().year() - 1, 3, 1);
        newRentalF.VRT_DAT_FinalDate__c = Date.newInstance(Date.today().year() - 1, 3, 2);
        newRentalF.VRT_SEL_Status__c = 'En curso';
        newRentalF.VRT_SEL_PaymentStatus__c = 'Pagado';
        testRentals.add(newRentalF);

        insert testRentals;
    }

    @isTest
    static void calculatePunish(){

        List<VRT_Rental__c> testRental = [SELECT Id, VRT_SEL_Status__c FROM VRT_Rental__c];
        
        for(VRT_Rental__c rent : testRental){
            rent.VRT_SEL_Status__c = 'Completado';
        }

        Test.startTest();
        update testRental;
        Test.stopTest();


        List<VRT_Rental__c> updatedRentals = [SELECT Id, VRT_DIV_penalty__c FROM VRT_Rental__c];

        for (VRT_Rental__c rent : updatedRentals){

            system.debug('penalty:  '+rent.VRT_DIV_penalty__c);
            assert.isTrue(rent.VRT_DIV_penalty__c > 0, 'La penalizacion ha de ser mayor de cero');
        }
    }
    
}

@isTest
private class VRT_TRG_LWC_GetRentFullData_Test {
    public VRT_TRG_LWC_GetRentFullData_Test() {

    }

    @testSetup
    static void setup() {

        Account testAcc = new Account(Name = 'Bacalao de Bilbao',
            VRT_TXT_Email__c = 'josebagoikol@gmail.com');
        insert testAcc;

        VRT_Vehicle__c testVeh = new VRT_Vehicle__c(
            VRT_TXT_ExternalId__c = 'TestVeh', 
            VRT_TXT_LicensePlate__c = 'TST0001',
            VRT_TXT_Brand__c = 'Opel', 
            VRT_SEL_VehicleType__c = 'Coche', 
            VRT_SEL_Status__c = 'Listo',  
            VRT_SEL_EnergyType__c = 'Diesel', 
            VRT_NUM_Passengers__c = 5,
            VRT_FLG_Available__c = true,
            VRT_DAT_ManufacturedYear__c = System.today().addYears(-1)
        ); 
        insert testVeh;

        VRT_Rental__c newRental= new VRT_Rental__c();
        newRental.VRT_LKP_Account__c = testAcc.Id;
        newRental.VRT_LKP_Vehicle__c = testVeh.Id;
        newRental.VRT_DAT_InitialDate__c = Date.Today();
        newRental.VRT_DAT_FinalDate__c = Date.Today()+5;
        newRental.VRT_SEL_Status__c = 'Reservado';
        newRental.VRT_SEL_PaymentStatus__c = 'Pagado';
        insert newRental;
    }

    @isTest
    static void getRentFullDataTest(){

        VRT_Rental__c rental = [SELECT Id, Name FROM VRT_Rental__c LIMIT 1];

        Test.startTest();
        VRT_Rental__c testRental = VRT_TRG_LWC_GetRentFullData.getRentFullData(rental.Name);
        Test.stopTest();

        System.assertEquals(rental.Name, testRental.name, 'El registro devuelto debe ser el mismo');

        // System.debug(testRental.VRT_DAT_InitialDate__c);
        // System.debug(testRental.VRT_DAT_FinalDate__c);
        // System.debug(testRental.VRT_DIV_TotalCost__c);
        // System.debug(testRental.VRT_SEL_Status__c);

    }



}
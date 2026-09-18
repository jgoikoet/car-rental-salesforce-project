


@isTest
public with sharing class VRT_CLS_RentalPDFGenerator_Test {
    public VRT_CLS_RentalPDFGenerator_Test() {

    }

    @testSetup
    static void setup() {

        Account testAcc = new Account(Name = 'Bacalao de Bilbao',
            VRT_TXT_Email__c = 'josebagoikol@gmail.com');
        insert testAcc;

        VRT_Vehicle__c testVeh = new VRT_Vehicle__c(
            VRT_TXT_ExternalId__c = 'TestVeh'+0, 
            VRT_TXT_LicensePlate__c = 'TST000'+0,
            VRT_TXT_Brand__c = 'Opel', 
            VRT_SEL_VehicleType__c = 'Coche', 
            VRT_SEL_Status__c = 'Listo',  
            VRT_SEL_EnergyType__c = 'Diesel', 
            VRT_NUM_Passengers__c = 5,
            VRT_DAT_ManufacturedYear__c = System.today().addYears(-5)
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
    static void generateInvoicePDFTest(){

        VRT_Rental__c testRental = [SELECT Id, VRT_SEL_Status__c  FROM VRT_Rental__c];

        Test.startTest();

        testRental.VRT_SEL_Status__c = 'Completado';
        //System.assertEquals(1, activeRentals.size(), 'Deberia de haber una alquiler activo para esta cuenta');

        Test.stopTest();



    }

}
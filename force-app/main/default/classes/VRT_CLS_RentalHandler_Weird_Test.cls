
//esta clase se ha creado para cubrir el 100% del codigo
//chekea de la funcion onBeforeUpdate de VRT_TRG_RentalHandler
//que hace una verificacion muy rara:
//if (oldRental.VRT_SEL_Status__c == 'Cancelado' && newRental.VRT_SEL_Status__c != 'Cancelado')
//No creo que se usa para nada, pero venia en el proyecto proporcionado por NTTData
//asi que por si acaso hasta una proxima revision la mantengo

@isTest
private class VRT_CLS_RentalHandler_Weird_Test {
    public VRT_CLS_RentalHandler_Weird_Test() {

    }

    @TestSetup
    static void setup(){

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
            VRT_DAT_ManufacturedYear__c = Date.today().addYears(-1)); 
        insert testCoche;
        
        VRT_Rental__c testRent= new VRT_Rental__c();
        testRent.VRT_LKP_Account__c = testAcc.Id;
        testRent.VRT_LKP_Vehicle__c = testCoche.Id;
        testRent.VRT_DAT_InitialDate__c = Date.today();
        testRent.VRT_DAT_FinalDate__c = Date.today() + 2;
        testRent.VRT_SEL_Status__c = 'Cancelado';
        testRent.VRT_SEL_PaymentStatus__c = 'Pagado';
        insert testRent;
        
    }

    @isTest
    static void onBeforeUpdateTest(){

        VRT_Rental__c testRent = [SELECT Id,VRT_SEL_Status__c FROM  VRT_Rental__c];

        testRent.VRT_SEL_Status__c = 'Reservado';

        Test.startTest();
        update testRent;
        Test.stopTest();
    }
}
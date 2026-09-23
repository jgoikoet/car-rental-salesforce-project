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

        VRT_Rental__c testRentB= new VRT_Rental__c();
        testRentB.VRT_LKP_Account__c = testAcc.Id;
        testRentB.VRT_LKP_Vehicle__c = testCoche.Id;
        testRentB.VRT_DAT_InitialDate__c = Date.today()+3;
        testRentB.VRT_DAT_FinalDate__c = Date.today() + 4;
        testRentB.VRT_SEL_Status__c = 'Reservado';
        testRentB.VRT_SEL_PaymentStatus__c = 'Pendiente';
        insert testRentB;
        
    }

    @isTest
    static void onBeforeUpdateTest(){

        VRT_Rental__c testRentCancelado = [SELECT Id,VRT_SEL_Status__c FROM  VRT_Rental__c WHERE VRT_SEL_Status__c = 'Cancelado'];
        VRT_Rental__c testRentReservado = [SELECT Id,VRT_SEL_Status__c FROM  VRT_Rental__c WHERE VRT_SEL_Status__c = 'Reservado'];

        testRentCancelado.VRT_SEL_Status__c = 'Reservado';
        testRentReservado.VRT_SEL_Status__c = 'En curso';

        Test.startTest();
        update testRentCancelado;

        try{
            update testRentReservado;
            Assert.fail('Se esperaba que el update fuera bloqueado por la validqation rule');
        } catch(Exception e){
            Assert.isTrue(e.getMessage().contains('pendiente de pago no se puede iniciar'),
            'Mensaje de error inesperado: ' + e.getMessage());

            //system.debug('Error excepcion: ' + e.getMessage());
        }

        Test.stopTest();
    }
}
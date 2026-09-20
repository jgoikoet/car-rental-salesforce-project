//ataca a rental handler triger
@isTest
private class VRT_TRG_ApprovalProcces_Test {
    public VRT_TRG_ApprovalProcces_Test() {

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

        
        
    }

    @isTest
    static void approvalProccesTest(){

        Account testAcc = [SELECT Id FROM Account];
        VRT_Vehicle__c testCoche = [SELECT Id FROM VRT_Vehicle__c];

        Test.startTest();

        VRT_Rental__c rentToAproval= new VRT_Rental__c();
        rentToAproval.VRT_LKP_Account__c = testAcc.Id;
        rentToAproval.VRT_LKP_Vehicle__c = testCoche.Id;
        rentToAproval.VRT_DAT_InitialDate__c = Date.today();
        rentToAproval.VRT_DAT_FinalDate__c = Date.today() + 150;
        rentToAproval.VRT_SEL_Status__c = 'Reservado';
        rentToAproval.VRT_SEL_PaymentStatus__c = 'Pagado';
        insert rentToAproval;

        VRT_Rental__c rentNOTToAproval= new VRT_Rental__c();
        rentNOTToAproval.VRT_LKP_Account__c = testAcc.Id;
        rentNOTToAproval.VRT_LKP_Vehicle__c = testCoche.Id;
        rentNOTToAproval.VRT_DAT_InitialDate__c = Date.today()-5;
        rentNOTToAproval.VRT_DAT_FinalDate__c = Date.today() - 2;
        rentNOTToAproval.VRT_SEL_Status__c = 'Reservado';
        rentNOTToAproval.VRT_SEL_PaymentStatus__c = 'Pagado';
        insert rentNOTToAproval;

        Test.stopTest();

        List<VRT_Rental__c> testRental = [SELECT Id, VRT_SEL_Status__c FROM VRT_Rental__c];
        Integer rentsToAproval = 0;
        Integer rentsNotToAproval = 0;

        for(VRT_Rental__c rent: testRental){
            if (rent.VRT_SEL_Status__c == 'En_proceso_de _aprobacion'){rentsToAproval++;}
            else if(rent.VRT_SEL_Status__c == 'Reservado'){rentsNotToAproval++;}
        }
        assert.areEqual(1,rentsToAproval, 'Debe haber un alquiler en proceso de aprobacion');
        assert.areEqual(1,rentsNotToAproval, 'Debe haber un alquiler sin proceso de aprobacion');

        system.debug('VRT_SEL_Status__c: '+testRental[0].VRT_SEL_Status__c);

    }

    @isTest
    static void approvedProccesTest(){
        
        Account testAcc = [SELECT Id FROM Account];
        VRT_Vehicle__c testCoche = [SELECT Id FROM VRT_Vehicle__c];

        VRT_Rental__c rentToAproval= new VRT_Rental__c();
        rentToAproval.VRT_LKP_Account__c = testAcc.Id;
        rentToAproval.VRT_LKP_Vehicle__c = testCoche.Id;
        rentToAproval.VRT_DAT_InitialDate__c = Date.today();
        rentToAproval.VRT_DAT_FinalDate__c = Date.today() + 150;
        rentToAproval.VRT_SEL_Status__c = 'Reservado';
        rentToAproval.VRT_SEL_PaymentStatus__c = 'Pagado';
        insert rentToAproval;

        VRT_Rental__c testRental = [SELECT Id, VRT_SEL_Status__c FROM VRT_Rental__c
                                     WHERE VRT_SEL_Status__c = 'En_proceso_de _aprobacion'];

        testRental.VRT_SEL_Status__c ='Reservado';
        Test.startTest();
        update testRental;
        Test.stopTest();

        
    }

}
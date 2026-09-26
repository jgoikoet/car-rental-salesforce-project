@isTest
public with sharing class VRT_CLS_LWC_CreateNewRent_Test {
    public VRT_CLS_LWC_CreateNewRent_Test() {

    }

    @TestSetup
    static void setup(){

        List<VRT_Vehicle__c> testVehics = new List<VRT_Vehicle__c>();

        Account testAcc = new Account(Name = 'Bacalao de Bilbao');
        insert testAcc;

        for(Integer i=0;i < 3; i++) {
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
        
    }

    @isTest
    static void noExceptionCasesTest(){
        
        List<VRT_Vehicle__c> testVehics = [SELECT Id FROM VRT_Vehicle__c];
        Account testAcc = [SELECT Id FROM Account LIMIT 1];
        //*p* Texts correctos
        Test.startTest();

        //*p* Alquiler correcto y pagado
        VRT_CLS_LWC_CreateNewRent.createNewRent(
            Date.Today(),Date.Today()+2,testAcc.Id,
            testVehics[0].Id,true,200);

        //*p* Alquiler correcto y no pagado
        VRT_CLS_LWC_CreateNewRent.createNewRent(
            Date.Today(),Date.Today()+2,testAcc.Id,
            testVehics[1].Id,false,200);
        
        Test.stopTest();
    }

    @isTest
    static void exceptionCaseTest(){

        List<VRT_Vehicle__c> testVehics = [SELECT Id FROM VRT_Vehicle__c];
        Account testAcc = [SELECT Id FROM Account LIMIT 1];

        // //*p* Test que lanza excepcion por fechas incorrectas
        Test.startTest();

        try{
        VRT_CLS_LWC_CreateNewRent.createNewRent(
            Date.Today(),Date.Today()-2,testAcc.Id,
            testVehics[2].Id,false,200);
            Assert.fail('Se esperaba una excepcion debido a las fechas invalidas');
        } catch (AuraHandledException e){
            Assert.isNotNull(e.getMessage(), 'El mensaje de la excepción no debe ser nulo');
            //system.debug('----------------Mensaje de error: ' + e.getMessage());
        }

        Test.stopTest();
    }

}
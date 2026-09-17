
@isTest
public with sharing class VRT_CLS_LWC_CalculateTotalCost_Test {
    public VRT_CLS_LWC_CalculateTotalCost_Test() {

    }

    @testSetup
    static void setup() {
        
        //List<VRT_Vehicle__c> testVehics = new List<VRT_Vehicle__c>();
        List<VRT_Rental__c> testRentals = new List<VRT_Rental__c>();
        List<VRT_Vehicle__c> testVehics = new List<VRT_Vehicle__c>();

        //*p* creamos una cuenta para test que tendra 3 alquiles completados el ultimo año
        Account testAcc = new Account(Name = 'Bacalao de Bilbao');
        insert testAcc;

        //*p* creamos una cuenta para test que no tendra ningun alquiler completado el ultimo año
        Account testAccB = new Account(Name = 'Granujas S.L.');
        insert testAccB;

        //*p* creamos 3 vehiculos para los 3 alquileres de Bacalao de bilbao
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

        
        //*p* Creamos 3  alquileres completados paca Bacalao de Bilbao

        for (Integer i = 0; i < 3; i++){
            VRT_Rental__c newRental= new VRT_Rental__c();
            newRental.VRT_LKP_Account__c = testAcc.Id;
            newRental.VRT_LKP_Vehicle__c = testVehics[i].Id;
            newRental.VRT_DAT_InitialDate__c = Date.Today()-10;
            newRental.VRT_DAT_FinalDate__c = Date.Today()-5;
            newRental.VRT_SEL_Status__c = 'Completado';
            testRentals.add(newRental);
        }
        insert testRentals;
        

       
    }

    @isTest
    static void calculateCost(){
       
        Account testAcc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();

        //*p* "coche 2 dias en temporada alta (Enero);
        Decimal totalCost = VRT_CLS_LWC_CalculateTotalCost.calculateTotalCost(
            Date.newInstance(Date.today().year(), 1, 1), Date.newInstance(Date.today().year(), 1, 2), 'coche', testAcc.Id);
        system.debug('Coste:' + totalCost);
        System.assertEquals(300, totalCost, 'El coste deberia ser 300');

        //*p* "coche 2 dias en temporada media (Febrero);
        totalCost = VRT_CLS_LWC_CalculateTotalCost.calculateTotalCost(
            Date.newInstance(Date.today().year(), 2, 1), Date.newInstance(Date.today().year(), 2, 2), 'coche', testAcc.Id);
        system.debug('Coste:' + totalCost);
        System.assertEquals(200, totalCost, 'El coste deberia ser 200');

        //*p* "coche 2 dias en temporada baja (Marzo);
        totalCost = VRT_CLS_LWC_CalculateTotalCost.calculateTotalCost(
            Date.newInstance(Date.today().year(), 3, 1), Date.newInstance(Date.today().year(), 3, 2), 'coche', testAcc.Id);
        system.debug('Coste:' + totalCost);
        System.assertEquals(160, totalCost, 'El coste deberia ser 160');

        //*p* "Moto 2 dias en temporada alta (Enero);
        totalCost = VRT_CLS_LWC_CalculateTotalCost.calculateTotalCost(
            Date.newInstance(Date.today().year(), 1, 1), Date.newInstance(Date.today().year(), 1, 2), 'Moto', testAcc.Id);
        system.debug('Coste:' + totalCost);
        System.assertEquals(200, totalCost, 'El coste deberia ser 200');
        //System.assertEquals(1, activeRentals.size(), 'Deberia de haber una alquiler activ0 para esta cuenta');

        //*p* "Moto 2 dias en temporada media (Febrero);
        totalCost = VRT_CLS_LWC_CalculateTotalCost.calculateTotalCost(
            Date.newInstance(Date.today().year(), 2, 1), Date.newInstance(Date.today().year(), 2, 2), 'Moto', testAcc.Id);
        system.debug('Coste:' + totalCost);
        System.assertEquals(160, totalCost, 'El coste deberia ser 160');

        //*p* "Moto 2 dias en temporada baja (Marzo);
        totalCost = VRT_CLS_LWC_CalculateTotalCost.calculateTotalCost(
            Date.newInstance(Date.today().year(), 3, 1), Date.newInstance(Date.today().year(), 3, 2), 'Moto', testAcc.Id);
        system.debug('Coste:' + totalCost);
        System.assertEquals(120, totalCost, 'El coste deberia ser 120');


        Test.stopTest();

    }
    @isTest
    static void calculateDiscountTest(){

        Id bacalaoDeBilbaoId = [SELECT Id FROM Account WHERE Name = 'Bacalao de Bilbao'].Id;
        Id granujasSLId = [SELECT Id FROM Account WHERE Name = 'Granujas S.L.'].Id;

        Test.startTest();

        Boolean discount = VRT_CLS_LWC_CalculateTotalCost.calculateDiscount(bacalaoDeBilbaoId);
        System.assertEquals(true, discount, 'El decuento deberia ser true');

        discount = VRT_CLS_LWC_CalculateTotalCost.calculateDiscount(granujasSLId);
        System.assertEquals(false, discount, 'El decuento deberia ser false');

        Test.stopTest();

    }
}
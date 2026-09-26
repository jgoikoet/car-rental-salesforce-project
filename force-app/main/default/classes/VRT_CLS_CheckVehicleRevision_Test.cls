@isTest
public class VRT_CLS_CheckVehicleRevision_Test {

    @testSetup
    static void setup() {

        List<VRT_Vehicle__c> vehicles = new List<VRT_Vehicle__c>();
        
        //  2 vehiculos coche y moto que necesitan ITV por antiguedad y sin fecha de ultima ITV
        vehicles.add(new VRT_Vehicle__c(VRT_TXT_ExternalId__c = 'TestVeh'+0, 
                                        VRT_TXT_LicensePlate__c = 'TST000'+0,
                                        VRT_TXT_Brand__c = 'Opel', 
                                        VRT_SEL_VehicleType__c = 'Coche', 
                                        VRT_SEL_Status__c = 'Listo',  
                                        VRT_SEL_EnergyType__c = 'Diesel', 
                                        VRT_NUM_Passengers__c = 5,
                                        VRT_DAT_ManufacturedYear__c = System.today().addYears(-5)
                                       ));
        vehicles.add(new VRT_Vehicle__c(VRT_TXT_ExternalId__c = 'TestVeh'+1, 
                                        VRT_TXT_LicensePlate__c = 'TST000'+1,
                                        VRT_TXT_Brand__c = 'Opel', 
                                        VRT_SEL_VehicleType__c = 'Moto', 
                                        VRT_SEL_Status__c = 'Listo',  
                                        VRT_SEL_EnergyType__c = 'Diesel', 
                                        VRT_NUM_Passengers__c = 2,
                                        VRT_DAT_ManufacturedYear__c = System.today().addYears(-4)
                                       ));
       
       //*p*   2 vehiculos coche y moto  que NO  necesitan ITV por nuevos
        vehicles.add(new VRT_Vehicle__c(VRT_TXT_ExternalId__c = 'TestVeh'+3, 
                                        VRT_TXT_LicensePlate__c = 'TST000'+3,
                                        VRT_TXT_Brand__c = 'Opel', 
                                        VRT_SEL_VehicleType__c = 'Coche', 
                                        VRT_SEL_Status__c = 'Listo',  
                                        VRT_SEL_EnergyType__c = 'Diesel', 
                                        VRT_NUM_Passengers__c = 5,
                                        VRT_DAT_ManufacturedYear__c = System.today().addYears(-1)
                                       ));
        vehicles.add(new VRT_Vehicle__c(VRT_TXT_ExternalId__c = 'TestVeh'+4, 
                                        VRT_TXT_LicensePlate__c = 'TST000'+4,
                                        VRT_TXT_Brand__c = 'Opel', 
                                        VRT_SEL_VehicleType__c = 'Moto', 
                                        VRT_SEL_Status__c = 'Listo',  
                                        VRT_SEL_EnergyType__c = 'Diesel', 
                                        VRT_NUM_Passengers__c = 2,
                                        VRT_DAT_ManufacturedYear__c = System.today().addYears(-1)
                                       ));

        //*p* Vehiculo con fecha de itv y fecha de fabricacio que NO necesita ITV
        vehicles.add(new VRT_Vehicle__c(VRT_TXT_ExternalId__c = 'TestVeh'+5, 
                                        VRT_TXT_LicensePlate__c = 'TST000'+5,
                                        VRT_TXT_Brand__c = 'Opel', 
                                        VRT_SEL_VehicleType__c = 'Coche', 
                                        VRT_SEL_Status__c = 'Listo',  
                                        VRT_SEL_EnergyType__c = 'Diesel', 
                                        VRT_NUM_Passengers__c = 5,
                                        VRT_DAT_ManufacturedYear__c = System.today().addYears(-8),
                                        VRT_DAT_LastITV__c = System.today().addYears(-1)
                                       ));
        //*p* Coche con fecha de itv de hace mas de 2 años y fabricado hace menos de 10 años  que  necesita ITV
        vehicles.add(new VRT_Vehicle__c(VRT_TXT_ExternalId__c = 'TestVeh'+6, 
                                        VRT_TXT_LicensePlate__c = 'TST000'+6,
                                        VRT_TXT_Brand__c = 'Opel', 
                                        VRT_SEL_VehicleType__c = 'Coche', 
                                        VRT_SEL_Status__c = 'Listo',  
                                        VRT_SEL_EnergyType__c = 'Diesel', 
                                        VRT_NUM_Passengers__c = 5,
                                        VRT_DAT_ManufacturedYear__c = System.today().addYears(-8),
                                        VRT_DAT_LastITV__c = System.today().addYears(-3)
                                       ));

        //*p* Coche con fecha de itv de hace mas de 1 año y fabricado hace mas de 10 años  que  necesita ITV
        vehicles.add(new VRT_Vehicle__c(VRT_TXT_ExternalId__c = 'TestVeh'+7, 
                                        VRT_TXT_LicensePlate__c = 'TST000'+7,
                                        VRT_TXT_Brand__c = 'Opel', 
                                        VRT_SEL_VehicleType__c = 'Coche', 
                                        VRT_SEL_Status__c = 'Listo',  
                                        VRT_SEL_EnergyType__c = 'Diesel', 
                                        VRT_NUM_Passengers__c = 5,
                                        VRT_DAT_ManufacturedYear__c = System.today().addYears(-14),
                                        VRT_DAT_LastITV__c = System.today().addYears(-1)
                                       ));
                                
        //*p* Moto con fecha de itv de hace menos de 2 años   que NO  necesita ITV
        vehicles.add(new VRT_Vehicle__c(VRT_TXT_ExternalId__c = 'TestVeh'+8, 
                                        VRT_TXT_LicensePlate__c = 'TST000'+8,
                                        VRT_TXT_Brand__c = 'Bultaco', 
                                        VRT_SEL_VehicleType__c = 'Moto', 
                                        VRT_SEL_Status__c = 'Listo',  
                                        VRT_SEL_EnergyType__c = 'Diesel', 
                                        VRT_NUM_Passengers__c = 2,
                                        VRT_DAT_ManufacturedYear__c = System.today().addYears(-14),
                                        VRT_DAT_LastITV__c = System.today().addYears(-1)
                                       ));
        
        //*p*   2 vehiculos coche y moto  que No tienen fecha de fabricacion (el sistema lo permite y no deberia!!) y cuya fecha de
        // ITV supera 1 año el coche y 2 la MOTO POR LO QUE NECESITAN REVISIÓN
        vehicles.add(new VRT_Vehicle__c(VRT_TXT_ExternalId__c = 'TestVeh'+9, 
                                        VRT_TXT_LicensePlate__c = 'TST000'+9,
                                        VRT_TXT_Brand__c = 'Opel', 
                                        VRT_SEL_VehicleType__c = 'Coche', 
                                        VRT_SEL_Status__c = 'Listo',  
                                        VRT_SEL_EnergyType__c = 'Diesel', 
                                        VRT_NUM_Passengers__c = 5,
                                        VRT_DAT_LastITV__c = System.today().addYears(-1)
                                       ));
        vehicles.add(new VRT_Vehicle__c(VRT_TXT_ExternalId__c = 'TestVeh'+10, 
                                        VRT_TXT_LicensePlate__c = 'TST001'+0,
                                        VRT_TXT_Brand__c = 'Suzuki', 
                                        VRT_SEL_VehicleType__c = 'Moto', 
                                        VRT_SEL_Status__c = 'Listo',  
                                        VRT_SEL_EnergyType__c = 'Diesel', 
                                        VRT_NUM_Passengers__c = 2,
                                        VRT_DAT_LastITV__c = System.today().addYears(-2)
                                       ));
       
        insert vehicles;

    }

    // Método de prueba para VRT_CLS_CheckVehicleRevision
    @isTest
     static void testCheckVehicleRevision() {
        
        // Ejecuta el batch
        Test.startTest();
        VRT_CLS_CheckVehicleRevision batch = new VRT_CLS_CheckVehicleRevision();
        Database.executeBatch(batch);
        Test.stopTest();
        
        // Verifica que los vehículos sean marcados correctamente para inspección
        List<VRT_Vehicle__c> updatedVehicles = [SELECT Id FROM VRT_Vehicle__c WHERE VRT_FLG_NeedsInspection__c = true];        
        
        System.assertEquals(6, updatedVehicles.size(), 'Debe haber 6 vehiculos que necesitan inspeccion');

    }

}
public with sharing class VRT_CLS_LWC_GetRentFullData {
    
    @AuraEnabled
    public static VRT_Rental__c getRentFullData(String name){

        List<VRT_Rental__c> rents = [
            SELECT Name, VRT_DIV_TotalCost__c, VRT_LKP_Account__c,
            VRT_FLG_descuento__c, VRT_SEL_Status__c, VRT_SEL_PaymentStatus__c,
            VRT_DAT_InitialDate__c, VRT_DAT_FinalDate__c, VRT_LKP_Vehicle__c
            
            FROM VRT_Rental__c
            WHERE Name = :name
            LIMIT 1
        ];
        return !rents.isEmpty() ? rents[0] : null;
        //return null;
    }

    @AuraEnabled
    public static VRT_Vehicle__c getVehicleData(Id vehId){

        VRT_Vehicle__c veh = [
            SELECT Name, VRT_TXT_Model__c
            FROM VRT_Vehicle__c
            WHERE Id = :vehId
            LIMIT 1
        ];

        return veh;
    }

    @AuraEnabled
    public static Account getAccountData(Id accId){

        Account acc = [
            SELECT Name FROM Account WHERE Id = :accId LIMIT 1
        ];
        return acc;
    }
    
}
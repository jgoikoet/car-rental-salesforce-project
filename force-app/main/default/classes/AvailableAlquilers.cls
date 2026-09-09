
public with sharing class AvailableAlquilers {
    
    @AuraEnabled(cacheable=true)
    public static List<VRT_Rental__c> getAlquileresActivos(Id accId){
       
        return [
            SELECT Id, VRT_SEL_Status__c, Name, VRT_DIV_TotalCost__c, VRT_DAT_InitialDate__c, VRT_DAT_FinalDate__c
            FROM VRT_Rental__c
            WHERE VRT_LKP_Account__c = :accId
            AND VRT_SEL_Status__c IN ('Reservado', 'En curso', 'En_proceso_de _aprobacion') 
            WITH USER_MODE  
        ];  
    }
}
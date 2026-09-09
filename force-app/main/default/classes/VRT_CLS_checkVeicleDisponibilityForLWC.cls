public with sharing class VRT_CLS_checkVeicleDisponibilityForLWC {
    
    
    @AuraEnabled
    public static List<VRT_Vehicle__c> getDisponibleVehicles(Date fechaInicio, Date fechaFin){
        
        Set<Id> vehiculosOcupadosIds = new Set<Id>();

        List<VRT_Rental__c> alquileres = [
            SELECT Id, VRT_LKP_Vehicle__c FROM VRT_Rental__c
            WHERE VRT_DAT_InitialDate__c < :fechaFin
            AND VRT_DAT_FinalDate__c > :fechaInicio
        ];

        for(VRT_Rental__c rent : alquileres){
            vehiculosOcupadosIds.add(rent.VRT_LKP_Vehicle__c);
        }

        List<VRT_Vehicle__c> vehiculosDisponibles = [
            SELECT Id, VRT_SEL_VehicleType__c, VRT_SEL_Condition__c, VRT_TXT_Brand__c, VRT_TXT_Model__c
            FROM VRT_Vehicle__c
            WHERE VRT_FLG_Available__c = true
            AND Id NOT IN :vehiculosOcupadosIds
        ];

        return vehiculosDisponibles;

    }
}

/**
 * @author		jgoikoet (42 Urduliz)
 * @since		02/2023
 * @desc		Class for checking vehicle disponibility for the LWC console
 * @history		15/06/2026 - jgoikoet - Created class
 */
public with sharing class VRT_CLS_checkVeicleDisponibilityForLWC {
    
    /**
     * @desc	looks for available vehicles on the dates provided
     * @param	fechaInicio: rent start date
     * @param	fechaFin: rent finishing date
     * @return	vehiculosDisponibles: list of abailable vehicles
     */
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
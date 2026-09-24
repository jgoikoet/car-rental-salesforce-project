/**
 * @author		jgoikoet (42 Urduliz)
 * @since		02/2023
 * @desc		Searchs for vehicles wich contains the imput of the user 
 *              in their Brand, license plate or Model, on the searching LWC console
 *              'buscadorGlobalFlota' of the Home Tab
 * @history		02/07/2026 - jgoikoet - Created class
 */
public with sharing class VRT_CLS_LWC_SearchVehicles {
    
    /**
     * @desc	Searchs for the vehicles containing the provided parameter
     * @param	veh: string to search for
     * @return	vehList or Null: list of records found or null if nothing found
     */
    @AuraEnabled
    public static  List<VRT_Vehicle__c> searchVehicles(String veh){

        String clave = '%' + veh + '%';

        List<VRT_Vehicle__c> vehList = [

            SELECT Id, VRT_TXT_Brand__c, VRT_TXT_LicensePlate__c,VRT_TXT_Model__c
            FROM VRT_Vehicle__c
            WHERE VRT_TXT_Brand__c LIKE :clave
            OR VRT_TXT_LicensePlate__c LIKE :clave
            OR VRT_TXT_Model__c LIKE :clave
        ];
        
        if (!vehList.isEmpty()) {return vehList;}
        return null;
    }

    /**
     * @desc	Searchs and returns full data of required vehicle
     * @param	vehId: Id of required vehicle
     * @return	veh: instance of required vehicle
     */
    @AuraEnabled
    public static  VRT_Vehicle__c searchVehicle(Id vehId){

        VRT_Vehicle__c veh = [
            SELECT Id, VRT_TXT_Color__c, VRT_SEL_EnergyType__c, VRT_SEL_VehicleType__c,
            VRT_FLG_Available__c, VRT_SEL_Status__c, VRT_NUM_Mileage__c, VRT_SEL_Condition__c,
            VRT_TXT_Brand__c, VRT_TXT_Model__c, VRT_TXT_LicensePlate__c,
            VRT_NUM_Usage__c, VRT_NUM_Passengers__c, VRT_FLG_NeedsInspection__c
            FROM VRT_Vehicle__c
            WHERE Id = :vehId
            LIMIT 1
        ];

        return veh;
    }

}
/**
 * @author		jgoikoet (42 Urduliz)
 * @since		02/2023
 * @desc		Returns data from a s specifict rental, vehicle or account
 * @history		15/06/2026 - jgoikoet - Created class
 */
public with sharing class VRT_CLS_LWC_GetRentFullData {
    
    /**
     * @desc	gets the info of the requested rental
     * @param	name: Name of the rent 
     * @return	rents: a instance of the requested rental
     */
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
    }

    /**
     * @desc	gets the info of the required vehicle
     * @param	vehId: required vehicle´s Id
     * @return	veh: a instance of the requested vehicle
     */
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

    /**
     * @desc	gets the info of the required account
     * @param	vehId: required account´s Id
     * @return	acc: a instance of the requested account
     */
    @AuraEnabled
    public static Account getAccountData(Id accId){

        Account acc = [
            SELECT Name FROM Account WHERE Id = :accId LIMIT 1
        ];
        return acc;
    }
}
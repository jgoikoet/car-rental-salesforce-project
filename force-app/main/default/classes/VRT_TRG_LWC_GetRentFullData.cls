/**
 * @author		jgoikoet (42 Urduliz)
 * @since		02/2023
 * @desc		Returns data from a s specifict rental by its name
 * @history		15/06/2026 - jgoikoet - Created class
 *              20/07/2026 - jgoikoet - Not in use for the moment
 */
public with sharing class VRT_TRG_LWC_GetRentFullData {
    
    public static VRT_Rental__c getRentFullData(String name){

        VRT_Rental__c rent = [
            SELECT Name, VRT_DIV_TotalCost__c, VRT_LKP_Account__c,
            VRT_FLG_descuento__c, VRT_SEL_Status__c, VRT_SEL_PaymentStatus__c,
            VRT_DAT_InitialDate__c, 	VRT_DAT_FinalDate__c, VRT_LKP_Vehicle__c,
            CreatedById, LastModifiedById
            FROM VRT_Rental__c
            WHERE Name = :name
            LIMIT 1
        ];
        return rent;
    }

}
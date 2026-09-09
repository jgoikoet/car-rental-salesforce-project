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
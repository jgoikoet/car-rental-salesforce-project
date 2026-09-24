/**
 * @author		jgoikoet (42 Urduliz)
 * @since		02/2023
 * @desc		Class for create a new rental from the LWC 'alquilerConsole'
 * @history		15/06/2026 - jgoikoet - Created class
 */
public with sharing class VRT_CLS_LWC_CreateNewRent {
    
    /**
     * @desc	Inserts a new rent record
     * @param	inicio: start date
     * @param	fin: finish date
     * @param	accountId: Id of the related account
     * @param	vehicleID: Id of the related vehicle
     * @param	estadoPago: payment status
     * @param	coste: cost of the rental
     * @return	Boolean: True if the insert succcess
     */
    @AuraEnabled//(cacheable=true)
    public static Boolean createNewRent(
        Date inicio,
        Date fin,
        Id accountId,
        Id vehicleId,
        Boolean estadoPago,
        Decimal coste
    ){   
        String pago;
        if(estadoPago){pago = 'Pagado';}
        else {pago = 'Pendiente';}

        VRT_Rental__c newRent = new VRT_Rental__c();

        newRent.VRT_DAT_InitialDate__c = inicio;
        newRent.VRT_DAT_FinalDate__c = fin;
        newRent.VRT_LKP_Account__c = accountId;
        newRent.VRT_LKP_Vehicle__c = vehicleId;
        newRent.VRT_SEL_PaymentStatus__c = pago;
        newRent.VRT_SEL_Status__c = 'Reservado';
        newRent.VRT_DIV_TotalCost__c = coste;

        try {
            insert newRent;
            return true;
        } catch (DmlException e) {
            throw new AuraHandledException('Fallo en Apex: ' + e.getMessage());
        }
    }
}
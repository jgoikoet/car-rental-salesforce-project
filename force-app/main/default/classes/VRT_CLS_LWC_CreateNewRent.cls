public with sharing class VRT_CLS_LWC_CreateNewRent {
    

    @AuraEnabled//(cacheable=true) no se puede poner si vamos a hacer insert
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
            System.debug('Error al insertar: ' + e.getMessage());
            throw new AuraHandledException('Fallo en Apex: ' + e.getMessage());
            //return false;
        }
    }
}
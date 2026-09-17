public with sharing class VRT_CLS_LWC_CalculateTotalCost {

    
    @AuraEnabled(cacheable=true)
    public static Decimal calculateTotalCost(Date inicio, Date fin,
        String tipoVehiculo,Id accountId){

        //system.debug('----------Calculando coste-----------');
        
        Decimal finalCost = 0;

        while (inicio <= fin){

            Integer month = inicio.month();

            switch on month{
                    when  1, 4, 7, 8, 12 {
                        if (tipoVehiculo == 'Coche') {finalCost += 150;}
                        else{finalCost += 100;}
                    }
                    when 2, 5, 6, 9 {
                        if (tipoVehiculo == 'Coche') {finalCost += 100;}
                        else{finalCost += 80;}
                    }
                    when else {
                        if (tipoVehiculo == 'Coche') {finalCost += 80;}
                        else{finalCost += 60;}
                    }
                }
                inicio = inicio.addDays(1);

        }
        
        
        return finalCost;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean calculateDiscount(Id acc){
        
        Integer totalRents = [
            SELECT COUNT() FROM VRT_Rental__c WHERE VRT_LKP_Account__c = :acc
            AND VRT_DAT_FinalDate__c = LAST_N_DAYS:365
            AND VRT_SEL_Status__c = 'Completado'
        ];

        system.debug('TotlRents: ' + totalRents);

        if (totalRents > 2) {return true;}
        return false;
    }

    
}
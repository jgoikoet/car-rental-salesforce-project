/**
 * @author		jgoikoet (42 Urduliz)
 * @since		02/2023
 * @desc		Calculates the total cost for a new rent in the LWC 'alquilerConsole'
 * @history		15/06/2026 - jgoikoet - Created class
 */
public with sharing class VRT_CLS_LWC_CalculateTotalCost {

    /**
     * @desc	Counts the number of rents for each account
     * @param	inicio: start date
     * @param	fin: finish date
     * @param	tipoVehiculo: type of vehicle 'coche' or 'Moto'
     * @param	accountId: Id of the related account
     * @return	finalCost: final ammount
     */
    @AuraEnabled(cacheable=true)
    public static Decimal calculateTotalCost(Date inicio, Date fin,
        String tipoVehiculo,Id accountId){
       
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

    /**
     * @desc	Calculates discount if the customer has 3 or more completed rents in the last year
     * @param	acc: Id of the account
     * @return	Boolean: True or false depending in the number of completed rents last year
     */
    @AuraEnabled(cacheable=true)
    public static Boolean calculateDiscount(Id acc){
        
        Integer totalRents = [
            SELECT COUNT() FROM VRT_Rental__c WHERE VRT_LKP_Account__c = :acc
            AND VRT_DAT_FinalDate__c = LAST_N_DAYS:365
            AND VRT_SEL_Status__c = 'Completado'
        ];

        if (totalRents > 2) {return true;}
        return false;
    }  
}
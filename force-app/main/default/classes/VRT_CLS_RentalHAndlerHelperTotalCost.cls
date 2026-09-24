/**
 * @author		jgoikoet (42 Urduliz)
 * @since		02/2023
 * @desc		Class for calculate the costs of rents
 * @history		04/04/2026 - jgoikoet - Created class
 * 				18/07/2026 - jgoikoet - Added'filterRepeated' method
 *              07/09/2026 - jgoikoet - Refactoring deleting debug messages and adding apexDoc for methods
 */
public with sharing class VRT_CLS_RentalHAndlerHelperTotalCost {

    /**
     * @desc	Counts the number of rents for each account
     * @param	accounts: Set of accounts to chek
     * @param	alquileres: Set of rents to check
     * @return	alquileresPorCuenta: Map with the number of rents (value) for each account(key)
     */
    private Map<Id, Integer> alquilersLastYear(Set<Id> accounts, List<VRT_Rental__c> alquileres){

        Map<Id, Integer> alquileresPorCuenta = new Map<Id,Integer>();

        for (Id account : accounts) { alquileresPorCuenta.put(account, 0);}

        for (VRT_Rental__c alquiler : alquileres){
            alquileresPorCuenta.put(alquiler.VRT_LKP_Account__c, alquileresPorCuenta.get(alquiler.VRT_LKP_Account__c) + 1);
        }

        return alquileresPorCuenta;
    } 

    /**
     * @desc	Calculate the value of the rent based on the number of days,
     *          time of the year, type of vehicle and customer loyalty
     * @param	triggerNew: List of new rents
     */
    public  void calculateCost(List<VRT_Rental__c> triggerNew){

        Set<Id> vehicles = new Set<Id>();
        Set<Id> accounts = new Set<Id>();
        
        for(VRT_Rental__c rent : triggerNew){
            vehicles.add(rent.VRT_LKP_Vehicle__c);
            accounts.add(rent.VRT_LKP_Account__c);
        }

        Map<Id, VRT_Vehicle__c> vehiclesType = new Map<Id, VRT_Vehicle__c>(
            [SELECT Id, VRT_SEL_VehicleType__c FROM VRT_Vehicle__c WHERE Id IN :vehicles]);

        List<VRT_Rental__c> alquileres = [SELECT Id, VRT_LKP_Account__c FROM VRT_Rental__c
            WHERE VRT_LKP_Account__c IN :accounts
            AND VRT_DAT_FinalDate__c = LAST_N_DAYS:365
            AND VRT_SEL_Status__c = 'Completado'];
            
        Map<Id, Integer> alquileresPorCuenta = alquilersLastYear(accounts, alquileres);

        for(VRT_Rental__c rent : triggerNew){
            Decimal finalCost = 0;
            Date initialDate = rent.VRT_DAT_InitialDate__c;
            Date finalDate = rent.VRT_DAT_FinalDate__c;
            String vehicleType = vehiclesType.get(rent.VRT_LKP_Vehicle__c).VRT_SEL_VehicleType__c;
            
            while (initialDate <= finalDate){
            
                Integer month = initialDate.month();

                switch on month{
                    when  1, 4, 7, 8, 12 {
                        if (vehicleType == 'Coche') {finalCost += 150;}
                        else{finalCost += 100;}
                    }
                    when 2, 5, 6, 9 {
                        if (vehicleType == 'Coche') {finalCost += 100;}
                        else{finalCost += 80;}
                    }
                    when else {
                        if (vehicleType == 'Coche') {finalCost += 80;}
                        else{finalCost += 60;}
                    }
                }
                initialDate = initialDate.addDays(1);
            }
            if (alquileresPorCuenta.get(rent.VRT_LKP_Account__c) > 2){
                finalCost -= (finalCost * 0.05);
                rent.VRT_FLG_descuento__c = True;
            }
            rent.VRT_DIV_TotalCost__c = finalCost;
        } 
    }
}
public with sharing class VRT_CLS_CheckVehicleDataDisponibility {
    
    public static void checkDisponibility(List<VRT_Rental__c> newRentals){

        //system.debug('A ver si inserta!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        
        // OJO!!!!! Si se insertan varios registros a la vez, habria que ver que no se solapan entre
        // ellos, 

        Set<Id> vehiclesInNewRentals =new  Set<Id>();
        Map<Id, List<VRT_Rental__c>> oldRentalsByVehicle = new Map<Id, List<VRT_Rental__c>>();

        for (VRT_Rental__c rent : newRentals) { 
            vehiclesInNewRentals.add(rent.VRT_LKP_Vehicle__c);
        }

        List<VRT_Rental__c> sameVehicleOldRentals = [
            SELECT Id, VRT_LKP_Vehicle__c, VRT_DAT_InitialDate__c, VRT_DAT_FinalDate__c
            FROM VRT_Rental__c
            WHERE VRT_LKP_Vehicle__c IN :vehiclesInNewRentals
            AND VRT_SEL_Status__c != 'Cancelado'
        ];
        
        for(VRT_Rental__c oldRental : sameVehicleOldRentals){

            if (!oldRentalsByVehicle.containsKey(oldRental.VRT_LKP_Vehicle__c)){
                oldRentalsByVehicle.put(oldRental.VRT_LKP_Vehicle__c, new List<VRT_Rental__c>());
            }
            oldRentalsByVehicle.get(oldRental.VRT_LKP_Vehicle__c).add(oldRental);
        }

        for(VRT_Rental__c newRental : newRentals){
            if (oldRentalsByVehicle.containsKey (newRental.VRT_LKP_Vehicle__c)){
                List<VRT_Rental__c> vehicleRentals = oldRentalsByVehicle.get(newRental.VRT_LKP_Vehicle__c);
                for(VRT_Rental__c rent : vehicleRentals){
                    if (newRental.VRT_DAT_InitialDate__c < rent.VRT_DAT_FinalDate__c &&
                    newRental.VRT_DAT_FinalDate__c > rent.VRT_DAT_InitialDate__c){
                        newRental.addError('Este vehículo no está disponible en esas fechas');
                    }
                }
            }
        }
    }
}
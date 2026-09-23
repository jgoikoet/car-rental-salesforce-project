/**
 * @author		jgoikoet (42 Urduliz)
 * @since		02/2023
 * @desc		Class for checking vehicle disponibility
 * @history		04/04/2026 - jgoikoet - Created class
 * 				18/07/2026 - jgoikoet - Added'filterRepeated' method
 *              07/09/2026 - jgoikoet - Refactoring deleting debug messages and adding apexDoc for methods
 */
public with sharing class VRT_CLS_CheckVehicleDataDisponibility {
    
    /**
     * @desc	Checks for Vehicles Overlapping by Date. If so selects the one who offers the most money
     * @param	sameVehicleList: List of rents to insert
     * @return	sameVehicleList: Filtered list
     */
    private static List<VRT_Rental__c> filterRepeated(List<VRT_Rental__c> sameVehicleList){

        Integer l = sameVehicleList.size();
        
        system.debug('Tamaño lista: '+ l);
        for (Integer j = 0; j < l - 1; j++){
            for(integer i = j + 1; i < l; i++)
            {
                //system.debug('j = '+ j);
                //system.debug('jos de puta');
                if(sameVehicleList[j].VRT_DAT_InitialDate__c < sameVehicleList[i].VRT_DAT_FinalDate__c &&
                    sameVehicleList[j].VRT_DAT_FinalDate__c > sameVehicleList[i].VRT_DAT_InitialDate__c){

                        //system.debug(sameVehicleList[j].VRT_DIV_TotalCost__c +' merda ' + sameVehicleList[i].VRT_DIV_TotalCost__c);
                        
                        if (sameVehicleList[j].VRT_DIV_TotalCost__c == sameVehicleList[i].VRT_DIV_TotalCost__c){
                            sameVehicleList[i].addError('El vehiculo del alquiler se solapa en fechas con otro alquiler de la misma lista');
                            //system.debug('Costes Iguales');
                            sameVehicleList.remove(i);                            
                        }
                        else if(sameVehicleList[j].VRT_DIV_TotalCost__c > sameVehicleList[i].VRT_DIV_TotalCost__c){
                            //system.debug('Vale mas el primero');
                            sameVehicleList[i].addError('El vehiculo del alquiler se solapa en fechas con otro alquiler de la misma lista');
                            sameVehicleList.remove(i);         
                           
                        }
                        else{
                            //system.debug('Vale mas el segundo');
                            sameVehicleList[j].addError('El vehiculo del alquiler se solapa en fechas con otro alquiler de la misma lista');
                            sameVehicleList.remove(j); 
                        }
                        l--;
                        j = - 1;
                        break;
                }
            }
        }

        return sameVehicleList;

    }


    /**
     * @desc	Checs for rentals wih the same vehicle. If so send them to the filterRepeated method for filtering
     * @param	newRentals: List of rents to insert
     * @return	filteredRentals: Filtered list
     */
    private static List<VRT_Rental__c> selectFromRepeated(List<VRT_Rental__c> newRentals){

        Map<Id, List<VRT_Rental__c>> rentalsByVehicle = new Map<Id, List<VRT_Rental__c>>();
        List<VRT_Rental__c> filteredRentals = new List<VRT_Rental__c>();

        //Agrupo rentals por vehiculo
        for (VRT_Rental__c rent : newRentals) {
            if (!rentalsByVehicle.containsKey(rent.VRT_LKP_Vehicle__c)) {
                rentalsByVehicle.put(rent.VRT_LKP_Vehicle__c, new List<VRT_Rental__c>());
            }
            rentalsByVehicle.get(rent.VRT_LKP_Vehicle__c).add(rent);
        }


        for (Id vehId : rentalsByVehicle.keySet()){

            List<VRT_Rental__c> sameVehicleRents = rentalsByVehicle.get(vehId);      

            if (sameVehicleRents.size() > 1){
                sameVehicleRents = filterRepeated(sameVehicleRents);
            }
            for (VRT_Rental__c rent : sameVehicleRents){
                filteredRentals.add(rent);
            }
        }

        return filteredRentals;

    }
    
    /**
     * @desc	After filtering Overlapping rents in newRentals, checks overlapping with already inserted records
     * @param	newRentals: List of rents to insert
     */
    public static void checkDisponibility(List<VRT_Rental__c> newRentals){
            
        newRentals = selectFromRepeated(newRentals);
        
        for(VRT_Rental__c rent : newRentals){
            system.debug('coste = ' + rent.VRT_DIV_TotalCost__c + 
            '     del ' + rent.VRT_DAT_InitialDate__c + ' al ' + rent.VRT_DAT_FinalDate__c);
        }

        system.debug ('Chekeando disponibilidad');

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
/**
 * @author		AMADRIDN (NTT Data)
 * @since		04/04/2024
 * @desc		Helper class for trigger VRT_TRG_Rental
 * @history		04/04/2024 - AMADRIDN - Created class
 * 				08/04/2024 - AMADRIDN - Added comments and fixed calculateCondition 
 */
public class VRT_TRG_RentalHandlerHelper {

    /**
     * @desc	Calculate total cost of rentals
     * @param	triggerNew: list of vehicles inserted
     */ 
    public static void calculateTotalCost(List<VRT_Rental__c> triggerNew) { 
        
        VRT_CLS_RentalHAndlerHelperTotalCost cost = new VRT_CLS_RentalHAndlerHelperTotalCost();

        system.debug('Me caguen Soria!!!!!!');
        //VRT_CLS_CheckVehicleDataDisponibility.checkDisponibility(triggerNew);
        cost.calculateCost(triggerNew);
            
    }

    /**
     * @desc	Update the vehicle condition based on number of uses
     * @param	triggerNew: list of vehicles inserted
     */ 
     public static void updateConditionVehicle(List<VRT_Rental__c> triggerNew) {
        Set<Id> vehicleIds = new Set<Id>(); 
        for(VRT_Rental__c rental : triggerNew){
            // Guardamos los ids de los alquileres que tengan el vehículo relleno!!!! AHORA DEBERIAN SER TODOS!!
            if(rental.VRT_LKP_Vehicle__c != null) {
                vehicleIds.add(rental.VRT_LKP_Vehicle__c);
            }
        }
        
        // Obtenemos los vehículos y añadimos un Uso y calculamos la condición
        List<VRT_Vehicle__c> vehicles = [SELECT Id,
                                          		 VRT_NUM_Usage__c,
                                            	 VRT_SEL_Condition__c
                                          FROM VRT_Vehicle__c
                                          WHERE Id IN :vehicleIds]; 
        if(vehicles != null && vehicles.size() > 0) {
            for(VRT_Vehicle__c vehicle : vehicles) {
                vehicle.VRT_NUM_Usage__c = vehicle.VRT_NUM_Usage__c != null? vehicle.VRT_NUM_Usage__c + 1 : 0;
                vehicle.VRT_SEL_Condition__c = calculateCondition(vehicle.VRT_NUM_Usage__c.intValue());
            }
            update vehicles;
        }
    }

    /**
     * @desc	Calculate de penalty for late devolution
     * @param	triggerNew: Final date of the rental 
     */ 
    private static void calculatePunish(List<VRT_Rental__c>  punishAlquilers, Map<Id, String> vehicleType){

        Date today = Date.today();

        for(VRT_Rental__c rental : punishAlquilers){

            Date firstPenalDate = rental.VRT_DAT_FinalDate__c.addDays(1);
            Decimal penalty = 0;
            String rentalVehicleType = vehicleType.get(rental.VRT_LKP_Vehicle__c);

            while (firstPenalDate <= today){

                Integer month = firstPenalDate.month();

                switch on month{
                    when  1, 4, 7, 8, 12 {
                        if (rentalVehicleType == 'Coche') {penalty += 187.5;}
                        else{penalty += 125;}
                    }
                    when 2, 5, 6, 9 {
                        if (rentalVehicleType == 'Coche') {penalty += 125;}
                        else{penalty += 100;}
                    }
                    when else {
                        if (rentalVehicleType == 'Coche') {penalty += 100;}
                        else{penalty += 75;}
                    }
                }
                firstPenalDate = firstPenalDate.addDays(1);
            }
            rental.VRT_DIV_penalty__c = penalty;
            rental.VRT_DIV_TotalCost__c += penalty;
        }     
    }
    
    /**
     * @desc	Update the vehicle mileage based on rental duration and impose a penalty if necesary
     * @param	oldMap: map with rentals in old state 
     * @param	newMap: map with rentals in new state 
     */
    public static void updateVehicleRentalCompleted(Map<Id, VRT_Rental__c> oldMap, Map<Id, VRT_Rental__c> newMap) {
		Map<Id, VRT_Rental__c> completedVehRentals = new Map<Id, VRT_Rental__c>();
        List<VRT_Rental__c>  punishAlquilers = new List<VRT_Rental__c>();
        List<VRT_Rental__c>  approvedAlquilers = new List<VRT_Rental__c>();
        
        for (Id rentalId : newMap.keySet()) {
            VRT_Rental__c oldRental = oldMap.get(rentalId);
            VRT_Rental__c newRental = newMap.get(rentalId);
            
            // Cambio de estado de En curso a Completado
            if(oldRental.VRT_SEL_Status__c == 'En curso' && newRental.VRT_SEL_Status__c == 'Completado' && newRental.VRT_LKP_Vehicle__c != null) {
                completedVehRentals.put(newRental.VRT_LKP_Vehicle__c, newRental);
                
                // Chequeo si hay retraso en la devolución
                if (newRental.VRT_DAT_FinalDate__c < Date.today()){
                    VRT_Rental__c rent = new VRT_Rental__c(
                        Id = newRental.Id,
                        VRT_DAT_FinalDate__c = newRental.VRT_DAT_FinalDate__c,
                        VRT_LKP_Vehicle__c = newRental.VRT_LKP_Vehicle__c,
                        VRT_DIV_TotalCost__c = newRental.VRT_DIV_TotalCost__c
                    );
                    punishAlquilers.add(rent);
                }
            } else if(oldRental.VRT_SEL_Status__c == 'En_proceso_de _aprobacion' && newRental.VRT_SEL_Status__c == 'Reservado' && newRental.VRT_LKP_Vehicle__c != null){
                approvedAlquilers.add(newRental);
            }
        }      
        if (!approvedAlquilers.isEmpty()){
            updateConditionVehicle(approvedAlquilers);
        }

        // Si algún alquiler se completó, actualizamos el kilometraje del vehículo asociado basado en los días que duró el alquiler x 200km
        if(completedVehRentals.keyset().size() > 0) {
            
            Map<Id, String> vehicleType = new Map<Id, String>();

            List<VRT_Vehicle__c> vehicles = [SELECT Id,
                                                    VRT_NUM_Mileage__c,
                                                    VRT_SEL_VehicleType__c
                                             FROM VRT_Vehicle__c
                                             WHERE Id IN :completedVehRentals.keyset()];
            if(vehicles != null && vehicles.size() > 0) {
                
                for(VRT_Vehicle__c vehicle : vehicles) {
                    vehicle.VRT_NUM_Mileage__c = vehicle.VRT_NUM_Mileage__c + (completedVehRentals.get(vehicle.Id).VRT_FOR_Duration__c * 200);
                    vehicleType.put(vehicle.Id, vehicle.VRT_SEL_VehicleType__c);
                }
                update vehicles;  
            }
            if (punishAlquilers.size() > 0) {
                calculatePunish(punishAlquilers, vehicleType);
                update punishAlquilers;
            }
        }
    }

    /**
     * @desc	Calculate vehicle condition string based of number of uses
     * @param	numberOfUses: number of vehicle uses
     * @return	conditionResult: string with resulted condition
     */
    public static String calculateCondition(Integer numberOfUses) {
        String conditionResult = 'Deplorable';
        
        if(numberOfUses <= 50) {
            conditionResult = 'Recién fabricado';
        } else if(numberOfUses <= 200) {
            conditionResult = 'Casi nuevo';
        } else if(numberOfUses <= 500) {
            conditionResult = 'Algo desgastado';
        } else if(numberOfUses <= 1000) {
            conditionResult = 'Bastante desgastado';
        } else if (numberOfUses > 1000) {
            conditionResult = 'Deplorable';
        }   
        return conditionResult;
    }
}
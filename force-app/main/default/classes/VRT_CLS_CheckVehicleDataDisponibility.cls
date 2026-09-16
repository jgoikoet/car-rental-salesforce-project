public with sharing class VRT_CLS_CheckVehicleDataDisponibility {
    
    private static List<VRT_Rental__c> filterRepeated(List<VRT_Rental__c> sameVehicleList){


        //*p* si dos alquileres de la lista se solapan en fechas dejamos el que da mas dinerin

        
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
    
    private static List<VRT_Rental__c> selectFromRepeated(List<VRT_Rental__c> newRentals){

        Map<Id, List<VRT_Rental__c>> rentalsByVehicle = new Map<Id, List<VRT_Rental__c>>();
        List<VRT_Rental__c> filteredRentals = new List<VRT_Rental__c>();

        for (VRT_Rental__c rent : newRentals) {
            if (!rentalsByVehicle.containsKey(rent.VRT_LKP_Vehicle__c)) {
                rentalsByVehicle.put(rent.VRT_LKP_Vehicle__c, new List<VRT_Rental__c>());
            }
            rentalsByVehicle.get(rent.VRT_LKP_Vehicle__c).add(rent);
        }

        for (Id vehId : rentalsByVehicle.keySet()){

            system.debug('Lista antes en bucle---------------------------------------------------');
            List<VRT_Rental__c> sameVehicleRents = rentalsByVehicle.get(vehId);
            VRT_Vehicle__c vehicle =[SELECT Name FROM VRT_Vehicle__c WHERE Id = :sameVehicleRents[0].VRT_LKP_Vehicle__c];       

            for(VRT_Rental__c rent : sameVehicleRents){
                            
                system.debug(vehicle.Name + ' coste = ' + rent.VRT_DIV_TotalCost__c + 
                '     del ' + rent.VRT_DAT_InitialDate__c + ' al ' + rent.VRT_DAT_FinalDate__c);       
            }

            //filterRepeated(sameVehicleRents);
            if (sameVehicleRents.size() > 1){
                sameVehicleRents = filterRepeated(sameVehicleRents);
                //rentalsByVehicle.put(vehId, sameVehicleRents);
            }
            system.debug('Lista despues en bucle------------------------------------------------');
            for (VRT_Rental__c rent : sameVehicleRents){
                system.debug(vehicle.Name + ' coste = ' + rent.VRT_DIV_TotalCost__c + 
                '     del ' + rent.VRT_DAT_InitialDate__c + ' al ' + rent.VRT_DAT_FinalDate__c);
                filteredRentals.add(rent);
            }
            system.debug('**********************************************************************************');
        }

        system.debug('Lista Final filteredRentals-------------------------------------');
        for(VRT_Rental__c rent : filteredRentals){
            system.debug('coste = ' + rent.VRT_DIV_TotalCost__c + 
            '     del ' + rent.VRT_DAT_InitialDate__c + ' al ' + rent.VRT_DAT_FinalDate__c);
        }
        return filteredRentals;

    }
    
    public static void checkDisponibility(List<VRT_Rental__c> newRentals){

        //system.debug('A ver si inserta!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        
        // OJO!!!!! Si se insertan varios registros a la vez, habria que ver que no se solapan entre
        // ellos, 

        // List<VRT_Rental__c> filteredRentals = new List<VRT_Rental__c>();
        // filteredRentals = selectFromRepeated(newRentals);
        // system.debug('Lista Final filteredRentals ultima posicion y ole-------------------------------------');
        // for(VRT_Rental__c rent : filteredRentals){
        //     system.debug('coste = ' + rent.VRT_DIV_TotalCost__c + 
        //     '     del ' + rent.VRT_DAT_InitialDate__c + ' al ' + rent.VRT_DAT_FinalDate__c);
        // }

        
        newRentals = selectFromRepeated(newRentals);
        system.debug('Lista Final filteredRentals ultima posicion y ole-------------------------------------');
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
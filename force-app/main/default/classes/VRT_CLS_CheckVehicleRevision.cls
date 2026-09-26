/**
 *  @author		AMADRIDN (NTT Data)
 * @since		04/04/2024
 * @desc		Clase para comprobar revisión ITV en vehículos
 * @history		18/04/2024 - AMADRIDN - Created class
 *              02/06/20 - jgoikoet - The range of cases is expanding
 */
public class VRT_CLS_CheckVehicleRevision implements Database.Batchable<sObject> {
    
    public VRT_CLS_CheckVehicleRevision() {}
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name, VRT_DAT_ManufacturedYear__c, VRT_DAT_LastITV__c, VRT_FLG_NeedsInspection__c, VRT_SEL_VehicleType__c FROM VRT_Vehicle__c WHERE VRT_FLG_NeedsInspection__c = false');
    }
    
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        
        Integer thisYear = Date.today().year();
        Integer yearsPassedFromFabrication;
        
        for(SObject s : scope) {
            
            VRT_Vehicle__c veh = (VRT_Vehicle__c) s;

            system.debug('Vehículo: '+veh.Name);
            if(veh.VRT_DAT_ManufacturedYear__c != null){

                // Obtenemos los años transcurridos desde que se fabricó
                yearsPassedFromFabrication = thisYear -  veh.VRT_DAT_ManufacturedYear__c.year();

                //*p* A car with less than 4 years does not nedd ITV so it passes to the next vehicle
                if (veh.VRT_SEL_VehicleType__c == 'Coche' && yearsPassedFromFabrication < 4){
                    continue;
                }
                //*p* A motocicle with less than 4 years does not nedd ITV so it passes to the next vehicle
                else if (veh.VRT_SEL_VehicleType__c == 'Moto' && yearsPassedFromFabrication < 3){
                    continue;
                }
            }

            // *p* Calculations when the vehicle has a previous ITV date
            if (veh.VRT_DAT_LastITV__c != null){

                //*p* Gettin years since last ITV
                Integer yearsPassedFromLastITV = thisYear - veh.VRT_DAT_LastITV__c.year();

                //*p* Calculations if, in addition to any ITV, the vehicle has a date of manufacture
                if(veh.VRT_DAT_ManufacturedYear__c != null){

                    if(veh.VRT_SEL_VehicleType__c == 'Coche') {

                        //*p* If it was manufactured less than 10 years ago
                        if(yearsPassedFromFabrication <= 10){

                            //*p* 2 or more years from the last ITV
                            if (yearsPassedFromLastITV >= 2){
                                veh.VRT_FLG_NeedsInspection__c = true;
                                continue;
                            }
                            //*p* Less than 2 years from the last ITV
                            else{
                                continue;
                            }
                        }
                        //*p* If it was manufactured more than 10 years ago
                        else{
                            if(yearsPassedFromLastITV >= 1){
                                veh.VRT_FLG_NeedsInspection__c = true;
                                continue;
                            }
                        }
                    }
                    //*p* It's a motorcycle and it's been less than 2 years since the lastITV
                    else if(veh.VRT_SEL_VehicleType__c == 'Moto' && yearsPassedFromLastITV < 2){
                        continue;
                    }
                }
                //*p* If there is no year of manufacture (the system allows for this!!)
                //*p* If it has been more than a year since the last ITV and it is a car
                if(yearsPassedFromLastITV >= 1 && veh.VRT_SEL_VehicleType__c == 'Coche'){
                        veh.VRT_FLG_NeedsInspection__c = true;
                        continue;
                }
                //*p* If it has been more than 2 yeasr since the last ITVn and it is a Motorcycle
                if(yearsPassedFromLastITV >= 2 && veh.VRT_SEL_VehicleType__c == 'Moto'){
                        veh.VRT_FLG_NeedsInspection__c = true;
                        continue;
                }
            
            }

            //*p* Vehicles without last ITV data
            if(veh.VRT_DAT_ManufacturedYear__c == null){continue;}
          
            // Si es un coche, comprueba que hayan pasado 4 años
            if(veh.VRT_SEL_VehicleType__c == 'Coche' && yearsPassedFromFabrication >= 4) {
                veh.VRT_FLG_NeedsInspection__c = true;
            }
            // Si es una moto, comprueba que hayan pasado 3 años
            else if(veh.VRT_SEL_VehicleType__c == 'Moto' && yearsPassedFromFabrication >= 3) {
                veh.VRT_FLG_NeedsInspection__c = true;
            } 
        }      
        update scope;
    }
    
    public void finish(Database.BatchableContext bc) {
        
    }
    
}
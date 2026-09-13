/**
 *  @author		AMADRIDN (NTT Data)
 * @since		04/04/2024
 * @desc		Clase para comprobar revisión ITV en vehículos
 * @history		18/04/2024 - AMADRIDN - Created class
 */
public class VRT_CLS_CheckVehicleRevision implements Database.Batchable<sObject> {
    
    public VRT_CLS_CheckVehicleRevision() {}
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name, VRT_DAT_ManufacturedYear__c, VRT_DAT_LastITV__c, VRT_FLG_NeedsInspection__c, VRT_SEL_VehicleType__c FROM VRT_Vehicle__c WHERE VRT_FLG_NeedsInspection__c = false');
    }
    
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        
        //system.debug('Vamooooooooos!!!!!!!!!!!!!!');
        
        // Obtenemos el año actual
        Integer thisYear = Date.today().year();
        Integer yearsPassedFromFabrication;
        
        for(SObject s : scope) {
            
            VRT_Vehicle__c veh = (VRT_Vehicle__c) s;

            system.debug('Vehículo: '+veh.Name);
            if(veh.VRT_DAT_ManufacturedYear__c != null){

                // Obtenemos los años transcurridos desde que se fabricó
                yearsPassedFromFabrication = thisYear -  veh.VRT_DAT_ManufacturedYear__c.year();

                //*p* Si es coche y tiene menos de 4 años no necesita ITV y pasamos al siguiente vehiculo
                if (veh.VRT_SEL_VehicleType__c == 'Coche' && yearsPassedFromFabrication < 4){
                    system.debug('Fecha Fabricacion  : '+ veh.VRT_DAT_ManufacturedYear__c);
                    system.debug('Este coche tiene menos de 4 años, NO NECESITA ITV');
                    system.debug('\n *******************************************************************\n');
                    continue;
                }
                //*p* Si es moto y tiene menos de 3 años no necesita ITV y pasamos al siguiente vehiculo
                else if (veh.VRT_SEL_VehicleType__c == 'Moto' && yearsPassedFromFabrication < 3){
                    system.debug('Fecha Fabricacion  : '+ veh.VRT_DAT_ManufacturedYear__c);
                    system.debug('Esta Moto tiene menos de 3 años, NO NECESITA ITV');
                    system.debug('\n *******************************************************************\n');
                    continue;
                }
            }

            // *p* Calculos si el vehiculo ya tiene alguna ITV realizada
            if (veh.VRT_DAT_LastITV__c != null){
                system.debug('Fecha ultima ITV: '+ veh.VRT_DAT_LastITV__c);

                //*p* Obtenemos Los años transcurridos desde la ultima ITV
                Integer yearsPassedFromLastITV = thisYear - veh.VRT_DAT_LastITV__c.year();

                //*p* Calculos si ademas de alguna ITV, el vehiculo tiene fecha de fabricación
                if(veh.VRT_DAT_ManufacturedYear__c != null){
                    system.debug('Fecha Fabricacion  : '+ veh.VRT_DAT_ManufacturedYear__c);

                    //*p* Si es coche
                    if(veh.VRT_SEL_VehicleType__c == 'Coche') {
                        system.debug('Tipo de vehiculo: coche');

                        //*p* Si hace menos de 10 años que se fabricó
                        if(yearsPassedFromFabrication <= 10){

                            //*p* Si han pasado 2 o mas años desde la ultima ITV
                            if (yearsPassedFromLastITV >= 2){
                                system.debug('Este coche tiene 10 o menos años y han pasado 2 o mas años desde la ultima ITV');
                                veh.VRT_FLG_NeedsInspection__c = true;
                                system.debug('Se actualiza el campo de necesita ITV a TRUE'
                                + '\n *******************************************************************\n');
                                continue;
                            }
                            //*p*Si han pasado menos de 2 años desde la ultima ITV
                            else{
                                system.debug('Este coche tiene 10 o menos años y han pasado menos de 2 años desde la ultima ITV');
                                system.debug('NO NECESITA ITV'
                                + '\n *******************************************************************\n');
                                continue;
                            }
                        }
                        //*p* SI hace mas de 10 años que se fabricó
                        else{
                            if(yearsPassedFromLastITV >= 1){
                                system.debug('Este coche tiene mas de 10  años y ha pasado 1 año o mas desde la ultima ITV');
                                veh.VRT_FLG_NeedsInspection__c = true;
                                system.debug('Se actualiza el campo de necesita ITV a TRUE'
                                + '\n *******************************************************************\n');
                                continue;
                            }
                        }
                    }
                    //*p* Si es una moto y han pasado menos de 2 años desde la ultima ITV
                    else if(veh.VRT_SEL_VehicleType__c == 'Moto' && yearsPassedFromLastITV < 2){
                        system.debug('Han pasado menos de 2 años desde la ultima ITV');
                        system.debug('NO NECESITA ITV'
                        + '\n *******************************************************************\n');
                        continue;
                    }
                }
                //*p* Si no tiene año de fabricación (el sistema lo permite!!)

                //*p* Si ha pasado mas de un año dede la ultima ITV y es coche
                if(yearsPassedFromLastITV >= 1 && veh.VRT_SEL_VehicleType__c == 'Coche'){
                        veh.VRT_FLG_NeedsInspection__c = true;
                        system.debug('Este coche no tiene fecha de fabricación y su ultima ITV data de hace mas de un año'+
                        'Se actualiza el campo de necesita ITV a TRUE\n'
                        + '\n *******************************************************************\n');
                        continue;
                }
                //*p* Si ha pasado mas de 2 años desde la ultima ITV y es moto
                if(yearsPassedFromLastITV >= 2 && veh.VRT_SEL_VehicleType__c == 'Moto'){
                        veh.VRT_FLG_NeedsInspection__c = true;
                        system.debug('Esta moto no tiene fecha de fabricación (o si) y su ultima ITV data de hace mas de dos años'+
                        '\nSe actualiza el campo de necesita ITV a TRUE'
                        + '\n *******************************************************************\n');
                        continue;
                }
            
            }

            //*p* Vehiculos sin fecha de ultima ITV

            // *p* Proteccion para evitar error si no hay fecha de fabricación
            if(veh.VRT_DAT_ManufacturedYear__c == null){continue;}

            
            // Si es un coche, comprueba que hayan pasado 4 años
            if(veh.VRT_SEL_VehicleType__c == 'Coche' && yearsPassedFromFabrication >= 4) {
                veh.VRT_FLG_NeedsInspection__c = true;List<VRT_Rental__c> r = [SELECT Id FROM VRT_Rental__c WHERE VRT_LKP_Vehicle__c = 'a01Qy000028ane5IAA'];

                system.debug('Este coche no tiene fecha de ultima ITV y fue fabricado hace 4 o mas años asi que'+
                '\nSe actualiza el campo de necesita ITV a TRUE'
                + '\n *******************************************************************\n');
            }
            // Si es una moto, comprueba que hayan pasado 3 años
            else if(veh.VRT_SEL_VehicleType__c == 'Moto' && yearsPassedFromFabrication >= 3) {
                veh.VRT_FLG_NeedsInspection__c = true;
                system.debug('Esta moto no tiene fecha de ultima ITV y fue fabricado hace 3 o mas años asi que'+
                '\nSe actualiza el campo de necesita ITV a TRUE'
                + '\n *******************************************************************\n');
            } 
        }      
        update scope;
    }
    
    public void finish(Database.BatchableContext bc) {
        
    }
    
}
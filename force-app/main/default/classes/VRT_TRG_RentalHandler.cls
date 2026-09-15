/**
 * @author		AMADRIDN (NTT Data)
 * @since		04/04/2024
 * @desc		Handler class for trigger VRT_TRG_Rental
 * @history		04/04/2024 - AMADRIDN - Created class
 * 				08/04/2024 - AMADRIDN - Added comments
 * 				12/04/2024 - AMADRIDN - Added onAfterUpdate
 */
public class VRT_TRG_RentalHandler {
    
     /**
     * @desc	After Insert Handler
     * @param	triggerNew: list of rentals inserted
     */
    public void onBeforeInsert(List<VRT_Rental__c> triggerNew) {

        VRT_TRG_RentalHandlerHelper.calculateTotalCost(triggerNew);
        VRT_CLS_CheckVehicleDataDisponibility.checkDisponibility(triggerNew);
    }
    
    
    
    /**
     * @desc	After Insert Handler
     * @param	triggerNew: list of rentals inserted
     */
    public void onAfterInsert(List<VRT_Rental__c> triggerNew) {

        List<Approval.ProcessSubmitRequest> needApproval = new List<Approval.ProcessSubmitRequest>();
        List<VRT_Rental__c> needApprovalStatusUpdate = new List<VRT_Rental__c>();
        List<VRT_Rental__c> dontNeedApproval = new List<VRT_Rental__c>();

        for (VRT_Rental__c rent : triggerNew){
            if (rent.VRT_DIV_TotalCost__c > 3000){
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(rent.Id);
                req.setProcessDefinitionNameOrId('Alquiler_ammount');
                //req.setSkipEntryCriteria(false);
                needApproval.add(req);

                VRT_Rental__c rentCopy = new VRT_Rental__c(
                    Id = rent.Id,
                    VRT_SEL_Status__c = 'En_proceso_de _aprobacion');         
                needApprovalStatusUpdate.add(rentCopy);

            } else {
                dontNeedApproval.add(rent);
            }
        }

        if(!needApprovalStatusUpdate.isEmpty()){
            update needApprovalStatusUpdate;
        }

        if (!needApproval.isEmpty()){
            Approval.process(needApproval);
        }

        if (!dontNeedApproval.isEmpty()){
            VRT_TRG_RentalHandlerHelper.updateConditionVehicle(triggerNew);
        } 
    }
    
    /**
     * @desc	After Update Handler
     * @param	oldMap: map with rentals in old state 
     * @param	newMap: map with rentals in new state 
     */
    public void onAfterUpdate(Map<Id, VRT_Rental__c> oldMap, Map<Id, VRT_Rental__c> newMap) {
        VRT_TRG_RentalHandlerHelper.updateVehicleRentalCompleted(oldMap, newMap);
    }

    /**
     * @desc	Before Update Handler
     * @param	oldMap: map with rentals in old state 
     * @param	newMap: map with rentals in new state 
     */
    public void onBeforeUpdate(Map<Id, VRT_Rental__c> oldRentalsMap, Map<Id, VRT_Rental__c> newRentalsMap) {
        
        List<VRT_Rental__c> rentalsToCheck = new List<VRT_Rental__c>();
        
        for (Id rentalId : newRentalsMap.keySet()){
            VRT_Rental__c newRental = newRentalsMap.get(rentalId);
            VRT_Rental__c oldRental = oldRentalsMap.get(rentalId);
            if (oldRental.VRT_SEL_Status__c == 'Cancelado' && newRental.VRT_SEL_Status__c != 'Cancelado'){
                rentalsToCheck.add(newRental);
                //newRental.addError('Este vehículo no está disponible en esas fechas');
            }
        }
        if (!rentalsToCheck.isEmpty()){
            VRT_CLS_CheckVehicleDataDisponibility.checkDisponibility(rentalsToCheck);
        }
    }
}
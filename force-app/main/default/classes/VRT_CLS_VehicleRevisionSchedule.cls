/**
 * @author		jgoikoet (42 Urduliz)
 * @since		02/2023
 * @desc		Shedulable class launched from a sheduled job wich executes a batcheable class
 * @history		06/05/2026 - jgoikoet - Created class			
 */
public class VRT_CLS_VehicleRevisionSchedule implements Schedulable {
    public void execute(SchedulableContext ctx) {
        VRT_CLS_CheckVehicleRevision batch = new VRT_CLS_CheckVehicleRevision();
        Database.executebatch(batch, 200);
    }
}
import { getURL } from './getVehicleURL';
import getDisponibleVehicles from '@salesforce/apex/VRT_CLS_checkVeicleDisponibilityForLWC.getDisponibleVehicles';

var returnedColor = null;
const blackColor = "slds-col slds-size_1-of-1 slds-var-p-around_x-small slds-text-color_default";
const succesColor = "slds-col slds-size_1-of-1 slds-var-p-around_x-small slds-text-color_success";
const errorColor = "slds-col slds-size_1-of-1 slds-var-p-around_x-small slds-text-color_error";




function checkValidDate(fechaInicio, fechaFin){

    if (fechaFin >= fechaInicio) {return true;}
    else {return false;}

}

export function getCochesDisponibles(fechaInicio, fechaFin) {
    
    if (!fechaInicio || !fechaFin) {
        console.warn('¡Ojo! Falta alguna de las fechas. No se ejecuta la llamada.');
        return Promise.resolve([]); // Devolvemos una lista vacía de inmediato de forma segura
    }

    return getDisponibleVehicles({fechaInicio: fechaInicio, fechaFin: fechaFin})
    .then(vehiculos => {return vehiculos});

}

export function setDateMesaggeColor(){
    return returnedColor;
}

export function checkDates(fechaInicio, fechaFin){

    if(fechaInicio && !fechaFin){
        returnedColor = blackColor;
        return 'Introduzca fecha de finalizacion de alquiler.';
    } else if (!fechaInicio && fechaFin){
        returnedColor = blackColor;
        return 'Introduzca fecha de Inicio de alquiler.';
    } else if (fechaInicio && fechaFin){

        if (checkValidDate(fechaInicio, fechaFin)){
            returnedColor = succesColor;
            return 'OK';
        } else {
            returnedColor = errorColor;
            return 'ERROR la fecha de inicio no puede ser posterior a la fecha de finalización payaso!';
        }

    } else if(!fechaInicio && !fechaFin){
        returnedColor = blackColor;
        return 'Introduzca Fechas de inicio y fin del alquiler.';
    } 

}
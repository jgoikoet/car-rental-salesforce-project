import { LightningElement, api, wire } from 'lwc';
import COCHES_1  from '@salesforce/resourceUrl/coches1';
import { getURL } from './getVehicleURL';
import { checkDates, setDateMesaggeColor, getCochesDisponibles } from './handleAlquiler'
import getAlquileresActivos from '@salesforce/apex/VRT_CLS_GetActiveRentals.getAlquileresActivos';
import calculateTotalCost from '@salesforce/apex/VRT_CLS_LWC_CalculateTotalCost.calculateTotalCost';
import calculateDiscount from '@salesforce/apex/VRT_CLS_LWC_CalculateTotalCost.calculateDiscount';
import createNewRent from '@salesforce/apex/VRT_CLS_LWC_CreateNewRent.createNewRent';
import getRentFullData from '@salesforce/apex/VRT_CLS_LWC_GetRentFullData.getRentFullData';
import getVehicleData from '@salesforce/apex/VRT_CLS_LWC_GetRentFullData.getVehicleData';
import getAccountData from '@salesforce/apex/VRT_CLS_LWC_GetRentFullData.getAccountData';

import { refreshApex } from '@salesforce/apex';
//import { NavigationMixin } from 'lightning/navigation';

export default class AlquilerConsole extends LightningElement {
    
    @api recordId;
    alquileres;
    filteredAlquileres
    error;
    selectedAlquilerId;
    showList = true;
    cochesDisponibles = null;
    selectedCar = null;
    selectedCarName = null;
    coste = 0;
    descuento = 0;
    pagado = false;
    estadoPagoText = 'Pendiente';
    seteandoAlquiler = true;
    alquilerCompletado = false;
    alquilerExitoso = false;
    mensajeError = null;
    fechaInicio = null;
    fechaFin = null;
    cargadoRentDetail = null;
    detailedRent = null;
    detailedVehicle = null;
    detailedAcount = null;
    detailedURL = null;
    colorTextoCabecera = 'slds-text-heading_medium slds-text-color_default';
    //alquileresActivosHeadText = 'Alquileres Activos';
    newRentHeadText = 'Nuevo Alquiler';
    fechasMensaje = "Introduzca Fechas de inicio y fin del alquiler.";
    fechasMensajeClass = "slds-col slds-size_1-of-1 slds-var-p-around_x-small slds-text-color_default";
    criterioOrdenacion = "VRT_DIV_TotalCost__c";
    filtroAlquileres = "NONE";
    hayVehiculos = "SELECCIONA UN VEHICULO SUBNORMAL";
    estadoAlquiler = "Reservado";

    objetoWireRegenerable;//para actualizar la lista de alquileres

    get opcionesPicklistOrden() {
        return [
            { label: 'Coste Total', value: 'VRT_DIV_TotalCost__c' },
            { label: 'Fecha de Inicio', value: 'VRT_DAT_InitialDate__c' },
            { label: 'Fecha de Finalización', value: 'VRT_DAT_FinalDate__c' },
            { label: 'Número de Alquiler', value: 'Name' }
        ];
    }

    get opcionesPicklistFiltro() {
        return [
            { label: 'Sin filtro', value: 'NONE' },
            { label: 'Reservados', value: 'Reservado' },
            { label: 'En curso', value: 'En curso' },
            { label: 'Pendientes de validación', value: 'En_proceso_de _aprobacion' }
        ];
    }

    // Variables de control para la visibilidad de los modales
    alquilerDetail = false;
    nuevoAlquiler = false;
    

    setVehicleDisponibilityMessage(){
        if (this.cochesDisponibles && this.cochesDisponibles.length > 0){
            this.hayVehiculos = "SELECCIONA UN VEHICULO SUBNORMAL";
        } else {
            this.hayVehiculos = "NO HAY VEHICULOS DISPONIBLES PARA ESTAS FECHAS, SELECCIONA OTRAS FECHAS.";
        }
    }

    setFechaInicio(event) {
        
        this.fechaInicio = event.target.value;
        this.fechasMensaje = checkDates(this.fechaInicio, this.fechaFin);
        this.fechasMensajeClass = setDateMesaggeColor();
        if (this.fechasMensaje == 'OK') {
            this.fechasMensaje = null;
            this.selectedCar = null;
            this.coste = 0;
            this.descuento = 0;
            getCochesDisponibles(this.fechaInicio, this.fechaFin)
            .then(vehiculos => {

                const cochesDIsponiblesClean = JSON.parse(JSON.stringify(vehiculos));
                const cochesDisponiblesconURL = cochesDIsponiblesClean.map(vehiculo => {
                    return {
                        ...vehiculo, // lo copia todo
                        miUrl: getURL(vehiculo.VRT_TXT_Model__c)
                    };

                });
                this.cochesDisponibles = [...cochesDisponiblesconURL];
                //console.log('cochesDisponibles:', JSON.stringify(this.cochesDisponibles, null, 2));
                this.setVehicleDisponibilityMessage();
            })
            .catch(error => {
                this.cochesDisponibles = null;
            });
        }  else {
            console.log('HA entro en ELSE-------------------------');
            this.cochesDisponibles = null;}

    }
    setFechaFin(event) {
        
        this.fechaFin = event.target.value;
        this.fechasMensaje = checkDates(this.fechaInicio, this.fechaFin);
        this.fechasMensajeClass = setDateMesaggeColor();
        if (this.fechasMensaje == 'OK') {
            this.fechasMensaje = null;
            this.selectedCar = null;
            this.coste = 0;
            this.descuento = 0;
            getCochesDisponibles(this.fechaInicio, this.fechaFin)
            .then(vehiculos => {

                const cochesDIsponiblesClean = JSON.parse(JSON.stringify(vehiculos));
                const cochesDisponiblesconURL = cochesDIsponiblesClean.map(vehiculo => {
                    return {
                        ...vehiculo, // lo copia todo
                        miUrl: getURL(vehiculo.VRT_TXT_Model__c)
                    };

                });
                this.cochesDisponibles = [...cochesDisponiblesconURL];
                console.log('cochesDisponibles:', JSON.stringify(this.cochesDisponibles, null, 2));
                this.setVehicleDisponibilityMessage();
            })
            .catch(error => {
                this.cochesDisponibles = null;
            });
        }  else {
            console.log('HA entro en ELSE-------------------------');
            this.cochesDisponibles = null;}
    }
    
    async calculateCost(){

        try {
            
            this.coste = await calculateTotalCost({
                inicio: this.fechaInicio,
                fin: this.fechaFin,
                tipoVehiculo: this.selectedCar.VRT_SEL_VehicleType__c,
                accountId: this.recordId
            })

        } catch(error){this.coste = 0;}
            
        try{
            const abailableDiscount = await calculateDiscount({acc: this.recordId});
            if (abailableDiscount){

                this.descuento = this.coste * 0.05;
                this.coste -= this.descuento;
            }
            
        }catch(error){
            console.log('-----------ERROR:', error);
            this.descuento = 0;}
    }

    async crearAlquiler(){

        this.seteandoAlquiler = false;
        this.alquilerCompletado = false;
        try {
            this.alquilerExitoso = await createNewRent({
                inicio: this.fechaInicio,
                fin: this.fechaFin,
                accountId: this.recordId,
                vehicleId: this.selectedCar.Id,
                estadoPago: this.pagado, 
                coste: this.coste        
            });
            if (this.pagado == true){this.estadoPagoText = 'Pagado';}
            if (this.coste > 3000){this.estadoAlquiler = "Pendiente de validación";}
            this.colorTextoCabecera = 'slds-text-heading_medium slds-text-color_success';
            this.newRentHeadText = 'Alquiler creado con exito';
            this.selectedCarName = this.selectedCar.VRT_TXT_Brand__c + ' ' + this.selectedCar.VRT_TXT_Model__c;
            this.alquilerCompletado = true;
            if(this.objetoWireRegenerable){await refreshApex(this.objetoWireRegenerable)}
            console.log('¡Alquiler creado con éxito! Resultado:', this.alquilerExitoso);

        } catch (error) {
            this.colorTextoCabecera = 'slds-text-heading_medium slds-text-color_error';
            this.newRentHeadText = 'ERROR';
            // ESTO EVITA EL "UNCAUGHT IN PROMISE" Y DA EL ERROR REAL
            console.error('--- ERROR DETECTADO EN APEX ---');
            console.error(error); // Abre este objeto en la consola del navegador
            
            // Extraemos el mensaje limpio de Salesforce
            if (error.body && error.body.message) {
                console.error('Mensaje de Salesforce:', error.body.message);
                this.mensajeError = error.body.message;
            }
        }
        this.alquilerCompletado = true;
    }

    estadoPago(event){
        this.pagado = event.target.checked;
    }

    selectCar(event){
        event.preventDefault();
        const cocheId = event.currentTarget.dataset.id;

        for (let coche of this.cochesDisponibles) {
            if (coche.Id === cocheId) {
                this.selectedCar = coche;
                break;
            }
        }
        this.coste = 0;
        this.descuento = 0;
        this.calculateCost();
    }


    resetVariablesNewAlquiler(){
        this.fechaInicio = null;
        this.fechaFin = null;
        this.cochesDisponibles = null;
        this.selectedCar = null;
        this.coste = 0;
        this.descuento = 0;
        this.pagado = false;
        this.seteandoAlquiler = true;
        this.alquilerCompletado = false;
        this.alquilerExitoso = false;
        this.mensajeError = null;
        this.colorTextoCabecera = 'slds-text-heading_medium slds-text-color_default';
        this.fechasMensaje = "Introduzca Fechas de inicio y fin del alquiler.";
        this.fechasMensajeClass = "slds-col slds-size_1-of-1 slds-var-p-around_x-small slds-text-color_default";
        this.newRentHeadText = 'Nuevo Alquiler';
        this.estadoPagoText = 'Pendiente';
        this.estadoAlquiler = "Reservado";
    }


    // Métodos para la Ventana 1
    async openAlquilererDetail(event) {
        this.cargadoRentDetail = false;
        this.alquilerDetail = true;
        const rentName = event.target.dataset.name;
        //await new Promise(resolve => setTimeout(resolve, 2000));
        this.detailedRent = await getRentFullData({ name: rentName });
        this.detailedVehicle = await getVehicleData({vehId: this.detailedRent.VRT_LKP_Vehicle__c});
        this.detailedAcount = await getAccountData({accId: this.detailedRent.VRT_LKP_Account__c});
        this.detailedURL = getURL(this.detailedVehicle.VRT_TXT_Model__c);
        this.cargadoRentDetail = true;

    }
    
    closeAlquilerDetail() {
        this.alquilerDetail = false;
        //this.showList = true;
    }
    
    // Métodos para la Ventana 2
    openNewAlquiler() {
        this.nuevoAlquiler = true;
    }
    
    closeNewAlquiler() {
        this.nuevoAlquiler = false;
        this.resetVariablesNewAlquiler();
    }

    filterAlquileres(event){
        this.filtroAlquileres = event.detail.value;
        if (this.filtroAlquileres == 'NONE'){
            this.filteredAlquileres = this.alquileres;
            return;
        }
        this.filteredAlquileres = this.alquileres.filter(alquiler => alquiler.VRT_SEL_Status__c === this.filtroAlquileres);
        //this.filteredAlquileres = null;
    }

    sortAlquileres(event){
        this.criterioOrdenacion = event.detail.value;
        if (this.criterioOrdenacion == "VRT_DAT_InitialDate__c" ||
            this.criterioOrdenacion == "VRT_DAT_FinalDate__c"){
            this.filteredAlquileres.sort((a, b) => Date.parse(b[this.criterioOrdenacion]) - Date.parse(a[this.criterioOrdenacion]));
        } else{
            this.filteredAlquileres.sort((a, b) => b[this.criterioOrdenacion] - a[this.criterioOrdenacion]);
        }
    }

    @wire(getAlquileresActivos, { accId: '$recordId' })
    wiredAlquilers (resultadoCompleto){

        this.objetoWireRegenerable = resultadoCompleto;
        const {data, error} = resultadoCompleto;

        if (data) {
            this.alquileres = [...data];
            this.filteredAlquileres = this.alquileres;
            this.filteredAlquileres.sort((a, b) => b[this.criterioOrdenacion] - a[this.criterioOrdenacion]);
            // this.alquileres.sort((a, b) => b[this.criterioOrdenacion] - a[this.criterioOrdenacion]);
            this.error = undefined;
        }
        else if (error) {this.alquileres = undefined; this.error = error;}
    }

    verDetalle(event){
        event.preventDefault();
        this.selectedAlquilerId = event.currentTarget.dataset.id;
        this.showList  = false;
    }

    volVerALista (){
        this.showList = true;
        this.selectedAlquilerId = undefined;
    }

}
import { LightningElement } from 'lwc';
import searchVehicles from '@salesforce/apex/VRT_CLS_LWC_SearchVehicles.searchVehicles';
import searchVehicle from '@salesforce/apex/VRT_CLS_LWC_SearchVehicles.searchVehicle';
import { getURL } from './getVehicleURL';

export default class BuscadorGlobalFlota extends LightningElement {


    sugerencias = [];
    valorBusqueda = '';
    vehList = null;
    showVehicle = false;
    vehCargado = false;
    vehiculo = null;
    vehImgURL ='';

    
    get mostrarSugerencias(){
        return this.sugerencias.length > 0;
    }



    async handleSearch(event){

        this.valorBusqueda = event.target.value.toLowerCase();

        if (this.valorBusqueda.length < 3){
            const vehiculoSeleccionado = event.currentTarget.dataset.value;
            this.sugerencias = [];
            return;
        }
        this.vehList = await searchVehicles( { veh: this.valorBusqueda } );
        if(!this.vehList) {       
            this.sugerencias=[];
        }

        this.sugerencias = this.vehList.map(vehiculo => {
            return {
                id: vehiculo.Id,
                texto: `${vehiculo.VRT_TXT_Brand__c} ${vehiculo.VRT_TXT_Model__c} ${vehiculo.VRT_TXT_LicensePlate__c}`
            };
        });

    }

    closeVehicleDetail(){
        this.showVehicle = false;
    }

    async handleSelect(event){
        event.preventDefault();
        
        const vehiculoSeleccionado = event.currentTarget.dataset.id;      
        this.vehCargado = false;
        this.showVehicle = true;

        this.vehiculo = await searchVehicle({ vehId: vehiculoSeleccionado});
        this.vehImgURL = getURL(this.vehiculo.VRT_TXT_Model__c);
        this.vehCargado = true;

        //console.log('Has elegido:', vehiculoSeleccionado);
    }
}
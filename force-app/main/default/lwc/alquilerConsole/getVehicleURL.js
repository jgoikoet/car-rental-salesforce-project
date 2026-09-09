import COCHES_1  from '@salesforce/resourceUrl/coches1';
import COCHES_2  from '@salesforce/resourceUrl/coches2';
import COCHES_3  from '@salesforce/resourceUrl/coches3';
import MOTOS_1  from '@salesforce/resourceUrl/motos1';
import MOTOS_2  from '@salesforce/resourceUrl/motos2';


const vehiculos = new Map([
    ['127', `${COCHES_1}/coches1/127.png`],
    ['600', `${COCHES_1}/coches1/600.png`],
    ['Camaro', `${COCHES_1}/coches1/chevrolet_camaro.png`],

    ['Fiesta', `${COCHES_2}/coches2/For_fiesta.png`],
    ['Accent', `${COCHES_2}/coches2/Hunday_accent.png`],
    ['Model S', `${COCHES_2}/coches2/Tesla.png`],

    ['Camry', `${COCHES_3}/coches3/Toyota_Camry.png`],
    ['Corolla', `${COCHES_3}/coches3/Toyota_corolla.png`],

    ['Motoreta', `${MOTOS_1}/motos1/derby_motoreta.png`],
    ['CRF250L', `${MOTOS_1}/motos1/Honda_crf.png`],
    ['Ninja 300', `${MOTOS_1}/motos1/Kawasaki_Ninja.png`],

    ['V-Strom 650', `${MOTOS_2}/motos2/Suzuki_V_Storm.png`],
    ['MT-07', `${MOTOS_2}/motos2/Yamaha_MT07.png`],
]);

export function getURL(model){
    return vehiculos.get(model);
}



@isTest
public with sharing class VRT_CLS_RentalPDFGenerator_Test {
    public VRT_CLS_RentalPDFGenerator_Test() {

    }

    @testSetup
    static void setup() {

        Account testAcc = new Account(Name = 'Bacalao de Bilbao',
            VRT_TXT_Email__c = 'josebagoikol@gmail.com');
        insert testAcc;

        VRT_Vehicle__c testVeh = new VRT_Vehicle__c(
            VRT_TXT_ExternalId__c = 'TestVeh', 
            VRT_TXT_LicensePlate__c = 'TST0001',
            VRT_TXT_Brand__c = 'Opel', 
            VRT_SEL_VehicleType__c = 'Coche', 
            VRT_SEL_Status__c = 'Listo',  
            VRT_SEL_EnergyType__c = 'Diesel', 
            VRT_NUM_Passengers__c = 5,
            VRT_FLG_Available__c = true,
            VRT_DAT_ManufacturedYear__c = System.today().addYears(-1)
        ); 
        insert testVeh;

        VRT_Rental__c newRental= new VRT_Rental__c();
        newRental.VRT_LKP_Account__c = testAcc.Id;
        newRental.VRT_LKP_Vehicle__c = testVeh.Id;
        newRental.VRT_DAT_InitialDate__c = Date.Today();
        newRental.VRT_DAT_FinalDate__c = Date.Today()+5;
        newRental.VRT_SEL_Status__c = 'Reservado';
        newRental.VRT_SEL_PaymentStatus__c = 'Pagado';
        insert newRental;
    }


    @isTest
    static void generateInvoicePDFTest(){

        VRT_Rental__c testRental = [SELECT Id, VRT_SEL_Status__c  FROM VRT_Rental__c];

        Test.startTest();
        testRental.VRT_SEL_Status__c = 'Completado';
        update testRental;
        Test.stopTest();

        //Comprobacion de que el PDF se ha creado correctamente
        List<ContentVersion> versions = [
            SELECT Id, Title, FileType, PathOnClient, VersionData, ContentDocumentId
            FROM ContentVersion
            WHERE FileType = 'PDF'
        ];
        System.assertEquals(1, versions.size(), 'Debería haberse creado exactamente 1 PDF');
        System.assert(versions[0].VersionData != null, 'El PDF no debería estar vacío');
        System.assert(versions[0].VersionData.size() > 0, 'El contenido del PDF debe tener bytes');
        System.assertEquals('Factura_'+testRental.Id + '.pdf', versions[0].PathOnClient, 'Nombre de archivo esperado');

        // System.debug('**********************************************************************************');
        // for(ContentVersion ver : versions){
        //     System.debug(ver.PathOnClient);
        // }
        // System.debug('**********************************************************************************');



        //Comprobacion de que el contentDocument esta enlazado a la account
        List<ContentDocumentLink> links = [
            SELECT contentDocumentId, LinkedEntityId, ContentDocument.Title
            FROM ContentDocumentLink
            WHERE contentDocumentId = :versions[0].contentDocumentId
        ];

        // System.debug('**********************************************************************************');
        // for (ContentDocumentLink link : links){

        //     System.debug(link.ContentDocument.Title + '      ' + link.LinkedEntityId);
        //     System.debug('tipo de objeto: ' + link.LinkedEntityId.getSObjectType().getDescribe().getName());
        // }
        // System.debug('**********************************************************************************');

        System.assertEquals(2, links.size(), 'El archivo ha de estar enlazado a un registro y al User');
        // links[1] que es el que esta enlazado al rental, link[0] esta enlazado al User
        System.assertEquals(testRental.Id, links[1].LinkedEntityId, 'El archivo ha de estar enlazado al registro correcto');
        
        //Deberia haberse enviado el email OJO!!!! al ser un futuro no se puede comprobar con Limits
        //System.assertEquals(1, Limits.getEmailInvocations(), 'Debería haberse invocado el envío de 1 email');
    }

}
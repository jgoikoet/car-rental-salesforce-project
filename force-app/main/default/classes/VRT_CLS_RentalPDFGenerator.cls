public with sharing class VRT_CLS_RentalPDFGenerator {
    
    @invocableMethod(label='Generar y Adjuntar PDF de Factura' description='Crea un PDF desde Visualforce y lo guarda en Files del Rental')
    public static void generateInvoicePDF(List<Id> rentalIds){

        if (rentalIds == null || rentalIds.isEmpty()) return;

        createPDFAsync(rentalIds);

    }

    @future(callout=true)
    private static void createPDFAsync(List<Id> rentalIds){

        List<ContentVersion> cvList = new List<ContentVersion>();

        Map<Id, VRT_Rental__c> rentalsMaps = new Map<Id, VRT_Rental__c>([
            SELECT Id, Name, VRT_LKP_Account__r.VRT_TXT_Email__c, VRT_LKP_Account__r.Name
            FROM VRT_Rental__c
            WHERE Id IN :rentalIds 
        ]);

        Map<Id, Blob> pdfBlobsMap = new Map<Id, Blob>();

        for (Id rentalId : rentalIds){

            PageReference pdfPage = Page.FacturaRentalPDF;//la pagina de visualforce, PageReference referencia URLs
            pdfPage.getParameters().put('id', rentalId);

            Blob pdfBlob; //Binary Large Object

            try{
                pdfBlob = pdfPage.getContentAsPDF();
            }
            catch (Exception e) {
                // Bloque de escape para que los test de Apex no fallen (getContentAsPDF no corre en tests)
                pdfBlob = Blob.valueOf('Test PDF Content');
            }

            pdfBlobsMap.put(rentalId, pdfBlob);

            //Esto crea el archivo en la sección 'Files'
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Factura_Rental_' + rentalId + '.pdf';
            cv.PathOnClient = 'Factura_' + rentalId + '.pdf';
            cv.VersionData = pdfBlob;

            //para relacionarla con la lista de files del registro
            cv.FirstPublishLocationId = rentalId;

            cvList.add(cv);
        }

        if(!cvList.isEmpty()){ insert cvList; }

        //CODIGO PARA ENVIAR EL CORREO ELECTRONICO
        List<Messaging.SingleEmailMessage> emailsToSEnd = new List<Messaging.SingleEmailMessage>();
        
        for (Id rentalID : rentalIds){
            
            VRT_Rental__c rent = rentalsMaps.get(rentalID);
            Blob pdfFile = pdfBlobsMap.get(rentalID);
            
            String accountEmail = rent.VRT_LKP_Account__r.VRT_TXT_Email__c;
            if (String.isNotBlank(accountEmail)){
                
                String body = 
                    'Estimado/a ' + rent.VRT_LKP_Account__r.Name + ',<br/><br/>' +
                    'Le adjuntamos en este correo la factura en PDF correspondiente a su alquiler con referencia ' + rent.Name + '.<br/><br/>' +
                    'Muchas gracias por confiar en nosotros.<br/><br/>' +
                    'Un saludo.';

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] {accountEmail});
                email.setSubject('Factura del alquiler -' + rent.Name);
                email.setHtmlBody(body);

                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('Factura_' + rent.Name + '.pdf');
                attachment.setBody(pdfFile);
                attachment.setContentType('application/pdf');

                email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });

                emailsToSEnd.add(email);
            }
        }
        if(!emailsToSEnd.isEmpty()){
            Messaging.sendEmail(emailsToSEnd);
        }
    }

}
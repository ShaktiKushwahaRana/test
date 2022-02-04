@RestResource(urlMapping='/kbupdate/*')
global with sharing class webservicesDemo{
    
    @HttpPost
    global static void postRequest(){
        RestRequest request = RestContext.request; 
        RestResponse res = RestContext.response;
        String kbupdateId = request.params.get('id');
        String  articleBody= request.requestBody.toString();
       // knowledgeBaseAPI__c kbAPI = new knowledgeBaseAPI__c();
        List<Id> articleIDs = new List<Id>();
        responseWrapper response=new responseWrapper();
        response.status='Failure'; // Set failure initially
        try{
            if(!string.isBlank(kbupdateId)){
                if(!string.isBlank(articleBody)){
                    List<String> draftArticleId = new List<String>();
                    for (Knowledge__kav kv : [SELECT Id, KnowledgeArticleId, Description__c, PublishStatus FROM Knowledge__kav WHERE KnowledgeArticleId =: kbupdateId]){
                    // System.debug('knowledge Article id'+kv.KnowledgeArticleId);
                        if(kv.PublishStatus == 'Online'){                       
                            String Id = KbManagement.PublishingService.editOnlineArticle(kv.KnowledgeArticleId, true);
                            articleIDs.add(kv.KnowledgeArticleId);
                            draftArticleId.add(Id);
                        }
                        else{
                            response.message='Either the article is in draft state or not exist';
                    		response.statusCode=400;
                    		res.statusCode = 400;
                        }
                    }
                    if(draftArticleId.size()!=0){
                        
                        List<Knowledge__kav> articles = new List<Knowledge__kav>();
                        for (Knowledge__kav kb : [SELECT Id, KnowledgeArticleId, Description__c, PublishStatus FROM Knowledge__kav WHERE PublishStatus = 'Draft' AND KnowledgeArticleId IN :articleIds]){
                            if(!string.isBlank(articleBody)){
                               // System.debug('knowledge Articlegggg id'+draftArticleId.size());
                            	Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestBody.toString());
                                articleBody = String.valueof(params.get('body'));
                               // kbAPI.Description__c = articleBody;
                               System.debug('knowledge Article id'+draftArticleId.size());
                                kb.Description__c = articleBody;
                                kb.question__c = articleBody;
                            }
                            articles.add(kb);
                        }
                        update articles;
                       // insert kbAPI;
                        for (String draftKbId : articleIDs){
                            KbManagement.PublishingService.publishArticle(draftKbId, true);
                        }
                    }
                    response.status='Success';
                    response.message='Article '+kbupdateId+' Updated Succesfully';
                    response.statusCode=200;
                    res.statusCode = 200;
                }else{
                    response.message='Body is missing';
                    response.statusCode=501;
                    res.statusCode = 500; 
                }
            }else{
                response.message='Id is missing';
                response.statusCode=502;
                res.statusCode = 500; 
            }
        }
        Catch(Exception e){
            System.debug('Error Occcured '+e);
        }
        res.responseBody = Blob.valueOf(JSON.serializePretty(response));  
    }
    
}
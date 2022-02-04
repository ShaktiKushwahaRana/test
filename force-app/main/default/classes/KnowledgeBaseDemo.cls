public class KnowledgeBaseDemo {
    
    public static void CreateArticle()
    {
        //Create an article in draft state
        Knowledge__kav ka = new Knowledge__kav();
		ka.Title = ' ARTICLE 6';
		ka.UrlName = 'ARTICLE-6';
		insert ka;
        publishArticle(ka.id);
    }

    public static void publishArticle(String idd)
    {   //To publish Article
        String knowledgeArticleId=idd; //idd received is article version id
        
        KbManagement.PublishingService.publishArticle(knowledgeArticleId, true);
    }
}
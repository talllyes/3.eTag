<%@ Application Language="C#" %>
<%@ Import Namespace="System.Web.Routing" %>

<script RunAt="server">

    void Application_Start(object sender, EventArgs e)
    {
        // 在應用程式啟動時執行的程式碼
        RegisterRoutes(RouteTable.Routes);
    }

    void RegisterRoutes(RouteCollection routes)
    {
        //加入路徑設定
        routes.Add("api", new Route("api/{model}/{type}", new RouteNamespace.ApiRoute()));
        routes.Add("webHtml", new Route("{htmlUrl}", new RouteNamespace.WebHtmlRoute()));
        routes.Add("webTemplateHtml", new Route("template/{htmlUrl}", new RouteNamespace.WebTemplateHtmlRoute()));
        routes.Add("webOtherHtml", new Route("other/{htmlUrl}", new RouteNamespace.WebOtherHtmlRoute()));
    }

    void Application_End(object sender, EventArgs e)
    {
        //  在應用程式關閉時執行的程式碼

    }

    void Application_Error(object sender, EventArgs e)
    {
        // 在發生未處理的錯誤時執行的程式碼
    }

    void Application_AcquireRequestState(Object sender, EventArgs e)
    {
        //驗證有沒有權限
        IdentityAuthority.check(Response, Request, Context);
    }

    void Session_Start(object sender, EventArgs e)
    {
        // 在新的工作階段啟動時執行的程式碼
        DataClasses2DataContext DB = new DataClasses2DataContext();
        var r = (from a in DB.loginNum where a.SystemType == "3system" select a).FirstOrDefault();
        DateTime s = (DateTime)r.LoginDate;
        if (DateTime.Now.ToString("yyyyMMdd") != s.ToString("yyyyMMdd"))
        {
            r.LoginID = "1";
            r.LoginDate = DateTime.Now;
        }
        else
        {
            r.LoginID = (Convert.ToInt32(r.LoginID) + 1).ToString();
            r.LoginDate = DateTime.Now;
        }
        DB.SubmitChanges();
        string ip = Request.ServerVariables["REMOTE_ADDR"];

        loginNum st = new loginNum
        {
            LoginDate = DateTime.Now,
            SystemType = "3",
            LoginID = ip
        };
        DB.loginNum.InsertOnSubmit(st);
        DB.SubmitChanges();

    }

    void Session_End(object sender, EventArgs e)
    {
        // 在工作階段結束時執行的程式碼
        // 注意: 只有在  Web.config 檔案中將 sessionstate 模式設定為 InProc 時，
        // 才會引起 Session_End 事件。如果將 session 模式設定為 StateServer 
        // 或 SQLServer，則不會引起該事件。
        DataClasses2DataContext DB = new DataClasses2DataContext();
        var r = (from a in DB.loginNum where a.SystemType == "3system" select a).FirstOrDefault();
        if (Convert.ToInt32(r.LoginID) > 0)
        {
            r.LoginID = (Convert.ToInt32(r.LoginID) - 1).ToString();
        }
        DB.SubmitChanges();

    }

</script>

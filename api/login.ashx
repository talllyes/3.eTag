<%@ WebHandler Language="C#" Class="login" %>

using System;
using System.Web;
using System.Net;

public class login : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{

    public void ProcessRequest(HttpContext context)
    {
        string type = context.Items["type"].ToString();
        if (type.Equals("login"))
        {
            string check = "no";
            context.Session["login"] = false;
            if (context.Request["id"] != null && context.Request["password"] != null)
            {
                string id = context.Request["id"];
                string password = context.Request["password"];
                if (id.ToLower().Equals("tbkcitc") && password.ToLower().Equals("tbkcitcetag2016"))
                {
                    check = "ok";
                    context.Session["login"] = true;
                }
                else
                {
                    check = "no";
                }
            }
            context.Response.ContentType = "text/plain";
            context.Response.Write(check);
        }
        else if (type.Equals("登出"))
        {
            context.Session["login"] = false;
        }
        else if (type.Equals("check"))
        {
            string check = "no";           
            if (UserInfo.loginValidation(context))
            {
                check = "ok";
            }
            context.Response.ContentType = "text/plain";
            context.Response.Write(check);
        }
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}
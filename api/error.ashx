<%@ WebHandler Language="C#" Class="error" %>

using System;
using System.Web;

public class error : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/plain";
        context.Response.Write("NotFound!!");
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}